import 'package:flutter/material.dart';
class ListItem {
  final String text;
  final EdgeInsetsGeometry padding;

  ListItem({required this.text, this.padding = const EdgeInsets.only(right:8.0)});
}