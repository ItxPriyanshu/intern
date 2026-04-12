import 'package:flutter/material.dart';

class MapScreen extends StatefulWidget {
  final String pickup;
  final String drop;
  const MapScreen({
    Key? key,
    required this.pickup,
    required this.drop,
  }) : super(key: key);

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}