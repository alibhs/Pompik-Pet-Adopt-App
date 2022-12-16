import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:pet_adopt/modeller/kullanici.dart';
import 'package:pet_adopt/servisler/firestoreservisi.dart';
import 'package:pet_adopt/servisler/yetkilendirmeservisi.dart';
import 'package:provider/provider.dart';

class HesapOlustur extends StatefulWidget {
  const HesapOlustur({Key? key}) : super(key: key);

  @override
  State<HesapOlustur> createState() => _HesapOlusturState();
}

class _HesapOlusturState extends State<HesapOlustur> {
  bool yukleniyor = false;
  final _formAnahtari = GlobalKey<FormState>();

  late String kullaniciAdi, email, sifre;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Hesap Oluştur"),
      ),
      body: ListView(
        children: [
          yukleniyor ? LinearProgressIndicator() : Center(),
          SizedBox(
            height: 20,
          ),
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Form(
                key: _formAnahtari,
                child: Column(
                  children: [
                    TextFormField(
                      keyboardType: TextInputType.emailAddress,
                      decoration: InputDecoration(
                        hintText: "Kullanıcı Adınızı Giriniz",
                        labelText: "Kullanıcı Adi:",
                        errorStyle: TextStyle(fontSize: 16),
                        prefixIcon: Icon(Icons.person),
                      ),
                      validator: (girilenDeger) {
                        if (girilenDeger!.isEmpty) {
                          return "Kullanıcı Adı boş bırakılmaz";
                        } else if (girilenDeger.trim().length < 4 ||
                            girilenDeger.trim().length > 10) {
                          return "En az 4 en fazla 10 karakterli olabilir";
                        }
                        return null;
                      },
                      onSaved: (girilenDeger) => kullaniciAdi = girilenDeger!,
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    TextFormField(
                      autocorrect: true,
                      keyboardType: TextInputType.emailAddress,
                      decoration: InputDecoration(
                        hintText: "Email Adresine Giriniz",
                        labelText: "Mail:",
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
                      onSaved: (girilenDeger) => email = girilenDeger!,
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    TextFormField(
                      obscureText: true,
                      decoration: InputDecoration(
                        hintText: "Şifrenizi Giriniz",
                        labelText: "Sifre:",
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
                      onSaved: (girilenDeger) => sifre = girilenDeger!,
                    ),
                    SizedBox(
                      height: 50,
                    ),
                    Container(
                      width: double.infinity,
                      child: TextButton(
                        onPressed: _kullaniciOlustur,
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
                  ],
                )),
          )
        ],
      ),
    );
  }

  void _kullaniciOlustur() async {
    final _yetkilendirmeServisi =
        Provider.of<YetkilendirmeServisi>(context, listen: false);

    var _formState = _formAnahtari.currentState!;
    if (_formState.validate()) {
      _formState.save();
      setState(() {
        yukleniyor = true;
      });
      try {
        Kullanici? kullanici =
            await _yetkilendirmeServisi.mailIleKayit(email, sifre);
        if (kullanici != null) {
          FireStoreServisi().kullaniciOlustur(
              id: kullanici.id, email: email, kullaniciAdi: kullaniciAdi);
        }
        Navigator.pop(context);
      } on FirebaseAuthException catch (hata) {
        setState(() {
          yukleniyor = false;
        });
        uyariGoster(hataKodu: hata.code);
      }
    }
  }

  uyariGoster({hataKodu}) {
    String? hataMesaji;
    if (hataKodu == "email-already-in-use") {
      hataMesaji = "Mail Adresi Zaten Kullanımda";
    } else if (hataKodu == "invalid-email") {
      hataMesaji = "Geçersiz Mail Adresi";
    } else if (hataKodu == "operation-not-allowed") {
      hataMesaji = "Sistemde Yasaklı Durumdasınız";
    } else if (hataKodu == "weak-password") {
      hataMesaji = "Lütfen Daha Güçlü Bir Şifre Giriniz";
    }
    var snackBar = SnackBar(content: Text(hataMesaji!));
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }
}
