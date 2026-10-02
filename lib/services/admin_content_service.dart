// ===============================================================
// ADMIN CONTENT SERVICE
//
// Sumber data konten admin yang terpusat.
// Saat ini memakai data in-memory (list statis).
//
// TODO (nanti):
// Ganti isi method-method di bawah dengan pembacaan/penulisan
// ke Firestore, tanpa perlu mengubah halaman admin.
// ===============================================================

class AdminArticle {
  final String title;
  final String summary;
  final String imageAsset;
  final bool isPublished;

  const AdminArticle({
    required this.title,
    required this.summary,
    required this.imageAsset,
    required this.isPublished,
  });
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
  // -----------------------------------------------------------
  // ARTIKEL
  // -----------------------------------------------------------

  static List<AdminArticle> articles = [
    AdminArticle(
      title: 'Tips Tidur Nyenyak untuk Penderita GERD',
      summary:
          'Tidur cukup bantu lambung menjadi lebih sehat.',
      imageAsset: 'assets/images/artikel_tidur.png',
      isPublished: true,
    ),
  ];

  static AdminArticle? get publishedArticle {
    for (final article in articles) {
      if (article.isPublished) {
        return article;
      }
    }

    return null;
  }

  // -----------------------------------------------------------
  // EDUKASI GERD
  // -----------------------------------------------------------

  static List<AdminContentItem> edukasiItems = [
    AdminContentItem(
      title: 'Apa Itu GERD?',
      category: 'Materi Dasar',
    ),
    AdminContentItem(
      title: 'Gejala & Tanda Bahaya',
      category: 'Materi Dasar',
    ),
    AdminContentItem(
      title: 'Pertolongan Pertama saat Kambuh',
      category: 'Materi Dasar',
    ),
    AdminContentItem(
      title: 'Mitos vs Fakta GERD',
      category: 'Materi Dasar',
    ),
    AdminContentItem(
      title: 'Waktu Makan yang Tepat',
      category: 'Materi Dasar',
    ),
  ];

  // -----------------------------------------------------------
  // REKOMENDASI MAKANAN
  // -----------------------------------------------------------

  static List<AdminContentItem> foodItems = [
    AdminContentItem(
      title: 'Oatmeal, Ubi Jalar, Roti Gandum',
      category: 'Karbohidrat',
    ),
    AdminContentItem(
      title: 'Pisang, Melon, Apel, Pir, Pepaya',
      category: 'Buah-Buahan',
    ),
    AdminContentItem(
      title: 'Putih Telur, Ayam, Ikan',
      category: 'Protein',
    ),
  ];

  // -----------------------------------------------------------
  // REKOMENDASI OLAHRAGA
  // -----------------------------------------------------------

  static List<AdminContentItem> sportItems = [
    AdminContentItem(
      title: 'Yoga',
      category: 'Relaksasi',
    ),
    AdminContentItem(
      title: 'Jalan Santai',
      category: 'Rendah Intensitas',
    ),
    AdminContentItem(
      title: 'Berenang',
      category: 'Rendah Intensitas',
    ),
    AdminContentItem(
      title: 'Stretching',
      category: 'Fleksibilitas',
    ),
  ];
}