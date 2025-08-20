import 'package:flutter/material.dart';
import 'package:calendar_appbar/calendar_appbar.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:monvest/pages/category_page.dart';
import 'package:monvest/pages/home_page.dart';
import 'package:monvest/pages/transaction_page.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  final List<Widget> _children = <Widget>[HomePage(), CategoryPage()];
  int currentIndex = 0;

  void onTabTapped(int index) {
    setState(() {
      currentIndex = index;
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
                onDateChanged: (value) => print(value),
                firstDate: DateTime.now().subtract(Duration(days: 140)),
                lastDate: DateTime.now(),
                selectedDate: DateTime.now(),
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
                )),
                preferredSize: Size.fromHeight(100)),
        floatingActionButton: Visibility(
          visible: currentIndex == 0 ? true : false,
          child: FloatingActionButton(
            onPressed: () {
              Navigator.of(context)
                  .push(MaterialPageRoute(
                    builder: (context) => TransactionPage(),
                  ))
                  .then((value) => setState(() {}));
            },
            backgroundColor: Colors.deepPurple[900],
            shape: const CircleBorder(),
            child: Icon(
              Icons.add,
              color: Colors.white,
            ),
          ),
        ),
        body: _children[currentIndex],
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
        bottomNavigationBar: BottomAppBar(
          child:
              Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
            IconButton(
              onPressed: () {
                onTabTapped(0);
              },
              icon: Icon(Icons.home),
            ),
            SizedBox(
              width: 30,
            ),
            IconButton(
                onPressed: () {
                  onTabTapped(1);
                },
                icon: Icon(Icons.list))
          ]),
        ));
  }
}
