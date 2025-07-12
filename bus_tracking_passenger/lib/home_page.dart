import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'status_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<String> stops = [];
  String? selectedStop;
  bool isOnline = true;

  @override
  void initState() {
    super.initState();
    fetchStops();
    monitorConnection();
  }

  void monitorConnection() {
    FirebaseFirestore.instance
        .collection('bus_status')
        .snapshots()
        .listen((_) {
      setState(() => isOnline = true);
    }, onError: (_) {
      setState(() => isOnline = false);
    });
  }

  Future<void> fetchStops() async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection('bus_stops')
          .doc('list')
          .get();
      if (doc.exists) {
        List<dynamic> data = doc['stops'];
        setState(() {
          stops = data.map((e) => e.toString()).toList();
        });
      }
    } catch (e) {
      setState(() => isOnline = false);
    }
  }

  void _confirmStop() {
    if (selectedStop == null) return;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => StatusPage(selectedStop: selectedStop!),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        title: const Text("Passenger App",
      style: TextStyle(
        color: Colors.white,
      ),
      ),
      centerTitle: true,
      ),
      body: Center(
        child :Padding( 
          padding:  EdgeInsets.all(16),
        child: Column(
         mainAxisAlignment: MainAxisAlignment.center, // vertical centering
          crossAxisAlignment: CrossAxisAlignment.center, // horizontal centering
          mainAxisSize: MainAxisSize.min,
          children: [
            
            const Text("Select your stop:",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold,color: Colors.deepOrange)),
            const SizedBox(height: 10),
            DropdownButtonFormField<String>(
              value: selectedStop,
              hint: const Text("Select Stop"),
              items: stops
              .sublist(1, stops.length - 1) // Removes first and last
              .map((stop) => DropdownMenuItem(
                    value: stop,
                    child: Text(stop),
                  ))
              .toList(),

              onChanged: (val) => setState(() => selectedStop = val),
              decoration: InputDecoration(
                              labelText: "Stops",
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
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _confirmStop,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color.fromARGB(255, 194, 225, 251),
              ),
              child: const Text("Confirm",
              style: TextStyle(
                fontWeight: FontWeight.bold,
              ),),
            ),
            Padding(padding:  EdgeInsets.all(30),
            child: Text(
              isOnline
                  ? "🟢  You are connected to Firebase"
                  : "🔴 You are not connected to Firebase",
              style: TextStyle(color: isOnline ? Colors.green : Colors.red),
            ),
            )
           
          ],
        ),
      ),
      ),
    );
  }
}
