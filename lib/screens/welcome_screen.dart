import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  static const String _onboardingKey = 'onboarding_completed_v2';

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _navigateToSignUp() {
    _completeOnboarding(true);
  }

  void _navigateToLogin() {
    _completeOnboarding(false);
  }

  Future<void> _completeOnboarding(bool isSignUp) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_onboardingKey, true);
    if (mounted) {
      Navigator.of(context).pushReplacementNamed(
        '/login',
        arguments: isSignUp,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFEF9F5), // Light beige background
      body: _WelcomePageWidget(
        onNext: _navigateToSignUp,
        onSignIn: _navigateToLogin,
        animationController: _animationController,
      ),
    );
  }
}

class _WelcomePageWidget extends StatelessWidget {
  final VoidCallback onNext;
  final VoidCallback onSignIn;
  final AnimationController animationController;

  const _WelcomePageWidget({
    required this.onNext,
    required this.onSignIn,
    required this.animationController,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Top section with diagonal ribbons
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          height: MediaQuery.of(context).size.height * 0.5,
          child: _PetRibbonsSection(animationController: animationController),
        ),

        // Bottom white section with content
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          height: MediaQuery.of(context).size.height * 0.55,
          child: Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(
                top: Radius.circular(30),
              ),
            ),
            child: _ContentSection(
              onNext: onNext,
              onSignIn: onSignIn,
            ),
          ),
        ),
      ],
    );
  }
}

class _PetRibbonsSection extends StatelessWidget {
  final AnimationController animationController;

  const _PetRibbonsSection({required this.animationController});

  @override
  Widget build(BuildContext context) {
      return Stack(
        clipBehavior: Clip.none,
        children: [
        // Out-left strip - leftmost - Grey tabby cat
        _PetRibbon(
          color: const Color(0xFFF1BFC9), // #f1bfc9
          leftOffset: -70,
          topOffset: -100,
          height: 320,
          petIcon: Icons.pets,
          petBackgroundColor: const Color(0xFFF8BE7A), // #f8be7a
          petImageX: 45, // Center horizontally
          petImageY: 265, // Moved up by 20
          delay: 0,
          animationController: animationController,
        ),
        
        // Strip to the left - Brown dog
        _PetRibbon(
          color: const Color(0xFFD7C0DE), // #d7c0de
          leftOffset: 40,
          topOffset: -100,
          height: 380,
          petIcon: Icons.pets,
          petBackgroundColor: const Color(0xFFC0E3E7), // #c0e3e7
          petImageX: 45, // Center horizontally
          petImageY: 325, // Moved up by 20
          delay: 100,
          animationController: animationController,
        ),
        
        // Strip 3 (middle) - Long - Brown and white rabbit
        _PetRibbon(
          color: const Color(0xFFFDB568), // #fdb568
          leftOffset: 150,
          topOffset: -100,
          height: 440,
          petIcon: Icons.pets,
          petBackgroundColor: const Color(0xFFFBEAD2), // #fbead2
          petImageX: 45, // Center horizontally
          petImageY: 385, // Moved up by 20
          delay: 200,
          animationController: animationController,
        ),
        
        // Strip to the right - Blue and yellow macaw
        _PetRibbon(
          color: const Color(0xFFBFE3E6), // #bfe3e6
          leftOffset: 220,
          topOffset: -100,
          height: 320,
          petIcon: Icons.pets,
          petBackgroundColor: const Color(0xFFD1C5DB), // #d1c5db
          petImageX: 45, // Center horizontally
          petImageY: 265, // Moved up by 20
          delay: 300,
          animationController: animationController,
        ),
        
        // Out-right strip - rightmost - Black and white tuxedo cat
        _PetRibbon(
          color: const Color(0xFFFFC0C0), // #ffc0c0
          leftOffset: 295,
          topOffset: -100,
          height: 220,
          petIcon: Icons.pets,
          petBackgroundColor: const Color(0xFFFCBD80), // #fcbd80
          petImageX: 45, // Center horizontally
          petImageY: 165, // Moved up by 20
          delay: 400,
          animationController: animationController,
        ),
      ],
    );
  }
}

class _PetRibbon extends StatelessWidget {
  final Color color;
  final double leftOffset;
  final double topOffset;
  final double height;
  final IconData? petIcon;
  final Color? petBackgroundColor;
  final double? petImageX;
  final double? petImageY;
  final int delay;
  final AnimationController animationController;

