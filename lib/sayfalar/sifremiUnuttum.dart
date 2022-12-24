import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:pet_adopt/servisler/yetkilendirmeservisi.dart';
import 'package:provider/provider.dart';

class SifremiUnuttum extends StatefulWidget {
  SifremiUnuttum({Key? key}) : super(key: key);

  @override
  State<SifremiUnuttum> createState() => _SifremiUnuttumState();
}

class _SifremiUnuttumState extends State<SifremiUnuttum> {
  bool yukleniyor = false;
  final _formAnahtari = GlobalKey<FormState>();

  late String email;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Şifremi Sıfırla",
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
        iconTheme: IconThemeData(
          color: Colors.white, //change your color here
        ),
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
                      height: 50,
                    ),
                    Container(
                      width: double.infinity,
                      child: TextButton(
                        onPressed: _sifreyiSifirla,
                        style: TextButton.styleFrom(
                            backgroundColor: Theme.of(context).primaryColor),
                        child: Text(
                          "Şifremi Sıfırla",
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

  void _sifreyiSifirla() async {
    final _yetkilendirmeServisi =
        Provider.of<YetkilendirmeServisi>(context, listen: false);

    var _formState = _formAnahtari.currentState!;

    if (_formState.validate()) {
      _formState.save();
      setState(() {
        yukleniyor = true;
      });
      try {
        await _yetkilendirmeServisi.sifremiSifirla(email);
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

    if (hataKodu == "auth/invalid-email") {
      hataMesaji = "Geçersiz Mail Adresi";
    } else if (hataKodu == "auth/user-not-found") {
      hataMesaji = "Bu Maile Ait Kullanıcı Bulunamıyor";
    }

    var snackBar = SnackBar(content: Text(hataMesaji!));
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }
}
