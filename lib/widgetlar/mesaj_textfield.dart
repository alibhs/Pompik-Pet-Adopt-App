import 'package:flutter/material.dart';
import 'package:pet_adopt/servisler/firestoreservisi.dart';

class MesajTextField extends StatefulWidget {
  MesajTextField({
    Key? key,
    this.kullaniciId,
    this.profilSahibiId,
  }) : super(key: key);

  final String? kullaniciId;
  final String? profilSahibiId;

  @override
  State<MesajTextField> createState() => _MesajTextFieldState();
}

class _MesajTextFieldState extends State<MesajTextField> {
  TextEditingController _kontrolKumandasi = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.pink[50],
      padding: EdgeInsetsDirectional.all(12),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _kontrolKumandasi,
              decoration: InputDecoration(
                  hintText: "Mesaj...",
                  fillColor: Colors.grey[200],
                  filled: true,
                  border: OutlineInputBorder(
                      borderSide: BorderSide(width: 0),
                      gapPadding: 10,
                      borderRadius: BorderRadius.circular(25))),
            ),
          ),
          SizedBox(
            width: 20,
          ),
          GestureDetector(
            onTap: () async {
              String mesaj = _kontrolKumandasi.text;
              _kontrolKumandasi.clear();
              FireStoreServisi().mesajOlustur(
                  widget.kullaniciId!, widget.profilSahibiId!, mesaj);
              FireStoreServisi()
                  .mesajAl(widget.kullaniciId!, widget.profilSahibiId!, mesaj);
            },
            child: Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                  shape: BoxShape.circle, color: Colors.orange[400]),
              child: Icon(
                Icons.send,
                color: Colors.white,
              ),
            ),
          )
        ],
      ),
    );
  }
}
