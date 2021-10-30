import 'package:flutter/material.dart';
import 'package:xiaomi_scale_example/measurement_pane.dart';
import 'package:xiaomi_scale_example/raw_data_pane.dart';
import 'package:xiaomi_scale_example/scanning_pane.dart';

void main() {
  runApp(ScaleApp());
}

class ScaleApp extends StatefulWidget {
  @override
  _ScaleAppState createState() => _ScaleAppState();
}

class _ScaleAppState extends State<ScaleApp> {
  var _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Scale Example App'),
        ),
        body: IndexedStack(
          index: _currentIndex,
          children: [
            MeasurementPane(),
            ScanningPane(),
            RawDataPane(),
          ],
        ),
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: _bottomTapped,
          selectedItemColor: Colors.black,
          unselectedItemColor: Colors.black26,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.timeline),
              label: 'Measurements',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.search),
              label: 'Scanning',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.description),
              label: 'Raw Data',
            ),
          ],
        ),
      ),
    );
  }

  void _bottomTapped(int index) => setState(() => _currentIndex = index);
}
