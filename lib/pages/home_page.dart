import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:monvest/models/transaction_with_category.dart';
import 'package:monvest/models/database.dart';
import 'dart:ui';
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

    print(
        "HomePage init with selectedDate: $selectedDate"); // Inisialisasi dari widget
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
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(
                          sigmaX: 8, sigmaY: 8), // Efek blur kaca
                      child: Container(
                        width: double.infinity,
                        padding: EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(
                              0.8), // Latar belakang hitam semi-transparan
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color:
                                Colors.white.withOpacity(0.2), // Border halus
                            width: 1.5,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.15),
                              blurRadius: 12,
                              offset: Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            // Income Section
                            Row(
                              children: [
                                Container(
                                  padding: EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: Colors.blue[100]!.withOpacity(0.3),
                                    borderRadius: BorderRadius.circular(10),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.1),
                                        blurRadius: 4,
                                        offset: Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  child: Icon(
                                    Icons.download,
                                    color: Colors.blue[400],
                                    size: 24,
                                  ),
                                ),
                                SizedBox(width: 12),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "Income",
                                      style: GoogleFonts.montserrat(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.white.withOpacity(0.9),
                                      ),
                                    ),
                                    SizedBox(height: 8),
                                    Text(
                                      'Rp ${income.toStringAsFixed(0)}',
                                      style: GoogleFonts.montserrat(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.blue[200],
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            // Outcome Section
                            Row(
                              children: [
                                Container(
                                  padding: EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: Colors.red[100]!.withOpacity(0.3),
                                    borderRadius: BorderRadius.circular(10),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.1),
                                        blurRadius: 4,
                                        offset: Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  child: Icon(
                                    Icons.upload,
                                    color: Colors.red[400],
                                    size: 24,
                                  ),
                                ),
                                SizedBox(width: 12),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "Outcome",
                                      style: GoogleFonts.montserrat(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.white.withOpacity(0.9),
                                      ),
                                    ),
                                    SizedBox(height: 8),
                                    Text(
                                      'Rp ${outcome.toStringAsFixed(0)}',
                                      style: GoogleFonts.montserrat(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.red[200],
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
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
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                } else if (snapshot.hasData) {
                  final data = snapshot.data!;

                  if (data.isEmpty) {
                    return Center(child: Text("No transaction found"));
                  }

                  return ListView.builder(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    itemCount: data.length,
                    itemBuilder: (context, index) {
                      final transaction = data[index].transaction;
                      final category = data[index].category;
                      final isExpense = category.type == 2;

                      return Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 8),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: BackdropFilter(
                            filter: ImageFilter.blur(
                                sigmaX: 10, sigmaY: 10), // Efek blur kaca
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(
                                    0.15), // Latar belakang semi-transparan
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: Colors.white
                                      .withOpacity(0.3), // Border halus
                                  width: 1.5,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.grey.withOpacity(0.2),
                                    blurRadius: 10,
                                    offset: Offset(0, 5),
                                  ),
                                ],
                              ),
                              child: InkWell(
                                borderRadius: BorderRadius.circular(16),
                                onTap: () {
                                  // Optional: Tambahkan aksi saat card diklik
                                },
                                child: ListTile(
                                  contentPadding: EdgeInsets.symmetric(
                                      horizontal: 16, vertical: 12),
                                  trailing: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      IconButton(
                                        icon: Icon(
                                          Icons.edit,
                                          color: Colors.grey[600],
                                          size: 22,
                                        ),
                                        onPressed: () async {
                                          final result =
                                              await Navigator.of(context).push(
                                            MaterialPageRoute(
                                              builder: (context) =>
                                                  TransactionPage(
                                                transactionWithCategory:
                                                    data[index],
                                                selectedDate:
                                                    widget.selectedDate,
                                              ),
                                            ),
                                          );
                                          if (result == true) {
                                            setState(
                                                () {}); // Memaksa rebuild HomePage
                                          }
                                        },
                                      ),
                                      IconButton(
                                        icon: Icon(
                                          Icons.delete,
                                          color: Colors.red[400],
                                          size: 22,
                                        ),
                                        onPressed: () async {
                                          await database.deleteTransactionRepo(
                                              transaction.id);
                                          // StreamBuilder akan otomatis refresh
                                        },
                                      ),
                                    ],
                                  ),
                                  title: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 4, horizontal: 10),
                                        decoration: BoxDecoration(
                                          color: isExpense
                                              ? Colors.red[100]!
                                                  .withOpacity(0.3)
                                              : Colors.blue[100]!
                                                  .withOpacity(0.3),
                                          borderRadius:
                                              BorderRadius.circular(8),
                                        ),
                                        child: Text(
                                          category.name,
                                          style: TextStyle(
                                            fontWeight: FontWeight.w600,
                                            fontSize: 12,
                                            color: isExpense
                                                ? Colors.red[900]
                                                : Colors.blue[900],
                                          ),
                                        ),
                                      ),
                                      SizedBox(height: 8),
                                      Text(
                                        transaction.name,
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w500,
                                          color: Colors.black87,
                                        ),
                                      ),
                                      SizedBox(height: 6),
                                      Text(
                                        'Rp ${transaction.amount.toStringAsFixed(0)}',
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                          color: isExpense
                                              ? Colors.red[700]
                                              : Colors.blue[700],
                                        ),
                                      ),
                                    ],
                                  ),
                                  leading: Container(
                                    padding: EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: isExpense
                                          ? Colors.red[100]!.withOpacity(0.3)
                                          : Colors.blue[100]!.withOpacity(0.3),
                                      borderRadius: BorderRadius.circular(8),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(0.1),
                                          blurRadius: 4,
                                          offset: Offset(0, 2),
                                        ),
                                      ],
                                    ),
                                    child: Icon(
                                      isExpense ? Icons.upload : Icons.download,
                                      color: isExpense
                                          ? Colors.red[700]
                                          : Colors.blue[700],
                                      size: 24,
                                    ),
                                  ),
                                ),
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
