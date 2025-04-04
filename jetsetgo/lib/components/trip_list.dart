import 'package:flutter/material.dart';
import 'package:jetsetgo/components/trip_card.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:jetsetgo/pages/trip_profile.dart'; // Import the TripScreen

class TripList extends StatelessWidget {
  const TripList({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser!;

    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid) // Fetch data for the current user
          .collection('trip') // Access the trip subcollection
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(child: Text('No trips found.'));
        }

        //getting trip documents from Firestore
        final trips = snapshot.data!.docs;

        return ListView(
          children: trips.map((trip) {
            // fetching nested tripID document for each trip
            return StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('users')
                  .doc(user.uid)
                  .collection('trip')
                  .doc(trip.id) // Use the trip document ID
                  .collection('tripID') // Access the tripID subcollection
                  .snapshots(),
              builder: (context, tripIdSnapshot) {
                if (tripIdSnapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (tripIdSnapshot.hasError) {
                  return Center(child: Text('Error: ${tripIdSnapshot.error}'));
                }

                if (!tripIdSnapshot.hasData || tripIdSnapshot.data!.docs.isEmpty) {
                  return const Center(child: Text('No trip details found.'));
                }

                // get the details from the tripID document
                final tripDetails = tripIdSnapshot.data!.docs.first.data() as Map<String, dynamic>;

                return TripCard(
                  destination: '${tripDetails['City']}, ${tripDetails['Country']}',
                  dates: '${tripDetails['Month']} ${tripDetails['DateLeaving']} - ${tripDetails['DateReturning']}, 2025',
                  duration: '${tripDetails['Duration']} days',
                  onTap: () {
                    // Nnavigate to TripScreen with trip details
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => TripScreen(
                          tripName: '${tripDetails['City']}, ${tripDetails['Country']}',
                          tripDates: '${tripDetails['Month']} ${tripDetails['DateLeaving']} - ${tripDetails['DateReturning']}, 2025',
                          tripLocation: '${tripDetails['City']}, ${tripDetails['Country']}',
                          tripId: trip.id,
                        ),
                      ),
                    );
                  },
                );
              },
            );
          }).toList(),
        );
      },
    );
  }
}
