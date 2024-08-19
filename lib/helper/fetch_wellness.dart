// fetch_watch.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

Future<List<Map<String, dynamic>>> fetchWellness() async {
  List<Map<String, dynamic>> wellnessList = [];

  try {
    var amezcuaFuture = FirebaseFirestore.instance
        .collection('products')
        .doc('wellness')
        .collection('amezcuaCollection')
        .get();

    var snapshots = await Future.wait([amezcuaFuture]);

    for (var doc in snapshots[0].docs) {
      Map<String, dynamic> wellnessData = doc.data();
      wellnessData['productId'] = doc.id;
      wellnessData = await fetchImageUrl(wellnessData);
      wellnessList.add(wellnessData);
    }
  } catch (e) {
    print('Error fetching watches: $e');
  }

  return wellnessList;
}

Future<Map<String, dynamic>> fetchImageUrl(
    Map<String, dynamic> wellnessData) async {
  if (wellnessData.containsKey('imagePath') &&
      wellnessData['imagePath'] != null) {
    String gsPath = wellnessData['imagePath'];
    try {
      String imageUrl =
          await FirebaseStorage.instance.refFromURL(gsPath).getDownloadURL();
      wellnessData['imageUrl'] = imageUrl;
    } catch (e) {
      print('Error fetching image URL for $gsPath: $e');
      wellnessData['imageUrl'] = null;
    }
  } else {
    wellnessData['imageUrl'] = null;
  }
  return wellnessData;
}
