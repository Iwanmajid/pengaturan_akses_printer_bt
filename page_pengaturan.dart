import 'package:blue_thermal_printer/blue_thermal_printer.dart';
import 'package:flutter/material.dart';

String nama = 'Rekayasa Perangkat Lunak';

class PengaturanPage extends StatefulWidget {
  const PengaturanPage({super.key});

  @override
  State<PengaturanPage> createState() => _PengaturanPageState();
}

class _PengaturanPageState extends State<PengaturanPage> {
  BlueThermalPrinter bluetooth = BlueThermalPrinter.instance;
  List<BluetoothDevice> devices = [];
  BluetoothDevice? selectedDevice;
  bool isConnected = false;

  @override
  void initState() {
    // TODO: implement initState
    initBluetooth();
    super.initState();
  }

  Future<void> initBluetooth() async {
    // Cek apakah Bluetooth aktif
    bool? isOn = await bluetooth.isOn;
    if (isOn == true) {
      try {
        // Dapatkan perangkat yang sudah terpasang
        devices = await bluetooth.getBondedDevices();
      } catch (e) {
        print("Error getting bonded devices: $e");
      }
      setState(() {});
    } else {
      print("Bluetooth is off");
    }
  }

  // Fungsi untuk menghubungkan ke perangkat Bluetooth yang dipilih
  Future<void> connectToDevice(BluetoothDevice device) async {
    try {
      await bluetooth.connect(device);
      setState(() {
        selectedDevice = device;
        isConnected = true;
      });
      // Tampilkan SnackBar sukses
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Berhasil terhubung ke perangkat ${device.name}"),
          backgroundColor: Colors.green,
        ),
      );
      print("Terhubung ke perangkat ${device.name}");
    } catch (e) {
      print("Gagal terhubung ke perangkat: $e");
      setState(() {
        isConnected = false;
      });
      // Tampilkan SnackBar gagal
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Gagal menghubungkan ke perangkat ${device.name}"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // Fungsi untuk memutuskan koneksi dari perangkat
  Future<void> disconnectDevice() async {
    await bluetooth.disconnect();
    setState(() {
      selectedDevice = null;
      isConnected = false;
    });
    // Tampilkan SnackBar putus koneksi
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content:
            Text("Koneksi ke perangkat ${selectedDevice?.name ?? ''} terputus"),
        backgroundColor: Colors.orange,
      ),
    );
  }

  // Fungsi untuk me-*refresh* daftar perangkat
  Future<void> refreshDevices() async {
    setState(() {
      devices = [];
    });
    await initBluetooth();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("Daftar perangkat berhasil diperbarui"),
        backgroundColor: Colors.blue,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: PreferredSize(
          preferredSize: Size.fromHeight(60),
          child: AppBar(
            toolbarHeight: 60,
            backgroundColor: Colors.blue[900],
            title: Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Text(
                      'Pengaturan',
                      style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Refresh ->',
                        style: TextStyle(fontSize: 16),
                      ),
                      IconButton(
                          onPressed: () {
                            refreshDevices();
                          },
                          icon: Icon(Icons.refresh))
                    ],
                  ),
                ],
              ),
            ),
            isConnected
                ? ListTile(
                    title: Text("Terhubung ke: ${selectedDevice?.name ?? ''}"),
                    subtitle: Text("Status: Terhubung"),
                    trailing: ElevatedButton(
                      onPressed: disconnectDevice,
                      child: Text("Putuskan"),
                    ),
                  )
                : Text("Tidak ada perangkat yang terhubung"),
            Divider(),
            Expanded(
              child: ListView.builder(
                itemCount: devices.length,
                itemBuilder: (context, index) {
                  BluetoothDevice device = devices[index];
                  return ListTile(
                    title: Text(device.name ?? ''),
                    subtitle: Text(device.address ?? ''),
                    trailing: ElevatedButton(
                      onPressed: () {
                        connectToDevice(device);
                      },
                      child: Text("Hubungkan"),
                    ),
                  );
                },
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text(
                'Kembali',
                style: TextStyle(color: Colors.white),
              ),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
            ),
            SizedBox(height: 20,)
          ],
        ),
        bottomNavigationBar: Container(
          color: Colors.blue[900],
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '$nama',
                  style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
