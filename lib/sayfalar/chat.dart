// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:pet_adopt/servisler/firestoreservisi.dart';
import 'package:pet_adopt/widgetlar/chatBox.dart';
import 'package:provider/provider.dart';
import 'package:pet_adopt/modeller/kullanici.dart';
import 'package:pet_adopt/servisler/yetkilendirmeservisi.dart';
import 'package:pet_adopt/widgetlar/mesaj_textfield.dart';

class ChatEkrani extends StatefulWidget {
  ChatEkrani({
    Key? key,
    this.profilSahibiId,
    this.profilSahibiAdi,
    this.profilSahibiImage,
  }) : super(key: key);

  final String? profilSahibiAdi;
  final String? profilSahibiId;
  final String? profilSahibiImage;

  @override
  State<ChatEkrani> createState() => _ChatEkraniState();
}

class _ChatEkraniState extends State<ChatEkrani> {
  String? _aktifKullaniciId;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _aktifKullaniciId =
        Provider.of<YetkilendirmeServisi>(context, listen: false)
            .aktifKullaniciId;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(
          color: Colors.white, //change your color here
        ),
        backgroundColor: Colors.orange,
        title: Row(
          children: [
            CircleAvatar(
              backgroundColor: Colors.blue,
              backgroundImage: (widget.profilSahibiImage!.isNotEmpty)
                  ? NetworkImage(widget.profilSahibiImage!)
                  : AssetImage("assets/images/anonim_images.png")
                      as ImageProvider,
            ),
            SizedBox(
              width: 20,
            ),
            Text(
              widget.profilSahibiAdi!,
              style: TextStyle(fontSize: 20, color: Colors.white),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
              child: Container(
            padding: EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.pink[50],
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(25),
                topRight: Radius.circular(25),
              ),
            ),
            child: StreamBuilder<QuerySnapshot>(
              stream: FireStoreServisi()
                  .mesajlariGetir(_aktifKullaniciId!, widget.profilSahibiId!),
              builder: (BuildContext context,
                  AsyncSnapshot<QuerySnapshot> snapshot) {
                if (snapshot.hasData) {
                  if (snapshot.data!.docs.length < 1) {
                    return Center(
                        child: Text(
                      "Merhaba Diyerek Sohbete Başlayabilirsiniz",
                      style: TextStyle(
                        fontSize: 16,
                      ),
                    ));
                  }
                  return ListView.builder(
                    itemCount: snapshot.data!.docs.length,
                    reverse: true,
                    physics: BouncingScrollPhysics(),
                    itemBuilder: (context, index) {
                      bool aktifKullanici = snapshot.data!.docs[index]
                              ["gonderenId"] ==
                          _aktifKullaniciId;
                      return ChatBox(
                        mesaj: snapshot.data!.docs[index]["mesaj"],
                        aktifKullanici: aktifKullanici,
                      );
                    },
                  );
                }
                return Center(
                  child: CircularProgressIndicator(),
                );
              },
            ),
          )),
          MesajTextField(
            kullaniciId: _aktifKullaniciId,
            profilSahibiId: widget.profilSahibiId,
          ),
        ],
      ),
    );
  }
}
