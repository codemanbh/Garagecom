import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:garagecom/helpers/apiHelper.dart';
import '../models/Api.dart';
import '../data/symbols.dart';

class TestPage extends StatefulWidget {
  const TestPage({super.key});

  @override
  State<TestPage> createState() => _TestPageState();
}

class _TestPageState extends State<TestPage> {
  TextStyle stl({bool isBold = false}) {
    return TextStyle(
        fontSize: 16,
        color: const Color.fromARGB(211, 255, 255, 255),
        fontWeight: isBold ? FontWeight.bold : FontWeight.normal);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text("Test Page"),
        ),
        body: ListView.builder(
            itemCount: symbols.length,
            itemBuilder: (context, index) {
              return ListTile(
                title: Text(
                  symbols[index]['symbol_name'],
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color.fromARGB(232, 255, 255, 255),
                  ),
                ),
                subtitle: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      symbols[index]['description'],
                      style: stl(),
                    ),
                    Text('Possible causes:', style: stl(isBold: true)),
                    ...symbols[index]['possible_causes']
                        .map<Widget>((c) => Text(
                              '- $c',
                              style: stl(),
                            ))
                        .toList(),
                    Text('Recommended fix:', style: stl(isBold: true)),
                    Text(symbols[index]['recommended_fix'], style: stl()),
                  ],
                ),
                leading:ApiHelper.image('Battery.jpg', 'api/Posts/GetAttachmentTest')
                
             
              );
            }));
  }
}
