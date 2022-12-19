// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/framework.dart';

import 'package:pet_adopt/modeller/gonderi.dart';
import 'package:pet_adopt/modeller/kullanici.dart';
import 'package:pet_adopt/sayfalar/yorumlar.dart';
import 'package:pet_adopt/servisler/firestoreservisi.dart';
import 'package:pet_adopt/servisler/yetkilendirmeservisi.dart';
import 'package:provider/provider.dart';

class GonderiKarti extends StatefulWidget {
  final Gonderi? gonderi;
  final Kullanici? yayinlayanId;
  const GonderiKarti({
    Key? key,
    this.gonderi,
    this.yayinlayanId,
  }) : super(key: key);

  @override
  State<GonderiKarti> createState() => _GonderiKartiState();
}

class _GonderiKartiState extends State<GonderiKarti> {
  int _begeniSayisi = 0;
  bool _begendin = false;
  String? _aktifKullaniciId;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _aktifKullaniciId =
        Provider.of<YetkilendirmeServisi>(context, listen: false)
            .aktifKullaniciId;
    _begeniSayisi = widget.gonderi!.begeniSayisi!;
    begeniVarMi();
  }

  begeniVarMi() async {
    bool begeniVarMi = await FireStoreServisi()
        .begeniVarMi(widget.gonderi!, _aktifKullaniciId!);
    if (begeniVarMi) {
      if (mounted) {
        setState(() {
          _begendin = true;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: const EdgeInsets.only(bottom: 8.0),
        child: Column(
          children: [
            _gonderiBasligi(),
            _gonderiResmi(),
            _gonderiAlt(),
          ],
        ));
  }

  Widget _gonderiBasligi() {
    return ListTile(
      leading: Padding(
        padding: const EdgeInsets.only(left: 12.0),
        child: CircleAvatar(
          backgroundColor: Colors.blue,
          backgroundImage: (widget.yayinlayanId!.fotoUrl!.isNotEmpty)
              ? NetworkImage(widget.yayinlayanId!.fotoUrl!)
              : AssetImage("assets/images/anonim_images.png") as ImageProvider,
        ),
      ),
      title: Text(
        widget.yayinlayanId!.kullaniciAdi!,
        style: TextStyle(fontSize: 14.0, fontWeight: FontWeight.bold),
      ),
      trailing: IconButton(onPressed: null, icon: Icon(Icons.more_vert)),
      contentPadding:
          EdgeInsets.all(0.0), //list tile'ın default padingini sifirladik
    );
  }

  Widget _gonderiResmi() {
    return GestureDetector(
      onDoubleTap: _begeniDegistir,
      child: Image.network(
        widget.gonderi!.gonderiResmiUrl!,
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.width,
        fit: BoxFit.cover,
      ),
    );
  }

  Widget _gonderiAlt() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            IconButton(
              onPressed:
                  _begeniDegistir, //begenme durumuna göre içini dolu veya boş yaptık
              icon: !_begendin
                  ? Icon(Icons.favorite_border, size: 35)
                  : Icon(
                      Icons.favorite,
                      size: 35,
                      color: Colors.red,
                    ),
            ),
            IconButton(
              onPressed: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) =>
                            Yorumlar(gonderi: widget.gonderi)));
              },
              icon: Icon(Icons.comment, size: 35),
            ),
          ],
        ),
        Padding(
          padding: const EdgeInsets.only(left: 8.0),
          child: Text("$_begeniSayisi beğeni",
              style: TextStyle(fontSize: 15.0, fontWeight: FontWeight.bold)),
        ),
        SizedBox(
          height: 2.0,
        ),
        widget.gonderi!.aciklama!
                .isNotEmpty //acıklama satırı girilmediyse kullanici adini da göstermeyecek
            ? Padding(
                padding: const EdgeInsets.only(left: 8.0),
                child: RichText(
                  text: TextSpan(
                    text: widget.yayinlayanId!.kullaniciAdi! + " ",
                    style: TextStyle(
                        fontSize: 15.0,
                        fontWeight: FontWeight.bold,
                        color: Colors.black),
                    children: [
                      TextSpan(
                        text: widget.gonderi!.aciklama!,
                        style: TextStyle(
                            fontWeight: FontWeight.normal, fontSize: 14.0),
                      ),
                    ],
                  ),
                ),
              )
            : SizedBox(height: 0.0),
      ],
    );
  }

  void _begeniDegistir() {
    if (_begendin) {
      //Kullanıcı gönderiyi beğenmiş, kaldırılacak kodlar yazılacak.
      setState(() {
        _begendin = false;
        _begeniSayisi = _begeniSayisi - 1;
        FireStoreServisi()
            .gonderiBegeniKaldir(widget.gonderi!, _aktifKullaniciId!);
      });
    } else {
      //Kullanıcı gönderiyi beğenmemiş, beğeni ekleyen kodları çalıştırıcaz.
      setState(() {
        _begendin = true;
        _begeniSayisi = _begeniSayisi + 1;
      });
      FireStoreServisi().gonderiBegen(widget.gonderi!, _aktifKullaniciId!);
    }
  }
}
