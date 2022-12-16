import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:pet_adopt/servisler/yetkilendirmeservisi.dart';
import 'package:pet_adopt/yonlendirme.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Provider<YetkilendirmeServisi>(
      create: (_) => YetkilendirmeServisi(),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Evcil Hayvan Sahiplendirme',
        theme: ThemeData(
          primarySwatch: Colors.orange,
        ),
        home: Yonlendirme(),
      ),
    );
  }
}