  const _PetRibbon({
    required this.color,
    required this.leftOffset,
    required this.topOffset,
    required this.height,
    this.petIcon,
    this.petBackgroundColor,
    this.petImageX,
    this.petImageY,
    required this.delay,
    required this.animationController,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animationController,
      builder: (context, child) {
        // Calculate animation progress with delay
        final totalDuration = animationController.duration!.inMilliseconds;
        final delayMs = delay;
        final animationProgress = ((animationController.value * totalDuration - delayMs) / 600).clamp(0.0, 1.0);
        
        // Strip animation: starts from top left (-200, -200) and moves to final position
        final stripAnimation = Curves.easeOutCubic.transform(animationProgress);
        final stripX = leftOffset + (1 - stripAnimation) * -200;
        final stripY = topOffset + (1 - stripAnimation) * -200;
        final stripOpacity = stripAnimation;
        
        // Icon animation: starts slightly after strip (delay + 200ms) and fades in
        final iconDelay = delayMs + 200;
        final iconProgress = ((animationController.value * totalDuration - iconDelay) / 400).clamp(0.0, 1.0);
        final iconAnimation = Curves.easeOut.transform(iconProgress);
        final iconOpacity = iconAnimation;
        final iconScale = 0.5 + (iconAnimation * 0.5); // Scale from 0.5 to 1.0
        
        return Positioned(
          left: stripX,
          top: stripY,
          child: Opacity(
            opacity: stripOpacity,
            child: Transform.rotate(
              angle: -28 * 3.14159 / 180, // -28 degrees in radians (rotated more to the left)
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  Container(
                    width: 90,
                    height: height,
                    decoration: BoxDecoration(
                      color: color,
                      borderRadius: BorderRadius.circular(60), // More rounded ends
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.15),
                          offset: const Offset(0, 4),
                          blurRadius: 12,
                          spreadRadius: 0,
                        ),
                        BoxShadow(
                          color: Colors.black.withOpacity(0.08),
                          offset: const Offset(0, 2),
                          blurRadius: 6,
                          spreadRadius: 0,
                        ),
                      ],
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          color,
                          color.withOpacity(0.85),
                        ],
                      ),
                    ),
                  ),
                  // Circular pet image at the end of the strip
                  if (petIcon != null && petBackgroundColor != null && petImageX != null && petImageY != null)
                    Positioned(
                      left: petImageX! - 35, // Center the 70x70 circle
                      top: petImageY! - 35,
                      child: Opacity(
                        opacity: iconOpacity,
                        child: Transform.scale(
                          scale: iconScale,
                          child: Container(
                            width: 70,
                            height: 70,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: petBackgroundColor,
                            ),
                            child: Icon(
                              petIcon,
                              size: 45,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _ContentSection extends StatelessWidget {
  final VoidCallback onNext;
  final VoidCallback onSignIn;

  const _ContentSection({
    required this.onNext,
    required this.onSignIn,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Decorative graphics
        _DecorativeGraphics(),

        // Main content
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Title and subtitle
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title
                    const Text(
                      'Adopt your\nthe best friend',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 36,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                        height: 1.2,
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Subtitle
                    Text(
                      'When you adopt, you not only save a loving\ncompanion but also make space for others.',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 16,
                        color: Colors.grey[600],
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              // Create Account button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: onNext,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFB930B), // Orange
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: const BorderSide(color: Colors.black, width: 1.5),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    'Create Account',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Sign in link
              GestureDetector(
                onTap: onSignIn,
                child: RichText(
                  text: TextSpan(
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                    children: [
                      const TextSpan(text: 'I already have an account ? '),
                      TextSpan(
                        text: 'Sign in',
                        style: TextStyle(
                          color: const Color(0xFFFB930B), // Orange
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),
            ],
          ),
        ),
      ],
    );
  }
}

class _DecorativeGraphics extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Large incomplete circle on left
        Positioned(
          left: -60,
          top: 40,
          child: Container(
            width: 160,
            height: 160,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: const Color(0xFFFFE5D4).withOpacity(0.4),
                width: 2.5,
              ),
            ),
            child: CustomPaint(
              painter: _IncompleteCirclePainter(),
            ),
          ),
        ),

        // Small triangle near top-left
        Positioned(
          left: 15,
          top: 70,
          child: CustomPaint(
            size: const Size(18, 18),
            painter: _TrianglePainter(),
          ),
        ),

        // Paw print icon left of text
        Positioned(
          left: 25,
          top: 180,
          child: Icon(
            Icons.pets,
            size: 22,
            color: const Color(0xFFFFE5D4).withOpacity(0.5),
          ),
        ),

        // Paw print icon above title
        Positioned(
          left: 45,
          top: 100,
          child: Icon(
            Icons.pets,
            size: 18,
            color: const Color(0xFFFFE5D4).withOpacity(0.5),
          ),
        ),

        // Star icon on right
        Positioned(
          right: 35,
          top: 90,
          child: Icon(
            Icons.star,
            size: 22,
            color: const Color(0xFFFFE5D4).withOpacity(0.5),
          ),
        ),

        // Small incomplete circle on right edge
        Positioned(
          right: -40,
          top: 140,
          child: Container(
            width: 110,
            height: 110,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: const Color(0xFFFFE5D4).withOpacity(0.4),
                width: 2.5,
              ),
            ),
            child: CustomPaint(
              painter: _IncompleteCirclePainter(),
            ),
          ),
        ),
      ],
    );
  }
}

class _IncompleteCirclePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFFFFE5D4).withOpacity(0.4)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5;

    final rect = Rect.fromLTWH(0, 0, size.width, size.height);
    // Draw incomplete circle (about 270 degrees)
    canvas.drawArc(rect, 0, 4.7, false, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _TrianglePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFFFFE5D4).withOpacity(0.5)
      ..style = PaintingStyle.fill;

    final path = Path()
      ..moveTo(size.width / 2, 0)
      ..lineTo(0, size.height)
      ..lineTo(size.width, size.height)
      ..close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// Helper function to check if onboarding is completed
Future<bool> isOnboardingCompleted() async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getBool('onboarding_completed_v2') ?? false;
}

// Helper function to reset onboarding (for testing/development)
Future<void> resetOnboarding() async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.remove('onboarding_completed_v2');
}
