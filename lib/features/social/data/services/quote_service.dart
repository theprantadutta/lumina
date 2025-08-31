import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:lumina/shared/models/social_models.dart';

class QuoteService {
  static const String _quotesCollection = 'daily_quotes';
  static const String _userQuoteHistoryCollection = 'user_quote_history';
  static const String _customQuotesCollection = 'custom_quotes';
  
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Get today's daily quote
  Future<DailyQuote?> getTodaysQuote() async {
    final today = DateTime.now();
    final todayString = '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';

    final querySnapshot = await _firestore
        .collection(_quotesCollection)
        .where('date', isEqualTo: Timestamp.fromDate(DateTime.parse(todayString)))
        .limit(1)
        .get();

    if (querySnapshot.docs.isEmpty) {
      // Fallback to a random inspirational quote if no specific date quote exists
      return await _getRandomQuote();
    }

    final doc = querySnapshot.docs.first;
    return DailyQuote.fromJson(doc.data());
  }

  /// Get a random inspirational quote as fallback
  Future<DailyQuote?> _getRandomQuote() async {
    // Get total count of quotes
    final countSnapshot = await _firestore
        .collection(_quotesCollection)
        .count()
        .get();
    
    final totalQuotes = countSnapshot.count ?? 0;
    if (totalQuotes == 0) return null;

    // Get a random quote (simplified approach)
    final querySnapshot = await _firestore
        .collection(_quotesCollection)
        .limit(1)
        .get();

    if (querySnapshot.docs.isNotEmpty) {
      return DailyQuote.fromJson(querySnapshot.docs.first.data());
    }

    return null;
  }

  /// Get quotes by category
  Future<List<DailyQuote>> getQuotesByCategory(
    String category, {
    int limit = 10,
  }) async {
    final querySnapshot = await _firestore
        .collection(_quotesCollection)
        .where('category', isEqualTo: category)
        .orderBy('likesCount', descending: true)
        .limit(limit)
        .get();

    return querySnapshot.docs.map((doc) {
      return DailyQuote.fromJson(doc.data());
    }).toList();
  }

  /// Get popular quotes
  Future<List<DailyQuote>> getPopularQuotes({int limit = 20}) async {
    final querySnapshot = await _firestore
        .collection(_quotesCollection)
        .orderBy('likesCount', descending: true)
        .orderBy('sharesCount', descending: true)
        .limit(limit)
        .get();

    return querySnapshot.docs.map((doc) {
      return DailyQuote.fromJson(doc.data());
    }).toList();
  }

  /// Search quotes by text or author
  Future<List<DailyQuote>> searchQuotes(
    String query, {
    int limit = 20,
  }) async {
    final textResults = await _firestore
        .collection(_quotesCollection)
        .where('text', isGreaterThanOrEqualTo: query)
        .where('text', isLessThanOrEqualTo: '$query\uf8ff')
        .limit(limit ~/ 2)
        .get();

    final authorResults = await _firestore
        .collection(_quotesCollection)
        .where('author', isGreaterThanOrEqualTo: query)
        .where('author', isLessThanOrEqualTo: '$query\uf8ff')
        .limit(limit ~/ 2)
        .get();

    final quotes = <DailyQuote>[];
    final seenIds = <String>{};

    // Combine results and remove duplicates
    for (final doc in [...textResults.docs, ...authorResults.docs]) {
      if (!seenIds.contains(doc.id)) {
        seenIds.add(doc.id);
        quotes.add(DailyQuote.fromJson(doc.data()));
      }
    }

    return quotes;
  }

  /// Like a quote
  Future<void> likeQuote(String quoteId) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('User not authenticated');

    // Check if already liked
    final likeDoc = await _firestore
        .collection(_quotesCollection)
        .doc(quoteId)
        .collection('likes')
        .doc(user.uid)
        .get();

