import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:uuid/uuid.dart';

class StorageServisi {
  Reference _storage =
      FirebaseStorage.instanceFor().ref(); //depolama alanına ulaşmak için
  String? resimId;

  Future<String> gonderiResmiYukle(File resimDosyasi) async {
    resimId = Uuid().v4();
    UploadTask yuklemeYoneticisi = _storage
        .child("resimler/gonderiler/gonderi._$resimId.jpg")
        .putFile(resimDosyasi);
    TaskSnapshot snapshot = await yuklemeYoneticisi;
    String yuklenenResimUrl = await snapshot.ref.getDownloadURL();
    return yuklenenResimUrl;
  }

  Future<String> ProfilResmiYukle(File resimDosyasi) async {
    resimId = Uuid().v4();
    UploadTask yuklemeYoneticisi = _storage
        .child("resimler/profil/profil._$resimId.jpg")
        .putFile(resimDosyasi);
    TaskSnapshot snapshot = await yuklemeYoneticisi;
    String yuklenenResimUrl = await snapshot.ref.getDownloadURL();
    return yuklenenResimUrl;
  }

  Future<void> gonderiResmiSil(String? gonderiResmiUrl) async {
    //storage içindeki silinecek fotoğrafın linkinden id kısmını getirtmek için regexp kullandık
    RegExp arama = RegExp(r"gonderi\._.+\.jpg");
    var eslesme = arama.firstMatch(gonderiResmiUrl!);
    String? dosyaAdi = eslesme![0];

    if (dosyaAdi != null) {
      await _storage.child("resimler/gonderiler/$dosyaAdi").delete();
    }
  }
}
