import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class IssueTicketPage extends StatefulWidget {
  final int currentStopIndex;
  final List<String> stops;

  const IssueTicketPage({
    super.key,
    required this.currentStopIndex,
    required this.stops,
  });
  

  @override
  State<IssueTicketPage> createState() => _IssueTicketPageState();
}

class _IssueTicketPageState extends State<IssueTicketPage> {
    String? destination;
  String? selectedPaymentMethod;
  String? selectedPassType;
  List<String> passTypes = [];

  @override
  void initState() {
    super.initState();
    fetchPassTypes();
  }

  Future<void> fetchPassTypes() async {
     final doc = await FirebaseFirestore.instance
      .collection('payment_methods')
      .doc('passes')
      .get();

  if (doc.exists) {
    List<dynamic> types = doc['type']; // key should match exactly
    setState(() {
      passTypes = types.map((e) => e.toString()).toList();
    });
  }
  }

  Future<void> issueTicket() async {
    if (destination == null) {
      showMessage("Please select destination");
      return;
    }
    if (selectedPaymentMethod == null) {
      showMessage("Please select a payment method");
      return;
    }
    if (selectedPaymentMethod == 'passes' && selectedPassType == null) {
      showMessage("Please select a pass type");
      return;
    }

    final doc = await FirebaseFirestore.instance
        .collection('bus_status')
        .doc('current')
        .get();

    List<dynamic> count = doc['passengerCount'];
    int toIndex = widget.stops.indexOf(destination!);
    int fromIndex = doc['currentStop'];

    for (int i = fromIndex; i <= toIndex; i++) {
      count[i] = (count[i] as int) + 1;
    }

  await FirebaseFirestore.instance
      .collection('bus_status')
      .doc('current')
      .update({'passengerCount': count});

  ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(content: Text("✅ Ticket Issued")),
  );

  Navigator.pop(context);
}

  void showMessage(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg)),
    );
  }


  @override
  Widget build(BuildContext context) {
    List<String> destinationStops = widget.stops.sublist(widget.currentStopIndex + 1, widget.stops.length - 1);



    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        
        title: const Text("Issue Ticket",
        style : TextStyle(
          color: Colors.white,
        )
        ),
        centerTitle: true,
        ),
      body:Center(
        
        child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center, // vertical centering
          crossAxisAlignment: CrossAxisAlignment.center, // horizontal centering
          mainAxisSize: MainAxisSize.min,
          children: [
             Padding(
              padding: const EdgeInsets.only(bottom:70),
              child: Text("From : ${widget.stops[widget.currentStopIndex]}",
            style: TextStyle(
              fontSize: 20,
              color: Colors.deepOrange,
              fontWeight: FontWeight.bold,
            ),
            ),
            ),
           Padding(
                    padding: const EdgeInsets.only(bottom: 40),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 10),
                          DropdownButtonFormField<String>(
                            value: destination,
                            hint: const Text("Select Destination"),
                             decoration: InputDecoration(
                              labelText: "Destination",
                              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8), // Optional rounded corners
                                borderSide: const BorderSide(
                                  color: Colors.blue, // Border color
                                  width: 1.5,         // Border thickness
                                ),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: const BorderSide(
                                  color: Colors.blue,
                                  width: 1.5,
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: const BorderSide(
                                  color: Colors.deepPurple,
                                  width: 2,
                                ),
                              ),
                            ),
                            items: destinationStops
                                .map((stop) => DropdownMenuItem(
                                      value: stop,
                                      child: Text(stop),
                                    ))
                                .toList(),
                            onChanged: (val) => setState(() => destination = val),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                           DropdownButtonFormField<String>(
                            value: selectedPaymentMethod,
                            hint: const Text("Select Payment Method"),
                            decoration: InputDecoration(
                        labelText: "Payment Method",
                        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8), // Optional rounded corners
                          borderSide: const BorderSide(
                            color: Colors.blue, // Border color
                            width: 1.5,         // Border thickness
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(
                            color: Colors.blue,
                            width: 1.5,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(
                            color: Colors.deepPurple,
                            width: 2,
                          ),
                        ),
                      ),
              items: [
                'cash',
                'credit/debit card',
                'smartcard',
                'passes',
                'GPay'
              ]
                  .map((method) => DropdownMenuItem(
                      value: method, child: Text(method.toUpperCase())))
                  .toList(),
              onChanged: (val) {
                setState(() {
                  selectedPaymentMethod = val;
                  selectedPassType = null; // reset if payment method changes
                });
              },
            ),
            const SizedBox(height: 20),
                        ],
                      ),
                    ),

             Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
            const SizedBox(height: 20),
            if (selectedPaymentMethod == 'passes')
              DropdownButtonFormField<String>(
                value: selectedPassType,
                hint: const Text("Select Pass Type"),
                   decoration: InputDecoration(
                        labelText: "Pass Type",
                        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8), // Optional rounded corners
                          borderSide: const BorderSide(
                            color: Colors.blue, // Border color
                            width: 1.5,         // Border thickness
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(
                            color: Colors.blue,
                            width: 1.5,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(
                            color: Colors.deepPurple,
                            width: 2,
                          ),
                        ),
                      ),
                items: passTypes
                    .map((type) => DropdownMenuItem(
                          value: type,
                          child: Text(type),
                        ))
                    .toList(),
                onChanged: (val) => setState(() => selectedPassType = val),
              ),
            const SizedBox(height: 40),
                        ],
                      ),
             ),
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child:ElevatedButton(
             onPressed: issueTicket,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color.fromARGB(255, 194, 225, 251),
              ),
              child: const Text("Confirm Ticket",
              style: TextStyle(
                fontWeight: FontWeight.bold
              ),
              ),
            ),
              ),
            
          ],
        ),
      ),
      ) 
    );
  }
}
