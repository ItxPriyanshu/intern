// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class TripsType extends StatelessWidget {
  final String? imageName;
  final String text;
  final Color color;
  final double height;
  final double? width;
  final Color textColor;
  const TripsType({
    Key? key,
    this.imageName,
    required this.text,
    required this.color,
    required this.height,
    this.width,
    required this.textColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      width: width,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (imageName != null && imageName!.isNotEmpty) ...[
              SizedBox(
                height: 30,
                width: 60,
                child: Image.asset(
                  'assets/images/$imageName.png',
                  fit: BoxFit.contain,
                ),
              ),
              const SizedBox(height: 4),
            ],
            Text(
              text,
              style: GoogleFonts.poppins(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: textColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
