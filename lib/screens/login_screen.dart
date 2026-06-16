import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../utils/app_colors.dart';
import '../services/auth_service.dart';
import '../services/localization_service.dart';
import 'main_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _usernameCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _confirmCtrl  = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  String _lang = 'fr';
  bool _isLogin = true, _showPw = false, _showConfirm = false,
       _loading = false;
  String? _error;

  @override void dispose() {
    _usernameCtrl.dispose(); _passwordCtrl.dispose(); _confirmCtrl.dispose();
    super.dispose();
  }

  String _t(String k) => LocalizationService.translate(k, _lang);

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    if (!_isLogin && _passwordCtrl.text != _confirmCtrl.text) {
      setState(() => _error = _t('passwords_not_match')); return;
    }
    setState(() { _loading = true; _error = null; });
    try {
      if (_isLogin) {
        final res = await AuthService().login(
          _usernameCtrl.text.trim(), _passwordCtrl.text);
        if (!mounted) return;
        if (res['success'] == true) {
          Navigator.pushReplacement(context, MaterialPageRoute(
            builder: (_) => MainScreen(
              username: _usernameCtrl.text.trim(),
              role: res['role'] ?? 'user')));
        } else { setState(() => _error = _t(res['code'] ?? 'error')); }
      } else {
        final res = await AuthService().registerUser(
          _usernameCtrl.text.trim(), _passwordCtrl.text, 'user');
        if (!mounted) return;
        if (res['success'] == true) {
          setState(() { _isLogin = true; _error = null; });
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(_t('registration_success')),
            backgroundColor: AppColors.success,
            behavior: SnackBarBehavior.floating));
        } else { setState(() => _error = _t(res['code'] ?? 'error')); }
      }
    } catch (e) { setState(() => _error = e.toString()); }
    finally { if (mounted) setState(() => _loading = false); }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        // Deep forest gradient — rich, not muddy
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF1E2A1E), Color(0xFF2D3D2A), Color(0xFF1A241A)],
            begin: Alignment.topLeft, end: Alignment.bottomRight,
            stops: [0.0, 0.5, 1.0])),
        child: Stack(children: [
          // ── Visible grid lines ─────────────────────────────────────────────
          Positioned.fill(child: CustomPaint(painter: _LoginGridPainter())),

          // ── Decorative circles ─────────────────────────────────────────────
          Positioned(top: -80, left: -80,
            child: Container(width: 300, height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.accent.withValues(alpha: 0.06)))),
          Positioned(bottom: -60, right: -60,
            child: Container(width: 250, height: 250,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.accentWarm.withValues(alpha: 0.06)))),

          // ── Language selector top right ────────────────────────────────────
          Positioned(top: 20, right: 24,
            child: SafeArea(child: _LangPicker(
              current: _lang,
              onChanged: (l) => setState(() => _lang = l)))),

          // ── Centered card ─────────────────────────────────────────────────
          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 48),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 420),
                child: Container(
                  padding: const EdgeInsets.all(40),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.3),
                        blurRadius: 60, offset: const Offset(0, 20)),
                      BoxShadow(
                        color: AppColors.accent.withValues(alpha: 0.1),
                        blurRadius: 20, offset: const Offset(0, 4)),
                    ]),
                  child: Column(mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Logo + brand inside card
                      Row(children: [
                        Container(
                          width: 42, height: 42,
                          decoration: BoxDecoration(
                            color: AppColors.sidebarBg,
                            borderRadius: BorderRadius.circular(10)),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: Image.asset('assets/images/images.jpg',
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => const Icon(
                                Icons.eco_rounded, color: Colors.white, size: 22)))),
                        const SizedBox(width: 10),
                        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          Text('MENANA', style: GoogleFonts.inter(
                            fontSize: 14, fontWeight: FontWeight.w800,
                            color: AppColors.textPrimary, letterSpacing: 0.5)),
                          Text('Organic Food', style: GoogleFonts.inter(
                            fontSize: 10, color: AppColors.textMuted)),
                        ]),
                      ]),
                      const SizedBox(height: 28),
                      const Divider(color: AppColors.border, height: 1),
                      const SizedBox(height: 24),

                      Text(_isLogin ? _t('login') : _t('register'),
                        style: GoogleFonts.playfairDisplay(
                          fontSize: 24, fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary, letterSpacing: -0.3)),
                      const SizedBox(height: 4),
                      Text(_isLogin
                        ? 'Connectez-vous a votre espace'
                        : 'Creez votre compte',
                        style: GoogleFonts.inter(
                          fontSize: 13, color: AppColors.textSecondary)),
                      const SizedBox(height: 24),

                      Form(key: _formKey, child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          _Field(label: _t('username'),
                            controller: _usernameCtrl,
                            icon: Icons.person_outline_rounded,
                            validator: (v) => (v == null || v.isEmpty)
                              ? _t('empty_fields') : null),
                          const SizedBox(height: 14),
                          _Field(label: _t('password'),
                            controller: _passwordCtrl,
                            icon: Icons.lock_outline_rounded,
                            obscure: !_showPw,
                            suffix: IconButton(
                              icon: Icon(_showPw
                                ? Icons.visibility_outlined
                                : Icons.visibility_off_outlined,
                                size: 18, color: AppColors.textMuted),
                              onPressed: () => setState(() => _showPw = !_showPw)),
                            validator: (v) {
                              if (v == null || v.isEmpty) return _t('empty_fields');
                              if (!_isLogin && v.length < 6) return _t('password_short');
                              return null;
                            }),
                          if (!_isLogin) ...[
                            const SizedBox(height: 14),
                            _Field(label: _t('confirm_password'),
                              controller: _confirmCtrl,
                              icon: Icons.lock_outline_rounded,
                              obscure: !_showConfirm,
                              suffix: IconButton(
                                icon: Icon(_showConfirm
                                  ? Icons.visibility_outlined
                                  : Icons.visibility_off_outlined,
                                  size: 18, color: AppColors.textMuted),
                                onPressed: () =>
                                  setState(() => _showConfirm = !_showConfirm)),
                              validator: (v) => (v == null || v.isEmpty)
                                ? _t('empty_fields') : null),
                          ],
                          if (_error != null) ...[
                            const SizedBox(height: 14),
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: AppColors.errorLight,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: AppColors.error.withValues(alpha: 0.3))),
                              child: Row(children: [
                                const Icon(Icons.error_outline,
                                  color: AppColors.error, size: 16),
                                const SizedBox(width: 8),
                                Expanded(child: Text(_error!,
                                  style: GoogleFonts.inter(
                                    fontSize: 12, color: AppColors.error))),
                              ])),
                          ],
                          const SizedBox(height: 22),
                          SizedBox(height: 48,
                            child: ElevatedButton(
                              onPressed: _loading ? null : _submit,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.sidebarBg,
                                foregroundColor: Colors.white,
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10))),
                              child: _loading
                                ? const SizedBox(width: 18, height: 18,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2, color: Colors.white))
                                : Text(_isLogin ? _t('login') : _t('create_account'),
                                    style: GoogleFonts.inter(
                                      fontWeight: FontWeight.w600, fontSize: 14)))),
                          const SizedBox(height: 14),
                          Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                            Text(_isLogin ? _t('no_account') : _t('have_account'),
                              style: GoogleFonts.inter(
                                fontSize: 12, color: AppColors.textSecondary)),
                            TextButton(
                              style: TextButton.styleFrom(
                                padding: const EdgeInsets.only(left: 4),
                                minimumSize: Size.zero,
                                tapTargetSize: MaterialTapTargetSize.shrinkWrap),
                              onPressed: () => setState(() {
                                _isLogin = !_isLogin; _error = null;
                                _passwordCtrl.clear(); _confirmCtrl.clear();
                              }),
                              child: Text(_isLogin
                                ? _t('create_account') : _t('login'),
                                style: GoogleFonts.inter(
                                  fontSize: 12, fontWeight: FontWeight.w600,
                                  color: AppColors.accent))),
                          ]),
                        ],
                      )),
                    ]),
                ),
              ),
            ),
          ),
        ]),
      ),
    );
  }
}

