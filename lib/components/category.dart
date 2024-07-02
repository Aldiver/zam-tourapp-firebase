import 'package:flutter/material.dart';

class Category extends StatefulWidget {
  const Category({super.key});

  @override
  State<Category> createState() => _CategoryState();
}

class _CategoryState extends State<Category> {
  get index => null;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 40,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemBuilder: (context, index){
          return const Chip(
            label: Text("Random")
          );
        }, 
        separatorBuilder: (context, index) => 
          const Padding(padding: EdgeInsets.only(right: 10)), 
        itemCount: 10)
    );
  }
}