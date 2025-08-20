import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

class TransactionPage extends StatefulWidget {
  const TransactionPage({super.key});

  @override
  State<TransactionPage> createState() => _TransactionPageState();
}

class _TransactionPageState extends State<TransactionPage> {
  bool isExpense = true;
  List<String> categories = ['Makanan', 'Paketan', 'Bensin'];
  late String dropdownValue = categories.first;
  TextEditingController dateController = TextEditingController();
  @override
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
              child:
                  Text("Category", style: GoogleFonts.montserrat(fontSize: 14)),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: DropdownButton<String>(
                value: dropdownValue,
                isExpanded: true,
                icon: const Icon(Icons.arrow_downward),
                items: categories.map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                onChanged: (String? value) {
                  setState(() {
                    dropdownValue = value!;
                  });
                },
              ),
            ),
            SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: TextField(
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
            Center(child: ElevatedButton(onPressed: () {}, child: Text("Save")))
          ],
        ),
      )),
    );
  }
}
