const functions = require("firebase-functions");
const admin = require('firebase-admin');
admin.initializeApp();

// exports.ilanlariGetir = functions.firestore.document('aboneler/{aboneOlunanId}/kullanicininAboneleri/{aboneOlanKullanici}').onCreate(async (snapshots, context) => { 
//     const aboneOlunanId = context.params.aboneOlunanId;
//     const aboneOlanKullaniciId = context.params.aboneOlanKullanici;


   
//    const ilanlarSnapshot = await admin.firestore().collection("gonderiler").doc(aboneOlunanId).collection("kullaniciGonderileri").get();
//    ilanlarSnapshot.forEach((doc)=>{
//     if(doc.exists){
//        const gonderiId = doc.id;
//         const gonderiData = doc.data();

//         admin.firestore().collection("akislar").doc(aboneOlanKullaniciId).collection("kullaniciAkisGonderileri").doc(gonderiId).set(gonderiData);
//     }
//    });
//  });


 /*
 exports.kayitSilindi = functions.firestore.document('deneme/{docId}').onDelete((snapshots, context) => { 
    admin.firestore().collection("günlük").add({
        "aciklama": "Deneme koleksiyonundan kayıt silindi."
    });
 });


 exports.kayitGuncellendi = functions.firestore.document('deneme/{docId}').onUpdate((change, context) => { 
    admin.firestore().collection("günlük").add({
        "aciklama": "Deneme koleksiyonunda kayıt güncellendi."
    });
 });
 

 exports.yazmaGerceklesti = functions.firestore.document('deneme/{docId}').onWrite((change, context) => { 
    admin.firestore().collection("günlük").add({
        "aciklama": "Deneme koleksiyonunda veri ekleme, silme, güncelleme işlemlerinden biri gerçekleşti."
    });
 });
*/
