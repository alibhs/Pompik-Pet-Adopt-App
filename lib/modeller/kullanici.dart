import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class Kullanici {
  final String? id;
  final String? kullaniciAdi;
  final String? fotoUrl;
  final String? email;
  final String? hakkinda;

  Kullanici(
      {this.id, this.kullaniciAdi, this.fotoUrl, this.email, this.hakkinda});

  factory Kullanici.firebasedenUret(User kullanici) {
    return Kullanici(
      id: kullanici.uid,
      kullaniciAdi: kullanici.displayName,
      fotoUrl: kullanici.photoURL,
      email: kullanici.email,
    );
  }

  factory Kullanici.dokumandanUret(DocumentSnapshot doc) {
    return Kullanici(
      id: doc.id,
      kullaniciAdi: doc['kullaniciAdi'],
      email: doc['email'],
      fotoUrl: doc['fotoUrl'],
      hakkinda: doc['hakkinda'],
    );
  }
}
