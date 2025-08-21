import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:monvest/models/database.dart';

class TransactionPage extends StatefulWidget {
  const TransactionPage({super.key});

  @override
  State<TransactionPage> createState() => _TransactionPageState();
}

class _TransactionPageState extends State<TransactionPage> {
  final database = AppDatabase();
  bool isExpense = true;
  List<String> categories = ['Makanan', 'Paketan', 'Bensin'];
  late String dropdownValue = categories.first;
  late int type;

  TextEditingController amountController = TextEditingController();
  TextEditingController dateController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();
  Category? selectedCategory;

  Future insert(int amouunt, DateTime date, String nameDescription,
      int categoryid) async {
    DateTime now = DateTime.now();
    final row = await database.into(database.transactions).insertReturning(
        TransactionsCompanion.insert(
            amount: amouunt,
            transaction_date: date,
            name: nameDescription,
            category_id: categoryid,
            createdAt: now,
            updatedAt: now));
  }

  Future<List<Category>> getAllCategories() async {
    return await database.getAllCategoriesRepo(isExpense ? 2 : 1);
  }

  @override
  void initState() {
    type = 2;
  }

  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(" Add Transaction")),
      body: SingleChildScrollView(
          child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: Switch(
                    value: isExpense,
                    onChanged: (bool value) {
                      setState(() {
                        isExpense = value;
                      });
                    },
                    inactiveTrackColor: Colors.green[200],
                    inactiveThumbColor: Colors.green,
                    activeColor: Colors.red,
                  ),
                ),
                Text(isExpense ? 'Expense' : 'Income',
                    style: GoogleFonts.montserrat(
                      fontSize: 16,
                    )),
              ],
            ),
            SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: TextFormField(
                controller: amountController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  border: UnderlineInputBorder(),
                  labelText: "Amount",
                ),
              ),
            ),
            SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: TextFormField(
                controller: descriptionController,
                keyboardType: TextInputType.text,
                decoration: InputDecoration(
                  border: UnderlineInputBorder(),
                  labelText: "Description",
                ),
              ),
            ),
            SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child:
                  Text("Category", style: GoogleFonts.montserrat(fontSize: 14)),
            ),
            SizedBox(height: 16),
            FutureBuilder<List<Category>>(
                future: getAllCategories(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  } else {
                    if (snapshot.hasData) {
                      if (snapshot.data!.length > 0) {
                        print('apa'+snapshot.toString());
                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0),
                          child: DropdownButton<Category>(
                            value: (snapshot.data!.contains(selectedCategory))
                                ? selectedCategory
                                : snapshot.data!.first,
                            isExpanded: true,
                            icon: const Icon(Icons.arrow_downward),
                            items: snapshot.data!.map((Category item) {
                              return DropdownMenuItem<Category>(
                                value: item,
                                child: Text(item.name),
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
                        return Center(child: Text("No Category Added"));
                      }
                    } else {
                      return Center(child: Text("No data"));
                    }
                  }
                }),
            SizedBox(height: 4),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: TextFormField(
                  readOnly: true,
                  controller: dateController,
                  decoration: InputDecoration(labelText: 'EnterDate'),
                  onTap: () async {
                    DateTime? pickedDate = await showDatePicker(
                        context: context,
                        initialDate: DateTime.now(),
                        firstDate: DateTime(2020),
                        lastDate: DateTime(2101));
                    if (pickedDate != null) {
                      String formattedDate =
                          DateFormat('yyyy-MM-dd').format(pickedDate);

                      setState(() {
                        dateController.text = formattedDate;
                      });
                    }
                  }),
            ),
            SizedBox(height: 16),
            Center(
                child: ElevatedButton(
                    onPressed: () {
                      insert(
                          int.parse(amountController.text),
                          DateTime.parse(dateController.text),
                          descriptionController.text,
                          selectedCategory!.id);
                          Navigator.pop(context,true);
                    },
                    child: Text("Save")))
          ],
        ),
      )),
    );
  }
}
