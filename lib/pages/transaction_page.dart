import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:monvest/models/database.dart';
import 'package:monvest/models/transaction_with_category.dart';

class TransactionPage extends StatefulWidget {
  final TransactionWithCategory? transactionWithCategory;
  final DateTime selectedDate;
  const TransactionPage({
    Key? key,
    required this.transactionWithCategory,
    required this.selectedDate,
  }) : super(key: key);

  @override
  State<TransactionPage> createState() => _TransactionPageState();
}

class _TransactionPageState extends State<TransactionPage> {
  final database = AppDatabase();
  bool isExpense = true;
  late int type;
  TextEditingController amountController = TextEditingController();
  TextEditingController dateController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();
  Category? selectedCategory;

  Future insert(int amount, DateTime date, String nameDescription, int categoryId) async {
    DateTime now = DateTime.now();
    final row = await database.into(database.transactions).insertReturning(
      TransactionsCompanion.insert(
        amount: amount,
        transaction_date: date,
        name: nameDescription,
        category_id: categoryId,
        createdAt: now,
        updatedAt: now,
      ),
    );
    print("Inserted transaction: $row");
    return row;
  }

  Future<List<Category>> getAllCategories() async {
    return await database.getAllCategoriesRepo(isExpense ? 2 : 1);
  }

  Future update(int transactionId, int amount, int categoryId, DateTime transactionDate, String descriptionName) async {
    return await database.updateTransactionRepo(transactionId, amount, categoryId, transactionDate, descriptionName);
  }

  @override
  void initState() {
    super.initState();
    if (widget.transactionWithCategory != null) {
      updateTransactionView(widget.transactionWithCategory!);
    } else {
      dateController.text = DateFormat('yyyy-MM-dd').format(widget.selectedDate);
    }
    type = 2;
  }

