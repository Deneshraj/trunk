
import 'package:pointycastle/export.dart';

class Friend {
  int id;
  String name;
  RSAPublicKey key;
  DateTime createdAt;

  Friend({ this.name, this.key, this.createdAt });
  Friend.withId({ this.id, this.name, this.key, this.createdAt });

  Map<String, dynamic> toMap() {
    Map<String, dynamic> map = new Map<String, dynamic>();
    map['id'] = "$id";
    map['name'] = "$name";
    map['key'] = publicKeyToString();
    map['created_at'] = createdAt.toString();

    return map;
  }

  Friend.fromMap(Map<String, dynamic> map) {
    this.id = map['id'];
    this.name = map['name'];
    this.key = strToPublicKey(map['key']);
    this.createdAt = map['created_at'];
  }

  String publicKeyToString() {
    return "" + key.modulus.toString() + "," + key.exponent.toString();
  }

  RSAPublicKey strToPublicKey(String key) {
    List<String> splitKey = key.split(",");
    BigInt modulus = BigInt.parse(splitKey[0]);
    BigInt exponent = BigInt.parse(splitKey[1]);
    return RSAPublicKey(modulus, exponent);
  }
}