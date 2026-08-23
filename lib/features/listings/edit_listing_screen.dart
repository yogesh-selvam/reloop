import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class EditListingScreen extends StatefulWidget {
  final String listingId;
  final Map<String, dynamic> listing;

  const EditListingScreen({
    super.key,
    required this.listingId,
    required this.listing,
  });

  @override
  State<EditListingScreen> createState() =>
      _EditListingScreenState();
}

class _EditListingScreenState
    extends State<EditListingScreen> {
  late final TextEditingController titleController;
  late final TextEditingController descriptionController;
  late final TextEditingController priceController;

  late String category;
  late String condition;
  late String listingType;

  bool isLoading = false;

  final categories = const [
    'Books',
    'Electronics',
    'Bags',
    'Stationery',
    'Furniture',
    'Other',
  ];

  final conditions = const [
    'New',
    'Like New',
    'Good',
    'Fair',
  ];

  final listingTypes = const [
    'Sell',
    'Exchange',
    'Donate',
  ];

  @override
  void initState() {
    super.initState();

    titleController = TextEditingController(
      text: widget.listing['title']?.toString() ?? '',
    );

    descriptionController = TextEditingController(
      text: widget.listing['description']?.toString() ?? '',
    );

    priceController = TextEditingController(
      text: widget.listing['price']?.toString() ?? '',
    );

    category =
        widget.listing['category']?.toString() ?? 'Books';

    condition =
        widget.listing['condition']?.toString() ?? 'Good';

    listingType =
        widget.listing['listingType']?.toString() ?? 'Sell';

    if (!categories.contains(category)) {
      category = 'Other';
    }

    if (!conditions.contains(condition)) {
      condition = 'Good';
    }

    if (!listingTypes.contains(listingType)) {
      listingType = 'Sell';
    }
  }

  @override
  void dispose() {
    titleController.dispose();
    descriptionController.dispose();
    priceController.dispose();
    super.dispose();
  }

  Future<void> saveChanges() async {
    final title = titleController.text.trim();
    final description =
    descriptionController.text.trim();
    final priceText = priceController.text.trim();

    if (title.isEmpty ||
        description.isEmpty ||
        priceText.isEmpty) {
      _showMessage(
        'Please fill all required fields.',
      );
      return;
    }

    final price = double.tryParse(priceText);

    if (price == null || price < 0) {
      _showMessage(
        'Please enter a valid price.',
      );
      return;
    }

    setState(() => isLoading = true);

    try {
      await FirebaseFirestore.instance
          .collection('listings')
          .doc(widget.listingId)
          .update({
        'title': title,
        'description': description,
        'category': category,
        'condition': condition,
        'listingType': listingType,
        'price': price,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      if (!mounted) return;

      Navigator.pop(context, true);
    } on FirebaseException catch (e) {
      if (!mounted) return;

      _showMessage(
        e.message ??
            'Unable to update listing. Please try again.',
      );
    } catch (_) {
      if (!mounted) return;

      _showMessage(
        'Unable to update listing. Please try again.',
      );
    } finally {
      if (mounted) {
        setState(() => isLoading = false);
      }
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  InputDecoration inputDecoration({
    required String hint,
    required IconData icon,
  }) {
    return InputDecoration(
      hintText: hint,
      prefixIcon: Icon(icon),
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: const BorderSide(
          color: Color(0xFFC6D1C4),
        ),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: const BorderSide(
          color: Color(0xFFC6D1C4),
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: const BorderSide(
          color: Color(0xFF2E7D32),
          width: 2,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FF),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF8F9FF),
        elevation: 0,
        foregroundColor: const Color(0xFF182018),
        title: const Text(
          'Edit Listing',
          style: TextStyle(
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(
            28,
            18,
            28,
            35,
          ),
          child: Column(
            crossAxisAlignment:
            CrossAxisAlignment.start,
            children: [
              const Text(
                'Edit Listing',
                style: TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF182018),
                ),
              ),

              const SizedBox(height: 8),

              const Text(
                'Update your item details.',
                style: TextStyle(
                  fontSize: 17,
                  color: Color(0xFF667066),
                ),
              ),

              const SizedBox(height: 30),

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
                decoration: inputDecoration(
                  hint: 'Item title',
                  icon: Icons.title_rounded,
                ),
              ),

              const SizedBox(height: 24),

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
                decoration: inputDecoration(
                  hint: 'Describe your item',
                  icon: Icons.description_outlined,
                ),
              ),

              const SizedBox(height: 24),

              const Text(
                'Category',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),

              const SizedBox(height: 10),

              DropdownButtonFormField<String>(
                initialValue: category,
                decoration: inputDecoration(
                  hint: 'Category',
                  icon: Icons.category_outlined,
                ),
                items: categories.map((item) {
                  return DropdownMenuItem(
                    value: item,
                    child: Text(item),
                  );
                }).toList(),
                onChanged: isLoading
                    ? null
                    : (value) {
                  if (value == null) return;

                  setState(() {
                    category = value;
                  });
                },
              ),

              const SizedBox(height: 24),

              const Text(
                'Condition',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),

              const SizedBox(height: 10),

              DropdownButtonFormField<String>(
                initialValue: condition,
                decoration: inputDecoration(
                  hint: 'Condition',
                  icon: Icons.verified_outlined,
                ),
                items: conditions.map((item) {
                  return DropdownMenuItem(
                    value: item,
                    child: Text(item),
                  );
                }).toList(),
                onChanged: isLoading
                    ? null
                    : (value) {
                  if (value == null) return;

                  setState(() {
                    condition = value;
                  });
                },
              ),

              const SizedBox(height: 24),

              const Text(
                'Listing Type',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),

              const SizedBox(height: 10),

              DropdownButtonFormField<String>(
                initialValue: listingType,
                decoration: inputDecoration(
                  hint: 'Listing type',
                  icon: Icons.swap_horiz_rounded,
                ),
                items: listingTypes.map((item) {
                  return DropdownMenuItem(
                    value: item,
                    child: Text(item),
                  );
                }).toList(),
                onChanged: isLoading
                    ? null
                    : (value) {
                  if (value == null) return;

                  setState(() {
                    listingType = value;
                  });
                },
              ),

              const SizedBox(height: 24),

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
                decoration: inputDecoration(
                  hint: 'Enter price in ₹',
                  icon: Icons.currency_rupee_rounded,
                ),
              ),

              const SizedBox(height: 35),

              SizedBox(
                width: double.infinity,
                height: 65,
                child: ElevatedButton(
                  onPressed:
                  isLoading ? null : saveChanges,
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
                    'Save Changes',
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

