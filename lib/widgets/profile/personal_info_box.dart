import 'package:flutter/material.dart';

class PersonalInformationBox extends StatelessWidget {
  final String firstName;
  final String lastName;
  final String phone;
  final String email;
  final String city;
  final String country;
  final String address;
  final String postCode;

  const PersonalInformationBox({
    super.key,
    required this.firstName,
    required this.lastName,
    required this.phone,
    required this.email,
    required this.city,
    required this.country,
    required this.address,
    required this.postCode,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(25),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: _buildInfoField('First Name', firstName)),
              const SizedBox(width: 10),
              Expanded(child: _buildInfoField('Last Name', lastName)),
            ],
          ),
          const SizedBox(height: 15),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: _buildInfoField('Phone Number', phone)),
              const SizedBox(width: 10),
              Expanded(child: _buildInfoField('Post Code', postCode)),
            ],
          ),
          const SizedBox(height: 15),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: _buildInfoField('City', city)),
              const SizedBox(width: 10),
              Expanded(child: _buildInfoField('Country', country)),
            ],
          ),
          const SizedBox(height: 15),
          _buildInfoField('Email', email.isNotEmpty ? email : '-'),
          const SizedBox(height: 15),
          _buildInfoField('Street Address', address),
        ],
      ),
    );
  }

  Widget _buildInfoField(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
              fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black),
        ),
        const SizedBox(height: 4),
        Text(
          value.isNotEmpty ? value : '-',
          style: TextStyle(fontSize: 14, color: Colors.grey[700], height: 1.3),
        ),
      ],
    );
  }
}