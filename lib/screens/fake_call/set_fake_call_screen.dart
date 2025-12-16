import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:safest/config/routes.dart';
import 'package:safest/screens/fake_call/fake_calling_screen.dart';

class SetFakeCallScreen extends StatefulWidget {
  const SetFakeCallScreen({Key? key}) : super(key: key);

  @override
  _SetFakeCallScreenState createState() => _SetFakeCallScreenState();
}

class _SetFakeCallScreenState extends State<SetFakeCallScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();

  int? _selectedTimeIndex;

  final List<String> _callTimes = [
    "Immediately",
    "In 10 seconds",
    "In 30 seconds",
    "In 1 minute",
    "In 3 minutes",
    "In 5 minutes",
  ];

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final buttonWidth =
        (screenWidth - (screenWidth * 0.06 * 2) - (screenWidth * 0.03)) / 2;

    return Scaffold(
      backgroundColor: Colors.white,

      body: SingleChildScrollView(
        padding: EdgeInsets.only(
          top: screenHeight * 0.08,
          left: screenWidth * 0.06,
          right: screenWidth * 0.06,
          bottom: screenHeight * 0.02,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Judul
            Text(
              "Set Fake Call",
              style: TextStyle(
                fontSize: screenWidth * 0.07,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF5A00D0),
              ),
            ),
            SizedBox(height: screenHeight * 0.015),

            // Deskripsi
            Text(
              "Your phone will ring and display a call screen, "
              "to make it look like you’re getting a call from someone specific.",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: screenWidth * 0.035,
                color: Colors.grey[700],
                height: 1.4,
              ),
            ),
            SizedBox(height: screenHeight * 0.02),

            // Input manual title
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "Enter manually",
                style: TextStyle(
                  fontSize: screenWidth * 0.04,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF512DAB),
                ),
              ),
            ),
            SizedBox(height: screenHeight * 0.015),

            // Input nama
            TextField(
              controller: _nameController,
              decoration: InputDecoration(
                hintText: "Enter caller name",
                filled: true,
                fillColor: Colors.white,
                contentPadding: EdgeInsets.symmetric(
                  vertical: screenHeight * 0.02,
                  horizontal: screenWidth * 0.04,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(screenWidth * 0.03),
                  borderSide: BorderSide(
                    color: Colors.grey.shade400,
                    width: 1.5,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(screenWidth * 0.03),
                  borderSide: const BorderSide(
                    color: Color(0xFF5A00D0),
                    width: 2.0,
                  ),
                ),
              ),
              style: TextStyle(fontSize: screenWidth * 0.04),
            ),

            SizedBox(height: screenHeight * 0.02),

            // Input nomor
            TextField(
              controller: _phoneController,
              keyboardType: TextInputType.phone,
              decoration: InputDecoration(
                hintText: "Enter phone number",
                filled: true,
                fillColor: Colors.white,
                contentPadding: EdgeInsets.symmetric(
                  vertical: screenHeight * 0.02,
                  horizontal: screenWidth * 0.04,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(screenWidth * 0.03),
                  borderSide: BorderSide(
                    color: Colors.grey.shade400,
                    width: 1.5,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(screenWidth * 0.03),
                  borderSide: const BorderSide(
                    color: Color(0xFF5A00D0),
                    width: 2.0,
                  ),
                ),
              ),
              style: TextStyle(fontSize: screenWidth * 0.04),
            ),

            SizedBox(height: screenHeight * 0.02),

            // Call Time title
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "Call Time",
                style: TextStyle(
                  fontSize: screenWidth * 0.04,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF512DAB),
                ),
              ),
            ),
            SizedBox(height: screenHeight * 0.015),

            // Grid tombol waktu (simetris)
            Wrap(
              spacing: screenWidth * 0.03,
              runSpacing: screenHeight * 0.015,
              children: List.generate(_callTimes.length, (index) {
                final isSelected = _selectedTimeIndex == index;
                return GestureDetector(
                  onTap: () {
                    setState(() => _selectedTimeIndex = index);
                  },
                  child: Container(
                    width: buttonWidth,
                    alignment: Alignment.center,
                    padding: EdgeInsets.symmetric(
                      vertical: screenHeight * 0.018,
                    ),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? const Color(0xFF5A00D0)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(screenWidth * 0.025),
                      border: Border.all(
                        color: const Color(0xFF5A00D0),
                        width: 1.5,
                      ),
                    ),
                    child: Text(
                      _callTimes[index],
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: isSelected
                            ? Colors.white
                            : const Color(0xFF5A00D0),
                        fontWeight: isSelected
                            ? FontWeight.w600
                            : FontWeight.w500,
                        fontSize: screenWidth * 0.035,
                      ),
                    ),
                  ),
                );
              }),
            ),

            SizedBox(height: screenHeight * 0.02),

            // Tombol Start Fake Call
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  context.push(
                    AppRoutes.fakeCalling,
                    extra: {
                      'name': _nameController.text,
                      'phone': _phoneController.text,
                      'callTime': _callTimes[_selectedTimeIndex!],
                    },
                  );
                },

                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF5A00D0),
                  padding: EdgeInsets.symmetric(vertical: screenHeight * 0.02),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(screenWidth * 0.03),
                  ),
                ),
                child: Text(
                  "Start Fake Call",
                  style: TextStyle(
                    fontSize: screenWidth * 0.045,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
