import 'dart:io';
import 'dart:ui';

import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:share/share.dart';
import 'package:trunk/constants.dart';
import 'package:trunk/model/note.dart';
import 'package:trunk/screens/components/elevated_button.dart';
import 'package:trunk/screens/components/modals.dart';
import 'package:trunk/screens/components/navdrawer.dart';
import 'package:trunk/screens/components/snackbar.dart';
import 'package:trunk/screens/components/text_button.dart';
import 'package:trunk/steganography/encoder.dart';
import 'package:trunk/steganography/request/encode_request.dart';
import 'package:trunk/steganography/response/encode_response.dart';
import 'package:trunk/utils/encrypt_note.dart';
import 'package:image/image.dart' as imglib;
import 'package:trunk/utils/exit_alert.dart';
import 'package:trunk/utils/store_file.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../../db/db.dart';

class ShareNoteWithPassword extends StatefulWidget {
  static const routeName = "ShareNoteWithPass";
  static const stegRouteName = "ShareNoteWithSteg";
  final bool steg;

  const ShareNoteWithPassword({
    Key key,
    this.steg = false,
  }) : super(key: key);

  @override
  _ShareNoteWithPasswordState createState() => _ShareNoteWithPasswordState();
}

class _ShareNoteWithPasswordState extends State<ShareNoteWithPassword> {
  Note _note;
  Map<String, dynamic> _key;

  String imgFileName; // For Steg
  String imgFilePath; // For Steg
  bool qrSteg = false;
  bool _loading = false;

  Future<Note> _getNoteModal(DatabaseHelper databaseHelper) {
    return getNotebookModal(context, databaseHelper);
  }

  Future<Map<String, dynamic>> _getKeyToEncryptModal(
      BuildContext context, DatabaseHelper databaseHelper) {
    return getKeyToEncryptModal(context, databaseHelper);
  }

  @override
  Widget build(BuildContext context) {
    DatabaseHelper databaseHelper = Provider.of<DatabaseHelper>(context);
    return WillPopScope(
      onWillPop: () => exitAlert(context),
      child: Scaffold(
        appBar: AppBar(
          title: Text("Sharing note with Password"),
        ),
        drawer: NavDrawer(),
        body: Container(
          child: ListView(
            children: <Widget>[
              SizedBox(width: double.infinity),
              CustomTextButton(
                text: "Select note",
                onPressed: () async {
                  Note note = await _getNoteModal(databaseHelper);
                  if (note != null) {
                    setState(() {
                      _note = note;
                    });
                  } else {
                    showSnackbar(context, "Please Select a Note");
                  }
                },
              ),
              (_note != null) ? Text("${_note.title}") : Container(),
              CustomTextButton(
                text: "Select Friend",
                onPressed: () async {
                  Map<String, dynamic> friend =
                      await _getKeyToEncryptModal(context, databaseHelper);

                  if (friend != null) {
                    setState(() {
                      _key = friend;
                    });
                  } else {
                    showSnackbar(
                        context, "Please Select a Friend's list to send note");
                  }
                },
              ),
              (_key != null) ? Text("${_key['name']}") : Container(),
              (widget.steg)
                  ? CustomTextButton(
                      text: "Select Image to Encrypt",
                      onPressed: () async {
                        try {
                          FilePickerResult result = await FilePicker.platform
                              .pickFiles(type: FileType.image);
                          if (result.isSinglePick) {
                            String path = result.files.single.path;
                            List<String> names = result.names;

                            if (path != null) {
                              setState(() {
                                imgFileName = names[0];
                                imgFilePath = path;
                              });
                            } else {
                              showSnackbar(context, "Unable to open file!");
                            }
                          } else {
                            showSnackbar(
                                context, "Please select only one file");
                          }
                        } catch (e, s) {
                          print("$e $s");
                        }
                      },
                    )
                  : Container(),
              (widget.steg)
                  ? Text("OR", textAlign: TextAlign.center)
                  : Container(),
              (widget.steg)
                  ? CustomTextButton(
                      text: "Use QR Steganography",
                      onPressed: () async {
                        setState(() {
                          qrSteg = true;
                        });
                      },
                    )
                  : Container(),
              (widget.steg == true && imgFileName != null)
                  ? Text("$imgFileName")
                  : Container(),
              CustomElevatedButton(
                text: "Encrypt and Share",
                onPressed: () async {
                  setState(() {
                    _loading = true;
                  });
                  try {
                    if (_note != null && _key != null) {
                      String path = await encryptNote(_key, _note);

                      if (path != null) {
                        if (widget.steg == false) {
                          await Share.shareFiles([
                            path,
                          ]);
                        } else {
                          imglib.Image image;
                          if (imgFilePath != null &&
                              imgFilePath.isNotEmpty &&
                              !qrSteg) {
                            image = imglib.decodeImage(
                                File(imgFilePath).readAsBytesSync().toList());
                          } else {
                            final qrValidatorResult = QrValidator.validate(
                              data: "Trunk Secure Password Manager",
                              version: 40,
                              errorCorrectionLevel: QrErrorCorrectLevel.L,
                            );
                            if (qrValidatorResult.status ==
                                QrValidationStatus.valid) {
                              final qrCode = qrValidatorResult.qrCode;

                              final painter = QrPainter.withQr(
                                qr: qrCode,
                                color: const Color(0xFF000000),
                                gapless: true,
                                embeddedImageStyle: null,
                                embeddedImage: null,
                              );

                              ByteData bytes = await painter.toImageData(2048,
                                  format: ImageByteFormat.png);
                              image = imglib.decodeImage(bytes.buffer
                                  .asUint8List(bytes.offsetInBytes,
                                      bytes.lengthInBytes));
                              imgFileName = "qr.png";
                            } else {
                              showSnackbar(context, "Something went wrong!");
                              print(qrValidatorResult.error);
                              setState(() {
                                _loading = true;
                              });
                              return;
                            }
                          }

                          String encryptedMsg = await File(path).readAsString();
                          imglib.Image img;

                          if(qrSteg) {
                            // Editing Image
                          } else {
                            EncodeRequest req =
                                EncodeRequest(image, encryptedMsg);
                            EncodeResponse res = encodeMessageIntoImage(req);
                            img = res.editableImage;
                          }

                          String imgPath =
                              await storeImageLocally(imgFileName, img);

                          await Share.shareFiles([
                            imgPath,
                          ]);
                        }
                      } else {
                        print("Path is null");
                        showSnackbar(context, "Unable to share");
                      }
                    } else {
                      showSnackbar(context, "Please select Note and Friend");
                    }

                    setState(() {
                      _loading = false;
                    });
                  } catch (e, s) {
                    print("$e $s");
                    showSnackbar(context, "Error occured while sharing");
                    setState(() {
                      _loading = false;
                    });
                  }
                },
              ),
              (_loading) ? SpinKitRing(color: kPrimaryColor) : Container(),
            ],
          ),
        ),
      ),
    );
  }
}
