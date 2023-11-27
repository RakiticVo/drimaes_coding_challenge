import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

class UserCard extends StatelessWidget {
  final String imageUrl;
  final String email;
  final String name;
  final bool isListView;

  const UserCard({super.key, required this.imageUrl, required this.email, required this.name, required this.isListView});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            height: isListView ? 200 : 120, // Adjust the height as needed
            decoration: BoxDecoration(
              borderRadius: BorderRadius.vertical(top: Radius.circular(12.0))
            ),
            child: CachedNetworkImage(
              imageUrl: imageUrl,
              placeholder: (context, url) => SizedBox(
                width: 60,
                height: 60,
                child: Center(child: CircularProgressIndicator())
              ), // You can customize the placeholder
              errorWidget: (context, url, error) => Icon(Icons.error),
              height: 120,
              fit: BoxFit.cover,
            ),
          ),
         SizedBox(height: 16.0,),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 2.0, horizontal: 4.0),
            child: Text(
              'Name: $name',
              style: const TextStyle(fontSize: 12),
              softWrap: true,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 2.0, horizontal: 4.0),
            child: Text(
              email,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                fontStyle: FontStyle.italic,
                color: Colors.blueAccent,
                decoration: TextDecoration.underline,
              ),
              softWrap: true,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}