import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shopping_app/core/helpers/app_functions.dart';

class FavoriteService {
  static Future<void> toggleFavorite(
    String productId,
    Map<String, dynamic> productData,
  ) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    try {
      bool isConnected = await isConnectedToInternet();
      if (!isConnected) {
        throw 'No internet connection';
      }

      final favDocRef = FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('favorites')
          .doc(productId);

      final doc = await favDocRef.get();

      if (doc.exists) {
        await favDocRef.delete();
      } else {
        await favDocRef.set(productData);
      }
    } catch (e) {
      print('Error toggling favorite: $e');
      throw 'Error: Could not update favorite. Please try again later.';
    }
  }

  static Future<bool> checkIfFavorite(String productId) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return false;

    try {
      bool isConnected = await isConnectedToInternet();
      if (!isConnected) {
        throw 'No internet connection';
      }

      final favDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('favorites')
          .doc(productId)
          .get();

      return favDoc.exists;
    } catch (e) {
      print('Error checking favorite: $e');
      return false;
    }
  }
}
