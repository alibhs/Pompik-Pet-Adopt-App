// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:pet_adopt/modeller/kullanici.dart';
import 'package:pet_adopt/sayfalar/chat.dart';
import 'package:pet_adopt/servisler/firestoreservisi.dart';
import 'package:pet_adopt/servisler/yetkilendirmeservisi.dart';

class MesajKutusu extends StatefulWidget {
  const MesajKutusu({
    Key? key,
  }) : super(key: key);

  @override
  State<MesajKutusu> createState() => _MesajKutusuState();
}

class _MesajKutusuState extends State<MesajKutusu> {
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
        centerTitle: true,
        backgroundColor: Colors.orange,
        title: Text(
          "Mesajlar",
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FireStoreServisi().mesajKullaniciGetir(_aktifKullaniciId!),
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.hasData) {
            if (snapshot.data!.docs.length < 1) {
              return Center(
                  child: Text(
                "Sohbet Ettiğiniz Kimse Yok ",
                style: TextStyle(
                  fontSize: 16,
                ),
              ));
            }
            return ListView.builder(
              itemCount: snapshot.data!.docs.length,
              itemBuilder: (context, index) {
                var kullaniciId = snapshot.data!.docs[index].id;
                var sonMesaj = snapshot.data!.docs[index]['sonMesaj'];

                return FutureBuilder<Kullanici?>(
                    future: FireStoreServisi().kullaniciGetir(kullaniciId),
                    builder: (context, snapshot) {
                      if (snapshot.hasData) {
                        Kullanici profilSahibi = snapshot.data!;
                        return ListTile(
                          leading: CircleAvatar(
                            backgroundImage: (profilSahibi.fotoUrl!.isNotEmpty)
                                ? NetworkImage(profilSahibi.fotoUrl!)
                                : AssetImage("assets/images/anonim_images.png")
                                    as ImageProvider,
                          ),
                          title: Text(profilSahibi.kullaniciAdi!),
                          subtitle: Container(
                            child: Text(
                              "$sonMesaj",
                              style: TextStyle(color: Colors.grey),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          onTap: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => ChatEkrani(
                                    profilSahibiId: profilSahibi.id!,
                                    profilSahibiAdi: profilSahibi.kullaniciAdi,
                                    profilSahibiImage: profilSahibi.fotoUrl,
                                  ),
                                ));
                          },
                        );
                      }
                      return LinearProgressIndicator();
                    });
              },
            );
          }
          return Center(
            child: CircularProgressIndicator(),
          );
        },
      ),
    );
  }
}