    if (likeDoc.exists) {
      // Unlike
      await likeDoc.reference.delete();
      await _firestore.collection(_quotesCollection).doc(quoteId).update({
        'likesCount': FieldValue.increment(-1),
      });
    } else {
      // Like
      await _firestore
          .collection(_quotesCollection)
          .doc(quoteId)
          .collection('likes')
          .doc(user.uid)
          .set({
        'userId': user.uid,
        'likedAt': FieldValue.serverTimestamp(),
      });
      
      await _firestore.collection(_quotesCollection).doc(quoteId).update({
        'likesCount': FieldValue.increment(1),
      });
    }
  }

  /// Share a quote
  Future<void> shareQuote(String quoteId) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('User not authenticated');

    // Increment share count
    await _firestore.collection(_quotesCollection).doc(quoteId).update({
      'sharesCount': FieldValue.increment(1),
    });

    // Track user's share activity
    await _firestore
        .collection(_userQuoteHistoryCollection)
        .doc(user.uid)
        .collection('shares')
        .add({
      'quoteId': quoteId,
      'sharedAt': FieldValue.serverTimestamp(),
    });
  }

  /// Save quote to favorites
  Future<void> saveQuoteToFavorites(String quoteId) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('User not authenticated');

    await _firestore
        .collection(_userQuoteHistoryCollection)
        .doc(user.uid)
        .collection('favorites')
        .doc(quoteId)
        .set({
      'quoteId': quoteId,
      'savedAt': FieldValue.serverTimestamp(),
    });
  }

  /// Remove quote from favorites
  Future<void> removeQuoteFromFavorites(String quoteId) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('User not authenticated');

    await _firestore
        .collection(_userQuoteHistoryCollection)
        .doc(user.uid)
        .collection('favorites')
        .doc(quoteId)
        .delete();
  }

  /// Get user's favorite quotes
  Future<List<DailyQuote>> getFavoriteQuotes() async {
    final user = _auth.currentUser;
    if (user == null) return [];

    final favoritesSnapshot = await _firestore
        .collection(_userQuoteHistoryCollection)
        .doc(user.uid)
        .collection('favorites')
        .orderBy('savedAt', descending: true)
        .get();

    if (favoritesSnapshot.docs.isEmpty) return [];

    final quoteIds = favoritesSnapshot.docs.map((doc) => doc.id).toList();
    
    // Batch get quotes
    final quotes = <DailyQuote>[];
    for (final quoteId in quoteIds) {
      final quoteDoc = await _firestore
          .collection(_quotesCollection)
          .doc(quoteId)
          .get();
      
      if (quoteDoc.exists) {
        quotes.add(DailyQuote.fromJson(quoteDoc.data()!));
      }
    }

    return quotes;
  }

  /// Check if user has liked a quote
  Future<bool> hasUserLikedQuote(String quoteId) async {
    final user = _auth.currentUser;
    if (user == null) return false;

    final likeDoc = await _firestore
        .collection(_quotesCollection)
        .doc(quoteId)
        .collection('likes')
        .doc(user.uid)
        .get();

    return likeDoc.exists;
  }

  /// Check if user has saved a quote to favorites
  Future<bool> hasUserSavedQuote(String quoteId) async {
    final user = _auth.currentUser;
    if (user == null) return false;

    final saveDoc = await _firestore
        .collection(_userQuoteHistoryCollection)
        .doc(user.uid)
        .collection('favorites')
        .doc(quoteId)
        .get();

    return saveDoc.exists;
  }

  /// Create a custom quote (for community sharing)
  Future<String> createCustomQuote({
    required String text,
    required String author,
    String? category,
    List<String> tags = const [],
  }) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('User not authenticated');

    final customQuote = {
      'text': text,
      'author': author,
      'category': category,
      'tags': tags,
      'createdBy': user.uid,
      'createdAt': FieldValue.serverTimestamp(),
      'isApproved': false, // Needs moderation
      'likesCount': 0,
      'sharesCount': 0,
    };

    final docRef = await _firestore
        .collection(_customQuotesCollection)
        .add(customQuote);

    return docRef.id;
  }

  /// Get user's custom quotes
  Future<List<Map<String, dynamic>>> getUserCustomQuotes() async {
    final user = _auth.currentUser;
    if (user == null) return [];

    final querySnapshot = await _firestore
        .collection(_customQuotesCollection)
        .where('createdBy', isEqualTo: user.uid)
        .orderBy('createdAt', descending: true)
        .get();

    return querySnapshot.docs.map((doc) {
      final data = doc.data();
      data['id'] = doc.id;
      return data;
    }).toList();
  }

  /// Get approved custom quotes from community
  Future<List<DailyQuote>> getCommunityQuotes({int limit = 20}) async {
    final querySnapshot = await _firestore
        .collection(_customQuotesCollection)
        .where('isApproved', isEqualTo: true)
        .orderBy('likesCount', descending: true)
        .limit(limit)
        .get();

    return querySnapshot.docs.map((doc) {
      final data = doc.data();
      return DailyQuote(
        id: doc.id,
        text: data['text'],
        author: data['author'],
        category: data['category'],
        date: DateTime.now(), // Community quotes don't have specific dates
        tags: List<String>.from(data['tags'] ?? []),
        likesCount: data['likesCount'] ?? 0,
        sharesCount: data['sharesCount'] ?? 0,
      );
    }).toList();
  }

  /// Report inappropriate quote
  Future<void> reportQuote({
    required String quoteId,
    required String reason,
    String? additionalInfo,
  }) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('User not authenticated');

    await _firestore.collection('content_reports').add({
      'reporterId': user.uid,
      'contentId': quoteId,
      'contentType': 'quote',
      'reason': reason,
      'additionalInfo': additionalInfo,
      'reportedAt': FieldValue.serverTimestamp(),
      'status': 'pending',
    });
  }

  /// Get quote categories
  Future<List<String>> getQuoteCategories() async {
    final querySnapshot = await _firestore
        .collection(_quotesCollection)
        .get();

    final categories = <String>{};
    for (final doc in querySnapshot.docs) {
      final category = doc.data()['category'] as String?;
      if (category != null && category.isNotEmpty) {
        categories.add(category);
      }
    }

    final sortedCategories = categories.toList()..sort();
    return sortedCategories;
  }

  /// Get user's quote activity stats
  Future<QuoteActivityStats> getUserQuoteStats() async {
    final user = _auth.currentUser;
    if (user == null) {
      return const QuoteActivityStats(
        quotesLiked: 0,
        quotesShared: 0,
        favoriteQuotes: 0,
        customQuotesCreated: 0,
      );
    }

    final likesSnapshot = await _firestore
        .collectionGroup('likes')
        .where('userId', isEqualTo: user.uid)
        .get();

    final sharesSnapshot = await _firestore
        .collection(_userQuoteHistoryCollection)
        .doc(user.uid)
        .collection('shares')
        .get();

    final favoritesSnapshot = await _firestore
        .collection(_userQuoteHistoryCollection)
        .doc(user.uid)
        .collection('favorites')
        .get();

    final customQuotesSnapshot = await _firestore
        .collection(_customQuotesCollection)
        .where('createdBy', isEqualTo: user.uid)
        .get();

    return QuoteActivityStats(
      quotesLiked: likesSnapshot.docs.length,
      quotesShared: sharesSnapshot.docs.length,
      favoriteQuotes: favoritesSnapshot.docs.length,
      customQuotesCreated: customQuotesSnapshot.docs.length,
    );
  }

  /// Mark quote as viewed for tracking purposes
  Future<void> markQuoteAsViewed(String quoteId) async {
    final user = _auth.currentUser;
    if (user == null) return;

    await _firestore
        .collection(_userQuoteHistoryCollection)
        .doc(user.uid)
        .collection('viewed')
        .doc(quoteId)
        .set({
      'quoteId': quoteId,
      'viewedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }
}

// Quote activity statistics model
class QuoteActivityStats {
  final int quotesLiked;
  final int quotesShared;
  final int favoriteQuotes;
  final int customQuotesCreated;

  const QuoteActivityStats({
    required this.quotesLiked,
    required this.quotesShared,
    required this.favoriteQuotes,
    required this.customQuotesCreated,
  });
}