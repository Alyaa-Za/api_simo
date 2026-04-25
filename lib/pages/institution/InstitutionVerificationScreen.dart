import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/ui/app_color.dart';
import '../../../core/api/api_s.dart';
import '../../../core/token_manager.dart';

class InstitutionVerificationScreen extends StatefulWidget {
  final String token;
  final int expiryMinutes;

  const InstitutionVerificationScreen({super.key, required this.token, required this.expiryMinutes});

  @override
  State<InstitutionVerificationScreen> createState() => _InstitutionVerificationScreenState();
}

class _InstitutionVerificationScreenState extends State<InstitutionVerificationScreen> {
  final List<TextEditingController> _controllers = List.generate(6, (index) => TextEditingController());
  final List<FocusNode> _focusNodes = List.generate(6, (index) => FocusNode());

  bool _isLoading = false;
  late int _timeLeft;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timeLeft = widget.expiryMinutes * 60;
    _startTimer();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_timeLeft > 0) {
        if (mounted) setState(() => _timeLeft--);
      } else {
        _timer?.cancel();
      }
    });
  }

  String _formatTime() {
    int m = _timeLeft ~/ 60;
    int s = _timeLeft % 60;
    return "${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}";
  }

  Future<void> _handleVerify() async {
    String fullCode = _controllers.map((c) => c.text).join();
    if (fullCode.length < 6) return;

    setState(() => _isLoading = true);
    try {
      final res = await ApiService().verifyRegistrationCode(widget.token, fullCode);
      await TokenManager.saveToken(res['data']['token']);

      if (!mounted) return;
      _showSuccessAndNavigate();
    } catch (e) {
      _showErrorSnackBar(e.toString().replaceAll("Exception: ", ""));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new, color: AppColors.textDark),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 25),
          child: Column(
            children: [
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.primaryBlue.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.mark_email_read_outlined, size: 60, color: AppColors.primaryBlue),
              ),
              const SizedBox(height: 30),
              Text("تحقق من بريدك الإلكتروني",
                  style: GoogleFonts.tajawal(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.textDark)),
              const SizedBox(height: 10),
              Text("لقد أرسلنا كود التحقق المكون من 6 أرقام إلى بريد المؤسسة، يرجى إدخاله للمتابعة.",
                  textAlign: TextAlign.center,
                  style: GoogleFonts.tajawal(fontSize: 14, color: Colors.grey, height: 1.5)),

              const SizedBox(height: 40),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: List.generate(6, (index) => _otpBox(index)),
              ),

              const SizedBox(height: 40),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.timer_outlined, size: 18, color: Colors.redAccent),
                  const SizedBox(width: 8),
                  Text("ينتهي الكود خلال: ", style: GoogleFonts.tajawal(color: Colors.grey)),
                  Text(_formatTime(), style: const TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold)),
                ],
              ),

              const SizedBox(height: 50),

              _isLoading
                  ? const CircularProgressIndicator()
                  : GestureDetector(
                onTap: _handleVerify,
                child: Container(
                  width: double.infinity,
                  height: 58,
                  decoration: BoxDecoration(
                    gradient: AppColors.buttonGradient,
                    borderRadius: BorderRadius.circular(18),
                    boxShadow: [BoxShadow(color: AppColors.primaryBlue.withOpacity(0.3), blurRadius: 12, offset: const Offset(0, 6))],
                  ),
                  child: Center(
                    child: Text("تأكيد وإنشاء الحساب",
                        style: GoogleFonts.tajawal(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                  ),
                ),
              ),

              const SizedBox(height: 25),

              TextButton(
                onPressed: _timeLeft == 0 ? () {
                  ApiService().resendVerificationCode(widget.token);
                  setState(() => _timeLeft = widget.expiryMinutes * 60);
                  _startTimer();
                } : null,
                child: Text(
                  "لم يصلك الكود؟ إعادة إرسال",
                  style: GoogleFonts.tajawal(
                      color: _timeLeft == 0 ? AppColors.primaryBlue : Colors.grey,
                      fontWeight: FontWeight.bold
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _otpBox(int index) {
    return Container(
      width: 50,
      height: 60,
      decoration: BoxDecoration(
        color: const Color(0xFFF5F9FF),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _focusNodes[index].hasFocus ? AppColors.primaryBlue : Colors.transparent, width: 2),
      ),
      child: TextField(
        controller: _controllers[index],
        focusNode: _focusNodes[index],
        textAlign: TextAlign.center,
        keyboardType: TextInputType.number,
        maxLength: 1,
        style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.primaryBlue),
        decoration: const InputDecoration(counterText: "", border: InputBorder.none),
        onChanged: (value) {
          if (value.isNotEmpty && index < 5) {
            _focusNodes[index + 1].requestFocus();
          } else if (value.isEmpty && index > 0) {
            _focusNodes[index - 1].requestFocus();
          }
          if (index == 5 && value.isNotEmpty) _handleVerify();
          setState(() {});
        },
      ),
    );
  }

  void _showSuccessAndNavigate() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.check_circle_rounded, color: Colors.green, size: 80),
              const SizedBox(height: 20),
              Text(
                "تم التحقق بنجاح! ",
                style: GoogleFonts.tajawal(fontWeight: FontWeight.bold, fontSize: 20),
              ),
              const SizedBox(height: 15),
              const Text(
                "تم إنشاء حساب مؤسستك بنجاح. يمكنك الآن تسجيل الدخول باستخدام بريدك الإلكتروني.",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14, color: Colors.grey),
              ),
              const SizedBox(height: 30),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryBlue,
                    shape: const StadiumBorder(),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  onPressed: () {
                    Navigator.pop(ctx);
                    Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
                  },
                  child: const Text("الذهاب لتسجيل الدخول", style: TextStyle(color: Colors.white)),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  void _showErrorSnackBar(String m) => ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(m), backgroundColor: Colors.red));

  @override
  void dispose() {
    _timer?.cancel();
    for (var node in _focusNodes) {
      node.dispose();
    }
    super.dispose();
  }
}
