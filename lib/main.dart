import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
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
      pageBuilder: (_, _, _) => const HomePlaceholder(),
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
/// HALAMAN SETELAH SPLASH (ganti dengan halaman utama aplikasimu)
/// ---------------------------------------------------------------------------
class HomePlaceholder extends StatelessWidget {
  const HomePlaceholder({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: TeduhColors.bgMid,
      body: Center(
        child: Text(
          'Beranda TEDUH',
          style: GoogleFonts.poppins(
            fontSize: 22,
            fontWeight: FontWeight.w600,
            color: TeduhColors.title,
          ),
        ),
      ),
    );
  }
}