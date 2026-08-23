import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/listing_model.dart';

class ListingService {
  final FirebaseFirestore _firestore =
      FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _listings =>
      _firestore.collection('listings');

  Future<String> createListing(
      ListingModel listing,
      ) async {
    final doc = await _listings.add(
      listing.toMap(),
    );

    return doc.id;
  }

  Future<List<ListingModel>> getUserListings(
      String userId,
      ) async {
    final snapshot = await _listings
        .where('userId', isEqualTo: userId)
        .get();

    return snapshot.docs.map((doc) {
      return ListingModel.fromMap(
        doc.id,
        doc.data(),
      );
    }).toList();
  }

  Future<List<ListingModel>> getActiveListings() async {
    final snapshot = await _listings
        .where('status', isEqualTo: 'active')
        .get();

    return snapshot.docs.map((doc) {
      return ListingModel.fromMap(
        doc.id,
        doc.data(),
      );
    }).toList();
  }

  Future<ListingModel?> getListing(
      String listingId,
      ) async {
    final doc = await _listings
        .doc(listingId)
        .get();

    if (!doc.exists || doc.data() == null) {
      return null;
    }

    return ListingModel.fromMap(
      doc.id,
      doc.data()!,
    );
  }

  Future<void> updateListing(
      String listingId,
      Map<String, dynamic> data,
      ) async {
    await _listings
        .doc(listingId)
        .update(data);
  }

  Future<void> deleteListing(
      String listingId,
      ) async {
    await _listings
        .doc(listingId)
        .delete();
  }
}