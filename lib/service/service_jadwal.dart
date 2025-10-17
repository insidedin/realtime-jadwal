import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/jadwal.dart';
import 'package:rxdart/rxdart.dart';

class JadwalService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Mengambil data jadwal dari dua rute (BANDARA_DJKA dan DJKA_BANDARA)
  /// secara realtime, lalu menggabungkannya menjadi satu list.
  Stream<List<JadwalKereta>> getJadwalRealtime() {
    final bandaraDjkaStream = _firestore
        .collection('jadwal')
        .doc('BANDARA_DJKA')
        .collection('schedule')
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => JadwalKereta.fromFirestore(doc.data()))
              .toList(),
        );

    final djkaBandaraStream = _firestore
        .collection('jadwal')
        .doc('DJKA_BANDARA')
        .collection('schedule')
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => JadwalKereta.fromFirestore(doc.data()))
              .toList(),
        );

    return Rx.combineLatest2<
      List<JadwalKereta>,
      List<JadwalKereta>,
      List<JadwalKereta>
    >(
      bandaraDjkaStream,
      djkaBandaraStream,
      (bandaraDjka, djkaBandara) => [...bandaraDjka, ...djkaBandara],
    );
  }
}
