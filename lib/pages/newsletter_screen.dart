import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:sos_unis/widget/newstemplate.dart';

class NewsletterPage extends StatefulWidget {
  const NewsletterPage({super.key});

  @override
  State<NewsletterPage> createState() => _NewsletterPageState();
}

class _NewsletterPageState extends State<NewsletterPage> {
  String get _todaysCollectionId {
    final now = DateTime.now();
    final formattedDate = DateFormat('ddMMyy').format(now); 
    return 'news_$formattedDate';
  }

  @override
  Widget build(BuildContext context) {
    final Query<Map<String, dynamic>> newsQuery = FirebaseFirestore.instance
        .collection('news')
        .doc('newsletter')
        .collection(_todaysCollectionId); 

    return Scaffold(
      appBar: AppBar(
        title: const Text('UniSphere Newsletter'),
        centerTitle: true,
        elevation: 0,
      ),
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: newsQuery.snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(child: Text('Error loading newsletter'));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final data = snapshot.data?.docs;

          if (data == null || data.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Icon(Icons.mark_email_read_outlined, size: 60, color: Colors.grey),
                  SizedBox(height: 16),
                  Text('No updates for today yet!', style: TextStyle(color: Colors.grey)),
                ],
              ),
            );
          }

          return PageView.builder(
            scrollDirection: Axis.vertical,
            itemCount: data.length,
            itemBuilder: (context, index) {
              final article = NewsArticle.fromFirestore(data[index]);
              return NewsCard(article: article);
            },
          );
        },
      ),
    );
  }
}

class NewsArticle {
  final String header;
  final String body;
  final String imageUrl;
  final String college;
  final DateTime timestamp;

  NewsArticle({
    required this.header,
    required this.body,
    required this.imageUrl,
    required this.college,
    required this.timestamp,
  });

  factory NewsArticle.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return NewsArticle(
      header: data['header'] ?? 'No Title',
      body: data['body'] ?? '',
      imageUrl: data['image_url'] ?? '', 
      college: data['college'] ?? 'UniSphere',
      timestamp: (data['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }
}