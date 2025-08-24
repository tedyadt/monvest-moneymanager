import 'package:flutter/material.dart';
import 'package:calendar_appbar/calendar_appbar.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:monvest/pages/category_page.dart';
import 'package:monvest/pages/home_page.dart';
import 'package:monvest/pages/transaction_page.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  late DateTime selectedDate;
  late List<Widget> _children;
  late int currentIndex;
  int _refreshKey = 0; // Tambahkan key untuk memicu rebuild HomePage

  @override
  void initState() {
    super.initState();
    updateView(0, DateTime.now());
  }

  void updateView(int index, DateTime? date) {
    setState(() {
      if (date != null) {
        selectedDate = DateTime.parse(DateFormat('yyyy-MM-dd').format(date));
      }
      currentIndex = index;
      _children = [
        HomePage(
          key: ValueKey(_refreshKey), // Tambahkan key untuk HomePage
          selectedDate: selectedDate,
        ),
        CategoryPage()
      ];
    });
  }

  void refreshHomePage() {
    setState(() {
      _refreshKey++; // Increment key untuk memicu rebuild HomePage
      updateView(currentIndex, selectedDate);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: (currentIndex == 0)
          ? CalendarAppBar(
              accent: Colors.deepPurple[900],
              backButton: false,
              locale: 'id',
              onDateChanged: (value) {
                setState(() {
                  selectedDate = value;
                  updateView(0, selectedDate);
                });
              },
              firstDate: DateTime.now().subtract(Duration(days: 140)),
              lastDate: DateTime.now(),
              selectedDate: selectedDate, // Gunakan selectedDate
            )
          : PreferredSize(
              child: Container(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                      vertical: 50.0, horizontal: 16.0),
                  child: Text(
                    "Category",
                    style: GoogleFonts.montserrat(
                        fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              preferredSize: Size.fromHeight(100),
            ),
      floatingActionButton: Visibility(
        visible: currentIndex == 0 ? true : false,
        child: FloatingActionButton(
          onPressed: () async {
            final result = await Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => TransactionPage(
                  transactionWithCategory: null,
                  selectedDate: selectedDate,
                ),
              ),
            );

            if (result == true) {
              refreshHomePage(); // Panggil refresh setelah insert/update
            }
          },
          backgroundColor: Colors.deepPurple[900],
          shape: const CircleBorder(),
          child: Icon(
            Icons.add,
            color: Colors.white,
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: BottomAppBar(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            IconButton(
              onPressed: () {
                updateView(0, selectedDate); // Gunakan selectedDate saat ini
              },
              icon: Icon(Icons.home),
            ),
            SizedBox(width: 30),
            IconButton(
              onPressed: () {
                updateView(1, null);
              },
              icon: Icon(Icons.list),
            ),
          ],
        ),
      ),
      body: _children[currentIndex],
    );
  }
}