import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class TripService {
  final _trips = FirebaseFirestore.instance.collection('trips');

  // Get trip ID
  Stream<List<Map<String, dynamic>>> getTrips() {
    return _trips
      .snapshots()
      .map((snapshot) => snapshot.docs.map((doc) => {
        'id': doc.id,
        ...doc.data(),
      }).toList());
  }

  // Create Trip
  Future<void> createTrip({
    required String name,
    required String destination,
    required DateTimeRange dateRange,
    required double budgetLimit,
    required List<String> memberIds
  }) async {
    await _trips.add({
      'name': name,
      'destination': destination,
      'startDate': Timestamp.fromDate(dateRange.start),
      'endDate': Timestamp.fromDate(dateRange.end),
      'memberIds': memberIds
    });
  }

  // Update Trip
  Future<void> updateTrip({
    required String tripID,
    required String name,
    required String destination,
    required double budgetLimit,
    required List<String> memberIds
  }) async {
    await _trips.doc(tripID).update({
      'name': name,
      'destination': destination,
      'budgetLimit': budgetLimit,
      'memberIds': memberIds

    });
  }

  // Delete 
  Future<void> deleteTrip(String tripID) async {
    await _trips.doc(tripID).delete();
  }
}