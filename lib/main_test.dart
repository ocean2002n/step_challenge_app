import 'package:flutter/material.dart';

void main() {
  runApp(TestApp());
}

class TestApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Test App',
      home: Scaffold(
        appBar: AppBar(
          title: Text('Test App'),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('APP 正常運行！'),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  print('按鈕被點擊');
                },
                child: Text('測試按鈕'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}