import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:pet_adopt/servisler/firestoreservisi.dart';
import 'package:pet_adopt/servisler/storageservisi.dart';
import 'package:pet_adopt/servisler/yetkilendirmeservisi.dart';
import 'package:provider/provider.dart';

class Yukle extends StatefulWidget {
  const Yukle({Key? key}) : super(key: key);

  @override
  State<Yukle> createState() => _YukleState();
}

class _YukleState extends State<Yukle> {
  File? dosya;
  bool yukleniyor = false;
  TextEditingController aciklamaTextKumandasi = TextEditingController();
  TextEditingController konumTextKumandasi = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return dosya == null ? yukleButonu() : gonderiFormu();
  }

  Widget yukleButonu() {
    return IconButton(
        onPressed: fotografSec, icon: Icon(Icons.file_upload, size: 50.0));
  }

  Widget gonderiFormu() {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.orange,
        title: Text(
          "İlan Oluştur",
          style: TextStyle(color: Colors.white),
        ),
        leading: IconButton(
            onPressed: () {
              setState(() {
                dosya = null;
              });
            },
            icon: Icon(
              Icons.arrow_back,
              color: Colors.white,
            )),
        actions: [
          IconButton(
            onPressed: _gonderiOlustur,
            icon: Icon(
              Icons.send,
              color: Colors.white,
            ),
          ),
        ],
      ),
      body: ListView(
        children: [
          yukleniyor
              ? LinearProgressIndicator()
              : SizedBox(
                  height: 0,
                ),
          AspectRatio(
            aspectRatio: 16.0 / 9.0,
            child: Image.file(dosya!, fit: BoxFit.cover),
          ),
          SizedBox(
            height: 20.0,
          ),
          TextField(
            controller: aciklamaTextKumandasi,
            decoration: InputDecoration(
              hintText: "Açıklama Ekle",
              contentPadding: EdgeInsets.only(left: 15, right: 15),
            ),
          ),
          TextField(
            controller: konumTextKumandasi,
            decoration: InputDecoration(
              hintText: "Konum",
              contentPadding: EdgeInsets.only(left: 15, right: 15),
            ),
          ),
        ],
      ),
    );
  }

  void _gonderiOlustur() async {
    if (!yukleniyor) {
      setState(() {
        yukleniyor = true;
      });
      String resimUrl = await StorageServisi().gonderiResmiYukle(dosya!);
      String? aktifKullaniciId =
          Provider.of<YetkilendirmeServisi>(context, listen: false)
              .aktifKullaniciId;

      await FireStoreServisi().gonderiOlustur(
          gonderiResmiUrl: resimUrl,
          aciklama: aciklamaTextKumandasi.text,
          yayinlayanId: aktifKullaniciId,
          konum: konumTextKumandasi.text);
      setState(() {
        yukleniyor = false;
        aciklamaTextKumandasi.clear();
        konumTextKumandasi.clear();
        dosya = null;
      });
    }
  }

  fotografSec() {
    return showDialog(
        context: context,
        builder: (context) {
          return SimpleDialog(
            title: Text("İlan Oluştur"),
            children: [
              SimpleDialogOption(
                child: Text("Fotoğraf Çek"),
                onPressed: () {
                  fotoCek();
                },
              ),
              SimpleDialogOption(
                child: Text("Galeriden Yükle"),
                onPressed: () {
                  galeridenSec();
                },
              ),
              SimpleDialogOption(
                child: Text("İptal"),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
            ],
          );
        });
  }

  fotoCek() async {
    Navigator.pop(context);
    var image = await ImagePicker().pickImage(
        source: ImageSource.camera,
        maxHeight: 600,
        maxWidth: 800,
        imageQuality: 80);
    setState(() {
      dosya = File(image!.path);
    });
  }

  galeridenSec() async {
    Navigator.pop(context);
    var image = await ImagePicker().pickImage(
        source: ImageSource.gallery,
        maxHeight: 600,
        maxWidth: 800,
        imageQuality: 80);
    setState(() {
      dosya = File(image!.path);
    });
  }
}
