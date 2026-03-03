// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables, prefer_const_constructors_in_immutables

import 'package:flutter/material.dart';

int itemCount = 1000;

class ImageListScreen extends StatelessWidget {
  ImageListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Naive Image List'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: List.generate(itemCount, (index) {
            return SizedBox(
              height: 200,
              width: double.infinity,
              child: Image.network(
                'https://picsum.photos/seed/$index/600/400',
                fit: BoxFit.cover,
              ),
            );
          }),
        ),
      ),
    );
  }
}
