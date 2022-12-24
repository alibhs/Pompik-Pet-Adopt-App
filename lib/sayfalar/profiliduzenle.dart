// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import 'package:pet_adopt/modeller/kullanici.dart';
import 'package:pet_adopt/servisler/firestoreservisi.dart';
import 'package:pet_adopt/servisler/storageservisi.dart';
import 'package:pet_adopt/servisler/yetkilendirmeservisi.dart';
import 'package:provider/provider.dart';

class ProfiliDuzenle extends StatefulWidget {
  final Kullanici? profil;

  ProfiliDuzenle({
    Key? key,
    this.profil,
  }) : super(key: key);

  @override
  State<ProfiliDuzenle> createState() => _ProfiliDuzenleState();
}

class _ProfiliDuzenleState extends State<ProfiliDuzenle> {
  var _formKey = GlobalKey<FormState>();
  String? _kullaniciAdi;
  String? _hakkinda;
  File? _secilmisFoto;
  bool _yukleniyor = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.orange,
        title: Text(
          "Profili Düzenle",
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: Icon(
            Icons.close,
            color: Colors.white,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
              icon: Icon(
                Icons.check,
                color: Colors.white,
              ),
              onPressed: _kaydet),
        ],
      ),
      body: ListView(
        children: [
          _yukleniyor
              ? LinearProgressIndicator()
              : SizedBox(
                  height: 0,
                ),
          _profilFoto(),
          _kullaniciBilgileri(),
        ],
      ),
    );
  }

  _kaydet() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      setState(() {
        _yukleniyor = true;
      });

      String? profilFotoUrl;
      if (_secilmisFoto == null) {
        //kullanıcının yeni seçtiği fotoğrafi firebase'a kaydetme
        profilFotoUrl = widget.profil!.fotoUrl;
      } else {
        profilFotoUrl = await StorageServisi().ProfilResmiYukle(_secilmisFoto!);
      }

      String? aktifKullaniciId =
          Provider.of<YetkilendirmeServisi>(context, listen: false)
              .aktifKullaniciId;

      FireStoreServisi().kullaniciGuncelle(
          kullaniciId: aktifKullaniciId,
          kullaniciAdi: _kullaniciAdi,
          hakkinda: _hakkinda,
          fotoUrl: profilFotoUrl);

      setState(() {
        _yukleniyor = false;
      });

      Navigator.pop(context);
    }
  }

  _profilFoto() {
    return Padding(
      padding: const EdgeInsets.only(top: 15.0, bottom: 20.0),
      child: InkWell(
        onTap: _galeridenSec,
        child: CircleAvatar(
          backgroundImage: _secilmisFoto == null
              ? NetworkImage(widget.profil!.fotoUrl!)
              : FileImage(_secilmisFoto!) as ImageProvider,
          backgroundColor: Colors.grey,
          radius: 55.0,
        ),
      ),
    );
  }

  _galeridenSec() async {
    var image = await ImagePicker().pickImage(
        source: ImageSource.gallery,
        maxHeight: 600,
        maxWidth: 800,
        imageQuality: 80);
    setState(() {
      _secilmisFoto = File(image!.path);
    });
  }

  _kullaniciBilgileri() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12.0),
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            SizedBox(
              height: 20,
            ),
            TextFormField(
              initialValue: widget.profil!.kullaniciAdi!,
              decoration: InputDecoration(labelText: "Kullanıcı Adı"),
              validator: (girilenDeger) {
                return girilenDeger!.trim().length <= 3
                    ? "Kullanici adi en az 4 karakter olmalı"
                    : null;
              },
              onSaved: (girilenDeger) {
                _kullaniciAdi = girilenDeger;
              },
            ),
            TextFormField(
              initialValue: widget.profil!.hakkinda!,
              decoration: InputDecoration(labelText: "Hakkında"),
              validator: (girilenDeger) {
                return girilenDeger!.trim().length > 100
                    ? "Hakkında karakteri en fazla 100 karakter olabilir"
                    : null;
              },
              onSaved: (girilenDeger) {
                _hakkinda = girilenDeger;
              },
            ),
          ],
        ),
      ),
    );
  }
}
