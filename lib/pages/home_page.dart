import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:monvest/models/transaction_with_category.dart';
import 'package:monvest/models/database.dart';
import 'package:monvest/pages/transaction_page.dart';

class HomePage extends StatefulWidget {
  final DateTime selectedDate;
  const HomePage({Key? key, required this.selectedDate}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final database = AppDatabase();
  late DateTime selectedDate;

  bool isExpense = true;

  @override

  void initState() {
    super.initState();
    selectedDate = widget.selectedDate;

    print("HomePage init with selectedDate: $selectedDate"); // Inisialisasi dari widget
  }

 
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- Income & Outcome Box ---
            StreamBuilder<Map<String, int>>(
              stream: database.getMonthlySummary(widget.selectedDate),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return Center(child: CircularProgressIndicator());
                }

                final income = snapshot.data!["income"] ?? 0;
                final outcome = snapshot.data!["outcome"] ?? 0;

                return Padding(
                  padding: const EdgeInsets.all(16),
                  child: Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(30),
                    decoration: BoxDecoration(
                      color: Colors.grey[800],
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(children: [
                          Container(
                            child: Icon(Icons.download, color: Colors.blue),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(6),
                            ),
                          ),
                          SizedBox(width: 10),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("Income",
                                  style: GoogleFonts.montserrat(
                                      fontSize: 12, color: Colors.white)),
                              SizedBox(height: 10),
                              Text("Rp.$income",
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
                              borderRadius: BorderRadius.circular(6),
                            ),
                          ),
                          SizedBox(width: 10),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("Outcome",
                                  style: GoogleFonts.montserrat(
                                      fontSize: 12, color: Colors.white)),
                              SizedBox(height: 10),
                              Text("Rp.$outcome",
                                  style: GoogleFonts.montserrat(
                                      fontSize: 15, color: Colors.white)),
                            ],
                          )
                        ])
                      ],
                    ),
                  ),
                );
              },
            ),

            // --- Judul Transaksi ---
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                'Transaksi',
                style: GoogleFonts.montserrat(
                    fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ),

            // --- List Transaksi ---
            StreamBuilder<List<TransactionWithCategory>>(
          
              stream: database.getTransactionByDate(widget.selectedDate),
              builder: (context, snapshot) {
                print("Stream emitted data: ${snapshot.data?.length} transactions for $selectedDate");
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                } else if (snapshot.hasData) {
                  final data = snapshot.data!;
                  print("Transactions: ${data.map((t) => t.transaction.toString())}");
                  if (data.isEmpty) {
                    return Center(child: Text("No transaction found"));
                  }

                  return ListView.builder(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    itemCount: data.length,
                    itemBuilder: (context, index) {
                      return Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Card(
                          elevation: 6,
                          child: ListTile(
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: Icon(Icons.edit),
                                  onPressed: () async {
                                    final result = await Navigator.of(context).push(
                                      MaterialPageRoute(
                                        builder: (context) => TransactionPage(
                                          transactionWithCategory: data[index],
                                          selectedDate: widget.selectedDate,
                                          
                                      ),

                                      
                                    ));
                                    if (result == true) {
                                      setState(() {}); // Memaksa rebuild HomePage
                                    }
                                  },
                                ),
                                SizedBox(width: 6),
                                IconButton(
                                  icon: Icon(Icons.delete),
                                  onPressed: () async {
                                    await database.deleteTransactionRepo(
                                        data[index].transaction.id);
                                    // Tidak perlu setState, StreamBuilder auto refresh
                                  },
                                ),
                              ],
                            ),
                            title: Text('Rp.${data[index].transaction.amount}'),
                            subtitle: Text(
                              '${data[index].category.name} (${data[index].transaction.name})',
                            ),
                            leading: Container(
                              child: (data[index].category.type == 2)
                                  ? Icon(Icons.upload, color: Colors.red)
                                  : Icon(Icons.download, color: Colors.blue),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(6),
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  );
                } else {
                  return Center(child: Text("No data"));
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
