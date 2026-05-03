import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class TripService {
  final _trips = FirebaseFirestore.instance.collection('trips');

  Future<void> createTrip({
    required String name,
    required String destination,
    required DateTimeRange dateRange,
    required double budgetLimit,
    required List<String> memberIds,
  }) async {
    await _trips.add({
      'name': name,
      'destination': destination,
      'startDate': Timestamp.fromDate(dateRange.start),
      'endDate': Timestamp.fromDate(dateRange.end),
      'memberIds': memberIds
    });
  }
}