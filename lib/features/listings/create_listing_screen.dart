import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../core/models/listing_model.dart';
import '../../core/services/listing_service.dart';

class CreateListingScreen extends StatefulWidget {
  const CreateListingScreen({super.key});

  @override
  State<CreateListingScreen> createState() =>
      _CreateListingScreenState();
}

class _CreateListingScreenState
    extends State<CreateListingScreen> {
  final titleController = TextEditingController();
  final descriptionController = TextEditingController();
  final priceController = TextEditingController();

  final ListingService _listingService = ListingService();

  String selectedCategory = 'Books';
  String selectedCondition = 'Like New';
  String selectedListingType = 'Sell';

  bool isLoading = false;

  final List<String> categories = [
    'Books',
    'Electronics',
    'Stationery',
    'Clothing',
    'Furniture',
    'Others',
  ];

  final List<String> conditions = [
    'New',
    'Like New',
    'Good',
    'Used',
  ];

  final List<String> listingTypes = [
    'Sell',
    'Exchange',
    'Donate',
  ];

  @override
  void dispose() {
    titleController.dispose();
    descriptionController.dispose();
    priceController.dispose();
    super.dispose();
  }

  Future<void> createListing() async {
    final title = titleController.text.trim();
    final description = descriptionController.text.trim();
    final priceText = priceController.text.trim();

    if (title.isEmpty || description.isEmpty) {
      _showMessage(
        'Please fill the title and description.',
      );
      return;
    }

    double price = 0;

    if (selectedListingType == 'Sell') {
      if (priceText.isEmpty) {
        _showMessage('Please enter the price.');
        return;
      }

      price = double.tryParse(priceText) ?? -1;

      if (price < 0) {
        _showMessage('Please enter a valid price.');
        return;
      }
    }

    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      _showMessage(
        'Please login before creating a listing.',
      );
      return;
    }

    setState(() => isLoading = true);

    try {
      final listing = ListingModel(
        id: '',
        userId: user.uid,
        title: title,
        description: description,
        category: selectedCategory,
        condition: selectedCondition,
        listingType: selectedListingType,
        price: price,
        imageUrl: '',
        status: 'active',
        createdAt: DateTime.now(),
      );

      await _listingService.createListing(listing);

      if (!mounted) return;

      _showMessage(
        'Listing created successfully! 🎉',
      );

      await Future.delayed(
        const Duration(milliseconds: 700),
      );

      if (!mounted) return;

      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;

      _showMessage(
        e.toString().replaceFirst(
          'Exception: ',
          '',
        ),
      );
    } finally {
      if (mounted) {
        setState(() => isLoading = false);
      }
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
      ),
    );
  }

  InputDecoration _inputDecoration({
    required String hint,
    required IconData icon,
  }) {
    return InputDecoration(
      hintText: hint,
      prefixIcon: Icon(icon),
      filled: true,
      fillColor: const Color(0xFFF7F9F7),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: const BorderSide(
          color: Color(0xFFD9E2D9),
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: const BorderSide(
          color: Color(0xFF2E7D32),
          width: 1.5,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool isSell = selectedListingType == 'Sell';

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Create Listing',
          style: TextStyle(
            fontWeight: FontWeight.w700,
          ),
        ),
        backgroundColor: Colors.transparent,
        foregroundColor: const Color(0xFF182018),
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(
            28,
            15,
            28,
            35,
          ),
          child: Column(
            crossAxisAlignment:
            CrossAxisAlignment.start,
            children: [
              const Text(
                'List an Item',
                style: TextStyle(
                  fontSize: 34,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF182018),
                ),
              ),

              const SizedBox(height: 8),

              const Text(
                'Give your unused items a second life.',
                style: TextStyle(
                  fontSize: 17,
                  color: Color(0xFF667066),
                ),
              ),

              const SizedBox(height: 35),

              const Text(
                'Item Title',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),

              const SizedBox(height: 10),

              TextField(
                controller: titleController,
                decoration: _inputDecoration(
                  hint: 'Example: Java Programming Book',
                  icon: Icons.title,
                ),
              ),

              const SizedBox(height: 25),

              const Text(
                'Description',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),

              const SizedBox(height: 10),

              TextField(
                controller: descriptionController,
                maxLines: 5,
                decoration: _inputDecoration(
                  hint: 'Describe your item...',
                  icon: Icons.description_outlined,
                ),
              ),

              const SizedBox(height: 25),

              const Text(
                'Category',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),

              const SizedBox(height: 10),

              DropdownButtonFormField<String>(
                initialValue: selectedCategory,
                decoration: _inputDecoration(
                  hint: 'Select category',
                  icon: Icons.category_outlined,
                ),
                items: categories.map((category) {
                  return DropdownMenuItem(
                    value: category,
                    child: Text(category),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value == null) return;

                  setState(() {
                    selectedCategory = value;
                  });
                },
              ),

              const SizedBox(height: 25),

              const Text(
                'Condition',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),

              const SizedBox(height: 10),

              DropdownButtonFormField<String>(
                initialValue: selectedCondition,
                decoration: _inputDecoration(
                  hint: 'Select condition',
                  icon: Icons.auto_awesome_outlined,
                ),
                items: conditions.map((condition) {
                  return DropdownMenuItem(
                    value: condition,
                    child: Text(condition),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value == null) return;

                  setState(() {
                    selectedCondition = value;
                  });
                },
              ),

              const SizedBox(height: 25),

              const Text(
                'Listing Type',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),

              const SizedBox(height: 10),

              DropdownButtonFormField<String>(
                initialValue: selectedListingType,
                decoration: _inputDecoration(
                  hint: 'Select listing type',
                  icon: Icons.swap_horiz_rounded,
                ),
                items: listingTypes.map((type) {
                  return DropdownMenuItem(
                    value: type,
                    child: Text(type),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value == null) return;

                  setState(() {
                    selectedListingType = value;
                  });
                },
              ),

              const SizedBox(height: 25),

              if (isSell) ...[
                const Text(
                  'Price',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),

                const SizedBox(height: 10),

                TextField(
                  controller: priceController,
                  keyboardType:
                  const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  decoration: _inputDecoration(
                    hint: 'Example: 250',
                    icon: Icons.currency_rupee,
                  ),
                ),

                const SizedBox(height: 25),
              ],

              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: const Color(0xFFF1FFF4),
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(
                    color: const Color(0xFFB8D4BF),
                  ),
                ),
                child: const Row(
                  children: [
                    Icon(
                      Icons.eco_outlined,
                      color: Color(0xFF2E7D32),
                      size: 28,
                    ),
                    SizedBox(width: 14),
                    Expanded(
                      child: Text(
                        'Every reused item helps reduce waste '
                            'and supports a more sustainable campus.',
                        style: TextStyle(
                          fontSize: 14,
                          height: 1.4,
                          color: Color(0xFF667066),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 30),

              SizedBox(
                width: double.infinity,
                height: 68,
                child: ElevatedButton(
                  onPressed:
                  isLoading ? null : createListing,
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                    const Color(0xFF2E7D32),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius:
                      BorderRadius.circular(20),
                    ),
                  ),
                  child: isLoading
                      ? const SizedBox(
                    width: 25,
                    height: 25,
                    child:
                    CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 3,
                    ),
                  )
                      : const Text(
                    'Create Listing',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight:
                      FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}