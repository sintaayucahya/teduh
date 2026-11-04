import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:google_fonts/google_fonts.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.dark,
    systemNavigationBarColor: Colors.transparent,
    systemNavigationBarIconBrightness: Brightness.dark,
  ));
  runApp(const TeduhApp());
}

/// ---------------------------------------------------------------------------
/// PALET WARNA (diambil dari desain)
/// ---------------------------------------------------------------------------
class TeduhColors {
  static const bgTop = Color(0xFFBFE0B8);
  static const bgMid = Color(0xFFF0F6E1);
  static const bgBottom = Color(0xFFB4D8AE);
  static const logoCircle = Color(0xFFF5F9EC);
  static const logoLeaf = Color(0xFF14695A);
  static const title = Color(0xFF14593F);
  static const tagline = Color(0xFF3F7A55);
  static const progressFill = Color(0xFF145238);
  static const progressTrack = Color(0xFF7FAA84);
}

class TeduhApp extends StatelessWidget {
  const TeduhApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TEDUH',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(useMaterial3: true),
      home: const SplashScreen(),
    );
  }
}

/// ---------------------------------------------------------------------------
/// SPLASH SCREEN
/// ---------------------------------------------------------------------------
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late final AnimationController _intro; // animasi masuk
  late final AnimationController _loop; // animasi berulang (sway, pulse)
  late final AnimationController _progress; // progress bar

  @override
  void initState() {
    super.initState();
    _intro = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2600),
      animationBehavior: AnimationBehavior.preserve,
    );
    _loop = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 6000),
      animationBehavior: AnimationBehavior.preserve,
    )..repeat();
    _progress = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3000),
      animationBehavior: AnimationBehavior.preserve,
    );

    _intro.forward();
    Future.delayed(const Duration(milliseconds: 900), () {
      if (mounted) {
        _progress.forward().whenComplete(_goNext);
      }
    });
  }

  void _goNext() {
    if (!mounted) return;
    Navigator.of(context).pushReplacement(PageRouteBuilder(
      transitionDuration: const Duration(milliseconds: 800),
      pageBuilder: (context, animation, secondaryAnimation) => const LoginScreen(),
      transitionsBuilder: (_, anim, _, child) =>
          FadeTransition(opacity: anim, child: child),
    ));
  }

  @override
  void dispose() {
    _intro.dispose();
    _loop.dispose();
    _progress.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final w = size.width;
    final h = size.height;
    final circleD = w * 0.417;

    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Latar gradasi: hijau muda -> krem -> hijau muda
          const DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  TeduhColors.bgTop,
                  TeduhColors.bgMid,
                  TeduhColors.bgMid,
                  TeduhColors.bgBottom,
                ],
                stops: [0.0, 0.42, 0.58, 1.0],
              ),
            ),
          ),

          // Daun-daun
          RepaintBoundary(
            child: CustomPaint(
              size: size,
              painter: LeavesPainter(intro: _intro, loop: _loop),
            ),
          ),

          // Logo + teks
          Align(
            alignment: const Alignment(0, -0.02),
            child: AnimatedBuilder(
              animation: Listenable.merge([_intro, _loop]),
              builder: (context, _) {
                final t = _intro.value;
                final logoScale = Interval(0.05, 0.50, curve: Curves.elasticOut)
                    .transform(t);
                final logoFade =
                    Interval(0.05, 0.25, curve: Curves.easeOut).transform(t);
                final iconProg =
                    Interval(0.30, 0.70, curve: Curves.easeOutBack)
                        .transform(t);
                final titleP =
                    Interval(0.55, 0.85, curve: Curves.easeOutCubic)
                        .transform(t);
                final tagP = Interval(0.70, 1.0, curve: Curves.easeOutCubic)
                    .transform(t);

                final float =
                    math.sin(_loop.value * 2 * math.pi) * 4; // melayang

                return Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Transform.translate(
                      offset: Offset(0, float),
                      child: Opacity(
                        opacity: logoFade,
                        child: Transform.scale(
                          scale: logoScale.clamp(0.0, 1.4),
                          child: SizedBox(
                            width: circleD,
                            height: circleD,
                            child: Stack(
                              clipBehavior: Clip.none,
                              alignment: Alignment.center,
                              children: [
                                // Ring denyut halus
                                for (int i = 0; i < 2; i++)
                                  _PulseRing(
                                    progress:
                                        (_loop.value * 1.5 + i * 0.5) % 1.0,
                                    baseSize: circleD,
                                    enabled: t > 0.6,
                                  ),
                                // Lingkaran logo
                                Container(
                                  width: circleD,
                                  height: circleD,
                                  decoration: BoxDecoration(
                                    color: TeduhColors.logoCircle,
                                    shape: BoxShape.circle,
                                    boxShadow: [
                                      BoxShadow(
                                        color: const Color(0xFF2E6B45)
                                            .withValues(alpha: 0.18),
                                        blurRadius: 28,
                                        spreadRadius: 1,
                                        offset: const Offset(0, 10),
                                      ),
                                    ],
                                  ),
                                  child: Center(
                                    child: Transform.rotate(
                                      angle: (1 - iconProg) * -0.6 +
                                          math.sin(_loop.value *
                                                  2 *
                                                  math.pi) *
                                              0.04,
                                      child: Transform.scale(
                                        scale: 0.4 + 0.6 * iconProg,
                                        child: SizedBox(
                                          width: circleD * 0.52,
                                          height: circleD * 0.52,
                                          child: CustomPaint(
                                            painter: LeafLogoPainter(
                                                reveal: iconProg
                                                    .clamp(0.0, 1.0)),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: h * 0.012),
                    Opacity(
                      opacity: titleP,
                      child: Transform.translate(
                        offset: Offset(0, (1 - titleP) * 24),
                        child: Text(
                          'TEDUH',
                          style: GoogleFonts.poppins(
                            fontSize: w * 0.112,
                            fontWeight: FontWeight.w700,
                            letterSpacing: w * 0.006,
                            color: TeduhColors.title,
                            height: 1.1,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: h * 0.006),
                    Opacity(
                      opacity: tagP,
                      child: Transform.translate(
                        offset: Offset(0, (1 - tagP) * 18),
                        child: Text(
                          'Bernafas Lebih Sehat di Udara yang\nLebih Baik',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.poppins(
                            fontSize: w * 0.039,
                            fontWeight: FontWeight.w400,
                            color: TeduhColors.tagline,
                            height: 1.75,
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),

          // Progress bar
          Positioned(
            left: 0,
            right: 0,
            bottom: h * 0.066,
            child: Center(
              child: AnimatedBuilder(
                animation: Listenable.merge([_intro, _progress]),
                builder: (context, _) {
                  final appear = Interval(0.7, 1.0).transform(_intro.value);
                  final p = Curves.easeInOutCubic.transform(_progress.value);
                  final barW = w * 0.424;
                  return Opacity(
                    opacity: appear,
                    child: SizedBox(
                      width: barW,
                      height: 3.5,
                      child: Stack(
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              color:
                                  TeduhColors.progressTrack.withValues(alpha: 0.45),
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                          Container(
                            width: barW * (0.38 + 0.62 * p),
                            decoration: BoxDecoration(
                              color: TeduhColors.progressFill,
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PulseRing extends StatelessWidget {
  final double progress;
  final double baseSize;
  final bool enabled;

  const _PulseRing({
    required this.progress,
    required this.baseSize,
    required this.enabled,
  });

  @override
  Widget build(BuildContext context) {
    if (!enabled) return const SizedBox.shrink();
    final s = baseSize * (1.0 + 0.55 * progress);
    final o = (1 - progress) * 0.28;
    return Container(
      width: s,
      height: s,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: const Color(0xFF4E9A62).withValues(alpha: o),
          width: 1.6,
        ),
      ),
    );
  }
}

/// ---------------------------------------------------------------------------
/// LOGO DAUN (di dalam lingkaran)
/// ---------------------------------------------------------------------------
class LeafLogoPainter extends CustomPainter {
  final double reveal;
  LeafLogoPainter({required this.reveal});

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    Offset p(double x, double y) => Offset(x * w, y * h);

    // Bentuk daun
    final leaf = Path()
      ..moveTo(p(0.97, 0.03).dx, p(0.97, 0.03).dy)
      ..cubicTo(w * 0.52, h * 0.02, w * 0.06, h * 0.22, w * 0.04, h * 0.62)
      ..cubicTo(w * 0.03, h * 0.82, w * 0.22, h * 0.90, w * 0.42, h * 0.86)
      ..cubicTo(w * 0.80, h * 0.78, w * 0.98, h * 0.45, w * 0.97, h * 0.03)
      ..close();

    canvas.save();
    // Efek "terungkap" dari pangkal ke ujung
    canvas.clipRect(Rect.fromLTWH(
        0, h * (1 - reveal), w, h * reveal + 1));
    canvas.drawPath(
      leaf,
      Paint()
        ..color = TeduhColors.logoLeaf
        ..isAntiAlias = true,
    );

    // Goresan putih (tulang daun melengkung)
    final swoosh = Path()
      ..moveTo(w * 0.10, h * 0.98)
      ..cubicTo(w * 0.20, h * 0.62, w * 0.50, h * 0.36, w * 0.80, h * 0.24)
      ..cubicTo(w * 0.56, h * 0.46, w * 0.34, h * 0.70, w * 0.16, h * 1.00)
      ..close();
    canvas.drawPath(
      swoosh,
      Paint()
        ..color = TeduhColors.logoCircle
        ..isAntiAlias = true,
    );
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant LeafLogoPainter old) => old.reveal != reveal;
}

/// ---------------------------------------------------------------------------
/// DAUN-DAUN DEKORATIF
/// ---------------------------------------------------------------------------
class _LeafSpec {
  final double fx; // posisi pangkal (fraksi lebar layar)
  final double fy; // posisi pangkal (fraksi tinggi layar)
  final double len; // panjang (fraksi lebar layar)
  final double wid; // lebar (fraksi lebar layar)
  final double angle; // derajat, 0 = menghadap atas, searah jarum jam
  final Color c1; // warna pangkal
  final Color c2; // warna ujung
  final double opacity;
  final double phase; // fase sway
  final double amp = 0.035; // amplitudo sway (radian)

  const _LeafSpec(this.fx, this.fy, this.len, this.wid, this.angle, this.c1,
      this.c2,
      {this.opacity = 1.0, this.phase = 0});
}

const List<_LeafSpec> _leafSpecs = [
  // ---------------- Kiri atas ----------------
  _LeafSpec(-0.02, 0.00, 0.46, 0.15, 104, Color(0xFF7CBB72), Color(0xFF2F8052),
      phase: 0.2),
  _LeafSpec(-0.05, 0.075, 0.36, 0.12, 158, Color(0xFF9CCB84), Color(0xFF4E9A5A),
      phase: 1.1),
  _LeafSpec(-0.04, -0.01, 0.50, 0.19, 138, Color(0xFFB0DA94), Color(0xFF58A25C),
      phase: 2.0),

  // ---------------- Kanan atas ----------------
  _LeafSpec(0.64, -0.02, 0.44, 0.15, 188, Color(0xFFA2D48E), Color(0xFF4C9C5E),
      phase: 0.7),
  _LeafSpec(1.06, -0.02, 0.62, 0.22, 222, Color(0xFF3F9B62), Color(0xFF14594A),
      phase: 1.6),
  _LeafSpec(1.04, 0.27, 0.36, 0.13, 292, Color(0xFF86C47A), Color(0xFF3F8F5A),
      phase: 2.6),

  // ---------------- Kiri bawah ----------------
  _LeafSpec(0.00, 1.02, 0.58, 0.20, 24, Color(0xFF2B7D50), Color(0xFF17604A),
      phase: 0.4),
  _LeafSpec(0.10, 1.03, 0.52, 0.17, 10, Color(0xFF8FC27C), Color(0xFF3E8F5A),
      opacity: 0.75, phase: 1.3),
  _LeafSpec(0.20, 1.04, 0.46, 0.15, -8, Color(0xFFB4DB9A), Color(0xFF6DB070),
      opacity: 0.6, phase: 2.2),

  // ---------------- Kanan bawah ----------------
  _LeafSpec(0.52, 1.04, 0.72, 0.25, 20, Color(0xFFB2DA92), Color(0xFF3E955C),
      phase: 0.9),
  _LeafSpec(0.76, 1.04, 0.58, 0.20, 2, Color(0xFF5DAA68), Color(0xFF1F6E4F),
      phase: 1.9),
  _LeafSpec(1.02, 1.02, 0.40, 0.14, -24, Color(0xFF3D9461), Color(0xFF17604A),
      phase: 2.9),
];

class LeavesPainter extends CustomPainter {
  final Animation<double> intro;
  final Animation<double> loop;

  LeavesPainter({required this.intro, required this.loop})
      : super(repaint: Listenable.merge([intro, loop]));

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final center = Offset(w / 2, h / 2);

    for (int i = 0; i < _leafSpecs.length; i++) {
      final s = _leafSpecs[i];

      // Animasi masuk bertahap (staggered)
      final delay = i * 0.035;
      final raw = ((intro.value - delay) / 0.55).clamp(0.0, 1.0);
      final p = Curves.easeOutCubic.transform(raw);
      if (p <= 0) continue;

      final base = Offset(s.fx * w, s.fy * h);
      final dir = (base - center);
      final dirN = dir / dir.distance;
      final slide = dirN * ((1 - p) * w * 0.28);

      // Sway halus berulang
      final sway = math.sin(loop.value * 2 * math.pi + s.phase) * s.amp;
      final angle = s.angle * math.pi / 180 + sway + (1 - p) * 0.25;

      _drawLeaf(
        canvas,
        origin: base + slide,
        length: s.len * w,
        width: s.wid * w,
        angle: angle,
        c1: s.c1,
        c2: s.c2,
        opacity: s.opacity * p,
      );
    }
  }

  void _drawLeaf(
    Canvas canvas, {
    required Offset origin,
    required double length,
    required double width,
    required double angle,
    required Color c1,
    required Color c2,
    required double opacity,
  }) {
    canvas.save();
    canvas.translate(origin.dx, origin.dy);
    canvas.rotate(angle);

    final L = length;
    final W = width;

    final path = Path()
      ..moveTo(0, 0)
      ..cubicTo(W * 1.05, -L * 0.20, W * 0.95, -L * 0.72, 0, -L)
      ..cubicTo(-W * 0.95, -L * 0.72, -W * 1.05, -L * 0.20, 0, 0)
      ..close();

    // Gradasi badan daun
    final fill = Paint()
      ..isAntiAlias = true
      ..shader = LinearGradient(
        begin: Alignment.bottomCenter,
        end: Alignment.topCenter,
        colors: [
          c1.withValues(alpha: opacity),
          c2.withValues(alpha: opacity),
        ],
      ).createShader(Rect.fromLTWH(-W, -L, W * 2, L));
    canvas.drawPath(path, fill);

    // Separuh sisi kanan sedikit lebih gelap (efek lipatan daun)
    final half = Path()
      ..moveTo(0, 0)
      ..cubicTo(W * 1.05, -L * 0.20, W * 0.95, -L * 0.72, 0, -L)
      ..close();
    canvas.drawPath(
      half,
      Paint()
        ..isAntiAlias = true
        ..color = Colors.black.withValues(alpha: 0.06 * opacity),
    );

    // Tulang daun & urat halus
    final vein = Paint()
      ..isAntiAlias = true
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 1.1
      ..color = Colors.white.withValues(alpha: 0.20 * opacity);

    canvas.drawLine(Offset(0, -L * 0.02), Offset(0, -L * 0.94), vein);
    for (double t = 0.18; t <= 0.80; t += 0.12) {
      final y = -L * t;
      final spread = W * 0.62 * (1 - t * 0.75);
      final up = L * 0.10;
      canvas.drawLine(Offset(0, y), Offset(spread, y - up), vein);
      canvas.drawLine(Offset(0, y), Offset(-spread, y - up), vein);
    }

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant LeavesPainter old) => false;
}

/// ---------------------------------------------------------------------------
/// HALAMAN LOGIN
/// ---------------------------------------------------------------------------
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  bool passwordTersembunyi = true;

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  void tampilkanPesan(String pesan) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(pesan)),
    );
  }

  Widget _label(String teks) {
    return Text(
      teks,
      style: GoogleFonts.poppins(
        fontSize: 10,
        fontWeight: FontWeight.w600,
        color: const Color(0xFF31594C),
      ),
    );
  }

  InputDecoration _inputDecoration({
    required String hint,
    required IconData icon,
    Widget? suffix,
  }) {
    return InputDecoration(
      hintText: hint,
      hintStyle: GoogleFonts.poppins(
        fontSize: 11,
        color: const Color(0xFF94A59C),
      ),
      prefixIcon: Icon(
        icon,
        size: 17,
        color: const Color(0xFF438D78),
      ),
      suffixIcon: suffix,
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 14,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Color(0xFFDCE9E1)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Color(0xFFDCE9E1)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(
          color: Color(0xFF438D78),
          width: 1.2,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            stops: [0.0, 0.35, 0.52, 1.0],
            colors: [
              Color(0xFFE0F1E6),
              Color(0xFFF4F9F5),
              Colors.white,
              Colors.white,
            ],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: width * 0.107),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    height: 115,
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              SizedBox(
                                width: 32,
                                height: 32,
                                child: CustomPaint(
                                  painter: LeafLogoPainter(reveal: 1),
                                ),
                              ),
                              const SizedBox(width: 5),
                              Text(
                                'TEDUH',
                                style: GoogleFonts.poppins(
                                  fontSize: 27,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 1.5,
                                  color: const Color(0xFF176D59),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Hidup Sehat, Udara Sehat',
                            style: GoogleFonts.poppins(
                              fontSize: 11,
                              color: const Color(0xFF176D59),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 38),
                  Text.rich(
                    TextSpan(
                      children: [
                        TextSpan(
                          text: 'Selamat datang ',
                          style: GoogleFonts.poppins(
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF176D59),
                          ),
                        ),
                        TextSpan(
                          text: 'kembali',
                          style: GoogleFonts.poppins(
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF183D32),
                          ),
                        ),
                      ],
                    ),
                    style: TextStyle(fontSize: width * 0.057),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    'Masuk untuk memulai hari yang lebih sehat.',
                    style: GoogleFonts.poppins(
                      fontSize: 11,
                      color: const Color(0xFF81968C),
                    ),
                  ),
                  const SizedBox(height: 22),
                  _label('Email atau Nomor Telepon'),
                  const SizedBox(height: 6),
                  TextField(
                    controller: emailController,
                    keyboardType: TextInputType.emailAddress,
                    style: GoogleFonts.poppins(fontSize: 12),
                    decoration: _inputDecoration(
                      hint: 'nama@email.com',
                      icon: Icons.mail_outline,
                    ),
                  ),
                  const SizedBox(height: 15),
                  _label('Kata Sandi'),
                  const SizedBox(height: 6),
                  TextField(
                    controller: passwordController,
                    obscureText: passwordTersembunyi,
                    style: GoogleFonts.poppins(fontSize: 12),
                    decoration: _inputDecoration(
                      hint: 'Masukkan kata sandi',
                      icon: Icons.lock_outline,
                      suffix: IconButton(
                        onPressed: () {
                          setState(() {
                            passwordTersembunyi = !passwordTersembunyi;
                          });
                        },
                        icon: Icon(
                          passwordTersembunyi
                              ? Icons.visibility_off_outlined
                              : Icons.visibility_outlined,
                          size: 17,
                          color: const Color(0xFFB8C1BD),
                        ),
                      ),
                    ),
                  ),
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () {
                        tampilkanPesan(
                          'Fitur lupa kata sandi akan dihubungkan.',
                        );
                      },
                      child: Text(
                        'Lupa Kata Sandi',
                        style: GoogleFonts.poppins(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF176D59),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 2),
                  SizedBox(
                    width: double.infinity,
                    height: 46,
                    child: ElevatedButton(
                      onPressed: () {
                        if (emailController.text.trim().isEmpty ||
                            passwordController.text.isEmpty) {
                          tampilkanPesan(
                            'Email dan kata sandi harus diisi!',
                          );
                          return;
                        }
                        tampilkanPesan(
                          'Form login siap dihubungkan ke Firebase.',
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF176D59),
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(13),
                        ),
                      ),
                      child: Text(
                        'Masuk',
                        style: GoogleFonts.poppins(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Center(
                    child: TextButton(
                      onPressed: () {
                        tampilkanPesan('Mode tamu akan dihubungkan.');
                      },
                      child: Text(
                        'Mode Tamu',
                        style: GoogleFonts.poppins(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF176D59),
                        ),
                      ),
                    ),
                  ),
                  Row(
                    children: [
                      const Expanded(
                        child: Divider(color: Color(0xFFDCE9E1)),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 9),
                        child: Text(
                          'atau masuk dengan',
                          style: GoogleFonts.poppins(
                            fontSize: 10,
                            color: const Color(0xFF82968C),
                          ),
                        ),
                      ),
                      const Expanded(
                        child: Divider(color: Color(0xFFDCE9E1)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    height: 44,
                    child: OutlinedButton(
                      onPressed: () {
                        tampilkanPesan('Login Google akan dihubungkan.');
                      },
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFF31594C),
                        side: const BorderSide(color: Color(0xFFDCE9E1)),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(13),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'G',
                            style: GoogleFonts.poppins(
                              fontSize: 19,
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFF4285F4),
                            ),
                          ),
                          const SizedBox(width: 9),
                          Text(
                            'Lanjutkan dengan Google',
                            style: GoogleFonts.poppins(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Center(
                    child: Wrap(
                      children: [
                        Text(
                          'Belum punya akun? ',
                          style: GoogleFonts.poppins(
                            fontSize: 11,
                            color: const Color(0xFF82968C),
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => const RegisterScreen(),
                              ),
                            );
                          },
                          child: Text(
                            'Daftar',
                            style: GoogleFonts.poppins(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFF176D59),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 55),
                  Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.verified_user_outlined,
                          size: 12,
                          color: Color(0xFF428A73),
                        ),
                        const SizedBox(width: 5),
                        Flexible(
                          child: Text(
                            'Data pribadimu aman bersama TEDUH.',
                            textAlign: TextAlign.center,
                            style: GoogleFonts.poppins(
                              fontSize: 9,
                              color: const Color(0xFF91A49A),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 18),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}


/// ---------------------------------------------------------------------------
/// HALAMAN DAFTAR AKUN
/// ---------------------------------------------------------------------------
class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final TextEditingController namaController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController sandiController = TextEditingController();
  final TextEditingController konfirmasiController = TextEditingController();

  DateTime? tanggalLahir;
  String gender = 'Perempuan';
  bool sandiTersembunyi = true;
  bool konfirmasiTersembunyi = true;
  bool setuju = false;

  static const Color hijau = Color(0xFF176D59);
  static const Color teks = Color(0xFF31594C);
  static const Color garis = Color(0xFFDCE4E1);
  static const Color hint = Color(0xFF9AA9A2);

  @override
  void dispose() {
    namaController.dispose();
    emailController.dispose();
    sandiController.dispose();
    konfirmasiController.dispose();
    super.dispose();
  }

  void _pesan(String pesan) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(pesan)),
    );
  }

  String get _tanggalText {
    if (tanggalLahir == null) return 'Pilih tanggal lahir';
    final d = tanggalLahir!;
    return '${d.day.toString().padLeft(2, '0')}/'
        '${d.month.toString().padLeft(2, '0')}/${d.year}';
  }

  Future<void> _pilihTanggal() async {
    final now = DateTime.now();
    final hasil = await showDatePicker(
      context: context,
      initialDate: DateTime(now.year - 18, now.month, now.day),
      firstDate: DateTime(1900),
      lastDate: now,
      helpText: 'Pilih tanggal lahir',
      cancelText: 'BATAL',
      confirmText: 'PILIH',
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: hijau,
              onPrimary: Colors.white,
              onSurface: teks,
            ),
          ),
          child: child!,
        );
      },
    );
    if (hasil != null) setState(() => tanggalLahir = hasil);
  }

  InputDecoration _dekorasi({
    required String hintText,
    required IconData ikon,
    Widget? suffix,
  }) {
    return InputDecoration(
      hintText: hintText,
      hintStyle: GoogleFonts.poppins(fontSize: 10, color: hint),
      prefixIcon: Icon(ikon, size: 16, color: const Color(0xFF8A9B93)),
      suffixIcon: suffix,
      filled: true,
      fillColor: const Color(0xFFFEFFFE),
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(13),
        borderSide: const BorderSide(color: garis, width: 1),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(13),
        borderSide: const BorderSide(color: garis, width: 1),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(13),
        borderSide: const BorderSide(color: Color(0xFF55A58C), width: 1.3),
      ),
    );
  }

  Widget _label(String value) => Padding(
        padding: const EdgeInsets.only(bottom: 5),
        child: Text(
          value,
          style: GoogleFonts.poppins(
            fontSize: 9.5,
            fontWeight: FontWeight.w600,
            color: teks,
          ),
        ),
      );

  Widget _kolom({
    required String label,
    required String hintText,
    required IconData ikon,
    required TextEditingController controller,
    TextInputType? keyboardType,
    bool obscure = false,
    Widget? suffix,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _label(label),
        SizedBox(
          height: 40,
          child: TextField(
            controller: controller,
            keyboardType: keyboardType,
            obscureText: obscure,
            style: GoogleFonts.poppins(fontSize: 11, color: teks),
            decoration: _dekorasi(
              hintText: hintText,
              ikon: ikon,
              suffix: suffix,
            ),
          ),
        ),
      ],
    );
  }

  Widget _genderButton(String value, IconData ikon) {
    final aktif = gender == value;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => gender = value),
        child: Container(
          height: 37,
          decoration: BoxDecoration(
            color: aktif ? const Color(0xFFE2FFF2) : Colors.white,
            borderRadius: BorderRadius.circular(22),
            border: Border.all(
              color: aktif ? const Color(0xFF55A98D) : garis,
              width: aktif ? 1.5 : 1,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                ikon,
                size: 15,
                color: aktif ? hijau : const Color(0xFF98A69F),
              ),
              const SizedBox(width: 7),
              Text(
                value,
                style: GoogleFonts.poppins(
                  fontSize: 9,
                  fontWeight: aktif ? FontWeight.w600 : FontWeight.w400,
                  color: aktif ? hijau : const Color(0xFF87958E),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _daftar() {
    if (namaController.text.trim().isEmpty ||
        tanggalLahir == null ||
        emailController.text.trim().isEmpty ||
        sandiController.text.isEmpty ||
        konfirmasiController.text.isEmpty) {
      _pesan('Mohon lengkapi semua data terlebih dahulu.');
      return;
    }
    if (sandiController.text.length < 8) {
      _pesan('Kata sandi minimal 8 karakter.');
      return;
    }
    if (sandiController.text != konfirmasiController.text) {
      _pesan('Konfirmasi kata sandi tidak sama.');
      return;
    }
    if (!setuju) {
      _pesan('Silakan setujui Syarat dan Ketentuan serta Kebijakan Privasi.');
      return;
    }
    _pesan('Form pendaftaran siap dihubungkan ke Firebase.');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE8F2F5),
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                stops: [0, 0.30, 0.62, 1],
                colors: [
                  Color(0xFFDDF0E4),
                  Color(0xFFF4F8F5),
                  Colors.white,
                  Colors.white,
                ],
              ),
            ),
          ),
          Positioned(
            left: -22,
            bottom: -25,
            child: IgnorePointer(
              child: CustomPaint(
                size: const Size(115, 115),
                painter: _RegisterLeafCornerPainter(),
              ),
            ),
          ),
          Positioned(
            right: -22,
            bottom: -25,
            child: IgnorePointer(
              child: Transform(
                alignment: Alignment.center,
                transform: Matrix4.rotationY(math.pi),
                child: CustomPaint(
                  size: const Size(115, 115),
                  painter: _RegisterLeafCornerPainter(),
                ),
              ),
            ),
          ),
          SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                return SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(18, 8, 18, 16),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: constraints.maxHeight - 24,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                          height: 58,
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              Align(
                                alignment: Alignment.centerLeft,
                                child: IconButton(
                                  onPressed: () => Navigator.of(context).pop(),
                                  icon: const Icon(
                                    Icons.arrow_back,
                                    size: 20,
                                    color: Color(0xFF42665A),
                                  ),
                                  padding: EdgeInsets.zero,
                                  constraints: const BoxConstraints(
                                    minWidth: 34,
                                    minHeight: 34,
                                  ),
                                ),
                              ),
                              Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      SizedBox(
                                        width: 23,
                                        height: 23,
                                        child: CustomPaint(
                                          painter: LeafLogoPainter(reveal: 1),
                                        ),
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        'TEDUH',
                                        style: GoogleFonts.poppins(
                                          fontSize: 20,
                                          fontWeight: FontWeight.w700,
                                          letterSpacing: 1.5,
                                          color: hijau,
                                        ),
                                      ),
                                    ],
                                  ),
                                  Text(
                                    'Hidup Sehat, Udara Lebih Baik',
                                    style: GoogleFonts.poppins(
                                      fontSize: 8,
                                      color: const Color(0xFF4B8A73),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 14),
                        Text(
                          'Daftar Akun',
                          style: GoogleFonts.poppins(
                            fontSize: 21,
                            height: 1.15,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF176D59),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Mulai langkah kecil untuk hidup lebih sehat dan lingkungan\\nyang lebih baik bersama TEDUH.',
                          style: GoogleFonts.poppins(
                            fontSize: 9.5,
                            height: 1.35,
                            color: const Color(0xFF8A9B93),
                          ),
                        ),
                        const SizedBox(height: 14),
                        _kolom(
                          label: 'Nama Lengkap',
                          hintText: 'Masukkan nama lengkap Anda',
                          ikon: Icons.person_outline,
                          controller: namaController,
                          keyboardType: TextInputType.name,
                        ),
                        const SizedBox(height: 8),
                        _label('Tanggal Lahir'),
                        GestureDetector(
                          onTap: _pilihTanggal,
                          child: Container(
                            height: 40,
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFEFFFE),
                              border: Border.all(color: garis),
                              borderRadius: BorderRadius.circular(13),
                            ),
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.calendar_month_outlined,
                                  size: 16,
                                  color: Color(0xFF8A9B93),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Text(
                                    _tanggalText,
                                    style: GoogleFonts.poppins(
                                      fontSize: 10,
                                      color: tanggalLahir == null ? hint : teks,
                                    ),
                                  ),
                                ),
                                const Icon(
                                  Icons.calendar_month,
                                  size: 16,
                                  color: Color(0xFF8A9B93),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        _label('Gender'),
                        Row(
                          children: [
                            _genderButton('Perempuan', Icons.female),
                            const SizedBox(width: 8),
                            _genderButton('Laki-laki', Icons.male),
                          ],
                        ),
                        const SizedBox(height: 8),
                        _kolom(
                          label: 'Email',
                          hintText: 'Masukkan email Anda',
                          ikon: Icons.mail_outline,
                          controller: emailController,
                          keyboardType: TextInputType.emailAddress,
                        ),
                        const SizedBox(height: 8),
                        _kolom(
                          label: 'Sandi',
                          hintText: 'Minimal 8 karakter',
                          ikon: Icons.lock_outline,
                          controller: sandiController,
                          obscure: sandiTersembunyi,
                          suffix: IconButton(
                            visualDensity: VisualDensity.compact,
                            onPressed: () => setState(
                              () => sandiTersembunyi = !sandiTersembunyi,
                            ),
                            icon: Icon(
                              sandiTersembunyi
                                  ? Icons.visibility_off_outlined
                                  : Icons.visibility_outlined,
                              size: 16,
                              color: const Color(0xFF8A9B93),
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        _kolom(
                          label: 'Konfirmasi Sandi',
                          hintText: 'Ulangi kata sandi Anda',
                          ikon: Icons.lock_outline,
                          controller: konfirmasiController,
                          obscure: konfirmasiTersembunyi,
                          suffix: IconButton(
                            visualDensity: VisualDensity.compact,
                            onPressed: () => setState(
                              () => konfirmasiTersembunyi =
                                  !konfirmasiTersembunyi,
                            ),
                            icon: Icon(
                              konfirmasiTersembunyi
                                  ? Icons.visibility_off_outlined
                                  : Icons.visibility_outlined,
                              size: 16,
                              color: const Color(0xFF8A9B93),
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(
                              width: 18,
                              height: 18,
                              child: Checkbox(
                                value: setuju,
                                onChanged: (v) =>
                                    setState(() => setuju = v ?? false),
                                activeColor: hijau,
                                side: const BorderSide(color: garis, width: 1.3),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                materialTapTargetSize:
                                    MaterialTapTargetSize.shrinkWrap,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.only(top: 1),
                                child: Text.rich(
                                  TextSpan(
                                    style: GoogleFonts.poppins(
                                      fontSize: 8.5,
                                      height: 1.35,
                                      color: const Color(0xFF87968F),
                                    ),
                                    children: [
                                      const TextSpan(
                                        text: 'Saya menyetujui ',
                                      ),
                                      TextSpan(
                                        text: 'Syarat dan Ketentuan',
                                        style: const TextStyle(
                                          color: hijau,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      const TextSpan(text: ' serta '),
                                      TextSpan(
                                        text: 'Kebijakan\nPrivasi',
                                        style: const TextStyle(
                                          color: hijau,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        SizedBox(
                          width: double.infinity,
                          height: 40,
                          child: ElevatedButton(
                            onPressed: _daftar,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: hijau,
                              foregroundColor: Colors.white,
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(24),
                              ),
                            ),
                            child: Text(
                              'Daftar',
                              style: GoogleFonts.poppins(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        Center(
                          child: GestureDetector(
                            onTap: () => Navigator.of(context).pop(),
                            child: Text.rich(
                              TextSpan(
                                style: GoogleFonts.poppins(
                                  fontSize: 9,
                                  color: const Color(0xFF87968F),
                                ),
                                children: [
                                  const TextSpan(text: 'Sudah punya akun? '),
                                  TextSpan(
                                    text: 'Masuk',
                                    style: const TextStyle(
                                      color: hijau,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _RegisterLeafCornerPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFFEAF4EE)
      ..style = PaintingStyle.fill;
    final path = Path()
      ..moveTo(size.width * 0.08, size.height)
      ..cubicTo(
        size.width * 0.02, size.height * 0.56,
        size.width * 0.12, size.height * 0.16,
        size.width * 0.43, size.height * 0.08,
      )
      ..cubicTo(
        size.width * 0.40, size.height * 0.42,
        size.width * 0.60, size.height * 0.60,
        size.width * 0.95, size.height * 0.62,
      )
      ..cubicTo(
        size.width * 0.82, size.height * 0.92,
        size.width * 0.48, size.height * 1.02,
        size.width * 0.08, size.height,
      )
      ..close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _RegisterLeafCornerPainter oldDelegate) => false;
}
