import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class MyListingsScreen extends StatelessWidget {
  const MyListingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return const Scaffold(
        body: Center(child: Text('Please login to view your listings.')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'My Listings',
          style: TextStyle(fontWeight: FontWeight.w800),
        ),
        centerTitle: true,
      ),
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: FirebaseFirestore.instance
            .collection('listings')
            .where('sellerId', isEqualTo: user.uid)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(30),
                child: Text(
                  'Unable to load your listings right now.',
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }

          final docs = snapshot.data?.docs ?? [];

          if (docs.isEmpty) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(30),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.inventory_2_outlined, size: 70),
                    SizedBox(height: 18),
                    Text(
                      'No Listings Yet',
                      style: TextStyle(
                        fontSize: 25,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Create your first listing and manage it here.',
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(20),
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final doc = docs[index];
              final data = doc.data();

              return _ListingCard(
                listingId: doc.id,
                data: data,
              );
            },
          );
        },
      ),
    );
  }
}

class _ListingCard extends StatelessWidget {
  final String listingId;
  final Map<String, dynamic> data;

  const _ListingCard({
    required this.listingId,
    required this.data,
  });

  bool get isActive {
    final status = (data['status'] ?? 'active').toString().toLowerCase();
    return status != 'inactive' &&
        status != 'deleted' &&
        status != 'completed';
  }

  String _price(dynamic value) {
    if (value is num) return '₹${value.toStringAsFixed(0)}';

    final text = value?.toString().trim() ?? '';
    if (text.isEmpty) return '₹0';
    return text.startsWith('₹') ? text : '₹$text';
  }

  @override
  Widget build(BuildContext context) {
    final title = (data['title'] ?? 'Untitled Listing').toString();
    final description = (data['description'] ?? '').toString();
    final category = (data['category'] ?? 'Other').toString();
    final condition = (data['condition'] ?? 'Not specified').toString();
    final listingType = (data['listingType'] ?? 'Sell').toString();

    return Container(
      margin: const EdgeInsets.only(bottom: 18),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFFD9E2D9)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: .05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: const Color(0xFFEAF7ED),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(
                  Icons.inventory_2_outlined,
                  color: Color(0xFF087A2F),
                  size: 28,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              Text(
                _price(data['price']),
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF087A2F),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              _StatusChip(isActive: isActive),
              const SizedBox(width: 8),
              _InfoChip(text: category),
            ],
          ),
          if (description.isNotEmpty) ...[
            const SizedBox(height: 14),
            Text(
              description,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Color(0xFF687169),
                height: 1.4,
              ),
            ),
          ],
          const SizedBox(height: 14),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _InfoChip(text: condition),
              _InfoChip(text: listingType),
            ],
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => EditListingScreen(
                          listingId: listingId,
                          initialData: data,
                        ),
                      ),
                    );
                  },
                  icon: const Icon(Icons.edit_outlined, size: 18),
                  label: const Text('Edit'),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _toggleStatus(context),
                  icon: Icon(
                    isActive
                        ? Icons.pause_circle_outline
                        : Icons.play_circle_outline,
                    size: 18,
                  ),
                  label: Text(isActive ? 'Deactivate' : 'Activate'),
                ),
              ),
              const SizedBox(width: 4),
              IconButton(
                tooltip: 'Delete listing',
                onPressed: () => _deleteListing(context),
                icon: const Icon(
                  Icons.delete_outline_rounded,
                  color: Colors.red,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _toggleStatus(BuildContext context) async {
    final newStatus = isActive ? 'inactive' : 'active';

    try {
      await FirebaseFirestore.instance
          .collection('listings')
          .doc(listingId)
          .update({
        'status': newStatus,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      if (!context.mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            newStatus == 'active'
                ? 'Listing activated.'
                : 'Listing deactivated.',
          ),
        ),
      );
    } on FirebaseException catch (e) {
      if (!context.mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.message ?? 'Unable to update listing.'),
        ),
      );
    }
  }

  Future<void> _deleteListing(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Delete Listing?'),
          content: const Text(
            'This will permanently remove the listing. Continue?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, true),
              child: const Text(
                'Delete',
                style: TextStyle(color: Colors.red),
              ),
            ),
          ],
        );
      },
    );

    if (confirmed != true) return;

    try {
      await FirebaseFirestore.instance
          .collection('listings')
          .doc(listingId)
          .delete();

      if (!context.mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Listing deleted successfully.')),
      );
    } on FirebaseException catch (e) {
      if (!context.mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.message ?? 'Unable to delete listing.'),
        ),
      );
    }
  }
}

class EditListingScreen extends StatefulWidget {
  final String listingId;
  final Map<String, dynamic> initialData;

  const EditListingScreen({
    super.key,
    required this.listingId,
    required this.initialData,
  });

  @override
  State<EditListingScreen> createState() => _EditListingScreenState();
}

class _EditListingScreenState extends State<EditListingScreen> {
  late final TextEditingController titleController;
  late final TextEditingController descriptionController;
  late final TextEditingController priceController;

  late String category;
  late String condition;
  late String listingType;

  bool isSaving = false;

  static const categories = [
    'Books',
    'Electronics',
    'Bags',
    'Stationery',
    'Furniture',
    'Other',
  ];

  static const conditions = [
    'New',
    'Like New',
    'Good',
    'Fair',
  ];

