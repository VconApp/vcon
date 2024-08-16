import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:productdbb/screen/product_info_screen.dart';

class JewelleryScreen extends StatefulWidget {
  @override
  _JewelleryScreenState createState() => _JewelleryScreenState();
}

class _JewelleryScreenState extends State<JewelleryScreen> {
  late Future<List<Map<String, dynamic>>> _jewelleryFuture;

  @override
  void initState() {
    super.initState();
    _jewelleryFuture = _fetchJewellery();
  }

  Future<List<Map<String, dynamic>>> _fetchJewellery() async {
    List<Map<String, dynamic>> jewelleryList = [];

    try {
      QuerySnapshot<Map<String, dynamic>> snapshot =
          await FirebaseFirestore.instance.collection('Jewellery').get();

      print(
          'Jewellery collection fetched with ${snapshot.docs.length} documents.');

      for (var doc in snapshot.docs) {
        Map<String, dynamic> jewelleryData = doc.data();
        jewelleryData['productId'] = doc.id;

        if (jewelleryData['imagePath'] != null) {
          String gsPath = jewelleryData['imagePath'];
          String imageUrl = await FirebaseStorage.instance
              .refFromURL(gsPath)
              .getDownloadURL();
          jewelleryData['imageUrl'] = imageUrl;
        } else {
          jewelleryData['imageUrl'] = null;
        }

        jewelleryList.add(jewelleryData);
      }
    } catch (e) {
      print('Error fetching jewellery: $e');
    }

    return jewelleryList;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Jewellery'),
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _jewelleryFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('No jewellery found'));
          } else {
            final jewellerys = snapshot.data!;
            return GridView.builder(
              padding: const EdgeInsets.all(8.0),
              itemCount: jewellerys.length,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
                childAspectRatio: 0.75,
              ),
              itemBuilder: (context, index) {
                final jewellery = jewellerys[index];

                double price = 0.0;
                if (jewellery.containsKey('salesPrice') &&
                    jewellery['salesPrice'] > 0) {
                  price = jewellery['salesPrice'] is int
                      ? (jewellery['salesPrice'] as int).toDouble()
                      : jewellery['salesPrice'];
                } else {
                  price = jewellery['irPrice'] is int
                      ? (jewellery['irPrice'] as int).toDouble()
                      : jewellery['irPrice'] ?? 0.0;
                }

                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ProductInformation(
                          productID: jewellery['productId'],
                        ),
                      ),
                    );
                  },
                  child: Card(
                    elevation: 4,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: ClipRRect(
                            borderRadius: BorderRadius.vertical(
                              top: Radius.circular(10),
                            ),
                            child: Image.network(
                              jewellery['imageUrl'] ?? '',
                              fit: BoxFit.cover,
                              width: double.infinity,
                              errorBuilder: (context, error, stackTrace) {
                                return Container(
                                  color: Colors.grey,
                                  child: Center(
                                    child: Icon(
                                      Icons.broken_image,
                                      size: 50,
                                      color: Colors.white,
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: SizedBox(
                            height: 40, // Fixed height for the text
                            child: Text(
                              jewellery['productName'] ?? 'Unknown',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8.0),
                          child: Text(
                            NumberFormat.currency(symbol: 'RM').format(price),
                            style: TextStyle(color: Colors.black),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          }
        },
      ),
    );
  }
}