class _Field extends StatelessWidget {
  final String label; final TextEditingController controller;
  final IconData icon; final bool obscure;
  final Widget? suffix; final String? Function(String?)? validator;
  const _Field({required this.label, required this.controller,
    required this.icon, this.obscure = false, this.suffix, this.validator});
  @override
  Widget build(BuildContext context) => TextFormField(
    controller: controller, obscureText: obscure,
    style: GoogleFonts.inter(fontSize: 13, color: AppColors.textPrimary),
    decoration: InputDecoration(
      labelText: label,
      labelStyle: GoogleFonts.inter(fontSize: 13, color: AppColors.textMuted),
      prefixIcon: Icon(icon, size: 18, color: AppColors.textMuted),
      suffixIcon: suffix,
      filled: true, fillColor: AppColors.bgSubtle,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: AppColors.border)),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: AppColors.border)),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: AppColors.accent, width: 1.8)),
      errorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: AppColors.error)),
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13)),
    validator: validator);
}

class _LangPicker extends StatelessWidget {
  final String current; final void Function(String) onChanged;
  const _LangPicker({required this.current, required this.onChanged});
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(3),
    decoration: BoxDecoration(
      color: Colors.white.withValues(alpha: 0.1),
      borderRadius: BorderRadius.circular(9),
      border: Border.all(color: Colors.white.withValues(alpha: 0.2))),
    child: Row(mainAxisSize: MainAxisSize.min, children: [
      for (final l in [('fr','FR'), ('ar','AR'), ('en','EN')])
        GestureDetector(onTap: () => onChanged(l.$1),
          child: AnimatedContainer(duration: const Duration(milliseconds: 150),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: current == l.$1
                ? AppColors.accentWarm : Colors.transparent,
              borderRadius: BorderRadius.circular(6)),
            child: Text(l.$2, style: GoogleFonts.inter(fontSize: 11,
              fontWeight: FontWeight.w700,
              color: current == l.$1 ? Colors.white : Colors.white60)))),
    ]));
}

// Clearly visible grid on dark bg
class _LoginGridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.06)
      ..strokeWidth = 1;
    const step = 44.0;
    for (double x = 0; x < size.width; x += step)
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    for (double y = 0; y < size.height; y += step)
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
  }
  @override bool shouldRepaint(_) => false;
}