import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:pet_adopt/modeller/duyuru.dart';
import 'package:pet_adopt/modeller/kullanici.dart';
import 'package:pet_adopt/sayfalar/profil.dart';
import 'package:pet_adopt/sayfalar/tekligonderi.dart';
import 'package:pet_adopt/servisler/firestoreservisi.dart';
import 'package:pet_adopt/servisler/yetkilendirmeservisi.dart';
import 'package:provider/provider.dart';
import 'package:timeago/timeago.dart' as timeago;

class Duyurular extends StatefulWidget {
  const Duyurular({Key? key}) : super(key: key);

  @override
  State<Duyurular> createState() => _DuyurularState();
}

class _DuyurularState extends State<Duyurular> {
  List<Duyuru>? _duyurular;
  String? _aktifKullaniciId;
  bool _yukleniyor = true;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _aktifKullaniciId =
        Provider.of<YetkilendirmeServisi>(context, listen: false)
            .aktifKullaniciId;
    duyurulariGetir();
    timeago.setLocaleMessages('tr', timeago.TrMessages());
  }

  Future<void> duyurulariGetir() async {
    List<Duyuru> duyurular =
        await FireStoreServisi().duyurulariGetir(_aktifKullaniciId!);

    if (mounted) {
      setState(() {
        _duyurular = duyurular;
        _yukleniyor = false;
      });
    }
  }

  duyurulariGoster() {
    if (_yukleniyor) {
      return Center(child: CircularProgressIndicator());
    }
    if (_duyurular!.isEmpty) {
      return Center(child: Text("Duyurunuz Yok..."));
    }

    return Padding(
      padding: const EdgeInsets.only(top: 12.0),
      //sayfayı kaydırıp yenilemek için
      child: RefreshIndicator(
        onRefresh: duyurulariGetir,
        child: ListView.builder(
            itemCount: _duyurular!.length,
            itemBuilder: (context, index) {
              Duyuru duyuru = _duyurular![index];
              return duyuruSatiri(duyuru);
            }),
      ),
    );
  }

  duyuruSatiri(Duyuru duyuru) {
    String? mesaj = mesajOlustur(duyuru.aktiviteTipi!);
    return FutureBuilder(
        //bildirimi yapanın ismine ve fotoğrafına erişmek için
        future: FireStoreServisi().kullaniciGetir(duyuru.aktiviteYapanId),
        builder: (context, AsyncSnapshot snapshot) {
          if (!snapshot.hasData) {
            return SizedBox(height: 0);
          }
          Kullanici aktiviteYapan = snapshot.data!;

          return ListTile(
              leading: InkWell(
                onTap: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) =>
                              Profil(profilSahibiId: duyuru.aktiviteYapanId)));
                },
                child: CircleAvatar(
                  backgroundImage: NetworkImage(aktiviteYapan.fotoUrl!),
                ),
              ),
              title: RichText(
                text: TextSpan(
                    //recognizer tıklama gibi durumları algılar.
                    //iki nokta recognizera hem tapgesture gönderdik hem de ontap parametresini
                    recognizer: TapGestureRecognizer()
                      ..onTap = () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => Profil(
                                    profilSahibiId: duyuru.aktiviteYapanId)));
                      },
                    text: "${aktiviteYapan.kullaniciAdi}",
                    style: TextStyle(
                        color: Colors.black, fontWeight: FontWeight.bold),
                    children: [
                      TextSpan(
                          text: duyuru.yorum == null
                              ? " $mesaj"
                              : " $mesaj ${duyuru.yorum}",
                          style: TextStyle(fontWeight: FontWeight.normal))
                    ]),
              ),
              subtitle: Text(timeago.format(duyuru.olusturulmaZamani!.toDate(),
                  locale: "tr")),
              trailing: gonderiGorsel(
                  duyuru.aktiviteTipi!,
                  duyuru.gonderiFoto,
                  duyuru
                      .gonderiId) // beğeni ve yorumda postun fotoğrafını sağ tarafta göstermek ,
              );
        });
  }

  gonderiGorsel(String aktiviteTipi, String? gonderiFoto, String? gonderiId) {
    if (aktiviteTipi == "abone") {
      return null;
    } else if (aktiviteTipi == "begeni" || aktiviteTipi == "yorum") {
      return GestureDetector(
        onTap: () {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => TekliGonderi(
                      gonderiId: gonderiId,
                      gonderiSahibiId: _aktifKullaniciId)));
        },
        child: Image.network(
          gonderiFoto!,
          width: 50,
          height: 50,
          fit: BoxFit.cover,
        ),
      );
    }
  }

  mesajOlustur(String aktiviteTipi) {
    if (aktiviteTipi == "begeni") {
      return "gönderini beğendi.";
    } else if (aktiviteTipi == "abone") {
      return "seni takip etti.";
    } else if (aktiviteTipi == "yorum") {
      return "gönderine yorum yaptı.";
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Duyurular",
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
        backgroundColor: Colors.orange,
      ),
      body: duyurulariGoster(),
    );
  }
}
