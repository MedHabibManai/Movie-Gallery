import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:testlearn/Providers/movie_provider.dart';
import 'package:testlearn/Providers/actor_provider.dart';
import 'package:testlearn/Providers/review_provider.dart';
import 'package:testlearn/HomePage.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => MovieProvider()),
        ChangeNotifierProvider(create: (_) => ActorProvider()),
        ChangeNotifierProvider(create: (_) => ReviewProvider()), // Add this line

      ],
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {

    return MaterialApp(home: HomePage(),debugShowCheckedModeBanner: false,);
  }
}


