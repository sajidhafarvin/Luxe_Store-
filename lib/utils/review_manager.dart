import 'package:flutter/material.dart';
import '../utils/user_session.dart';

class ReviewManager {
  static final ReviewManager _instance = ReviewManager._internal();
  factory ReviewManager() => _instance;
  ReviewManager._internal();

  static final Map<String, List<Map<String, dynamic>>> _reviews = {
    'default': [
      {
        'name': 'Sarah Mitchell',
        'rating': 5,
        'date': 'Oct 15, 2025',
        'comment': 'Absolutely stunning quality! The fabric feels luxurious and the fit is perfect. Worth every penny.',
        'initials': 'SM',
        'color': 0xFF6C63FF,
        'helpful': 12,
      },
      {
        'name': 'James Anderson',
        'rating': 4,
        'date': 'Oct 10, 2025',
        'comment': 'Great product overall. Delivery was fast and packaging was beautiful. Slightly runs large.',
        'initials': 'JA',
        'color': 0xFF4CAF50,
        'helpful': 8,
      },
      {
        'name': 'Emma Thompson',
        'rating': 5,
        'date': 'Sep 28, 2025',
        'comment': 'I am obsessed with this! The color is exactly as shown. Already ordered in another color!',
        'initials': 'ET',
        'color': 0xFFE94560,
        'helpful': 15,
      },
    ],
  };

  List<Map<String, dynamic>> getReviews(String productName) {
    return _reviews[productName] ?? _reviews['default']!;
  }

  void addReview(String productName, Map<String, dynamic> review) {
    if (_reviews[productName] == null) {
      _reviews[productName] = List.from(_reviews['default']!);
    }
    _reviews[productName]!.insert(0, review);
  }

  double getAverageRating(String productName) {
    final reviews = getReviews(productName);
    if (reviews.isEmpty) return 0;
    final total = reviews.fold(0.0, (sum, r) => sum + (r['rating'] as int));
    return total / reviews.length;
  }

  int getRatingCount(String productName) {
    return getReviews(productName).length;
  }

  Map<String, int> getRatingBreakdown(String productName) {
    final reviews = getReviews(productName);
    final breakdown = {'5': 0, '4': 0, '3': 0, '2': 0, '1': 0};
    for (var r in reviews) {
      final rating = r['rating'].toString();
      breakdown[rating] = (breakdown[rating] ?? 0) + 1;
    }
    return breakdown;
  }
}
