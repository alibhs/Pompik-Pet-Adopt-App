// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:pet_adopt/modeller/gonderi.dart';
import 'package:pet_adopt/modeller/kullanici.dart';
import 'package:pet_adopt/modeller/yorum.dart';
import 'package:pet_adopt/servisler/firestoreservisi.dart';
import 'package:pet_adopt/servisler/yetkilendirmeservisi.dart';
import 'package:provider/provider.dart';
import 'package:timeago/timeago.dart' as timeago;

class Yorumlar extends StatefulWidget {
  final Gonderi? gonderi;
  Yorumlar({
    Key? key,
    this.gonderi,
  }) : super(key: key);

  @override
  State<Yorumlar> createState() => _YorumlarState();
}

class _YorumlarState extends State<Yorumlar> {
  TextEditingController _yorumKontrolcusu = TextEditingController();
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    timeago.setLocaleMessages('tr', timeago.TrMessages());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(color: Colors.white),
        backgroundColor: Colors.orange,
        title: Text(
          "Yorumlar",
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: Column(
        children: [
          _yorumlariGoster(),
          _yorumEkle(),
        ],
      ),
    );
  }

  _yorumlariGoster() {
    return Expanded(
        child: StreamBuilder<QuerySnapshot>(
      //anlık yorumlara ulaşabilmek için
      stream: FireStoreServisi().yorumlariGetir(widget.gonderi!.id!),
      builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (!snapshot.hasData) {
          return Center(child: CircularProgressIndicator());
        }
        //Her Gönderide Yorumları Farklı ListViewda Gösterebilmek İçin
        return ListView.builder(
            itemCount: snapshot.data?.docs.length,
            itemBuilder: (context, index) {
              Yorum yorum = Yorum.dokumandanUret(snapshot.data!.docs[index]);
              return _yorumSatiri(yorum);
            });
      },
    ));
  }

  _yorumSatiri(Yorum yorum) {
    //futurebuilder ile yorum yapan kişinin özelliklerine erişicez
    return FutureBuilder<Kullanici?>(
        future: FireStoreServisi().kullaniciGetir(yorum.yayinlayanId),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            //yorumun kullanici satiri henüz yüklenmediyse yorum satırın gösterme
            return SizedBox(
              height: 0,
            );
          }

          Kullanici yayinlayan = snapshot.data!;

          return ListTile(
            leading: CircleAvatar(
              backgroundColor: Colors.grey,
              backgroundImage: (yayinlayan.fotoUrl!.isNotEmpty)
                  ? NetworkImage(yayinlayan.fotoUrl!)
                  : AssetImage("assets/images/anonim_images.png")
                      as ImageProvider,
            ),
            title: RichText(
              text: TextSpan(
                text: yayinlayan.kullaniciAdi! + " ",
                style: TextStyle(
                    fontSize: 15.0,
                    fontWeight: FontWeight.bold,
                    color: Colors.black),
                children: [
                  TextSpan(
                    text: yorum.icerik,
                    style: TextStyle(
                        fontWeight: FontWeight.normal, fontSize: 14.0),
                  ),
                ],
              ),
            ),
            subtitle: Text(timeago.format(yorum.olusturulmaZamani!.toDate(),
                locale: "tr")),
          );
        });
  }

  _yorumEkle() {
    return ListTile(
      title: TextFormField(
        controller: _yorumKontrolcusu,
        decoration: InputDecoration(hintText: "Yorum Yazınız."),
      ),
      trailing: IconButton(onPressed: _yorumGonder, icon: Icon(Icons.send)),
    );
  }

  void _yorumGonder() {
    String? aktifKullaniciId =
        Provider.of<YetkilendirmeServisi>(context, listen: false)
            .aktifKullaniciId;
    FireStoreServisi().yorumEkle(
        aktifKullaniciId: aktifKullaniciId,
        gonderi: widget.gonderi,
        icerik: _yorumKontrolcusu.text);
    _yorumKontrolcusu.clear();
  }
}
