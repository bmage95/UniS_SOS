import 'package:flutter/material.dart';

class InShortsScreen extends StatefulWidget {
  @override
  State<InShortsScreen> createState() => _InShortsScreenState();
}

class _InShortsScreenState extends State<InShortsScreen> {
  final List<NewsArticle> articles = [
    NewsArticle(
      title: 'Breaking News Title',
      content: 'This is the news content summary that appears on the Inshorts style card.',
      source: 'TechNews',
      time: '2 hours ago',
      category: 'Tech',
    ),
    NewsArticle(
      title: 'Another News Story',
      content: 'Read the brief summary of this important news event in just one line.',
      source: 'WorldNews',
      time: '4 hours ago',
      category: 'World',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('UniSphere -News'),
        elevation: 0,
      ),
      body: PageView.builder(
        scrollDirection: Axis.vertical,
        itemCount: articles.length,
        itemBuilder: (context, index) {
          return NewsCard(article: articles[index]);
        },
      ),
    );
  }
}

class NewsCard extends StatelessWidget {
  final NewsArticle article;

  const NewsCard({required this.article});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            article.title,
            style: Theme.of(context).textTheme.headlineSmall,
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 24),
          Text(
            article.content,
            style: Theme.of(context).textTheme.bodyLarge,
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 40),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(article.source, style: TextStyle(fontWeight: FontWeight.bold)),
              Text(article.time, style: TextStyle(color: Colors.grey)),
            ],
          ),
        ],
      ),
    );
  }
}

class NewsArticle {
  final String title;
  final String content;
  final String source;
  final String time;
  final String category;

  NewsArticle({
    required this.title,
    required this.content,
    required this.source,
    required this.time,
    required this.category,
  });
}