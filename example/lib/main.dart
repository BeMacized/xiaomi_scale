import 'package:flutter/material.dart';
import 'package:xiaomi_scale_example/measurement-pane.dart';
import 'package:xiaomi_scale_example/raw-data-pane.dart';
import 'package:xiaomi_scale_example/scanning-pane.dart';

void main() {
  runApp(ScaleApp());
}

class ScaleApp extends StatefulWidget {
  @override
  _ScaleAppState createState() => _ScaleAppState();
}

class _ScaleAppState extends State<ScaleApp> {
  int bottomSelectedIndex = 0;

  PageController pageController = PageController(
    initialPage: 0,
    keepPage: true,
  );

  List<BottomNavigationBarItem> buildBottomNavBarItems() {
    return [
      BottomNavigationBarItem(
        icon: new Icon(Icons.timeline),
        title: new Text('Measurements'),
      ),
      BottomNavigationBarItem(
        icon: new Icon(Icons.search),
        title: new Text('Scanning'),
      ),
      BottomNavigationBarItem(
          icon: Icon(Icons.description), title: Text('Raw Data'))
    ];
  }

  void pageChanged(int index) {
    setState(() {
      bottomSelectedIndex = index;
    });
  }

  void bottomTapped(int index) {
    setState(() {
      bottomSelectedIndex = index;
      pageController.animateToPage(index,
          duration: Duration(milliseconds: 500), curve: Curves.ease);
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: Text('Scale Example App')),
        body: PageView(
          controller: pageController,
          onPageChanged: (index) {
            pageChanged(index);
          },
          children: <Widget>[
            MeasurementPane(),
            ScanningPane(),
            RawDataPane(),
          ],
        ),
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: bottomSelectedIndex,
          onTap: (index) {
            bottomTapped(index);
          },
          items: buildBottomNavBarItems(),
        ),
      ),
    );
  }
}
