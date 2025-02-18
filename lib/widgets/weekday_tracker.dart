import 'package:flutter/material.dart';

class WeekdayTracker extends StatelessWidget {
  const WeekdayTracker({super.key});

  @override
  Widget build(BuildContext context) {
    final today = DateTime.now().weekday;
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildDayCircle('M', 1, today),
          _buildDayCircle('T', 2, today),
          _buildDayCircle('W', 3, today),
          _buildDayCircle('T', 4, today),
          _buildDayCircle('F', 5, today),
          _buildDayCircle('S', 6, today),
          _buildDayCircle('S', 7, today),
        ],
      ),
    );
  }

  Widget _buildDayCircle(String day, int weekday, int today) {
    final isToday = weekday == today;
    final isPast = weekday < today;

    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: isToday ? Colors.green : Colors.transparent,
        border: Border.all(
          color: Colors.white,
          width: 2,
        ),
      ),
      child: Center(
        child: Text(
          day,
          style: TextStyle(
            color: Colors.white,
            fontWeight: isPast || isToday ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }
}
