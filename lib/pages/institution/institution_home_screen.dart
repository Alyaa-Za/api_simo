import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/ui/app_color.dart';
import '../../widgets/bubble_background.dart';
import '../../widgets/shared/home_app_bar.dart';
import '../../widgets/shared/stat_card.dart';
import '../../widgets/shared/action_card.dart';
import '../../widgets/shared/application_card.dart';

class InstitutionHomeScreen extends StatelessWidget {
  const InstitutionHomeScreen({super.key});

  // ── Static Data ───────────────────────────────────────────────
  static const _stats = [
    (icon: Icons.people_outline_rounded,      label: 'Trainees',  value: '12', color: AppColors.primaryBlue),
    (icon: Icons.inbox_outlined,              label: 'Requests',  value: '5',  color: Color(0xFFFF9500)),
    (icon: Icons.business_center_outlined,    label: 'Positions', value: '8',  color: Color(0xFF9B59B6)),
  ];

  static const _actions = [
    (icon: Icons.post_add_rounded,      label: 'Post Position', color: AppColors.primaryBlue),
    (icon: Icons.inbox_rounded,         label: 'View Requests', color: Color(0xFFFF9500)),
    (icon: Icons.people_rounded,        label: 'My Trainees',   color: Color(0xFF34C759)),
    (icon: Icons.bar_chart_rounded,     label: 'Reports',       color: Color(0xFF9B59B6)),
  ];

  static const _requests = [
    (name: 'Ahmed Al-Rashidi', position: 'Software Engineering Intern', letter: 'A', color: AppColors.primaryBlue),
    (name: 'Sara Al-Qahtani',  position: 'Data Analysis Intern',        letter: 'S', color: Color(0xFF9B59B6)),
    (name: 'Omar Al-Harbi',    position: 'UI/UX Design Intern',         letter: 'O', color: Color(0xFF34C759)),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BubbleBackground(
        style: BubbleStyle.onboarding,
        child: SafeArea(
          child: Column(
            children: [
              // ── AppBar ──────────────────────────────────────
              const HomeAppBar(
                title: 'Institution Portal',
                subtitle: 'Manage your training 🏢',
                icon: Icons.business_rounded,
              ),

              // ── Scrollable Content ───────────────────────────
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Stats
                      Row(
                        children: _stats
                            .map((s) => StatCard(
                          icon: s.icon,
                          label: s.label,
                          value: s.value,
                          color: s.color,
                        ))
                            .toList(),
                      ),

                      const SizedBox(height: 24),
                      _sectionTitle('Quick Actions'),
                      const SizedBox(height: 14),

                      // Actions Grid
                      GridView.count(
                        crossAxisCount: 2,
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                        childAspectRatio: 1.4,
                        children: _actions
                            .map((a) => ActionCard(
                          icon: a.icon,
                          label: a.label,
                          color: a.color,
                        ))
                            .toList(),
                      ),

                      const SizedBox(height: 24),
                      _sectionTitle('Recent Requests'),
                      const SizedBox(height: 14),

                      // Requests
                      ..._requests.map((r) => Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: RequestCard(
                          name: r.name,
                          position: r.position,
                          avatarLetter: r.letter,
                          color: r.color,
                          onAccept: () {},
                          onReject: () {},
                        ),
                      )),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Text(
      title,
      style: GoogleFonts.inter(
        fontSize: 18,
        fontWeight: FontWeight.w700,
        color: AppColors.textDark,
      ),
    );
  }
}