import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/api/api_s.dart';
import '../../../core/ui/app_color.dart';

class AttendanceScreen extends StatefulWidget {
  const AttendanceScreen({super.key});

  @override
  State<AttendanceScreen> createState() => _AttendanceScreenState();
}

class _AttendanceScreenState extends State<AttendanceScreen> {

  Future<Map<String, dynamic>> _fetchAttendanceData() async {
    final response = await ApiService().getMyInternship();
    return response['data']['attendance_summary'] ?? {
      "present": "0",
      "absent": "0",
      "late": "0",
      "logs": []
    };
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FD),
      appBar: AppBar(
        title: const Text("سجل الحضور والغياب"),
        backgroundColor: AppColors.primaryBlue,
        centerTitle: true,
        elevation: 0,
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: _fetchAttendanceData(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final data = snapshot.data!;
          final List logs = data['logs'] ?? [];

          return Column(
            children: [
              Container(
                margin: const EdgeInsets.all(20),
                padding: const EdgeInsets.symmetric(vertical: 25),
                decoration: BoxDecoration(
                  gradient: AppColors.buttonGradient,
                  borderRadius: BorderRadius.circular(25),
                  boxShadow: [BoxShadow(color: AppColors.primaryBlue.withOpacity(0.3), blurRadius: 15)],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _StatItem(label: "أيام الحضور", value: data['present'].toString()),
                    _StatItem(label: "أيام الغياب", value: data['absent'].toString()),
                    _StatItem(label: "التأخير", value: data['late'].toString()),
                  ],
                ),
              ),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 10),
                child: Align(
                  alignment: Alignment.centerRight,
                  child: Text("سجل السجلات اليومية",
                      style: GoogleFonts.tajawal(fontWeight: FontWeight.bold, fontSize: 16)),
                ),
              ),

              Expanded(
                child: logs.isEmpty
                    ? _buildEmptyState()
                    : ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  itemCount: logs.length,
                  itemBuilder: (context, index) => _buildAttendanceTile(logs[index]),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildAttendanceTile(Map<String, dynamic> log) {
    bool isPresent = log['status'] == 'present';
    Color statusColor = isPresent ? Colors.green : Colors.redAccent;
    String statusText = isPresent ? "حاضر" : "غائب";

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10)],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: statusColor.withOpacity(0.1), shape: BoxShape.circle),
            child: Icon(isPresent ? Icons.check_circle_outline : Icons.highlight_off, color: statusColor),
          ),
          const SizedBox(width: 15),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(log['date'] ?? "", style: GoogleFonts.tajawal(fontWeight: FontWeight.bold)),
              Text("وقت التسجيل: ${log['time'] ?? '--:--'}",
                  style: const TextStyle(color: Colors.grey, fontSize: 12)),
            ],
          ),
          const Spacer(),
          Text(statusText,
              style: GoogleFonts.tajawal(color: statusColor, fontWeight: FontWeight.bold, fontSize: 13)),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.event_note_rounded, size: 60, color: Colors.grey.shade300),
          const SizedBox(height: 10),
          Text("لا توجد سجلات حضور مسجلة بعد", style: GoogleFonts.tajawal(color: Colors.grey)),
        ],
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final String label, value;
  const _StatItem({required this.label, required this.value});
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(value, style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        Text(label, style: GoogleFonts.tajawal(color: Colors.white70, fontSize: 12)),
      ],
    );
  }
}
