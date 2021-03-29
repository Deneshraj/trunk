import 'package:pointycastle/export.dart';

class Keys {
  int id;
  String title;
  RSAPublicKey publicKey;
  RSAPrivateKey privateKey;
  DateTime dateCreated;

  Keys({ this.title, this.publicKey, this.privateKey, this.dateCreated });
  Keys.withId({ this.id, this.title, this.publicKey, this.privateKey, this.dateCreated });

  Map<String, dynamic> toMap() {
    Map<String, dynamic> map = new Map<String, dynamic>();
    if(id != null) {
      map['id'] = id;
    }
    map['title'] = this.title;
    map['pub_key'] = publicKeyToString();
    map['priv_key'] = privateKeyToString();
    map['date_created'] = dateCreated.toString();

    return map;
  }

  Keys.fromMapObject(Map<String, dynamic> map) {
    this.id = map['id'];
    this.title = map['title'];
    this.publicKey = strToPublicKey(map['pub_key']);
    this.privateKey = strToPrivateKey(map['priv_key']);
    this.dateCreated = DateTime.parse(map['date_created']);
  }

  String publicKeyToString() {
    return "" + publicKey.modulus.toString() + "," + publicKey.exponent.toString();
  }

  String privateKeyToString() {
    return "" + privateKey.modulus.toString() + "," + privateKey.exponent.toString() + "," + privateKey.p.toString() + "," + privateKey.q.toString();
  }

  RSAPublicKey strToPublicKey(String key) {
    List<String> splitKey = key.split(",");
    BigInt modulus = BigInt.parse(splitKey[0]);
    BigInt exponent = BigInt.parse(splitKey[1]);
    return RSAPublicKey(modulus, exponent);
  }
  
  RSAPrivateKey strToPrivateKey(String key) {
    List<String> splitKey = key.split(",");
    BigInt modulus = BigInt.parse(splitKey[0]);
    BigInt exponent = BigInt.parse(splitKey[1]);
    BigInt p = BigInt.parse(splitKey[2]);
    BigInt q = BigInt.parse(splitKey[3]);

    return RSAPrivateKey(modulus, exponent, p, q);
  }
}