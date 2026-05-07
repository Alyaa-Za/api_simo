import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../../core/ui/app_color.dart';
import '../../../core/api/api_s.dart';
import '../../../core/theme/language_provider.dart';

class AdminManageStudents extends StatefulWidget {
  const AdminManageStudents({super.key});

  @override
  State<AdminManageStudents> createState() => _AdminManageStudentsState();
}

class _AdminManageStudentsState extends State<AdminManageStudents> {
  void _refresh() => setState(() {});

  @override
  Widget build(BuildContext context) {
    final isAr = Provider.of<LanguageProvider>(context).locale.languageCode == 'ar';
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Directionality(
      textDirection: isAr ? TextDirection.rtl : TextDirection.ltr,
      child: Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        body: FutureBuilder<List<dynamic>>(
          future: ApiService().getAdminStudents(), // استدعاء دالة جلب الطلاب
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError) {
              return Center(
                child: Text(
                  isAr ? "حدث خطأ في الاتصال بالسيرفر" : "Server Connection Error",
                  style: const TextStyle(color: Colors.red),
                ),
              );
            }

            // ── [تأمين الداتا غصب مَسْطرة ملان العين] ──
            final dynamic rawData = snapshot.data;
            final List<dynamic> list = (rawData is Map && rawData.containsKey('data'))
                ? (rawData['data'] ?? [])
                : (rawData is List ? rawData : []);

            if (list.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.people_outline, size: 60, color: Colors.grey.withOpacity(0.3)),
                    const SizedBox(height: 10),
                    Text(isAr ? "لا توجد سجلات للطلاب حالياً" : "No records found", style: const TextStyle(color: Colors.grey)),
                  ],
                ),
              );
            }

            return ListView.builder(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 110),
              physics: const BouncingScrollPhysics(),
              itemCount: list.length,
              itemBuilder: (context, index) {
                final student = list[index];
                final String name = student['full_name'] ?? "---";
                final String status = student['status'] ?? "inactive";

                return Container(
                  margin: const EdgeInsets.only(bottom: 15),
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF1E293B) : Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10)],
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          CircleAvatar(
                            radius: 25,
                            backgroundColor: AppColors.primaryBlue.withOpacity(0.1),
                            child: Text(
                                name.isNotEmpty ? name.substring(0,1).toUpperCase() : "S",
                                style: const TextStyle(color: AppColors.primaryBlue, fontWeight: FontWeight.bold)
                            ),
                          ),
                          const SizedBox(width: 15),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(name, style: GoogleFonts.tajawal(fontWeight: FontWeight.bold, fontSize: 14)),
                                Text(student['email'] ?? "---", style: const TextStyle(fontSize: 11, color: Colors.grey)),
                              ],
                            ),
                          ),
                          // ── [زر السويتش لتفعيل أو إيقاف الطالب مَسْطرة] ──
                          Switch(
                            value: status == 'active',
                            activeColor: Colors.green,
                            onChanged: (val) async {
                              final String newStatus = val ? 'active' : 'inactive';
                              try {
                                // استدعاء دالة تغيير الحالة من ملفك بالملي
                                await ApiService().changeStudentStatus(student['student_id'] ?? student['id'], newStatus);
                                _refresh();
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(isAr ? "تم تحديث حالة الحساب بنجاح ✅" : "Account status updated ✅"),
                                    backgroundColor: Colors.green,
                                  ),
                                );
                              } catch (e) {
                                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e")));
                              }
                            },
                          ),
                        ],
                      ),
                      const Divider(height: 30),

                      // ── [بيانات الطالب التفصيلية] ──
                      _infoRow(isAr ? "الرقم الأكاديمي:" : "Student ID:", "${student['student_number'] ?? '---'}", isDark),
                      _infoRow(isAr ? "التخصص:" : "Major:", student['department'] ?? "---", isDark),
                      _infoRow(isAr ? "المستوى الدراسي:" : "Level:", student['level'] ?? "---", isDark),
                      _infoRow(isAr ? "المعدل التراكمي:" : "GPA:", "${student['gpa'] ?? '0.00'}", isDark),
                    ],
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }

  Widget _infoRow(String label, String value, bool isDark) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Text(label, style: const TextStyle(color: Colors.grey, fontSize: 12, fontWeight: FontWeight.bold)),
          const SizedBox(width: 8),
          Expanded(child: Text(value, style: TextStyle(fontSize: 12, color: isDark ? Colors.white : Colors.black87))),
        ],
      ),
    );
  }
}
