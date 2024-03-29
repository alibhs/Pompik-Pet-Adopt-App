import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pet_adopt/modeller/duyuru.dart';
import 'package:pet_adopt/modeller/gonderi.dart';
import 'package:pet_adopt/modeller/kullanici.dart';
import 'package:pet_adopt/servisler/storageservisi.dart';

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

  void kullaniciGuncelle(
      {String? kullaniciId,
      String? kullaniciAdi,
      String? fotoUrl = "",
      String? hakkinda}) {
    _firestore.collection("kullanicilar").doc(kullaniciId).update({
      "kullaniciAdi": kullaniciAdi,
      "hakkinda": hakkinda,
      "fotoUrl": fotoUrl,
    });
  }

  Future<List<Kullanici>> kullaniciAra(String kelime) async {
    QuerySnapshot snapshot = await _firestore
        .collection("kullanicilar")
        .where("kullaniciAdi", isGreaterThanOrEqualTo: kelime)
        .get();

    List<Kullanici> kullanicilar =
        snapshot.docs.map((doc) => Kullanici.dokumandanUret(doc)).toList();
    return kullanicilar;
  }

  void aboneOl({String? aktifKullanciId, String? profilSahibiId}) {
    _firestore
        .collection("aboneler")
        .doc(profilSahibiId)
        .collection("kullanicininAboneleri")
        .doc(aktifKullanciId)
        .set({});

    //abone olma bildirimi gidecek
    duyuruEkle(
      aktiviteTipi: "abone",
      aktiviteYapanId: aktifKullanciId,
      profilSahibiId: profilSahibiId,
    );
  }

  void aboneliktenCik({String? aktifKullanciId, String? profilSahibiId}) {
    _firestore
        .collection("aboneler")
        .doc(profilSahibiId)
        .collection("kullanicininAboneleri")
        .doc(aktifKullanciId)
        .get()
        .then((DocumentSnapshot doc) {
      if (doc.exists) {
        doc.reference.delete();
      }
    });
  }

  Future<bool> aboneKontrol(
      {String? aktifKullanciId, String? profilSahibiId}) async {
    DocumentSnapshot doc = await _firestore
        .collection("aboneler")
        .doc(profilSahibiId)
        .collection("kullanicininAboneleri")
        .doc(aktifKullanciId)
        .get();

    if (doc.exists) {
      return true;
    }
    return false;
  }

  Future<int> aboneSayisi(kullaniciId) async {
    QuerySnapshot snapshot = await _firestore
        .collection("aboneler")
        .doc(kullaniciId)
        .collection("kullanicininAboneleri")
        .get();
    return snapshot.docs.length;
  }

  void duyuruEkle(
      {String? aktiviteYapanId,
      String? profilSahibiId,
      String? aktiviteTipi,
      String? yorum,
      Gonderi? gonderi}) {
    if (aktiviteYapanId == profilSahibiId) {
      //kullanicinin kendine bildirim yaratmasını engelledik
      return;
    }

    _firestore
        .collection("duyurular")
        .doc(profilSahibiId)
        .collection("kullanicininDuyurulari")
        .add({
      "aktiviteYapanId": aktiviteYapanId,
      "aktiviteTipi": aktiviteTipi,
      "gonderiId": gonderi?.id,
      "gonderiFoto": gonderi?.gonderiResmiUrl,
      "yorum": yorum,
      "olusturulmaZamani": zaman
    });
  }

  Future<List<Duyuru>> duyurulariGetir(String profilSahibiId) async {
    QuerySnapshot snapshot = await _firestore
        .collection("duyurular")
        .doc(profilSahibiId)
        .collection("kullanicininDuyurulari")
        .orderBy("olusturulmaZamani", descending: true)
        .limit(20)
        .get();

    List<Duyuru> duyurular = [];
    snapshot.docs.forEach((DocumentSnapshot doc) {
      Duyuru duyuru = Duyuru.dokumandanUret(doc);
      duyurular.add(duyuru);
    });

    return duyurular;
  }

  Future<void> gonderiOlustur(
      {gonderiResmiUrl,
      aciklama,
      yayinlayanId,
      konum,
      yas,
      ad,
      cins,
      cinsiyet,
      renk,
      tur}) async {
    await _firestore
        .collection("gonderiler")
        .doc(yayinlayanId)
        .collection("kullaniciGonderileri")
        .add({
      "gonderiResmiUrl": gonderiResmiUrl,
      "aciklama": aciklama,
      "yayinlayanId": yayinlayanId,
      "konum": konum,
      "begeniSayisi": 0,
      "olusturulmaZamani": zaman,
      "yas": yas,
      "ad": ad,
      "cins": cins,
      "cinsiyet": cinsiyet,
      "renk": renk,
      "tur": tur,
    });
  }

  Future<List<Gonderi>> gonderileriGetir(kullaniciId) async {
    QuerySnapshot snapshot = await _firestore
        .collection("gonderiler")
        .doc(kullaniciId)
        .collection("kullaniciGonderileri")
        .orderBy("olusturulmaZamani", descending: true)
        .get();
    List<Gonderi> gonderiler =
        snapshot.docs.map((doc) => Gonderi.dokumandanUret(doc)).toList();
    return gonderiler;
  }

  Future<List<Gonderi>> akislariGetir() async {
    QuerySnapshot snapshot = await _firestore
        .collectionGroup("kullaniciGonderileri")
        .orderBy("olusturulmaZamani", descending: true)
        .get();
    List<Gonderi> gonderiler =
        snapshot.docs.map((doc) => Gonderi.dokumandanUret(doc)).toList();
    return gonderiler;
  }

  Future<void> gonderiSil({String? aktifKullaniciId, Gonderi? gonderi}) async {
    _firestore
        .collection("gonderiler")
        .doc(aktifKullaniciId)
        .collection("kullaniciGonderileri")
        .doc(gonderi!.id)
        .get()
        .then((DocumentSnapshot doc) {
      if (doc.exists) {
        doc.reference.delete();
      }
    });

    //Gonderi ait yorumlari silmek için

    QuerySnapshot yorumlarSnapshot = await _firestore
        .collection("yorumlar")
        .doc(gonderi.id)
        .collection("gonderiYorumlari")
        .get();
    yorumlarSnapshot.docs.forEach((DocumentSnapshot doc) {
      if (doc.exists) {
        doc.reference.delete();
      }
    });

    //Gonderiye ait duyurulari silmek için

    QuerySnapshot duyurularSnapshot = await _firestore
        .collection("duyurular")
        .doc(gonderi.yayinlayanId)
        .collection("kullanicininDuyurulari")
        .where("gonderiId", isEqualTo: gonderi.id)
        .get();

    duyurularSnapshot.docs.forEach((DocumentSnapshot doc) {
      if (doc.exists) {
        doc.reference.delete();
      }
    });

    //Gonderiye ait resmi silmek için
    StorageServisi().gonderiResmiSil(gonderi.gonderiResmiUrl!);
  }

  tekliGonderiGetir(String gonderiId, String gonderiSahibiId) async {
    DocumentSnapshot doc = await _firestore
        .collection("gonderiler")
        .doc(gonderiSahibiId)
        .collection("kullaniciGonderileri")
        .doc(gonderiId)
        .get();
    Gonderi gonderi = Gonderi.dokumandanUret(doc);
    return gonderi;
  }

  Future<void> gonderiBegen(Gonderi gonderi, String aktifKullaniciId) async {
    DocumentReference docRef = _firestore
        .collection("gonderiler")
        .doc(gonderi.yayinlayanId)
        .collection("kullaniciGonderileri")
        .doc(gonderi.id);

    DocumentSnapshot doc = await docRef.get();

    if (doc.exists) {
      //gönderi silinmiş olabilme ihtimaline karşı var mı diye kontrol ettik
      Gonderi gonderi = Gonderi.dokumandanUret(doc);

      int yeniBegeniSayisi = gonderi.begeniSayisi! + 1;
      docRef.update({"begeniSayisi": yeniBegeniSayisi});

      // Kullanici-Gonderi İlişkisinin Beğeniler Koleksiyonunu Eklenmesi
      _firestore
          .collection("begeniler")
          .doc(gonderi.id)
          .collection("gonderiBegenileri")
          .doc(aktifKullaniciId)
          .set({});
      //Beğeni haberlerini gönderi sahibine iletiyoruz.
      duyuruEkle(
        aktiviteTipi: "begeni",
        aktiviteYapanId: aktifKullaniciId,
        gonderi: gonderi,
        profilSahibiId: gonderi.yayinlayanId,
      );
    }
  }

  Future<void> gonderiBegeniKaldir(
      Gonderi gonderi, String aktifKullaniciId) async {
    DocumentReference docRef = _firestore
        .collection("gonderiler")
        .doc(gonderi.yayinlayanId)
        .collection("kullaniciGonderileri")
        .doc(gonderi.id);

    DocumentSnapshot doc = await docRef.get();

    if (doc.exists) {
      //gönderi silinmiş olabilme ihtimaline karşı var mı diye kontrol ettik
      Gonderi gonderi = Gonderi.dokumandanUret(doc);

      int yeniBegeniSayisi = gonderi.begeniSayisi! - 1;
      docRef.update({"begeniSayisi": yeniBegeniSayisi});
      // Kullanici-Gonderi İlişkisinin Beğeniler Koleksiyonunu Silinmesi
      DocumentSnapshot docBegeni = await _firestore
          .collection("begeniler")
          .doc(gonderi.id)
          .collection("gonderiBegenileri")
          .doc(aktifKullaniciId)
          .get();

      if (docBegeni.exists) {
        docBegeni.reference.delete();
      }
    }
  }

  Future<bool> begeniVarMi(Gonderi gonderi, String aktifKullaniciId) async {
    DocumentSnapshot docBegeni = await _firestore
        .collection("begeniler")
        .doc(gonderi.id)
        .collection("gonderiBegenileri")
        .doc(aktifKullaniciId)
        .get();
    if (docBegeni.exists) {
      return true;
    }
    return false;
  }

  Stream<QuerySnapshot> yorumlariGetir(String gonderiId) {
    return _firestore
        .collection("yorumlar")
        .doc(gonderiId)
        .collection("gonderiYorumlari")
        .orderBy("olusturulmaZamani", descending: true)
        .snapshots();
  }

  void yorumEkle({String? aktifKullaniciId, Gonderi? gonderi, String? icerik}) {
    _firestore
        .collection("yorumlar")
        .doc(gonderi!.id)
        .collection("gonderiYorumlari")
        .add({
      "icerik": icerik,
      "yayinlayanId": aktifKullaniciId,
      "olusturulmaZamani": zaman,
    });

    //Yorum duyurusunu gönderi sahibine iletiyoruz.
    duyuruEkle(
        aktiviteTipi: "yorum",
        aktiviteYapanId: aktifKullaniciId,
        gonderi: gonderi,
        profilSahibiId: gonderi.yayinlayanId,
        yorum: icerik);
  }

  mesajOlustur(
      String? kullaniciId, String? profilSahibiId, String? mesaj) async {
    await _firestore
        .collection("mesajlar")
        .doc(kullaniciId)
        .collection("sohbet")
        .doc(profilSahibiId)
        .collection("konusmalar")
        .add({
      "gonderenId": kullaniciId,
      "mesajAlanId": profilSahibiId,
      "mesaj": mesaj,
      "olusturulmaZamani": DateTime.now()
    }).then((value) {
      _firestore
          .collection("mesajlar")
          .doc(kullaniciId)
          .collection("sohbet")
          .doc(profilSahibiId)
          .set({"sonMesaj": mesaj});
    });
  }

  mesajAl(String kullaniciId, String profilSahibiId, String mesaj) async {
    await _firestore
        .collection("mesajlar")
        .doc(profilSahibiId)
        .collection("sohbet")
        .doc(kullaniciId)
        .collection("konusmalar")
        .add({
      "gonderenId": kullaniciId,
      "mesajAlanId": profilSahibiId,
      "mesaj": mesaj,
      "olusturulmaZamani": DateTime.now()
    }).then((value) {
      _firestore
          .collection("mesajlar")
          .doc(profilSahibiId)
          .collection("sohbet")
          .doc(kullaniciId)
          .set({"sonMesaj": mesaj});
    });
  }

  Stream<QuerySnapshot> mesajlariGetir(
      String kullaniciId, String profilSahibiId) {
    return _firestore
        .collection("mesajlar")
        .doc(kullaniciId)
        .collection("sohbet")
        .doc(profilSahibiId)
        .collection("konusmalar")
        .orderBy("olusturulmaZamani", descending: true)
        .snapshots();
  }

  Stream<QuerySnapshot> mesajKullaniciGetir(String kullaniciId) {
    return _firestore
        .collection("mesajlar")
        .doc(kullaniciId)
        .collection("sohbet")
        .snapshots();
  }
}
