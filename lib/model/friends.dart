
import 'package:pointycastle/export.dart';

class Friend {
  int id;
  String name;
  String title;
  RSAPublicKey key;
  DateTime createdAt;

  Friend({ this.name, this.key, this.title, this.createdAt });
  Friend.withId({ this.id, this.name, this.title, this.key, this.createdAt });

  Map<String, dynamic> toMap() {
    Map<String, dynamic> map = new Map<String, dynamic>();
    if(id != null) {
      map['id'] = "$id";
    }

    map['name'] = "$name";
    map['title'] = "$title";
    map['key'] = publicKeyToString();
    
    if(createdAt != null) {
      map['date_created'] = createdAt.toString();
    } else {
      map['date_created'] = DateTime.now().toString();
    }

    return map;
  }

  Friend.fromMapObject(Map<String, dynamic> map) {
    if(map['id'] != null) {
      this.id = map['id'];
    }
    this.name = map['name'];
    this.title = map['title'];
    this.key = strToPublicKey(map['key']);
    this.createdAt = DateTime.parse(map['date_created']);
  }

  String publicKeyToString() {
    return "" + key.modulus.toString() + "," + key.exponent.toString();
  }

  static RSAPublicKey strToPublicKey(String key) {
    List<String> splitKey = key.split(",");
    BigInt modulus = BigInt.parse(splitKey[0]);
    BigInt exponent = BigInt.parse(splitKey[1]);
    return RSAPublicKey(modulus, exponent);
  }
}