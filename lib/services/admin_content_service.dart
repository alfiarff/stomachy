import 'package:cloud_firestore/cloud_firestore.dart';

class AdminArticle {
  final String id;
  final String title;
  final String summary;
  final String imageAsset;
  final bool isPublished;
  final String content;

  const AdminArticle({
    required this.id,
    required this.title,
    required this.summary,
    required this.imageAsset,
    required this.isPublished,
    required this.content,
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
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'title': title,
      'summary': summary,
      'imageAsset': imageAsset,
      'isPublished': isPublished,
      'content': content,
    };
  }
}

class AdminContentItem {
  final String title;
  final String category;

  const AdminContentItem({
    required this.title,
    required this.category,
  });
}

class AdminContentService {
  static final FirebaseFirestore _db = FirebaseFirestore.instance;

  static CollectionReference get _articlesRef => _db.collection('articles');

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
  }) async {
    await _articlesRef.add({
      'title': title,
      'summary': summary,
      'imageAsset': imageAsset,
      'isPublished': isPublished,
      'content': content,
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
  }) async {
    await _articlesRef.doc(id).update({
      'title': title,
      'summary': summary,
      'imageAsset': imageAsset,
      'isPublished': isPublished,
      'content': content,
    });
  }

  static Future<void> deleteArticle(String id) async {
    await _articlesRef.doc(id).delete();
  }

  static List<AdminContentItem> edukasiItems = [
    AdminContentItem(title: 'Apa Itu GERD?', category: 'Materi Dasar'),
    AdminContentItem(title: 'Gejala & Tanda Bahaya', category: 'Materi Dasar'),
    AdminContentItem(title: 'Pertolongan Pertama saat Kambuh', category: 'Materi Dasar'),
    AdminContentItem(title: 'Mitos vs Fakta GERD', category: 'Materi Dasar'),
    AdminContentItem(title: 'Waktu Makan yang Tepat', category: 'Materi Dasar'),
  ];

  static List<AdminContentItem> foodItems = [
    AdminContentItem(title: 'Oatmeal, Ubi Jalar, Roti Gandum', category: 'Karbohidrat'),
    AdminContentItem(title: 'Pisang, Melon, Apel, Pir, Pepaya', category: 'Buah-Buahan'),
    AdminContentItem(title: 'Putih Telur, Ayam, Ikan', category: 'Protein'),
  ];

  static List<AdminContentItem> sportItems = [
    AdminContentItem(title: 'Yoga', category: 'Relaksasi'),
    AdminContentItem(title: 'Jalan Santai', category: 'Rendah Intensitas'),
    AdminContentItem(title: 'Berenang', category: 'Rendah Intensitas'),
    AdminContentItem(title: 'Stretching', category: 'Fleksibilitas'),
  ];
}
