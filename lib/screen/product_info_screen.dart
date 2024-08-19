import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:intl/intl.dart';
import 'package:vcon_testing/helper/cart_item.dart';
import 'package:vcon_testing/helper/cart_manager.dart';
import 'package:vcon_testing/screen/3dviewer_screen.dart';
import 'package:vcon_testing/screen/cart_screen.dart';
import 'package:vcon_testing/screen/checkout_screen.dart';
// import 'package:vcon_testing/screen/earring_ar_screen.dart';
import 'package:vcon_testing/screen/homepure_ar_screen.dart';
// import 'package:vcon_testing/screen/necklace_ar_page.dart';
import 'package:vcon_testing/screen/rating_screen.dart';
import 'package:vcon_testing/screen/watch_ar_screen.dart';
import 'package:vcon_testing/screen/wellness_ar_screen.dart';
import 'package:vcon_testing/helper/fetch_watch.dart';
import 'package:vcon_testing/helper/fetch_wellness.dart';

class ProductInformation extends StatelessWidget {
  final String productID;

  const ProductInformation({required this.productID, Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Product Information'),
      ),
      body: FutureBuilder<Map<String, dynamic>?>(
        future: _fetchProductData(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            print('Error loading product information: ${snapshot.error}');
            return Center(child: Text('Error loading product information'));
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            print('Product not found for productID: $productID');
            return Center(child: Text('Product not found'));
          }

          final product = snapshot.data!;
          return _buildProductDetails(context, product);
        },
      ),
      bottomNavigationBar: _buildBottomNavigationBar(context),
    );
  }

  Future<Map<String, dynamic>?> _fetchProductData() async {
    try {
      // Fetch watches and wellness data
      final watchList = await fetchWatches();
      final wellnessList = await fetchWellness();
      final jewelleryList = await fetchWellness();

      // Combine both lists
      final combinedList = [...watchList, ...wellnessList, ...jewelleryList];

      // Find the product by productID
      final product = combinedList.firstWhere(
        (item) => item['productId'] == productID,
        orElse: () => {}, // Return empty map if product not found
      );

      // If product is found, fetch its image URL
      if (product.isNotEmpty) {
        return await fetchImageUrl(product);
      }

      return null;
    } catch (e) {
      print('Error fetching product data: $e');
      return null;
    }
  }

  Future<Map<String, dynamic>> fetchImageUrl(
      Map<String, dynamic> productData) async {
    if (productData.containsKey('imagePath') &&
        productData['imagePath'] != null) {
      String gsPath = productData['imagePath'];
      try {
        String imageUrl =
            await FirebaseStorage.instance.refFromURL(gsPath).getDownloadURL();
        productData['imageUrl'] = imageUrl;
      } catch (e) {
        print('Error fetching image URL for $gsPath: $e');
        productData['imageUrl'] = null;
      }
    } else {
      productData['imageUrl'] = null;
    }
    return productData;
  }

  Widget _buildProductDetails(
      BuildContext context, Map<String, dynamic> product) {
    String name = product['productName'] ?? 'Unknown';
    double price = 0.0;
    if (product.containsKey('salesPrice') && product['salesPrice'] > 0) {
      price = product['salesPrice'] is int
          ? (product['salesPrice'] as int).toDouble()
          : product['salesPrice'];
    } else {
      price = product['irPrice'] is int
          ? (product['irPrice'] as int).toDouble()
          : product['irPrice'] ?? 0.0;
    }
    String imageUrl = product['imageUrl'] ?? '';
    String tagline = product['tagline'] ?? 'N/A';
    String description = product['description'] ?? 'No description available';

    // Category-specific fields
    String function = '';
    String diameter = '';
    String waterResistance = '';
    String movement = '';
    String assembly = '';

    String category = product['category'] ?? '';

    if (category == 'Watches') {
      function = product['function'] ?? 'N/A';
      diameter = product['diameter'] ?? 'N/A';
      waterResistance = product['waterResistance'] ?? 'N/A';
      movement = product['movement'] ?? 'N/A';
      assembly = product['assembly'] ?? 'N/A';
    } else if (category == 'Wellness') {
      // Add Wellness-specific fields here if needed
    } else if (category == 'Jewellery') {
      // Add Jewellery-specific fields here if needed
    } else if (category == 'HomePure') {
      // Add HomePure-specific fields here if needed
    }
    String getCategoryForProduct(String productID) {
      // Your logic to determine the category based on productID
      // Example placeholder logic:
      if (productID.startsWith('WN')) {
        return 'Wellness';
      } else if (productID.startsWith('J')) {
        return 'Jewellery';
      } else if (productID.startsWith('HP')) {
        return 'HomePure';
      } else if (productID.startsWith('W')) {
        return 'Watches';
      } else {
        return 'SkinCare';
      }
    }

    final NumberFormat currencyFormat = NumberFormat.currency(symbol: 'RM');

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (imageUrl.isNotEmpty)
              GestureDetector(
                onTap: () {
                  // Check if gitURL exists and is not empty
                  String? modelUrl = product['gitURL'] as String?;
                  if (modelUrl != null && modelUrl.isNotEmpty) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ModelViewerPage(
                          modelUrl: product['gitURL']!,
                          textModelUrl: product['gitText'] ??
                              '', // Provide a default empty string if 'gitText' is not available
                          productName: product['productName']!,
                        ),
                      ),
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                          content:
                              Text('3D model not available for this product')),
                    );
                  }
                },
                child: Center(
                  child: Container(
                    constraints: BoxConstraints(
                      maxHeight: 300.0,
                      maxWidth: double.infinity,
                    ),
                    child: Image.network(
                      imageUrl,
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
              ),

            SizedBox(height: 16),
            Text(name,
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            SizedBox(height: 16),
            Text(currencyFormat.format(price),
                style: TextStyle(fontSize: 20, color: Colors.black)),
            SizedBox(height: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(tagline,
                    style: TextStyle(fontSize: 20, color: Colors.black)),
                SizedBox(height: 16),
                if (category == 'Watches') ...[
                  Text('Functions',
                      style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.black)),
                  Text(function,
                      style: TextStyle(fontSize: 16, color: Colors.black)),
                  SizedBox(height: 16),
                  Text('Diameter',
                      style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.black)),
                  Text(diameter,
                      style: TextStyle(fontSize: 16, color: Colors.black)),
                  SizedBox(height: 16),
                  Text('Water Resistance',
                      style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.black)),
                  Text(waterResistance,
                      style: TextStyle(fontSize: 16, color: Colors.black)),
                  SizedBox(height: 16),
                  Text('Movement',
                      style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.black)),
                  Text(movement,
                      style: TextStyle(fontSize: 16, color: Colors.black)),
                  SizedBox(height: 16),
                  Text('Assembly',
                      style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.black)),
                  Text(assembly,
                      style: TextStyle(fontSize: 16, color: Colors.black)),
                  SizedBox(height: 16),
                ],
                if (category == 'Jewellery') ...[
                  // Add Jewellery-specific details here if needed
                ],
                if (category == 'Wellness') ...[
                  // Add Wellness-specific details here if needed
                ],
                if (category == 'HomePure') ...[
                  // Add HomePure-specific details here if needed
                ],
                SizedBox(height: 16),
                Text(description,
                    style: TextStyle(fontSize: 16, color: Colors.black)),
                SizedBox(height: 16),
              ],
            ),

            // Review bar
            _buildReviewBar(product),

            ElevatedButton(
              onPressed: () {
                String category = getCategoryForProduct(productID);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => RatingScreen(
                      productID: productID,
                      category: category,
                    ),
                  ),
                );
              },
              child: Text(
                'Add Review',
                style: TextStyle(color: Colors.black),
              ),
            ),

            SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildReviewBar(Map<String, dynamic> product) {
    List<dynamic> ratings = product['ratings'] ?? [];

    if (ratings.isEmpty) {
      return Text('No reviews yet.');
    }

    int totalReviews = ratings.length;
    double averageRating = ratings.fold<double>(0.0, (sum, item) {
          int ratingValue = item['rating'] ?? 0;
          return sum + ratingValue;
        }) /
        totalReviews;

    List<int> starCount = List.filled(5, 0);
    for (var rating in ratings) {
      int ratingValue = rating['rating'] ?? 0;
      if (ratingValue >= 1 && ratingValue <= 5) {
        starCount[ratingValue - 1]++;
      }
    }

    return Column(
      children: [
        Text(
          'Average Rating: ${averageRating.toStringAsFixed(1)}',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 10),
        Column(
          children: List.generate(5, (index) {
            int starLevel = 5 - index;
            int starRatings = starCount[starLevel - 1];
            double percentage =
                totalReviews > 0 ? starRatings / totalReviews : 0.0;

            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 4.0),
              child: Row(
                children: [
                  Text('$starLevel stars:'),
                  SizedBox(width: 8),
                  Expanded(
                    child: LinearProgressIndicator(
                      value: percentage,
                      backgroundColor: Colors.grey.shade300,
                      color: Colors.blue,
                    ),
                  ),
                  SizedBox(width: 8),
                  Text(
                      '${(percentage * 100).toStringAsFixed(1)}% ($starRatings)'),
                ],
              ),
            );
          }),
        ),
        SizedBox(height: 16),
        // Display reviews only if there are reviews
        if (ratings.isNotEmpty) ...[
          ...ratings.map((rating) {
            String comment = rating['comment'] ?? 'No comment';
            int stars = rating['rating'] ?? 0;
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: List.generate(stars, (index) {
                      return Icon(Icons.star, color: Colors.orange, size: 20);
                    }),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Anonymous:',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text(comment),
                ],
              ),
            );
          }).toList(),
        ],
      ],
    );
  }

  void _addToCart(BuildContext context, Map<String, dynamic> product,
      {int quantity = 1, bool navigateToCheckout = false}) async {
    String name = product['productName'] ?? 'Unknown';
    double price = 0.0;
    if (product.containsKey('salesPrice') && product['salesPrice'] > 0) {
      price = product['salesPrice'] is int
          ? (product['salesPrice'] as int).toDouble()
          : product['salesPrice'];
    } else {
      price = product['irPrice'] is int
          ? (product['irPrice'] as int).toDouble()
          : product['irPrice'] ?? 0.0;
    }
    String imageUrl = product['imageUrl'] ?? product['imagePath'] ?? '';

    Map<String, dynamic> productData = {
      'productName': name,
      'irPrice': price,
      'imagePath': imageUrl,
      'quantity': quantity,
      'isSelected': false, // Ensure isSelected is initialized
    };

    try {
      await CartManager().addToCart(productData);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Product added to cart!')),
      );

      if (navigateToCheckout) {
        // Navigate to CheckoutScreen
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => CheckoutScreen(
              cartItems: [
                CartItem(
                  name: name,
                  price: price,
                  imageUrl: imageUrl,
                  quantity: quantity,
                )
              ],
            ),
          ),
        );
      } else {
        // Navigate to the cart screen
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => CartScreen()),
        );
      }
    } catch (e) {
      print('Error adding product to cart: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error adding product to cart')),
      );
    }
  }

  Widget _buildBottomNavigationBar(BuildContext context) {
    return BottomAppBar(
      shape: CircularNotchedRectangle(),
      notchMargin: 5.0,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          IconButton(
            icon: Icon(Icons.camera_alt),
            onPressed: () async {
              final product = await _fetchProductData();
              if (product != null) {
                _navigateToARScreen(context, product);
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Product not found!')),
                );
              }
            },
          ),
          IconButton(
            icon: Icon(Icons.add_shopping_cart),
            onPressed: () async {
              final product = await _fetchProductData();
              if (product != null) {
                _addToCart(context, product);
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Product not found!')),
                );
              }
            },
          ),
          ElevatedButton(
            onPressed: () async {
              final product = await _fetchProductData();
              if (product != null) {
                _buyNow(context, product);
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Product not found!')),
                );
              }
            },
            child: Text('Buy Now'),
            style: ElevatedButton.styleFrom(
              foregroundColor: Colors.white,
              backgroundColor: Colors.green,
              padding: EdgeInsets.symmetric(horizontal: 20.0),
            ),
          ),
        ],
      ),
    );
  }

  void _buyNow(BuildContext context, Map<String, dynamic> product) async {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext bc) {
        return ProductBottomSheet(
          product: product,
          onBuyNow: (quantity) async {
            Navigator.pop(bc); // Close the bottom sheet

            // Add the product to the cart and navigate to the checkout screen
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => CheckoutScreen(
                  cartItems: [
                    CartItem(
                      name: product['productName'] ?? 'Unknown',
                      price: product['salesPrice'] != null &&
                              product['salesPrice'] > 0
                          ? (product['salesPrice'] as num).toDouble()
                          : (product['irPrice'] as num).toDouble(),
                      imageUrl: product['imagePath'] ?? '',
                      quantity: quantity,
                    )
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _addProductToCart(
      Map<String, dynamic> product, int quantity) async {
    Map<String, dynamic> productData = {
      'productName': product['productName'] ?? 'Unknown',
      'irPrice': product['irPrice'] ?? product['salesPrice'] ?? 0.0,
      'imagePath': product['imagePath'] ?? '',
      'quantity': quantity,
      'isSelected': false,
    };
    await CartManager().addToCart(productData);
  }

  void _navigateToARScreen(BuildContext context, Map<String, dynamic> product) {
    if (product.containsKey('category')) {
      String category = product['category'];
      String productID =
          product['productID']; // Get the productID from the product map

      if (category == 'Watch') {
        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => WatchARScreen(
                    productID: productID,
                  )),
        );
      } else if (category == 'Wellness') {
        // Navigator.push(
        //   context,
        //   MaterialPageRoute(
        //       builder: (context) => WellnessARScreen(productID: productID)),
        // );
      } else if (category == 'Jewellery') {
        // Debug print statement to check category and productID
        print('Navigating in Jewellery category with productID: $productID');

        if (productID != null && productID.length >= 4) {
          // Extract the numeric part of the productID
          String numericPart =
              productID.substring(2); // Get the part after "JN", "JE", or "JW"
          int productNumber = int.tryParse(numericPart) ?? -1;

          // Debug print statement to check productNumber
          print('Product number: $productNumber');

          if (productNumber != -1) {
            if (productNumber % 3 == 1) {
              print('Navigating to NecklaceARPage');
              // Navigator.push(
              //   context,
              //   MaterialPageRoute(
              //     builder: (context) => NecklaceARPage(productID: productID),
              //   ),
              // );
            } else if (productNumber % 3 == 2) {
              print('Navigating to EarARPage');
              // Navigator.push(
              //   context,
              //   MaterialPageRoute(
              //     builder: (context) => EarringARScreen(productID: productID),
              //   ),
              // );
            } else if (productNumber % 3 == 0) {
              print('Navigating to WristARPage');
              // Navigator.push(
              //   // context,
              //   // MaterialPageRoute(
              //   //   builder: (context) => WristARPage(),
              //   // ),
              // );
            } else {
              // Handle unexpected cases
              print('Unexpected case for product number: $productNumber');
            }
          } else {
            // Handle invalid product number case
            print('Invalid product number: $productNumber');
          }
        } else {
          // Handle invalid productID case
          print('Invalid productID: $productID');
        }
      } else if (category == 'HomePure') {
        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => HomePureARScreen(productID: productID)),
        );
      }
    }
  }
}

