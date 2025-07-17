import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/friend_service.dart';
import '../utils/app_theme.dart';

class FriendsScreenSimple extends StatefulWidget {
  const FriendsScreenSimple({super.key});

  @override
  State<FriendsScreenSimple> createState() => _FriendsScreenSimpleState();
}

class _FriendsScreenSimpleState extends State<FriendsScreenSimple> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Club',
          style: TextStyle(
            color: Colors.black,
            fontSize: 32,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Consumer<FriendService>(
        builder: (context, friendService, child) {
          return const Center(
            child: Text('Friends Screen - Simple Version'),
          );
        },
      ),
    );
  }
}