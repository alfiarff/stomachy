import 'package:cloud_firestore/cloud_firestore.dart';

class AdminArticle {
  final String id;
  final String title;
  final String summary;
  final String imageAsset;
  final bool isPublished;
  final String content;
  final String category;

  const AdminArticle({
    required this.id,
    required this.title,
    required this.summary,
    required this.imageAsset,
    required this.isPublished,
    required this.content,
    required this.category,
  });

  factory AdminArticle.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return AdminArticle(
      id: doc.id,
      title: data['title'] ?? '',
      summary: data['summary'] ?? '',
      imageAsset: data['imageAsset'] ?? 'assets/images/artikel_tidur.png',
      isPublished: data['isPublished'] ?? false,
      content: data['content'] ?? '',
      category: data['category'] ?? 'Kesehatan Lambung',
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'title': title,
      'summary': summary,
      'imageAsset': imageAsset,
      'isPublished': isPublished,
      'content': content,
      'category': category,
    };
  }
}

class AdminContentItem {
  final String id;
  final String title;
  final String category;
  final String type;
  final String imageAsset;
  final String content;

  const AdminContentItem({
    required this.id,
    required this.title,
    required this.category,
    required this.type,
    required this.imageAsset,
    required this.content,
  });

  factory AdminContentItem.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return AdminContentItem(
      id: doc.id,
      title: data['title'] ?? '',
      category: data['category'] ?? '',
      type: data['type'] ?? 'edukasi',
      imageAsset: data['imageAsset'] ?? 'assets/images/edukasi_gerd.png',
      content: data['content'] ?? '',
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'title': title,
      'category': category,
      'type': type,
      'imageAsset': imageAsset,
      'content': content,
    };
  }
}

class AdminContentService {
  static final FirebaseFirestore _db = FirebaseFirestore.instance;

  static CollectionReference get _articlesRef => _db.collection('articles');
  static CollectionReference get _contentsRef => _db.collection('contents');

  static Stream<List<AdminArticle>> get articlesStream {
    return _articlesRef
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => AdminArticle.fromFirestore(doc))
          .toList();
    });
  }

  static Stream<List<AdminArticle>> get publishedArticlesStream {
    return _articlesRef
        .where('isPublished', isEqualTo: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => AdminArticle.fromFirestore(doc))
          .toList();
    });
  }

  static Stream<AdminArticle?> get publishedArticleStream {
    return publishedArticlesStream.map((list) {
      return list.isNotEmpty ? list.first : null;
    });
  }

  static Future<void> addArticle({
    required String title,
    required String summary,
    required String imageAsset,
    required bool isPublished,
    required String content,
    required String category,
  }) async {
    await _articlesRef.add({
      'title': title,
      'summary': summary,
      'imageAsset': imageAsset,
      'isPublished': isPublished,
      'content': content,
      'category': category,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  static Future<void> updateArticle({
    required String id,
    required String title,
    required String summary,
    required String imageAsset,
    required bool isPublished,
    required String content,
    required String category,
  }) async {
    await _articlesRef.doc(id).update({
      'title': title,
      'summary': summary,
      'imageAsset': imageAsset,
      'isPublished': isPublished,
      'content': content,
      'category': category,
    });
  }

  static Future<void> deleteArticle(String id) async {
    await _articlesRef.doc(id).delete();
  }

  static Stream<List<AdminContentItem>> getContentsStream(String type) {
    return _contentsRef
        .where('type', isEqualTo: type)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => AdminContentItem.fromFirestore(doc))
          .toList();
    });
  }

  static Future<void> addContent({
    required String title,
    required String category,
    required String type,
    required String imageAsset,
    required String content,
  }) async {
    await _contentsRef.add({
      'title': title,
      'category': category,
      'type': type,
      'imageAsset': imageAsset,
      'content': content,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  static Future<void> updateContent({
    required String id,
    required String title,
    required String category,
    required String type,
    required String imageAsset,
    required String content,
  }) async {
    await _contentsRef.doc(id).update({
      'title': title,
      'category': category,
      'type': type,
      'imageAsset': imageAsset,
      'content': content,
    });
  }

  static Future<void> deleteContent(String id) async {
    await _contentsRef.doc(id).delete();
  }
}
