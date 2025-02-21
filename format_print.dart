import 'package:blue_thermal_printer/blue_thermal_printer.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:permission_handler/permission_handler.dart';

String nama = 'Nama Pembuat';

class BuktitfPage extends StatefulWidget {
  final int saldoBaru;
  final int totalTrfBaru;
  final String noRekTujuan;
  final String namaPenerima;
  final String keterangan;
  const BuktitfPage(
      {super.key,
      required this.saldoBaru,
      required this.totalTrfBaru,
      required this.noRekTujuan,
      required this.namaPenerima,
      required this.keterangan});

  @override
  State<BuktitfPage> createState() => _BuktitfPageState();
}

class _BuktitfPageState extends State<BuktitfPage> {
  BlueThermalPrinter bluetooth = BlueThermalPrinter.instance;
  String formatToday = DateFormat("dd-MM-yyyy").format(DateTime.now());
  // Fungsi untuk memformat angka ke format Rupiah
  String formatRupiah(int number) {
    final formatCurrency = NumberFormat.currency(
        locale: 'id_ID', symbol: 'Rp. ', decimalDigits: 0);
    return formatCurrency.format(number);
  }

  @override
  void initState() {
    super.initState();
    initBluetooth();
  }

  Future<void> initBluetooth() async {
    // Meminta izin untuk akses Bluetooth
    var bluetoothStatus = await Permission.bluetooth.request();

    if (bluetoothStatus.isGranted) {
      // Periksa status Bluetooth
      bool? isConnected = await bluetooth.isConnected;
      bool? isOn = await bluetooth.isOn;

      if (isOn != null && !isOn) {
        // Tampilkan pesan untuk mengaktifkan Bluetooth
        print("Bluetooth tidak aktif, mohon aktifkan Bluetooth.");
      } else if (isConnected == null || !isConnected) {
        // Dapatkan daftar perangkat yang sudah terpasang
        List<BluetoothDevice> devices = await bluetooth.getBondedDevices();

        if (devices.isNotEmpty) {
          // Sambungkan ke perangkat pertama dalam daftar
          await bluetooth.connect(devices[0]).timeout(Duration(seconds: 300),
              onTimeout: () {
            throw Exception("Timeout: Gagal menghubungkan ke perangkat.");
          });
          ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Berhasil terhubung ke ${devices}')));
        } else {
          print("Tidak ada perangkat terpasang yang ditemukan.");
        }
      }
    } else {
      print("Izin untuk Bluetooth tidak diberikan.");
    }
  }

  void printReceipt() async {
    int totalKolom = 46;
    String formatToday = DateFormat("dd-MM-yyyy").format(DateTime.now());
    int baris1 = totalKolom - ('Tanggal Transaksi'.length + formatToday.length);
    int baris2 = totalKolom - ('Jenis Transaksi'.length + 'Transfer'.length);
    int baris3 =
        totalKolom - ('Nama Pengirim'.length + '${nama.split(' ')[0]}'.length);
    int baris4 = totalKolom -
        ('Nama Penerima'.length + '${widget.namaPnrm.split(' ')[0]}'.length);
    int baris5 =
        totalKolom - ('No. Rek Tujuan'.length + '${widget.noRekTujuan}'.length);
    int baris6 = totalKolom -
        ('Nominal Transfer'.length +
            '${formatRupiah(widget.totalTrfBaru)}'.length);
    int baris7 = totalKolom - ('Berita'.length + '${widget.keterangan}'.length);

    String format1 = 'Tanggal Transaksi' + ' ' * baris1 + formatToday;
    String format2 = 'Jenis Transaksi' + ' ' * baris2 + 'Transfer';
    String format3 = 'Nama Pengirim' + ' ' * baris3 + '${nama.split(' ')[0]}';
    String format4 =
        'Nama Penerima' + ' ' * baris4 + '${widget.namaPnrm.split(' ')[0]}';
    String format5 = 'No. Rek Tujuan' + ' ' * baris5 + '${widget.noRekTujuan}';
    String format6 = 'Nominal Transfer' +
        ' ' * baris6 +
        '${formatRupiah(widget.totalTrfBaru)}';
    String format7 = 'Berita' + ' ' * baris7 + '${widget.keterangan}';

    if (await bluetooth.isConnected ?? false) {
      bluetooth.printCustom("Nama Bank", 3, 1);
      bluetooth.printNewLine();
      bluetooth.printCustom(format1, 1, 0);
      bluetooth.printCustom(format2, 1, 0);
      bluetooth.printCustom(format3, 1, 0);
      bluetooth.printCustom(format4, 1, 0);
      bluetooth.printCustom(format5, 1, 0);
      bluetooth.printCustom(format6, 1, 0);
      bluetooth.printCustom(format7, 1, 0);
      bluetooth.printNewLine();
      bluetooth.printCustom("Dibuat oleh ...", 1, 1);
      bluetooth.printNewLine();
      bluetooth.paperCut();
    } else {
      printReceipt();
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: PreferredSize(
          preferredSize: Size.fromHeight(70),
          child: AppBar(
            toolbarHeight: 70,
            backgroundColor: Colors.blue[900],
            title: Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '123456789',
                    style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white),
                  ),
                  Text(
                    'Hi, $nama',
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
        body: Column(
          children: [
            Expanded(
              child: Container(
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Text(
                        'Transfer Berhasil!',
                        style: TextStyle(
                            fontSize: 24, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 16),
                      Icon(
                        Icons.check_circle,
                        size: 50,
                        color: Colors.green,
                      ),
                      SizedBox(height: 16),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Tanggal Transaksi',
                                style: TextStyle(fontSize: 18),
                              ),
                              Text(
                                '$formatToday',
                                style: TextStyle(fontSize: 18),
                              )
                            ],
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Jenis Transaksi',
                                style: TextStyle(fontSize: 18),
                              ),
                              Text(
                                'Transfer',
                                style: TextStyle(fontSize: 18),
                              )
                            ],
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Nama Pengirim',
                                style: TextStyle(fontSize: 18),
                              ),
                              Text(
                                '${nama.split(' ')[0]}',
                                style: TextStyle(fontSize: 18),
                              )
                            ],
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Nama Penerima',
                                style: TextStyle(fontSize: 18),
                              ),
                              Text(
                                '${widget.namaPnrm.split(' ')[0]}',
                                style: TextStyle(fontSize: 18),
                              )
                            ],
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'No. Rekening Tujuan',
                                style: TextStyle(fontSize: 18),
                              ),
                              Text(
                                '${widget.noRekTujuan}',
                                style: TextStyle(fontSize: 18),
                              )
                            ],
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Nominal Transfer',
                                style: TextStyle(fontSize: 18),
                              ),
                              Text(
                                '${formatRupiah(widget.totalTrfBaru)}',
                                style: TextStyle(fontSize: 18),
                              )
                            ],
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Berita',
                                style: TextStyle(fontSize: 18),
                              ),
                              Text(
                                '${widget.keterangan}',
                                style: TextStyle(fontSize: 18),
                              )
                            ],
                          ),
                        ],
                      ),
                      SizedBox(height: 32),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                        ),
                        onPressed: () {
                          printReceipt();
                          Navigator.pop(context, widget.saldoBaru);
                        },
                        child: Text('Cetak dan Kembali',
                            style: TextStyle(color: Colors.white)),
                      ),
                    ],
                  ),
                ),
              ),
            ),
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
