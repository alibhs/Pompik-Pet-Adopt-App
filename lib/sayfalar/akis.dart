import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:pet_adopt/modeller/gonderi.dart';
import 'package:pet_adopt/modeller/kullanici.dart';
import 'package:pet_adopt/sayfalar/mesaj.dart';
import 'package:pet_adopt/servisler/firestoreservisi.dart';
import 'package:pet_adopt/widgetlar/gonderikarti.dart';
import 'package:pet_adopt/widgetlar/silinmeyenFutureBuilder.dart';

class Akis extends StatefulWidget {
  const Akis({Key? key}) : super(key: key);

  @override
  State<Akis> createState() => _AkisState();
}

class _AkisState extends State<Akis> {
  List<Gonderi> _gonderiler = [];

  @override
  void initState() {
    super.initState();
    _akisGonderileriniGetir();
  }

  Future<void> _akisGonderileriniGetir() async {
    List<Gonderi> gonderiler = await FireStoreServisi().akislariGetir();
    if (mounted) {
      setState(() {
        _gonderiler = gonderiler;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("Pompik", style: TextStyle(color: Colors.white)),
          centerTitle: true,
          actions: [
            Padding(
                padding: const EdgeInsets.only(right: 10.0),
                child: IconButton(
                  onPressed: () {
                    Navigator.push(context,
                        MaterialPageRoute(builder: (context) => MesajKutusu()));
                  },
                  icon: Icon(
                    FontAwesomeIcons.inbox,
                    color: Colors.white,
                  ),
                )),
          ],
        ),
        body: RefreshIndicator(
          onRefresh: _akisGonderileriniGetir,
          child: ListView.builder(
              shrinkWrap: true,
              primary: false, //kaydırma yapmaya ihtiyacın yoksa kaydırma yapma
              itemCount: _gonderiler.length,
              itemBuilder: (context, index) {
                Gonderi gonderi = _gonderiler[index];
                return SilinmeyenFutureBuilder(
                    //aşağı kaydırınca yukarda kalan listviewlar silinmesin.
                    future:
                        FireStoreServisi().kullaniciGetir(gonderi.yayinlayanId),
                    builder: (context, AsyncSnapshot snapshot) {
                      if (!snapshot.hasData) {
                        return SizedBox();
                      }
                      Kullanici gonderiSahibi = snapshot.data;
                      return GonderiKarti(
                          gonderi: gonderi, yayinlayanId: gonderiSahibi);
                    });
              }),
        ));
  }
}
