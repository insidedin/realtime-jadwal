class Stasiun {
  final String nama;
  final String waktu;

  Stasiun({required this.nama, required this.waktu});

  factory Stasiun.fromMap(Map<String, dynamic> data) {
    return Stasiun(nama: data['nama'] ?? '', waktu: data['waktu'] ?? '');
  }

  Map<String, dynamic> toMap() {
    return {'nama': nama, 'waktu': waktu};
  }
}

class JadwalKereta {
  final String direction;
  final String start;
  final String end;
  final List<Stasiun> stasiun;

  JadwalKereta({
    required this.direction,
    required this.start,
    required this.end,
    required this.stasiun,
  });

  factory JadwalKereta.fromFirestore(Map<String, dynamic> data) {
    return JadwalKereta(
      direction: data['direction'] ?? '',
      start: data['start'] ?? '',
      end: data['end'] ?? '',
      stasiun:
          (data['stasiun'] as List<dynamic>?)
              ?.map((e) => Stasiun.fromMap(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'direction': direction,
      'start': start,
      'end': end,
      'stasiun': stasiun.map((e) => e.toMap()).toList(),
    };
  }
}

class TimeHelper {
  static String getStatus(String start, String end) {
    final now = DateTime.now();

    try {
      final startParts = start.split(':');
      final endParts = end.split(':');

      final startTime = DateTime(
        now.year,
        now.month,
        now.day,
        int.parse(startParts[0]),
        int.parse(startParts[1]),
      );

      final endTime = DateTime(
        now.year,
        now.month,
        now.day,
        int.parse(endParts[0]),
        int.parse(endParts[1]),
      );

      if (now.isBefore(startTime)) {
        return "Belum berangkat";
      } else if (now.isAfter(endTime)) {
        return "Tiba di tujuan";
      } else {
        return "Sedang dalam perjalanan";
      }
    } catch (e) {
      return "Format waktu tidak valid";
    }
  }
}
