import 'package:flutter/material.dart';

typedef OnSaveItinerary = void Function(String day, List<String> activities);

void showItineraryDialog({
  required BuildContext context,
  required bool isEditing,
  String? existingDay,
  List<String>? existingActivities,
  required OnSaveItinerary onSave,
}) {
  final TextEditingController dayController = TextEditingController(
    text: isEditing ? existingDay?.replaceAll(RegExp(r'\D'), '') ?? '' : '',
  );

  List<TextEditingController> timeControllers = [];
  List<TextEditingController> activityControllers = [];
  List<String> selectedAmPm = [];

  final List<String> amPmOptions = ["AM", "PM"];

  if (isEditing && existingActivities != null) {
    for (var activity in existingActivities) {
      final parts = activity.split(" - ");
      final timeParts = parts[0].split(" ");
      timeControllers.add(TextEditingController(text: timeParts[0])); // HH
      selectedAmPm.add(timeParts[1]);
      activityControllers.add(TextEditingController(text: parts[1]));
    }
  } else {
    timeControllers.add(TextEditingController());
    activityControllers.add(TextEditingController());
    selectedAmPm.add("AM");
  }

  showDialog(
    context: context,
    builder: (context) {
      return StatefulBuilder(
        builder: (context, setDialogState) {
          return Dialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            backgroundColor: const Color(0xFF2C2C2E),
            child: Container(
              padding: const EdgeInsets.all(20),
              width: MediaQuery.of(context).size.width * 0.85,
              height: MediaQuery.of(context).size.height * 0.7,
              child: Column(
                children: [
                  const Text(
                    "Itinerary Details",
                    style: TextStyle(fontSize: 20, color: Colors.white,),
                  ),
                  const SizedBox(height: 14),
                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        children: [
                          Row(
                            children: [
                              const Text("Day:", style: TextStyle(fontSize: 16, color: Colors.white)),
                              const SizedBox(width: 10),
                              Expanded(
                                child: TextField(
                                  controller: dayController,
                                  keyboardType: TextInputType.number,
                                  style: TextStyle(color: Colors.white70),
                                  decoration: _peachOutlineInput("Enter number"),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          ...List.generate(timeControllers.length, (index) {
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 16),
                              child: Column(
                                children: [
                                  Row(
                                    children: [
                                      SizedBox(
                                        width: 70,
                                        child: TextField(
                                          controller: timeControllers[index],
                                          keyboardType: TextInputType.number,
                                          style: const TextStyle(color: Colors.white70),
                                          decoration: _peachOutlineInput("Hour"),
                                        ),
                                      ),
                                      const SizedBox(width: 10),
                                      SizedBox(
                                        width: 80,
                                        child: DropdownButtonFormField<String>(
                                          value: selectedAmPm[index],
                                          dropdownColor: const Color(0xFF3A3A3C),
                                          decoration: _peachOutlineInput(null),
                                          items: amPmOptions.map((String value) {
                                            return DropdownMenuItem<String>(
                                              value: value,
                                              child: Text(value, style: const TextStyle(color: Colors.white70)),
                                            );
                                          }).toList(),
                                          onChanged: (newValue) {
                                            setDialogState(() {
                                              selectedAmPm[index] = newValue!;
                                            });
                                          },
                                        ),
                                      ),
                                      const Spacer(),
                                      IconButton(
                                        icon: const Icon(Icons.delete_outlined, color: Color(0xFFD76C5B)),
                                        onPressed: () {
                                          setDialogState(() {
                                            timeControllers.removeAt(index);
                                            activityControllers.removeAt(index);
                                            selectedAmPm.removeAt(index);
                                          });
                                        },
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  TextField(
                                    controller: activityControllers[index],
                                    style: const TextStyle(color: Colors.white70),
                                    decoration: _peachOutlineInput("Activity"),
                                  ),
                                ],
                              ),
                            );
                          }),
                          const SizedBox(height: 8),
                          TextButton(
                            onPressed: () {
                              setDialogState(() {
                                timeControllers.add(TextEditingController());
                                activityControllers.add(TextEditingController());
                                selectedAmPm.add("AM");
                              });
                            },
                            child: const Text(
                              "+ Add Another Activity",
                              style: TextStyle(
                                color: Color(0xFFD76C5B),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text(
                          "Cancel",
                          style: TextStyle(color: Color(0xFFD76C5B)),
                        ),
                      ),
                      const SizedBox(width: 8),
                      TextButton(
                        onPressed: () {
                          if (dayController.text.isNotEmpty) {
                            List<String> activities = [];
                            for (int i = 0; i < timeControllers.length; i++) {
                              if (timeControllers[i].text.isNotEmpty &&
                                  activityControllers[i].text.isNotEmpty) {
                                activities.add(
                                  "${timeControllers[i].text} ${selectedAmPm[i]} - ${activityControllers[i].text}",
                                );
                              }
                            }
                            if (activities.isNotEmpty) {
                              final day = "Day ${dayController.text}";
                              onSave(day, activities);
                              Navigator.pop(context);
                            }
                          }
                        },
                        child: Text(
                          isEditing ? "Update" : "Add",
                          style: const TextStyle(
                            color: Colors.white70,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      );
    },
  );
}

InputDecoration _peachOutlineInput(String? label) {
  return InputDecoration(
    labelText: label,
    labelStyle: const TextStyle(color: Colors.white70),
    filled: true,
    fillColor: const Color(0xFF3A3A3C),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide.none,
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: Color(0xFFF4CBB2), width: 1.5),
    ),
    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
  );
}

