import 'package:flutter/material.dart';

// 1. Import the specific pages for each workout category.
//    (Adjust these paths to match your project structure)
import 'package:arise/workouts/strength.dart';
import 'package:arise/workouts/cardio.dart';
import 'package:arise/workouts/stretching.dart';
import 'package:arise/workouts/warmup.dart';

// Renamed for clarity to better match the file name and purpose
class TrainerWorkoutsPage extends StatelessWidget {
  const TrainerWorkoutsPage({super.key});

  @override
  Widget build(BuildContext context) {
    // 2. Updated list: Removed dummy exercises and added a 'page' key
    //    to hold the destination widget for each category.
    final workoutCategories = [
      {
        "title": "Strength",
        "image": "assets/strenth.png",
        "page": const StrengthWorkoutsPage(),
      },
      {
        "title": "Cardio",
        "image": "assets/cardio.png",
        "page": const CardioWorkoutsPage(),
      },
      {
        "title": "Stretching",
        "image": "assets/stretching.png",
        "page": const StretchingWorkoutsPage(),
      },
      {
        "title": "Warmup",
        "image": "assets/warmup.png",
        "page": const WarmupWorkoutsPage(),
      },
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Workout Categories",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        // Using your app's theme color for consistency
        backgroundColor: const Color.fromARGB(255, 238, 255, 65),
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(12),
        itemCount: workoutCategories.length,
        itemBuilder: (context, index) {
          final category = workoutCategories[index];
          return GestureDetector(
            onTap: () {
              // 3. Updated Navigation: Pushes the specific page widget
              //    associated with the tapped category.
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => category["page"] as Widget),
              );
            },
            child: Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 3,
              margin: const EdgeInsets.symmetric(vertical: 10),
              child: Row(
                children: [
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Text(
                        category["title"] as String,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  ClipRRect(
                    borderRadius: const BorderRadius.only(
                      topRight: Radius.circular(12),
                      bottomRight: Radius.circular(12),
                    ),
                    child: Image.asset(
                      category["image"] as String,
                      width: 140,
                      height: 100,
                      fit: BoxFit.cover,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
