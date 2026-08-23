class ListingModel {
  final String id;
  final String userId;
  final String title;
  final String description;
  final String category;
  final String condition;
  final String listingType;
  final double price;
  final String imageUrl;
  final String status;
  final DateTime? createdAt;

  ListingModel({
    required this.id,
    required this.userId,
    required this.title,
    required this.description,
    required this.category,
    required this.condition,
    required this.listingType,
    required this.price,
    required this.imageUrl,
    required this.status,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'title': title,
      'description': description,
      'category': category,
      'condition': condition,
      'listingType': listingType,
      'price': price,
      'imageUrl': imageUrl,
      'status': status,
      'createdAt': createdAt,
    };
  }

  factory ListingModel.fromMap(
      String id,
      Map<String, dynamic> map,
      ) {
    return ListingModel(
      id: id,
      userId: map['userId'] ?? '',
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      category: map['category'] ?? '',
      condition: map['condition'] ?? '',
      listingType: map['listingType'] ?? '',
      price: (map['price'] ?? 0).toDouble(),
      imageUrl: map['imageUrl'] ?? '',
      status: map['status'] ?? 'active',
      createdAt: map['createdAt']?.toDate(),
    );
  }
}