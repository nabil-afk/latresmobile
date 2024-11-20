import 'package:flutter/material.dart';
import 'package:latres/pages/detail_screen.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart'; // Untuk format tanggal

class ListScreen extends StatelessWidget {
  final String endpoint;

  ListScreen({required this.endpoint});

  Future<List<dynamic>> fetchData() async {
    final response = await http
        .get(Uri.parse('https://api.spaceflightnewsapi.net/v4/$endpoint'));
    if (response.statusCode == 200) {
      return json.decode(response.body)['results'];
    } else {
      throw Exception("Failed to load data");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("List of $endpoint"),
        centerTitle: true,
        backgroundColor: Colors.deepPurple,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: FutureBuilder(
          future: fetchData(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(child: Text("Error: ${snapshot.error}"));
            } else {
              final List<dynamic> data = snapshot.data!;
              return ListView.builder(
                itemCount: data.length,
                itemBuilder: (context, index) {
                  return ListCard(
                    title: data[index]['title'],
                    imageUrl: data[index]['image_url'], // URL gambar dari API
                    date: data[index]['published_at'], // Tanggal diterbitkan
                    endpoint: endpoint,
                    id: data[index]['id'],
                  );
                },
              );
            }
          },
        ),
      ),
    );
  }
}

class ListCard extends StatelessWidget {
  final String title;
  final String? imageUrl; // URL gambar dari API
  final String? date; // Tanggal diterbitkan
  final String endpoint;
  final int id;

  const ListCard({
    required this.title,
    required this.endpoint,
    required this.id,
    this.imageUrl,
    this.date,
  });

  String formatDate(String? date) {
    if (date == null) return "Unknown date";
    final DateTime parsedDate = DateTime.parse(date);
    return DateFormat('dd MMM yyyy').format(parsedDate);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => DetailScreen(
                endpoint: endpoint, id: id, title: title, imageUrl: imageUrl),
          ),
        );
      },
      child: Container(
        margin: EdgeInsets.only(bottom: 16),
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.deepPurple, width: 1),
          boxShadow: [
            BoxShadow(
              color: Colors.deepPurple.withOpacity(0.1),
              blurRadius: 6,
              offset: Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Menampilkan gambar dari URL (imageUrl) di atas
            imageUrl != null && imageUrl!.isNotEmpty
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      imageUrl!,
                      height: 150,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return Center(
                          child: CircularProgressIndicator(
                            value: loadingProgress.expectedTotalBytes != null
                                ? loadingProgress.cumulativeBytesLoaded /
                                    (loadingProgress.expectedTotalBytes!)
                                : null,
                          ),
                        );
                      },
                      errorBuilder: (context, error, stackTrace) => Container(
                        height: 150,
                        color: Colors.grey[200],
                        child: Icon(
                          Icons.broken_image,
                          size: 50,
                          color: Colors.grey,
                        ),
                      ),
                    ),
                  )
                : Container(
                    height: 150,
                    color: Colors.grey[200],
                    child: Icon(Icons.image, size: 50, color: Colors.grey),
                  ),
            SizedBox(height: 16),
            // Judul
            Text(
              title,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.deepPurple,
              ),
              overflow: TextOverflow.ellipsis,
            ),
            SizedBox(height: 8),
            // Tanggal diterbitkan
            Text(
              "Published: ${formatDate(date)}",
              style: TextStyle(
                fontSize: 14,
                color: Colors.black54,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