  static const listingTypes = [
    'Sell',
    'Exchange',
    'Donate',
  ];

  @override
  void initState() {
    super.initState();

    titleController = TextEditingController(
      text: widget.initialData['title']?.toString() ?? '',
    );
    descriptionController = TextEditingController(
      text: widget.initialData['description']?.toString() ?? '',
    );
    priceController = TextEditingController(
      text: widget.initialData['price']?.toString() ?? '',
    );

    final storedCategory =
        widget.initialData['category']?.toString() ?? 'Other';
    final storedCondition =
        widget.initialData['condition']?.toString() ?? 'Good';
    final storedType =
        widget.initialData['listingType']?.toString() ?? 'Sell';

    category =
    categories.contains(storedCategory) ? storedCategory : 'Other';
    condition =
    conditions.contains(storedCondition) ? storedCondition : 'Good';
    listingType =
    listingTypes.contains(storedType) ? storedType : 'Sell';
  }

  @override
  void dispose() {
    titleController.dispose();
    descriptionController.dispose();
    priceController.dispose();
    super.dispose();
  }

  Future<void> saveChanges() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      showMessage('Please login again.');
      return;
    }

    final title = titleController.text.trim();
    final description = descriptionController.text.trim();
    final priceText = priceController.text.trim();

    if (title.isEmpty) {
      showMessage('Please enter an item title.');
      return;
    }

    if (description.isEmpty) {
      showMessage('Please enter a description.');
      return;
    }

    if (priceText.isEmpty) {
      showMessage('Please enter a price.');
      return;
    }

    final price = double.tryParse(
      priceText.replaceAll(RegExp(r'[^0-9.]'), ''),
    );

    if (price == null || price < 0) {
      showMessage('Please enter a valid price.');
      return;
    }

    setState(() => isSaving = true);

    try {
      final ref = FirebaseFirestore.instance
          .collection('listings')
          .doc(widget.listingId);

      final current = await ref.get();
      final currentData = current.data();

      if (!current.exists || currentData == null) {
        throw FirebaseException(
          plugin: 'cloud_firestore',
          code: 'not-found',
          message: 'This listing no longer exists.',
        );
      }

      if ((currentData['sellerId'] ?? '').toString() != user.uid) {
        throw FirebaseException(
          plugin: 'cloud_firestore',
          code: 'permission-denied',
          message: 'You can only edit your own listing.',
        );
      }

      await ref.update({
        'title': title,
        'description': description,
        'price': price,
        'category': category,
        'condition': condition,
        'listingType': listingType,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Listing updated successfully.')),
      );

      Navigator.pop(context);
    } on FirebaseException catch (e) {
      if (!mounted) return;
      showMessage(e.message ?? 'Unable to update listing.');
    } finally {
      if (mounted) {
        setState(() => isSaving = false);
      }
    }
  }

  void showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  InputDecoration decoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Edit Listing',
          style: TextStyle(fontWeight: FontWeight.w800),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            TextField(
              controller: titleController,
              decoration: decoration('Item Title', Icons.title_rounded),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: descriptionController,
              maxLines: 5,
              decoration: decoration(
                'Description',
                Icons.description_outlined,
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: priceController,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              decoration: decoration(
                'Price',
                Icons.currency_rupee_rounded,
              ),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              initialValue: category,
              decoration: decoration(
                'Category',
                Icons.category_outlined,
              ),
              items: categories
                  .map(
                    (item) => DropdownMenuItem(
                  value: item,
                  child: Text(item),
                ),
              )
                  .toList(),
              onChanged: isSaving
                  ? null
                  : (value) {
                if (value != null) {
                  setState(() => category = value);
                }
              },
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              initialValue: condition,
              decoration: decoration(
                'Condition',
                Icons.star_border_rounded,
              ),
              items: conditions
                  .map(
                    (item) => DropdownMenuItem(
                  value: item,
                  child: Text(item),
                ),
              )
                  .toList(),
              onChanged: isSaving
                  ? null
                  : (value) {
                if (value != null) {
                  setState(() => condition = value);
                }
              },
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              initialValue: listingType,
              decoration: decoration(
                'Listing Type',
                Icons.swap_horiz_rounded,
              ),
              items: listingTypes
                  .map(
                    (item) => DropdownMenuItem(
                  value: item,
                  child: Text(item),
                ),
              )
                  .toList(),
              onChanged: isSaving
                  ? null
                  : (value) {
                if (value != null) {
                  setState(() => listingType = value);
                }
              },
            ),
            const SizedBox(height: 28),
            SizedBox(
              width: double.infinity,
              height: 54,
              child: ElevatedButton.icon(
                onPressed: isSaving ? null : saveChanges,
                icon: isSaving
                    ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
                    : const Icon(Icons.save_outlined),
                label: Text(
                  isSaving ? 'Saving...' : 'Save Changes',
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  final bool isActive;

  const _StatusChip({required this.isActive});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: isActive
            ? const Color(0xFFE8F5E9)
            : const Color(0xFFF1F1F1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        isActive ? 'ACTIVE' : 'INACTIVE',
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w800,
          color: isActive
              ? const Color(0xFF2E7D32)
              : const Color(0xFF687169),
        ),
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  final String text;

  const _InfoChip({required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFFE8EDFC),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w700,
          color: Color(0xFF536055),
        ),
      ),
    );
  }
}
