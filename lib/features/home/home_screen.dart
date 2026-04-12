import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intern/features/map/map_screen.dart';
import 'package:intl/intl.dart';
import 'package:intern/core/utils/responsive.dart';
import 'package:intern/features/home/home_provider.dart';
import 'package:intern/features/home/home_utils/trips_type.dart';
import 'package:intern/features/home/home_utils/enry_fields.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  late TextEditingController pickupController;
  late TextEditingController dropController;
  late TextEditingController dateController;
  late TextEditingController timeController;

  @override
  void initState() {
    super.initState();
    pickupController = TextEditingController();
    dropController = TextEditingController();
    dateController = TextEditingController();
    timeController = TextEditingController();
  }

  @override
  void dispose() {
    pickupController.dispose();
    dropController.dispose();
    dateController.dispose();
    timeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: Color(0xFF212728),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.all(ResponsiveUi.widhtPercent(context, 4)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: ResponsiveUi.heightPercent(context, 2)),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    SizedBox(
                      height: ResponsiveUi.heightPercent(context, 8),
                      child: Image.asset(
                        'assets/images/yatri.png',
                        fit: BoxFit.contain,
                      ),
                    ),
                    Icon(Icons.notifications_active, color: Colors.white),
                  ],
                ),
                SizedBox(height: 15),
                RichText(
                  text: TextSpan(
                    text: "India's Leading ",
                    style: GoogleFonts.poppins(
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                    children: [
                      TextSpan(
                        text: "Inter-City One Way ",
                        style: GoogleFonts.poppins(
                          fontSize: 24,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF38B000),
                        ),
                      ),
                      TextSpan(
                        text: "Cab Service Provider",
                        style: GoogleFonts.poppins(
                          fontSize: 24,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),

                Container(
                  height: 132,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    color: Colors.grey,
                    image: DecorationImage(
                      image: AssetImage('assets/images/cab.jpg'),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),

                SizedBox(height: 15),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    TripsType(
                      imageName: 'pickup',
                      text: 'Outstation trip',
                      color: Colors.white,
                      height: 80,
                      textColor: Color(0xFF38B000),
                    ),
                    TripsType(
                      imageName: 'train',
                      text: 'Local Trip',
                      color: Colors.white,
                      height: 80,
                      textColor: Color(0xFF38B000),
                    ),
                    TripsType(
                      imageName: 'flight',
                      text: 'Airport Transfer',
                      color: Colors.white,
                      height: 80,
                      textColor: Color(0xFF38B000),
                    ),
                  ],
                ),
                SizedBox(height: 15),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    TripsType(
                      text: "One-way",
                      color: Color(0xFF38B000),
                      height: 40,
                      width: 140,
                      textColor: Colors.white,
                    ),
                    TripsType(
                      text: "Round Trip",
                      color: Color(0xFF38B000),
                      height: 40,
                      width: 140,
                      textColor: Colors.white,
                    ),
                  ],
                ),

                SizedBox(height: 15),

                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        SearchInputField(
                          label: 'Pick-up City',
                          hint: 'Type City Name',
                          icon: Icons.location_on,
                          backgroundColor: const Color(0xFFC8E6C9),
                          height: 60,
                          controller: pickupController,
                          onChanged: (val) =>
                              ref.read(bookingProvider.notifier).setPick(val),
                        ),

                        SizedBox(
                          height: ResponsiveUi.heightPercent(context, 2),
                        ),

                        SearchInputField(
                          label: 'Drop City',
                          hint: 'Type City Name',
                          icon: Icons.flag,
                          backgroundColor: const Color(0xFFC8E6C9),
                          height: 60,
                          controller: dropController,
                          onChanged: (val) =>
                              ref.read(bookingProvider.notifier).setDrop(val),
                        ),

                        SizedBox(
                          height: ResponsiveUi.heightPercent(context, 2),
                        ),

                        SearchInputField(
                          label: 'Pick-up Date',
                          hint: 'DD-MM-YYYY',
                          icon: Icons.calendar_today,
                          backgroundColor: const Color(0xFFC8E6C9),
                          height: 60,
                          fieldType: FieldType.date,
                          controller: dateController,
                          onTap: () async {
                            DateTime? picked = await showDatePicker(
                              context: context,
                              initialDate: DateTime.now(),
                              firstDate: DateTime.now(),
                              lastDate: DateTime(2100),
                            );
                            if (picked != null) {
                              String formattedDate = DateFormat(
                                'dd-MM-yyyy',
                              ).format(picked);
                              dateController.text = formattedDate;
                              ref
                                  .read(bookingProvider.notifier)
                                  .setDate(formattedDate);
                            }
                          },
                        ),

                        SizedBox(
                          height: ResponsiveUi.heightPercent(context, 2),
                        ),

                        SearchInputField(
                          label: 'Time',
                          hint: 'HH:MM',
                          icon: Icons.access_time,
                          backgroundColor: const Color(0xFFC8E6C9),
                          height: 60,
                          fieldType: FieldType.time,
                          controller: timeController,
                          onTap: () async {
                            TimeOfDay? picked = await showTimePicker(
                              context: context,
                              initialTime: TimeOfDay.now(),
                            );
                            if (picked != null) {
                              String formattedTime = picked.format(context);
                              timeController.text = formattedTime;
                              ref
                                  .read(bookingProvider.notifier)
                                  .setTime(formattedTime);
                            }
                          },
                        ),

                        SizedBox(
                          height: ResponsiveUi.heightPercent(context, 3),
                        ),

                        SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: ElevatedButton(
                            onPressed: () {
                              final booking = ref.read(bookingProvider);
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => MapScreen(
                                    pickup: booking.pickup,
                                    drop: booking.drop,
                                  ),
                                ),
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF38B000),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                            child: Text(
                              'Explore Cabs',
                              style: GoogleFonts.poppins(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
