import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../../core/ui/app_color.dart';
import '../../../core/api/api_s.dart';
import '../../../core/token_manager.dart';
import '../../../core/theme/language_provider.dart';

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
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_timeLeft > 0) {
        if (mounted) setState(() => _timeLeft--);
      } else {
        _timer?.cancel();
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    for (var controller in _controllers) { controller.dispose(); }
    for (var node in _focusNodes) { node.dispose(); }
    super.dispose();
  }

  String _formatTime() {
    int m = _timeLeft ~/ 60;
    int s = _timeLeft % 60;
    return "${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}";
  }

  Future<void> _handleVerify(bool isAr) async {
    String fullCode = _controllers.map((c) => c.text).join();
    if (fullCode.length < 6) return;

    setState(() => _isLoading = true);
    try {
      final res = await ApiService().verifyRegistrationCode(widget.token, fullCode);
      if (res['data']?['token'] != null) {
        await TokenManager.saveToken(res['data']['token']);
      }

      if (!mounted) return;
      _showSuccessAndNavigate(isAr);
    } catch (e) {
      _showErrorSnackBar(e.toString().replaceAll("Exception: ", ""), isAr);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showErrorSnackBar(String msg, bool isAr) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg, style: GoogleFonts.tajawal()),
      backgroundColor: Colors.redAccent,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    ));
  }

  @override
  Widget build(BuildContext context) {
    final langProvider = Provider.of<LanguageProvider>(context);
    bool isAr = langProvider.locale.languageCode == 'ar';
    bool isDark = Theme.of(context).brightness == Brightness.dark;

    return Directionality(
      textDirection: isAr ? TextDirection.rtl : TextDirection.ltr,
      child: Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: Icon(isAr ? Icons.arrow_back_ios_new : Icons.arrow_forward_ios,
                color: isDark ? Colors.white : AppColors.textDark),
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
              Text(isAr ? "تحقق من بريدك الإلكتروني" : "Verify Your Email",
                  textAlign: TextAlign.center,
                  style: GoogleFonts.tajawal(fontSize: 22, fontWeight: FontWeight.bold, color: isDark ? Colors.white : AppColors.textDark)),
              const SizedBox(height: 12),
              Text(isAr
                  ? "لقد أرسلنا كود التحقق المكون من 6 أرقام إلى بريد المؤسسة، يرجى إدخاله للمتابعة."
                  : "We've sent a 6-digit verification code to your institution email. Please enter it to continue.",
                  textAlign: TextAlign.center,
                  style: GoogleFonts.tajawal(fontSize: 14, color: Colors.grey, height: 1.5)),

              const SizedBox(height: 40),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: List.generate(6, (index) => _otpBox(index, isDark, isAr)),
              ),

              const SizedBox(height: 40),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.timer_outlined, size: 18, color: Colors.redAccent),
                  const SizedBox(width: 8),
                  Text(isAr ? "ينتهي الكود خلال: " : "Code expires in: ",
                      style: GoogleFonts.tajawal(color: Colors.grey, fontSize: 13)),
                  Text(_formatTime(), style: const TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold)),
                ],
              ),

              const SizedBox(height: 50),

              _isLoading
                  ? const CircularProgressIndicator()
                  : GestureDetector(
                onTap: () => _handleVerify(isAr),
                child: Container(
                  width: double.infinity,
                  height: 60,
                  decoration: BoxDecoration(
                    gradient: AppColors.buttonGradient,
                    borderRadius: BorderRadius.circular(18),
                    boxShadow: [BoxShadow(color: AppColors.primaryBlue.withOpacity(0.3), blurRadius: 12, offset: const Offset(0, 6))],
                  ),
                  child: Center(
                    child: Text(isAr ? "تأكيد وإنشاء الحساب" : "Confirm & Create Account",
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
                  isAr ? "لم يصلك الكود؟ إعادة إرسال" : "Didn't get the code? Resend",
                  style: GoogleFonts.tajawal(
                      color: _timeLeft == 0 ? AppColors.primaryBlue : Colors.grey,
                      fontWeight: FontWeight.bold,
                      fontSize: 14
                  ),
                ),
              ),
              const SizedBox(height: 50),
            ],
          ),
        ),
      ),
    );
  }

  Widget _otpBox(int index, bool isDark, bool isAr) {
    return Container(
      width: 45,
      height: 60,
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : const Color(0xFFF5F9FF),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _focusNodes[index].hasFocus ? AppColors.primaryBlue : (isDark ? Colors.white10 : Colors.transparent), width: 2),
      ),
      child: TextField(
        controller: _controllers[index],
        focusNode: _focusNodes[index],
        textAlign: TextAlign.center,
        keyboardType: TextInputType.number,
        maxLength: 1,
        style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: isDark ? Colors.white : AppColors.primaryBlue),
        decoration: const InputDecoration(counterText: "", border: InputBorder.none),
        onChanged: (value) {
          if (value.isNotEmpty && index < 5) {
            _focusNodes[index + 1].requestFocus();
          } else if (value.isEmpty && index > 0) {
            _focusNodes[index - 1].requestFocus();
          }
          if (index == 5 && value.isNotEmpty) _handleVerify(isAr);
          setState(() {});
        },
      ),
    );
  }

  void _showSuccessAndNavigate(bool isAr) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => Directionality(
        textDirection: isAr ? TextDirection.rtl : TextDirection.ltr,
        child: AlertDialog(
          backgroundColor: Theme.of(context).cardColor,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.check_circle_rounded, color: Colors.green, size: 80),
              const SizedBox(height: 20),
              Text(
                isAr ? "تم التحقق بنجاح! " : "Verified Successfully! ",
                style: GoogleFonts.tajawal(fontWeight: FontWeight.bold, fontSize: 18),
              ),
              const SizedBox(height: 15),
              Text(
                isAr
                    ? "تم إنشاء حساب مؤسستك بنجاح. يمكنك الآن تسجيل الدخول باستخدام بريدك الإلكتروني."
                    : "Your institution account has been created successfully. You can now login using your email.",
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 13, color: Colors.grey),
              ),
              const SizedBox(height: 30),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryBlue,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                  ),
                  onPressed: () {
                    Navigator.pop(ctx);
                    Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
                  },
                  child: Text(isAr ? "الذهاب لتسجيل الدخول" : "Go to Login",
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
