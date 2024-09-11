import 'package:flutter/material.dart';
class HomePageItem extends StatelessWidget {
  final String text;

  final EdgeInsetsGeometry padding;
  final VoidCallback onTap;
  const HomePageItem({required this.text, this.padding = const EdgeInsets.only(right: 8), required this.onTap} );

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap:onTap,
      child: Padding(
        padding: padding,
        child: Container(
          color: Colors.green,
          height: 300,
          width: 400,
          child: Center(
            child: Text(
              text,
              style: const TextStyle(color: Colors.white, fontSize: 20),
            ),
          ),
        ),
      ),
    );
  }
}