  void updateTransactionView(TransactionWithCategory transaction) {
    amountController.text = transaction.transaction.amount.toString();
    dateController.text = DateFormat('yyyy-MM-dd').format(transaction.transaction.transaction_date);
    descriptionController.text = transaction.transaction.name;
    type = transaction.category.type;
    isExpense = (type == 2);
    selectedCategory = transaction.category;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black, // Latar belakang hitam
      appBar: AppBar(
        title: Text(
          widget.transactionWithCategory == null ? "Add Transaction" : "Edit Transaction",
          style: GoogleFonts.montserrat(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10), // Efek blur kaca
              child: Container(
                padding: EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.3), // Latar belakang hitam semi-transparan
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.2),
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
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Switch untuk Expense/Income
                    Row(
                      children: [
                        Container(
                          padding: EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Switch(
                            value: isExpense,
                            onChanged: (bool value) {
                              setState(() {
                                isExpense = value;
                                type = isExpense ? 2 : 1;
                                selectedCategory = null; // Reset kategori saat switch berubah
                              });
                            },
                            inactiveTrackColor: Colors.blue[200],
                            inactiveThumbColor: Colors.blue[600],
                            activeTrackColor: Colors.red[200],
                            activeColor: Colors.red[600],
                          ),
                        ),
                        SizedBox(width: 12),
                        Text(
                          isExpense ? 'Expense' : 'Income',
                          style: GoogleFonts.montserrat(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.white.withOpacity(0.9),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 20),
                    // Amount Input
                    TextFormField(
                      controller: amountController,
                      keyboardType: TextInputType.number,
                      style: GoogleFonts.montserrat(color: Colors.white),
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.white.withOpacity(0.1),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        labelText: "Amount",
                        labelStyle: GoogleFonts.montserrat(
                          color: Colors.white.withOpacity(0.7),
                        ),
                        prefixIcon: Icon(Icons.attach_money, color: Colors.white.withOpacity(0.7)),
                      ),
                    ),
                    SizedBox(height: 20),
                    // Description Input
                    TextFormField(
                      controller: descriptionController,
                      keyboardType: TextInputType.text,
                      style: GoogleFonts.montserrat(color: Colors.white),
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.white.withOpacity(0.1),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        labelText: "Description",
                        labelStyle: GoogleFonts.montserrat(
                          color: Colors.white.withOpacity(0.7),
                        ),
                        prefixIcon: Icon(Icons.description, color: Colors.white.withOpacity(0.7)),
                      ),
                    ),
                    SizedBox(height: 20),
                    // Category Dropdown
                    Text(
                      "Category",
                      style: GoogleFonts.montserrat(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.white.withOpacity(0.9),
                      ),
                    ),
                    SizedBox(height: 12),
                    FutureBuilder<List<Category>>(
                      future: getAllCategories(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return Center(child: CircularProgressIndicator(color: Colors.white));
                        } else if (snapshot.hasData && snapshot.data!.isNotEmpty) {
                          return Container(
                            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: DropdownButton<Category>(
                              value: selectedCategory != null && snapshot.data!.contains(selectedCategory)
                                  ? selectedCategory
                                  : snapshot.data!.first,
                              isExpanded: true,
                              icon: Icon(Icons.arrow_drop_down, color: Colors.white.withOpacity(0.7)),
                              dropdownColor: Colors.black.withOpacity(0.8),
                              underline: SizedBox(),
                              items: snapshot.data!.map((Category item) {
                                return DropdownMenuItem<Category>(
                                  value: item,
                                  child: Text(
                                    item.name,
                                    style: GoogleFonts.montserrat(
                                      color: Colors.white,
                                      fontSize: 14,
                                    ),
                                  ),
                                );
                              }).toList(),
                              onChanged: (Category? value) {
                                setState(() {
                                  selectedCategory = value;
                                });
                              },
                            ),
                          );
                        } else {
                          return Center(
                            child: Text(
                              snapshot.hasData ? "No Category Added" : "No data",
                              style: GoogleFonts.montserrat(color: Colors.white.withOpacity(0.7)),
                            ),
                          );
                        }
                      },
                    ),
                    SizedBox(height: 20),
                    // Date Picker
                    TextFormField(
                      readOnly: true,
                      controller: dateController,
                      style: GoogleFonts.montserrat(color: Colors.white),
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.white.withOpacity(0.1),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        labelText: "Date",
                        labelStyle: GoogleFonts.montserrat(
                          color: Colors.white.withOpacity(0.7),
                        ),
                        prefixIcon: Icon(Icons.calendar_today, color: Colors.white.withOpacity(0.7)),
                      ),
                      onTap: () async {
                        DateTime? pickedDate = await showDatePicker(
                          context: context,
                          initialDate: DateTime.parse(dateController.text),
                          firstDate: DateTime(2020),
                          lastDate: DateTime(2101),
                        );
                        if (pickedDate != null) {
                          String formattedDate = DateFormat('yyyy-MM-dd').format(pickedDate);
                          setState(() {
                            dateController.text = formattedDate;
                          });
                        }
                      },
                    ),
                    SizedBox(height: 24),
                    // Save Button
                    Center(
                      child: ElevatedButton(
                        onPressed: () async {
                          if (amountController.text.isNotEmpty && selectedCategory != null) {
                            try {
                              if (widget.transactionWithCategory == null) {
                                await insert(
                                  int.parse(amountController.text),
                                  DateTime.parse(dateController.text),
                                  descriptionController.text,
                                  selectedCategory!.id,
                                );
                              } else {
                                await update(
                                  widget.transactionWithCategory!.transaction.id,
                                  int.parse(amountController.text),
                                  selectedCategory!.id,
                                  DateTime.parse(dateController.text),
                                  descriptionController.text,
                                );
                              }
                              Navigator.pop(context, true);
                            } catch (e) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text("Error: Please check input data")),
                              );
                            }
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text("Please fill all fields")),
                            );
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.deepPurple[600],
                          padding: EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          "Save",
                          style: GoogleFonts.montserrat(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}