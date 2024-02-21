import 'dart:async';
import 'dart:io';
import 'package:image/image.dart' as img;
import 'package:bluetooth_thermal_printer/bluetooth_thermal_printer.dart';
import 'package:esc_pos_utils/esc_pos_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_application_2/src/pages/print_page.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
  }

  bool connected = false;
  List availableBluetoothDevices = [];
  String _customerName = 'Faisal Ismail';
  String _Receiptno = '101359';
  String _ReceiptDate = '21/2/2024';
  String _Amount = '156900';
  String _bank = 'Meezan';
  String _chequeNO = '789456';
  String _donationtype = 'SADQA FOR KARACHI IDARA';
  String _user = 'farhan';
  String _Datetime = '21/2/2024  11:01 AM';

  Future<void> getBluetooth() async {
    final List? bluetooths = await BluetoothThermalPrinter.getBluetooths;
    print("Print $bluetooths");
    setState(() {
      availableBluetoothDevices = bluetooths!;
    });
  }

  Future<void> setConnect(String mac) async {
    final String? result = await BluetoothThermalPrinter.connect(mac);
    final String? result2 = await BluetoothThermalPrinter.connectionStatus;
    print("state conneected $result");
    if (result == "true") {
      setState(() {
        connected = true;
      });
    } else {
      print('result2  $result2');
    }
  }

  Future<void> printTicket() async {
    String? isConnected = await BluetoothThermalPrinter.connectionStatus;
    if (isConnected == "true") {
      CapabilityProfile profile = await CapabilityProfile.load();
      List<int> bytes = await getTicket2();
      final result = await BluetoothThermalPrinter.writeBytes(bytes);
      print("Print $result");
    } else {
      print('not connected');
      //Hadnle Not Connected Senario
    }
  }

  Future<void> printGraphics() async {
    String? isConnected = await BluetoothThermalPrinter.connectionStatus;
    if (isConnected == "true") {
      List<int> bytes = await getGraphicsTicket();
      final result = await BluetoothThermalPrinter.writeBytes(bytes);
      print("Print $result");
    } else {
      //Hadnle Not Connected Senario
    }
  }

  Future<List<int>> getGraphicsTicket() async {
    List<int> bytes = [];

    CapabilityProfile profile = await CapabilityProfile.load();
    final generator = Generator(PaperSize.mm80, profile);

    // Print QR Code using native function
    bytes += generator.qrcode('example.com');

    bytes += generator.hr();

    // Print Barcode using native function
    final List<int> barData = [1, 2, 3, 4, 5, 6, 7, 8, 9, 0, 4];
    bytes += generator.barcode(Barcode.upcA(barData));

    bytes += generator.cut();

    return bytes;
  }

  Future<List<int>> testTicket(
      PaperSize paper, CapabilityProfile profile) async {
    final Generator generator = Generator(paper, profile);
    List<int> bytes = [];

    bytes += generator.text(
        'Regular: aA bB cC dD eE fF gG hH iI jJ kK lL mM nN oO pP qQ rR sS tT uU vV wW xX yY zZ');
    // bytes += generator.text('Special 1: àÀ èÈ éÉ ûÛ üÜ çÇ ôÔ',
    //     styles: PosStyles(codeTable: PosCodeTable.westEur));
    // bytes += generator.text('Special 2: blåbærgrød',
    //     styles: PosStyles(codeTable: PosCodeTable.westEur));

    bytes += generator.text('Bold text', styles: PosStyles(bold: true));
    bytes += generator.text('Reverse text', styles: PosStyles(reverse: true));
    bytes += generator.text('Underlined text',
        styles: PosStyles(underline: true), linesAfter: 1);
    bytes +=
        generator.text('Align left', styles: PosStyles(align: PosAlign.left));
    bytes += generator.text('Align center',
        styles: PosStyles(align: PosAlign.center));
    bytes += generator.text('Align right',
        styles: PosStyles(align: PosAlign.right), linesAfter: 1);

    bytes += generator.row([
      PosColumn(
        text: 'col3',
        width: 3,
        styles: PosStyles(align: PosAlign.center, underline: true),
      ),
      PosColumn(
        text: 'col6',
        width: 6,
        styles: PosStyles(align: PosAlign.center, underline: true),
      ),
      PosColumn(
        text: 'col3',
        width: 3,
        styles: PosStyles(align: PosAlign.center, underline: true),
      ),
    ]);

    bytes += generator.text('Text size 200%',
        styles: PosStyles(
          height: PosTextSize.size2,
          width: PosTextSize.size2,
        ));

    // Print image
    final ByteData data = await rootBundle.load('assets/images/thermal.jpg');
    final Uint8List buf = data.buffer.asUint8List();
    final img.Image image = img.decodeImage(buf)!;
    bytes += generator.image(image);
    // Print image using alternative commands
    // bytes += generator.imageRaster(image);
    // bytes += generator.imageRaster(image, imageFn: PosImageFn.graphics);

    // Print barcode
    final List<int> barData = [1, 2, 3, 4, 5, 6, 7, 8, 9, 0, 4];
    bytes += generator.barcode(Barcode.upcA(barData));

    // Print mixed (chinese + latin) text. Only for printers supporting Kanji mode
    // bytes += generator.text(
    //   'hello ! 中文字 # world @ éphémère &',
    //   styles: PosStyles(codeTable: PosCodeTable.westEur),
    //   containsChinese: true,
    // );

    bytes += generator.feed(2);

    bytes += generator.cut();
    return bytes;
  }

  Future<List<int>> getTicket() async {
    List<int> bytes = [];
    CapabilityProfile profile = await CapabilityProfile.load();
    final generator = Generator(PaperSize.mm80, profile);

    bytes += generator.text("Demo Shop",
        styles: PosStyles(
          align: PosAlign.center,
          height: PosTextSize.size2,
          width: PosTextSize.size2,
        ),
        linesAfter: 1);

//     final ByteData data = await rootBundle.load('assets/images/download.png');
//     final Uint8List bytes2 = data.buffer.asUint8List();
//     final img.Image image1 = img.decodeImage(bytes2)!;
// // Using `ESC *`
// //    generator.image(image1);
//     //  generator.imageRaster(image1);
//     generator.imageRaster(image1, imageFn: PosImageFn.graphics);

    bytes += generator.text(
        "18th Main Road, 2nd Phase, J. P. Nagar, Bengaluru, Karnataka 560078",
        styles: PosStyles(align: PosAlign.center));
    bytes += generator.text('Tel: +919591708470',
        styles: PosStyles(align: PosAlign.center));

    bytes += generator.hr();
    bytes += generator.row([
      PosColumn(
          text: 'No',
          width: 1,
          styles: PosStyles(align: PosAlign.left, bold: true)),
      PosColumn(
          text: 'Item',
          width: 5,
          styles: PosStyles(align: PosAlign.left, bold: true)),
      PosColumn(
          text: 'Price',
          width: 2,
          styles: PosStyles(align: PosAlign.center, bold: true)),
      PosColumn(
          text: 'Qty',
          width: 2,
          styles: PosStyles(align: PosAlign.center, bold: true)),
      PosColumn(
          text: 'Total',
          width: 2,
          styles: PosStyles(align: PosAlign.right, bold: true)),
    ]);

    bytes += generator.row([
      PosColumn(text: "1", width: 1),
      PosColumn(
          text: "Tea",
          width: 5,
          styles: PosStyles(
            align: PosAlign.left,
          )),
      PosColumn(
          text: "10",
          width: 2,
          styles: PosStyles(
            align: PosAlign.center,
          )),
      PosColumn(text: "1", width: 2, styles: PosStyles(align: PosAlign.center)),
      PosColumn(text: "10", width: 2, styles: PosStyles(align: PosAlign.right)),
    ]);

    bytes += generator.row([
      PosColumn(text: "2", width: 1),
      PosColumn(
          text: "Sada Dosa",
          width: 5,
          styles: PosStyles(
            align: PosAlign.left,
          )),
      PosColumn(
          text: "30",
          width: 2,
          styles: PosStyles(
            align: PosAlign.center,
          )),
      PosColumn(text: "1", width: 2, styles: PosStyles(align: PosAlign.center)),
      PosColumn(text: "30", width: 2, styles: PosStyles(align: PosAlign.right)),
    ]);

    bytes += generator.row([
      PosColumn(text: "3", width: 1),
      PosColumn(
          text: "Masala Dosa",
          width: 5,
          styles: PosStyles(
            align: PosAlign.left,
          )),
      PosColumn(
          text: "50",
          width: 2,
          styles: PosStyles(
            align: PosAlign.center,
          )),
      PosColumn(text: "1", width: 2, styles: PosStyles(align: PosAlign.center)),
      PosColumn(text: "50", width: 2, styles: PosStyles(align: PosAlign.right)),
    ]);

    bytes += generator.row([
      PosColumn(text: "4", width: 1),
      PosColumn(
          text: "Rova Dosa",
          width: 5,
          styles: PosStyles(
            align: PosAlign.left,
          )),
      PosColumn(
          text: "70",
          width: 2,
          styles: PosStyles(
            align: PosAlign.center,
          )),
      PosColumn(text: "1", width: 2, styles: PosStyles(align: PosAlign.center)),
      PosColumn(text: "70", width: 2, styles: PosStyles(align: PosAlign.right)),
    ]);

    bytes += generator.hr();

    bytes += generator.row([
      PosColumn(
          text: 'TOTAL',
          width: 6,
          styles: PosStyles(
            align: PosAlign.left,
            height: PosTextSize.size4,
            width: PosTextSize.size4,
          )),
      PosColumn(
          text: "160",
          width: 6,
          styles: PosStyles(
            align: PosAlign.right,
            height: PosTextSize.size4,
            width: PosTextSize.size4,
          )),
    ]);

    bytes += generator.hr(ch: '=', linesAfter: 1);

    // ticket.feed(2);
    bytes += generator.text('Thank you!',
        styles: PosStyles(align: PosAlign.center, bold: true));

    bytes += generator.text("26-11-2020 15:22:45",
        styles: PosStyles(align: PosAlign.center), linesAfter: 1);

    bytes += generator.text(
        'Note: Goods once sold will not be taken back or exchanged.',
        styles: PosStyles(align: PosAlign.center, bold: false));
    bytes += generator.cut();
    return bytes;
  }

  Future<List<int>> getTicket2() async {
    List<int> bytes = [];
    CapabilityProfile profile = await CapabilityProfile.load();
    final generator = Generator(PaperSize.mm80, profile);

    // bytes += generator.text("    ",
    //     styles: PosStyles(
    //       align: PosAlign.center,
    //       height: PosTextSize.size2,
    //       width: PosTextSize.size2,
    //     ),
    //     linesAfter: 1);

    try {
      print('image k ly aya ho');
      final ByteData data = await rootBundle.load('assets/images/thermal.jpg');
      final Uint8List buf = data.buffer.asUint8List();
      final img.Image image = img.decodeImage(buf)!;
      bytes += generator.image(image);
      print('ban gayi h');
    } catch (e) {
      print(e);
      print('image nhi ayi ho');
    }

// // Using `ESC *`
// //    generator.image(image1);
//     //  generator.imageRaster(image1);
//     generator.imageRaster(image1, imageFn: PosImageFn.graphics);

    bytes += generator.text("Receipt No    :    $_Receiptno",
        styles: PosStyles(align: PosAlign.left));
    bytes += generator.text('Receipt Date  :    $_ReceiptDate',
        styles: PosStyles(align: PosAlign.left));
    bytes += generator.text('Received From :    $_customerName',
        styles: PosStyles(align: PosAlign.left));
    bytes += generator.text('Total Rupees  :    $_Amount',
        styles: PosStyles(align: PosAlign.left));
    bytes += generator.text('Donation Type :    $_donationtype',
        styles: PosStyles(align: PosAlign.left));

    bytes += generator.hr();
    bytes += generator.row([
      // PosColumn(
      //     text: '',
      //     width: 1,
      //     styles: PosStyles(align: PosAlign.left, bold: true)),
      PosColumn(
          text: 'Chq No  ',
          width: 3,
          styles: PosStyles(align: PosAlign.left, bold: true)),
      PosColumn(
          text: 'Date       ',
          width: 3,
          styles: PosStyles(align: PosAlign.center, bold: true)),
      PosColumn(
          text: 'Bank ',
          width: 3,
          styles: PosStyles(align: PosAlign.center, bold: true)),
      PosColumn(
          text: 'Amount  ',
          width: 3,
          styles: PosStyles(align: PosAlign.right, bold: true)),
    ]);

    bytes += generator.hr();
    bytes += generator.row([
      PosColumn(
          text: "$_chequeNO",
          width: 3,
          styles: PosStyles(
            align: PosAlign.left,
          )),
      PosColumn(
          text: "$_ReceiptDate  ",
          width: 3,
          styles: PosStyles(
            align: PosAlign.center,
          )),
      PosColumn(
          text: "  $_bank",
          width: 3,
          styles: PosStyles(align: PosAlign.center)),
      PosColumn(
          text: "$_Amount  ",
          width: 3,
          styles: PosStyles(align: PosAlign.right)),
    ]);

    bytes += generator.hr();

    bytes += generator.text('                                         ',
        styles: PosStyles(align: PosAlign.left));
    bytes += generator.text('Bank Name     : United Bank Limited (UBL)',
        styles: PosStyles(align: PosAlign.left));
    bytes += generator.text('Branch Code   : 1679',
        styles: PosStyles(align: PosAlign.left));
    bytes += generator.text('Swift Code    : UNILPKKA',
        styles: PosStyles(align: PosAlign.left));
    bytes += generator.text('IBAN          : PK41 UNIL 0109 0002 4523 8264',
        styles: PosStyles(align: PosAlign.left));

    bytes += generator.hr();

    // bytes += generator.text(
    //     "Note : Receipt valid request to realization            of Cheque",
    //     styles: PosStyles(align: PosAlign.left));
    bytes += generator.text('User          : $_user',
        styles: PosStyles(height: PosTextSize.size1, align: PosAlign.left));
    bytes += generator.text('Date & Time   : $_Datetime',
        styles: PosStyles(height: PosTextSize.size1, align: PosAlign.left));
    // bytes += generator.row([
    //   PosColumn(text: "2", width: 1),
    //   PosColumn(
    //       text: "Sada Dosa",
    //       width: 5,
    //       styles: PosStyles(
    //         align: PosAlign.left,
    //       )),
    //   PosColumn(
    //       text: "30",
    //       width: 2,
    //       styles: PosStyles(
    //         align: PosAlign.center,
    //       )),
    //   PosColumn(text: "1", width: 2, styles: PosStyles(align: PosAlign.center)),
    //   PosColumn(text: "30", width: 2, styles: PosStyles(align: PosAlign.right)),
    // ]);

    // bytes += generator.row([
    //   PosColumn(text: "3", width: 1),
    //   PosColumn(
    //       text: "Masala Dosa",
    //       width: 5,
    //       styles: PosStyles(
    //         align: PosAlign.left,
    //       )),
    //   PosColumn(
    //       text: "50",
    //       width: 2,
    //       styles: PosStyles(
    //         align: PosAlign.center,
    //       )),
    //   PosColumn(text: "1", width: 2, styles: PosStyles(align: PosAlign.center)),
    //   PosColumn(text: "50", width: 2, styles: PosStyles(align: PosAlign.right)),
    // ]);

    // bytes += generator.row([
    //   PosColumn(text: "4", width: 1),
    //   PosColumn(
    //       text: "Rova Dosa",
    //       width: 5,
    //       styles: PosStyles(
    //         align: PosAlign.left,
    //       )),
    //   PosColumn(
    //       text: "70",
    //       width: 2,
    //       styles: PosStyles(
    //         align: PosAlign.center,
    //       )),
    //   PosColumn(text: "1", width: 2, styles: PosStyles(align: PosAlign.center)),
    //   PosColumn(text: "70", width: 2, styles: PosStyles(align: PosAlign.right)),
    // ]);

    // bytes += generator.hr();

    // bytes += generator.row([
    //   PosColumn(
    //       text: 'TOTAL',
    //       width: 6,
    //       styles: PosStyles(
    //         align: PosAlign.left,
    //         height: PosTextSize.size4,
    //         width: PosTextSize.size4,
    //       )),
    //   PosColumn(
    //       text: "160",
    //       width: 6,
    //       styles: PosStyles(
    //         align: PosAlign.right,
    //         height: PosTextSize.size4,
    //         width: PosTextSize.size4,
    //       )),
    // ]);

    // bytes += generator.hr(ch: '=', linesAfter: 1);

    // // ticket.feed(2);
    // bytes += generator.text('Thank you!',
    //     styles: PosStyles(align: PosAlign.center, bold: true));

    // bytes += generator.text("26-11-2020 15:22:45",
    //     styles: PosStyles(align: PosAlign.center), linesAfter: 1);

    // bytes += generator.text(
    //     'Note: Goods once sold will not be taken back or exchanged.',
    //     styles: PosStyles(align: PosAlign.center, bold: false));
    bytes += generator.cut();
    return bytes;
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData.dark(),
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Bluetooth Thermal Printer Demo'),
        ),
        body: Container(
          padding: EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Search Paired Bluetooth"),
              TextButton(
                onPressed: () {
                  this.getBluetooth();
                },
                child: Text("Search"),
              ),
              Container(
                height: 200,
                child: ListView.builder(
                  itemCount: availableBluetoothDevices.length > 0
                      ? availableBluetoothDevices.length
                      : 0,
                  itemBuilder: (context, index) {
                    return ListTile(
                      onTap: () {
                        String select = availableBluetoothDevices[index];
                        List list = select.split("#");
                        // String name = list[0];
                        String mac = list[1];
                        this.setConnect(mac);
                      },
                      title: Text('${availableBluetoothDevices[index]}'),
                      subtitle: Text("Click to connect"),
                    );
                  },
                ),
              ),
              SizedBox(
                height: 30,
              ),
              TextButton(
                onPressed: connected ? this.printGraphics : null,
                child: Text("Print"),
              ),
              TextButton(
                onPressed: connected ? this.printTicket : null,
                child: Text("Print Ticket"),
              ),
              TextButton(
                onPressed: () {
                  //  getimage();
                },
                child: Text("Print Ticket 2"),
              ),
            ],
          ),
        ),
        floatingActionButton: FloatingActionButton(onPressed: () {}),
      ),
    );
  }
}