class ProductBottomSheet extends StatefulWidget {
  final Map<String, dynamic> product;
  final Function(int) onBuyNow;

  ProductBottomSheet({required this.product, required this.onBuyNow});

  @override
  _ProductBottomSheetState createState() => _ProductBottomSheetState();
}

class _ProductBottomSheetState extends State<ProductBottomSheet> {
  int quantity = 1;

  @override
  Widget build(BuildContext context) {
    double price = 0.0;
    if (widget.product.containsKey('salesPrice') &&
        widget.product['salesPrice'] != null &&
        widget.product['salesPrice'] > 0) {
      price = (widget.product['salesPrice'] as num).toDouble();
    } else {
      price = (widget.product['irPrice'] as num).toDouble();
    }

    return Container(
      padding: EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Row(
            children: [
              Image.network(
                widget.product['imagePath'] ?? '',
                width: 50,
                height: 50,
                fit: BoxFit.cover,
              ),
              SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(widget.product['productName'] ?? 'Unknown'),
                    Text('RM $price'),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                icon: Icon(Icons.remove),
                onPressed: () {
                  if (quantity > 1) {
                    setState(() {
                      quantity--;
                    });
                  }
                },
              ),
              Text('$quantity'),
              IconButton(
                icon: Icon(Icons.add),
                onPressed: () {
                  setState(() {
                    quantity++;
                  });
                },
              ),
            ],
          ),
          SizedBox(height: 16),
          ElevatedButton(
            child: Text('Buy Now'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange,
              foregroundColor: Colors.white,
            ),
            onPressed: () => widget.onBuyNow(quantity),
          ),
        ],
      ),
    );
  }
}
