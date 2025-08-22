import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:monvest/models/transaction_with_category.dart';
import 'package:monvest/models/database.dart';

class HomePage extends StatefulWidget {
  final DateTime selectedDate;
  const HomePage({Key? key, required this.selectedDate}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final database = AppDatabase();
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: SafeArea(
          child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
              padding: const EdgeInsets.all(16),
              child: Container(
                child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(children: [
                        Container(
                          child: Icon(Icons.download, color: Colors.blue),
                          decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(6)),
                        ),
                        SizedBox(
                          width: 10,
                        ),
                        Column(
                          children: [
                            Text(
                              "Income",
                              style: GoogleFonts.montserrat(
                                  fontSize: 12, color: Colors.white),
                            ),
                            SizedBox(
                              height: 10,
                            ),
                            Text("Rp.400.000",
                                style: GoogleFonts.montserrat(
                                    fontSize: 15, color: Colors.white)),
                          ],
                        )
                      ]),
                      Row(children: [
                        Container(
                          child: Icon(Icons.upload, color: Colors.red),
                          decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(6)),
                        ),
                        SizedBox(
                          width: 10,
                        ),
                        Column(
                          children: [
                            Text(
                              "Outcome",
                              style: GoogleFonts.montserrat(
                                  fontSize: 12, color: Colors.white),
                            ),
                            SizedBox(
                              height: 10,
                            ),
                            Text("Rp.300.000",
                                style: GoogleFonts.montserrat(
                                    fontSize: 15, color: Colors.white)),
                          ],
                        )
                      ])
                    ]),
                width: double.infinity,
                padding: EdgeInsets.all(30),
                decoration: BoxDecoration(
                  color: Colors.grey[800],
                  borderRadius: BorderRadius.circular(20),
                ),
              )),
          // text transaksi
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              'Transaksi',
              style: GoogleFonts.montserrat(
                  fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ),
          StreamBuilder<List<TransactionWithCategory>>(
            stream: database.getTransactionByDate(widget.selectedDate),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator());
              } else {
                if (snapshot.hasData) {
                  if (snapshot.data!.length > 0) {
                    return ListView.builder(
                      shrinkWrap: true,
                      itemCount: snapshot.data!.length,
                      itemBuilder: (context, index) {
                        return Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Card(
                            elevation: 6,
                            child: ListTile(
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.edit),
                                  SizedBox(width: 6),
                                  Icon(Icons.delete),
                                ],
                              ),
                              title: Text('Rp.' +
                                  snapshot.data![index].transaction.amount
                                      .toString()),
                              subtitle: Text(
                                  snapshot.data![index].category.name +
                                      '(' +
                                      snapshot.data![index].transaction.name +
                                      ')'),
                              leading: Container(
                                child: Icon(Icons.download, color: Colors.blue),
                                decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(6)),
                              ),
                            ),
                          ),
                        );
                      },
                    );
                  } else {
                    return Center(child: Text("No transaction found"));
                  }
                } else {
                  return Center(child: Text("No data"));
                }
              }
            },
          ),
          // list transaksi
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Card(
              elevation: 6,
              child: ListTile(
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.edit),
                    SizedBox(width: 6),
                    Icon(Icons.delete),
                  ],
                ),
                title: Text('Rp.20.000'),
                subtitle: Text('makan random'),
                leading: Container(
                  child: Icon(Icons.download, color: Colors.blue),
                  decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(6)),
                ),
              ),
            ),
          )
        ],
      )),
    );
  }
}
