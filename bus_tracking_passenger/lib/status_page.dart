import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class StatusPage extends StatefulWidget {
  final String selectedStop;

  const StatusPage({super.key, required this.selectedStop});

  @override
  State<StatusPage> createState() => _StatusPageState();
}

class _StatusPageState extends State<StatusPage> {
  String currentStop = "Loading...";
  String futureStop = "Loading...";
  int expectedCount = 0;
  int currentPassengers = 0;
  int futurePassengers = 0;
  bool isOnline = true;
  bool isLastStop = true;

  List<String> stops = [];
  String statusMessage = ""; // To show "Bus not available" if needed

  Timer? timer;

  @override
  void initState() {
    super.initState();
    fetchData();
    timer = Timer.periodic(const Duration(seconds: 5), (_) => fetchData());
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  Future<void> fetchData() async {
    try {
      final stopDoc = await FirebaseFirestore.instance
          .collection('bus_stops')
          .doc('list')
          .get();
      final statusDoc = await FirebaseFirestore.instance
          .collection('bus_status')
          .doc('current')
          .get();

      if (stopDoc.exists && statusDoc.exists) {
        List<dynamic> stopData = stopDoc['stops'];
        List<String> stopNames = stopData.map((e) => e.toString()).toList();
        List<dynamic> passengerCounts = statusDoc['passengerCount'];
        int currentIndex = statusDoc['currentStop'];
        int selectedIndex = stopNames.indexOf(widget.selectedStop);

        setState(() {
          stops = stopNames;
          currentStop = stopNames[currentIndex];
          expectedCount = passengerCounts[selectedIndex];
          currentPassengers = passengerCounts[currentIndex];
          isOnline = true;
          isLastStop = selectedIndex == passengerCounts.length - 1;
          if(!isLastStop){
            futurePassengers=passengerCounts[selectedIndex+1];
            futureStop=stopNames[selectedIndex+1];
          }
          

          // Show "Bus not available" if trip not started or already passed
          if (currentIndex == 0 || currentIndex > selectedIndex) {
            statusMessage = "❌ Bus not available";
          } else {
            statusMessage = "";
          }
        });
      }
    } catch (e) {
      setState(() => isOnline = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        title: const Text("Live Bus Status",
        style: TextStyle(color: Colors.white,),),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
  body: Center(
  child: Padding(
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 32),
    child: Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          "Current Bus Stop : $currentStop",
          style: const TextStyle(
            fontSize: 23,
            fontWeight: FontWeight.bold,
            color: Colors.deepOrangeAccent
          ),
        ),
        const SizedBox(height: 20),

        if (statusMessage.isNotEmpty)
          Text(
            statusMessage,
            style: const TextStyle(fontSize: 16, color: Colors.red),
          )
        else ...[
          Text(
            "Passengers Onboard : $currentPassengers",
               style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
          ),
          const SizedBox(height: 90),
          Text("Expected Boardings:",
             style: const TextStyle(
            fontSize: 23,
            color: Color.fromARGB(255, 6, 85, 34),
            fontWeight: FontWeight.bold,
          ),
          ),
          const SizedBox(height: 20),
          Text(
            " '${widget.selectedStop}': $expectedCount",
              style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
          ),
          const SizedBox(height: 20),

          if (!isLastStop) ...[
            Text(
              " $futureStop : $futurePassengers",
                 style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
            ),
            const SizedBox(height: 20), // Extra bottom space
          ],
        ],
      ],
    ),
  ),
),


    );
  }
}
