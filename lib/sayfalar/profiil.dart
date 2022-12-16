// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/material.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:pet_adopt/modeller/kullanici.dart';
import 'package:pet_adopt/servisler/firestoreservisi.dart';
import 'package:provider/provider.dart';

import 'package:pet_adopt/servisler/yetkilendirmeservisi.dart';

class Profil extends StatefulWidget {
  final String? profilSahibiId;
  const Profil({
    Key? key,
    this.profilSahibiId,
  }) : super(key: key);

  @override
  State<Profil> createState() => _ProfilState();
}

class _ProfilState extends State<Profil> {
  int _ilanSayisi = 0;
  int _abone = 0;

  _aboneSayisiGetir() async {
    int aboneSayisi =
        await FireStoreServisi().aboneSayisi(widget.profilSahibiId);
    setState(() {
      _abone = aboneSayisi;
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _aboneSayisiGetir();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Profil",
          style: TextStyle(color: Colors.black),
        ),
        backgroundColor: Colors.grey[100],
        actions: [
          IconButton(
              onPressed: _cikisYap,
              icon: Icon(
                Icons.exit_to_app,
                color: Colors.black,
              ))
        ],
      ),
      body: FutureBuilder<Kullanici?>(
          future: FireStoreServisi().kullaniciGetir(widget.profilSahibiId),
          builder: (context, AsyncSnapshot<Kullanici?> snapshot) {
            if (!snapshot.hasData) {
              return Center(child: CircularProgressIndicator());
            }
            return ListView(
              children: [
                _profilDetaylari(snapshot.data!),
              ],
            );
          }),
    );
  }

  Widget _profilDetaylari(Kullanici profilData) {
    return Padding(
      padding: const EdgeInsets.all(15.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                backgroundColor: Colors.grey[300],
                backgroundImage: (profilData.fotoUrl!.isNotEmpty)
                    ? NetworkImage(profilData.fotoUrl!)
                    : AssetImage("assets/images/anonim_images.png")
                        as ImageProvider,
                radius: 50.0,
              ),
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _sosyalSayac(baslik: "İlanlar", sayi: _ilanSayisi),
                    _sosyalSayac(baslik: "Aboneler", sayi: _abone),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(
            height: 10,
          ),
          Text(
            profilData.kullaniciAdi!,
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
          ),
          SizedBox(
            height: 5,
          ),
          Text(profilData.hakkinda!),
          SizedBox(
            height: 20.0,
          ),
          _profiliDuzenleButon()
        ],
      ),
    );
  }

  Widget _profiliDuzenleButon() {
    return Container(
      width: double.infinity,
      child: OutlinedButton(
        onPressed: () {},
        child: Text(
          "Profili Düzenle",
          style: TextStyle(color: Colors.black),
        ),
      ),
    );
  }

  Widget _sosyalSayac({String? baslik, int? sayi}) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          sayi.toString(),
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        SizedBox(
          height: 2.0,
        ),
        Text(
          baslik!,
          style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  void _cikisYap() {
    final _yetkilendirmeServisi =
        Provider.of<YetkilendirmeServisi>(context, listen: false).cikisYap();
  }
}
