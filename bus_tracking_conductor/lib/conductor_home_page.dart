import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'issue_ticket_page.dart';


class ConductorHomePage extends StatefulWidget {
  const ConductorHomePage({super.key});

  @override
  State<ConductorHomePage> createState() => _ConductorHomePageState();
}

class _ConductorHomePageState extends State<ConductorHomePage> {
  List<String> stops = [];
  int currentStopIndex = 0;
  bool isLoading = true;
  bool isOnline = true;

  String get currentStop => stops.isNotEmpty ? stops[currentStopIndex] : "Loading...";

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
      setState(() {
        isOnline = true;
      });
    }, onError: (error) {
      setState(() {
        isOnline = false;
      });
    });
  }

  Future<void> fetchStops() async {
    final stopDoc = await FirebaseFirestore.instance
        .collection('bus_stops')
        .doc('list')
        .get();

    if (stopDoc.exists) {
      List<dynamic> data = stopDoc.data()?['stops'] ?? [];
      stops = data.map((e) => e.toString()).toList();
    }

    final busStatus = await FirebaseFirestore.instance
        .collection('bus_status')
        .doc('current')
        .get();

    if (busStatus.exists) {
      currentStopIndex = busStatus.data()?['currentStop'] ?? 0;
    }

    setState(() {
      isLoading = false;
    });
  }

  void _nextStop() async {
    if (currentStopIndex < stops.length - 1) {
      setState(() {
        currentStopIndex++;
      });

      await FirebaseFirestore.instance
          .collection('bus_status')
          .doc('current')
          .update({'currentStop': currentStopIndex});
    }
  }

  void _resetTrip() async {
    setState(() {
      currentStopIndex = 0;
    });

    await FirebaseFirestore.instance
        .collection('bus_status')
        .doc('current')
        .set({
      'currentStop': 0,
      'passengerCount': List.filled(stops.length, 0),
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("🧹 Trip Reset Successfully")),
    );
  }

  void _issueTicket() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => IssueTicketPage(
          currentStopIndex: currentStopIndex,
          stops: stops,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        title: const Text("Conductor App",
        style: TextStyle(
          color: Colors.white
          )
        ),
        centerTitle: true,
        ),

      body: Center(
      child: Padding(
        padding: const EdgeInsets.only(bottom:100),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center, // vertical centering
          crossAxisAlignment: CrossAxisAlignment.center, // horizontal centering
          mainAxisSize: MainAxisSize.min,
          children: [
            Text("Current Stop: $currentStop", style: const TextStyle(fontSize: 18,
            color: Colors.deepOrange,
            fontWeight: FontWeight.bold
            )),
            const SizedBox(height: 20),
            Padding(
              padding:const EdgeInsets.only(bottom:15),
              child:ElevatedButton(
              onPressed: currentStopIndex == 0 ? null : _issueTicket,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color.fromARGB(255, 194, 225, 251),
              ),
              child: const Text("Issue Ticket",
               style: TextStyle(
                fontWeight: FontWeight.bold
              )
              ),
              
            ),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom:15),
               child:ElevatedButton(
              onPressed: _nextStop,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color.fromARGB(255, 194, 225, 251),
              ),
              child: const Text("Next Stop",
               style: TextStyle(
                fontWeight: FontWeight.bold
              )
              ),
            ),
            ),
             Padding(
              padding: const EdgeInsets.only(bottom:15),
              child: ElevatedButton(
              onPressed: _resetTrip, 
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color.fromARGB(255, 194, 225, 251),
              ),
              child: const Text("Reset Trip",
              style: TextStyle(
                fontWeight: FontWeight.bold
              ),),
            ),
            ),
             Padding(
              padding: const EdgeInsets.only(bottom:15),
              child: ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color.fromARGB(255, 194, 225, 251),
              ),
              child: const Text("Exit",
               style: TextStyle(
                fontWeight: FontWeight.bold
              )
              ),
            ),
            ),
           
            const SizedBox(height: 40),
            Text(
              isOnline ? "🟢 You are connected to Firebase" : "🔴 You are not connected to Firebase",
              style: TextStyle(color: isOnline ? Colors.green : Colors.red),
            ),
          ],
        ),
      ),
      ),
    );
  }
}
