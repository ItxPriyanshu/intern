// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter_riverpod/legacy.dart';

class Booking {
  final String pickup;
  final String drop;
  final String date;
  final String time;


  Booking({
    this.pickup = '',
    this.drop = '',
    this.date = '',
    this.time = '',
  });

  Booking copyWith({
    String? pickup,
    String? drop,
    String? date,
    String? time,
  }) {
    return Booking(
      pickup: pickup ?? this.pickup,
      drop: drop ?? this.drop,
      date: date ?? this.date,
      time: time ?? this.time,
    );
  }
}


class BookingNotifier extends StateNotifier<Booking>{
  BookingNotifier() : super(Booking());
  

  void setPick(String value){
    state = state.copyWith(pickup: value);
  }

  void setDrop(String value){
    state = state.copyWith(drop: value);
  }

  void setDate(String value){
    state = state.copyWith(date: value);
  }


  void setTime(String value){
    state = state.copyWith(time: value);
  }
}


final bookingProvider = StateNotifierProvider<BookingNotifier,Booking>((ref)=>BookingNotifier());
