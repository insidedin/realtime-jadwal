import 'dart:async';
import 'package:flutter/material.dart';
import '../models/jadwal.dart';
import '../service/service_jadwal.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final JadwalService _service = JadwalService();
  late Timer _timer;

  @override
  void initState() {
    super.initState();
    // Timer untuk update status setiap 1 menit
    _timer = Timer.periodic(const Duration(minutes: 1), (_) {
      setState(() {});
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Realtime Jadwal Kereta"),
        centerTitle: true,
        backgroundColor: Colors.blueAccent,
      ),
      body: StreamBuilder<List<JadwalKereta>>(
        stream: _service.getJadwalRealtime(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(child: Text("Terjadi kesalahan memuat data"));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final jadwals = snapshot.data ?? [];

          if (jadwals.isEmpty) {
            return const Center(child: Text("Belum ada jadwal tersedia"));
          }

          return ListView.builder(
            itemCount: jadwals.length,
            itemBuilder: (context, index) {
              final jadwal = jadwals[index];
              final status = TimeHelper.getStatus(jadwal.start, jadwal.end);

              return Card(
                margin: const EdgeInsets.all(10),
                elevation: 4,
                child: ExpansionTile(
                  title: Text(
                    jadwal.direction,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("${jadwal.start} - ${jadwal.end}"),
                      const SizedBox(height: 4),
                      Text(
                        "Status: $status",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: status == "Belum berangkat"
                              ? Colors.blue
                              : status == "Sedang dalam perjalanan"
                                  ? Colors.orange
                                  : Colors.green,
                        ),
                      ),
                    ],
                  ),
                  children: jadwal.stasiun.map((stasiun) {
                    return ListTile(
                      leading: const Icon(Icons.train),
                      title: Text(stasiun.nama),
                      trailing: Text(stasiun.waktu),
                    );
                  }).toList(),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
