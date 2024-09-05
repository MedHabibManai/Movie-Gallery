
import 'package:flutter/material.dart';
import 'Widgets.dart';
import 'models.dart';
class MostPopularPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Most Popular')),
      body: Center(
        child: Text('Content of Most Popular Page'),
      ),
    );
  }
}