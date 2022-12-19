import 'package:flutter/material.dart';
import 'package:pet_adopt/modeller/kullanici.dart';
import 'package:pet_adopt/sayfalar/profil.dart';
import 'package:pet_adopt/servisler/firestoreservisi.dart';

class Ara extends StatefulWidget {
  const Ara({Key? key}) : super(key: key);

  @override
  State<Ara> createState() => _AraState();
}

class _AraState extends State<Ara> {
  TextEditingController _aramaKontroller = TextEditingController();
  Future<List<Kullanici>>? _aramaSonucu;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _appbarOlustur(),
      body: _aramaSonucu != null ? sonuclariGetir() : aramaYok(),
    );
  }

  AppBar _appbarOlustur() {
    return AppBar(
        titleSpacing: 0.0, //kenarlardan boşluk bırakma
        backgroundColor: Colors.white,
        title: TextFormField(
          onFieldSubmitted: (girilenDeger) {
            setState(() {
              _aramaSonucu = FireStoreServisi().kullaniciAra(girilenDeger);
            });
          },
          controller: _aramaKontroller,
          decoration: InputDecoration(
            prefixIcon: Icon(
              Icons.search,
              size: 30,
            ),
            suffixIcon: IconButton(
                onPressed: () {
                  _aramaKontroller.clear();
                  setState(() {
                    _aramaSonucu = null;
                  });
                },
                icon: Icon(Icons.clear)),
            border: InputBorder.none,
            fillColor: Colors.white,
            filled: true,
            hintText: "Kullanıcı Ara...",
            contentPadding: EdgeInsets.only(top: 16.0),
          ),
        ));
  }

  aramaYok() {
    return Center(child: Text("Kullanici Ara"));
  }

  sonuclariGetir() {
    return FutureBuilder<List<Kullanici>>(
      future: _aramaSonucu,
      builder: (context, AsyncSnapshot<List<Kullanici>> snapshot) {
        if (!snapshot.hasData) {
          return Center(child: CircularProgressIndicator());
        }
        if (snapshot.data!.length == 0) {
          return Center(child: Text("Bu arama için sonuç bulunamadı"));
        }

        return ListView.builder(
            itemCount: snapshot.data!.length,
            itemBuilder: (context, index) {
              Kullanici kullanici = snapshot.data![index];

              return kullaniciSatiri(kullanici);
            });
      },
    );
  }

  kullaniciSatiri(Kullanici kullanici) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => Profil(
                      profilSahibiId: kullanici.id,
                    )));
      },
      child: ListTile(
        leading: CircleAvatar(
          backgroundImage: NetworkImage(kullanici.fotoUrl!),
        ),
        title: Text(
          kullanici.kullaniciAdi!,
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
