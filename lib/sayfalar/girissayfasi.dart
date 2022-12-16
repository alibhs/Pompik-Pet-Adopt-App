import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:pet_adopt/modeller/kullanici.dart';
import 'package:pet_adopt/sayfalar/hesapolustur.dart';
import 'package:pet_adopt/servisler/firestoreservisi.dart';
import 'package:pet_adopt/servisler/yetkilendirmeservisi.dart';
import 'package:provider/provider.dart';

class GirisSayfasi extends StatefulWidget {
  @override
  State<GirisSayfasi> createState() => _GirisSayfasiState();
}

class _GirisSayfasiState extends State<GirisSayfasi> {
  final _formAnahtari = GlobalKey<FormState>();
  bool yukleniyor = false;
  String? email, sifre;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.only(left: 20.0, right: 20.0, top: 60.0),
        child: Stack(
          children: [
            _sayfaElemanlari(),
            _yuklemeAnimasyonu(),
          ],
        ),
      ),
    );
  }

  Widget _yuklemeAnimasyonu() {
    if (yukleniyor) {
      return Center(child: CircularProgressIndicator());
    } else {
      return Center();
    }
  }

  Widget _sayfaElemanlari() {
    return Form(
      key: _formAnahtari,
      child: ListView(children: [
        Image(
          height: 100,
          image: AssetImage("assets/images/proje_logo2.png"),
        ),
        SizedBox(height: 70),
        TextFormField(
          autocorrect: true,
          keyboardType: TextInputType.emailAddress,
          decoration: InputDecoration(
            hintText: "Email Adresine Giriniz",
            errorStyle: TextStyle(fontSize: 16),
            prefixIcon: Icon(Icons.mail),
          ),
          validator: (girilenDeger) {
            if (girilenDeger!.isEmpty) {
              return "Email alanı boş bırakılmaz";
            } else if (!girilenDeger.contains("@")) {
              return "Girilen Değer Mail Formatında Olmalı";
            }
            return null;
          },
          onSaved: (girilenDeger) => email = girilenDeger,
        ),
        SizedBox(
          height: 40,
        ),
        TextFormField(
          obscureText: true,
          decoration: InputDecoration(
            hintText: "Şifrenizi Giriniz",
            errorStyle: TextStyle(fontSize: 16),
            prefixIcon: Icon(Icons.lock),
          ),
          validator: (girilenDeger) {
            //validator = dogrulama
            if (girilenDeger!.isEmpty) {
              return "Şifre alanı boş bırakılmaz";
            } else if (girilenDeger.trim().length < 4) {
              return "Sifre 4 karakterden az olamaz";
            }
            return null;
          },
          onSaved: (girilenDeger) => sifre = girilenDeger,
        ),
        SizedBox(
          height: 40,
        ),
        Row(
          children: [
            Expanded(
              child: TextButton(
                onPressed: () {
                  Navigator.of(context).push(
                      MaterialPageRoute(builder: (context) => HesapOlustur()));
                },
                style: TextButton.styleFrom(
                    backgroundColor: Theme.of(context).primaryColor),
                child: Text(
                  "Hesap Oluştur",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            SizedBox(
              width: 10,
            ),
            Expanded(
              child: TextButton(
                onPressed: _girisYap,
                style: TextButton.styleFrom(
                    backgroundColor: Theme.of(context).primaryColorDark),
                child: Text(
                  "Giriş Yap",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
        SizedBox(
          height: 35,
        ),
        Center(
            child: InkWell(
          onTap: _googleIleGiris,
          child: Text(
            "Google İle Giriş Yap",
            style: TextStyle(
                fontSize: 19, fontWeight: FontWeight.bold, color: Colors.grey),
          ),
        )),
        SizedBox(
          height: 20,
        ),
        Center(child: Text("Şifremi Unuttum"))
      ]),
    );
  }

  void _girisYap() async {
    final _yetkilendirmeServisi =
        Provider.of<YetkilendirmeServisi>(context, listen: false);

    if (_formAnahtari.currentState!.validate()) {
      _formAnahtari.currentState!.save();
      setState(() {
        yukleniyor = true;
      });
    }
    try {
      await _yetkilendirmeServisi.mailIleGiris(email!, sifre!);
    } on FirebaseAuthException catch (hata) {
      setState(() {
        yukleniyor = false;
      });
      uyariGoster(hataKodu: hata.code);
    }
  }

  void _googleIleGiris() async {
    final _yetkilendirmeServisi =
        Provider.of<YetkilendirmeServisi>(context, listen: false);
    setState(() {
      yukleniyor = true;
    });
    try {
      Kullanici? kullanici = await _yetkilendirmeServisi.googleIleGiris();
      if (kullanici != null) {
        Kullanici? firestoreKullanici =
            await FireStoreServisi().kullaniciGetir(kullanici.id);
        if (firestoreKullanici == null) {
          FireStoreServisi().kullaniciOlustur(
              id: kullanici.id,
              email: kullanici.email,
              kullaniciAdi: kullanici.kullaniciAdi,
              fotoUrl: kullanici.fotoUrl);
          print("Kullanici dokumanı olusturuldu");
        }
      }
    } on FirebaseAuthException catch (hata) {
      setState(() {
        yukleniyor = false;
      });
      uyariGoster(hataKodu: hata.code);
    }
  }

  uyariGoster({hataKodu}) {
    String? hataMesaji;
    if (hataKodu == "user-not-found") {
      hataMesaji = "Kullanıcı Bulunamadı";
    } else if (hataKodu == "invalid-email") {
      hataMesaji = "Geçersiz Mail Adresi";
    } else if (hataKodu == "user-disabled") {
      hataMesaji = "Sistemde Yasaklı Durumdasınız";
    } else if (hataKodu == "wrong-password") {
      hataMesaji = "Hatalı Şifre Girdiniz";
    } else {
      hataMesaji = "Tanimlanamayan Bir Hata İle Karşılaşıldı $hataKodu";
    }
    var snackBar = SnackBar(content: Text(hataMesaji));
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }
}
