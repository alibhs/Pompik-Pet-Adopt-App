// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/material.dart';
import 'package:pet_adopt/modeller/gonderi.dart';
import 'package:pet_adopt/modeller/kullanici.dart';
import 'package:pet_adopt/sayfalar/profiliduzenle.dart';
import 'package:pet_adopt/servisler/firestoreservisi.dart';
import 'package:pet_adopt/widgetlar/gonderikarti.dart';
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
  int _gonderiSayisi = 0;
  int _abone = 0;
  List<Gonderi> _gonderiler = [];
  String gonderiStili = "liste";
  String? _aktifKullaniciId;
  Kullanici? _profilSahibi;
  bool _aboneOlundu = false;

  _aboneSayisiGetir() async {
    int aboneSayisi =
        await FireStoreServisi().aboneSayisi(widget.profilSahibiId);
    if (mounted) {
      setState(() {
        _abone = aboneSayisi;
      });
    }
  }

  _gonderilerGetir() async {
    List<Gonderi> gonderiler =
        await FireStoreServisi().gonderileriGetir(widget.profilSahibiId);
    if (mounted) {
      if (mounted) {
        setState(() {
          _gonderiler = gonderiler;
          _gonderiSayisi = _gonderiler.length;
        });
      }
    }
  }

  _aboneKontrol() async {
    bool aboneVarMi = await FireStoreServisi().aboneKontrol(
        profilSahibiId: widget.profilSahibiId,
        aktifKullanciId: _aktifKullaniciId);

    setState(() {
      _aboneOlundu = aboneVarMi;
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _aboneSayisiGetir();
    _gonderilerGetir();
    _aktifKullaniciId =
        Provider.of<YetkilendirmeServisi>(context, listen: false)
            .aktifKullaniciId;
    _aboneKontrol();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Profil",
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.orange,
        iconTheme: IconThemeData(color: Colors.white),
        actions: [
          //sadece kendi profil sayfamızda çıkış yap ikonu görünecek
          widget.profilSahibiId == _aktifKullaniciId
              ? IconButton(
                  onPressed: _cikisYap,
                  icon: Icon(
                    Icons.exit_to_app,
                    color: Colors.white,
                  ))
              : SizedBox(
                  height: 0.0,
                )
        ],
      ),
      body: FutureBuilder<Kullanici?>(
          future: FireStoreServisi().kullaniciGetir(widget.profilSahibiId),
          builder: (context, AsyncSnapshot<Kullanici?> snapshot) {
            if (!snapshot.hasData) {
              return Center(child: CircularProgressIndicator());
            }
            _profilSahibi = snapshot
                .data; //profildüzenle kısmana bilgileri göndermek amaciyla kaydettik
            return ListView(
              children: [
                _profilDetaylari(snapshot.data!),
                _gonderileriGoster(snapshot.data!),
                //gonderigoster ve profildetaylari widgetina kullanici bilgilerini gönderdik
              ],
            );
          }),
    );
  }

  Widget _gonderileriGoster(Kullanici profilData) {
    if (gonderiStili == "liste") {
      return ListView.builder(
          shrinkWrap: true,
          primary: false, //kaydırma yapmaya ihtiyacın yoksa kaydırma yapma
          itemCount: _gonderiler.length,
          itemBuilder: (context, index) {
            return GonderiKarti(
                gonderi: _gonderiler[index], yayinlayanId: profilData);
          });
    } else {
      List<GridTile> fayanslar = [];
      _gonderiler.forEach((gonderi) {
        //ilanları fayanslar listesine ekleyip gridtile şeklinde döndürdük
        fayanslar.add(_fayansOlustur(gonderi));
      });
      return GridView.count(
        shrinkWrap:
            true, //sadece ihtiyacı kadar olanı kaplar diğer widgetlerin üstüne geçmez
        crossAxisCount: 3,
        mainAxisSpacing: 2.0,
        crossAxisSpacing: 2.0,
        childAspectRatio: 1.0,
        physics: NeverScrollableScrollPhysics(),
        children: fayanslar,
      );
    }
  }

  GridTile _fayansOlustur(Gonderi gonderi) {
    //resimleri veritabanından çektik
    return GridTile(
      child: Image.network(
        gonderi.gonderiResmiUrl!,
        fit: BoxFit.cover,
      ),
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
                    _sosyalSayac(baslik: "İlanlar", sayi: _gonderiSayisi),
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
          widget.profilSahibiId == _aktifKullaniciId
              ? _profiliDuzenleButon()
              : _aboneButonu()
        ],
      ),
    );
  }

  Widget _aboneButonu() {
    return _aboneOlundu ? _abonedenCikButonu() : _aboneOlButonu();
  }

  Widget _aboneOlButonu() {
    return Container(
      width: double.infinity,
      child: TextButton(
        style: TextButton.styleFrom(
            backgroundColor: Theme.of(context).primaryColor),
        onPressed: () {
          FireStoreServisi().aboneOl(
              profilSahibiId: widget.profilSahibiId,
              aktifKullanciId: _aktifKullaniciId);
          setState(() {
            _aboneOlundu = true;
            _abone = _abone + 1;
          });
        },
        child: Text(
          "Abone Ol",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  Widget _abonedenCikButonu() {
    return Container(
      width: double.infinity,
      child: OutlinedButton(
        onPressed: () {
          FireStoreServisi().aboneliktenCik(
              profilSahibiId: widget.profilSahibiId,
              aktifKullanciId: _aktifKullaniciId);
          setState(() {
            _aboneOlundu = false;
            _abone = _abone - 1;
          });
        },
        child: Text(
          "Abonelikten Çık",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  Widget _profiliDuzenleButon() {
    return Container(
      width: double.infinity,
      child: OutlinedButton(
        onPressed: () {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: ((context) => ProfiliDuzenle(
                        profil: _profilSahibi,
                      ))));
        },
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
    Provider.of<YetkilendirmeServisi>(context, listen: false).cikisYap();
  }
}
