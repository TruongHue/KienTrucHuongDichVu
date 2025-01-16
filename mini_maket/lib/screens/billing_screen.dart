import 'package:flutter/material.dart';

class BillingScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Billing')),
      body: Center(
        child: Column(
          children: [
            Text("Product List"),
            ElevatedButton(onPressed: () {}, child: Text("Add to Bill")),
            ElevatedButton(onPressed: () {}, child: Text("Generate Invoice")),
          ],
        ),
      ),
    );
  }
}
