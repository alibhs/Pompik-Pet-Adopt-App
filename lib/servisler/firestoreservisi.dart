import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pet_adopt/modeller/kullanici.dart';

class FireStoreServisi {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final DateTime zaman = DateTime.now();

  Future<void> kullaniciOlustur({id, email, kullaniciAdi, fotoUrl = ""}) async {
    await _firestore.collection("kullanicilar").doc(id).set({
      "kullaniciAdi": kullaniciAdi,
      "email": email,
      "fotoUrl": fotoUrl,
      "hakkinda": "",
      "olusturulduguZaman": zaman,
    });
  }

  Future<Kullanici?> kullaniciGetir(id) async {
    DocumentSnapshot<Map<String, dynamic>> doc =
        await _firestore.collection("kullanicilar").doc(id).get();
    if (doc.exists) {
      Kullanici kullanici = Kullanici.dokumandanUret(doc);
      return kullanici;
    }
    return null;
  }

  Future<int> aboneSayisi(kullaniciId) async {
    QuerySnapshot snapshot = await _firestore
        .collection("aboneler")
        .doc(kullaniciId)
        .collection("kullanicininAboneleri")
        .get();
    return snapshot.docs.length;
  }
}
