import 'package:cloud_firestore/cloud_firestore.dart';

// Creating Trip Planner Database

final CollectionReference _users = 
  FirebaseFirestore.instance.collection('users');

final CollectionReference _trips = 
  FirebaseFirestore.instance.collection('trips');



