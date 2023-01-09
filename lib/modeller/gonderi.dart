// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:cloud_firestore/cloud_firestore.dart';

class Gonderi {
  final String? id;
  final String? gonderiResmiUrl;
  final String? aciklama;
  final String? yayinlayanId;
  final int? begeniSayisi;
  final String? konum;
  final String? yas;
  final String? ad;
  final String? tur;
  final String? cins;
  final String? cinsiyet;
  final String? renk;

  Gonderi({
    this.id,
    this.gonderiResmiUrl,
    this.aciklama,
    this.yayinlayanId,
    this.begeniSayisi,
    this.konum,
    this.yas,
    this.ad,
    this.tur,
    this.cins,
    this.cinsiyet,
    this.renk,
  });

  factory Gonderi.dokumandanUret(DocumentSnapshot doc) {
    return Gonderi(
      id: doc.id,
      gonderiResmiUrl: doc["gonderiResmiUrl"],
      aciklama: doc["aciklama"],
      yayinlayanId: doc["yayinlayanId"],
      begeniSayisi: doc["begeniSayisi"],
      konum: doc["konum"],
      yas: doc["yas"],
      ad: doc["ad"],
      tur: doc["tur"],
      cins: doc["cins"],
      cinsiyet: doc["cinsiyet"],
      renk: doc["renk"],
    );
  }
}
