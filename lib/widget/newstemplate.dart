import 'package:flutter/material.dart';
import 'package:sos_unis/pages/newsletter_screen.dart';

class NewsCard extends StatelessWidget {
  final NewsArticle article;

  const NewsCard({super.key, required this.article});

  String _timeAgo(DateTime dateTime) {
    final Duration diff = DateTime.now().difference(dateTime);
    if (diff.inDays > 0) return '${diff.inDays}d ago';
    if (diff.inHours > 0) return '${diff.inHours}h ago';
    if (diff.inMinutes > 0) return '${diff.inMinutes}m ago';
    return 'Just now';
  }

  String _convertGsToHttpUrl(String url) {
    if (url.startsWith('gs://')) {
      final uri = Uri.parse(url);
      final bucket = uri.host;
      final path = uri.path.substring(1); 
      final encodedPath = Uri.encodeComponent(path);
      return 'https://firebasestorage.googleapis.com/v0/b/$bucket/o/$encodedPath?alt=media';
    }
    return url;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white, 
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Image Section
          if (article.imageUrl.isNotEmpty)
            Expanded(
              flex: 4,
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: NetworkImage(_convertGsToHttpUrl(article.imageUrl)),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            )
          else
            Expanded(
              flex: 2, 
              child: Container(
                color: Colors.grey[200], 
                child: const Center(child: Icon(Icons.image_not_supported, size: 50, color: Colors.grey)),
              ),
            ),

          // 2. Content Section
          Expanded(
            flex: 6,
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title
                  Text(
                    article.header,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      height: 1.2,
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  // Body
                  Expanded(
                    child: SingleChildScrollView(
                      child: Text(
                        article.body,
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey[800],
                          height: 1.5,
                        ),
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 10),
                  const Divider(),
                  
                  // Footer
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'SOURCE',
                            style: TextStyle(fontSize: 10, color: Colors.grey),
                          ),
                          Text(
                            article.college,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      Text(
                        _timeAgo(article.timestamp),
                        style: const TextStyle(color: Colors.grey, fontSize: 12),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
