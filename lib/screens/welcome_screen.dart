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
      duration: const Duration(milliseconds: 800),
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
        // Ribbon 1 - Pink (far left) - Grey tabby cat
        _PetRibbon(
          color: const Color(0xFFFFB6C1), // Pink
          petBackgroundColor: const Color(0xFFFB930B), // Orange
          petIcon: Icons.pets,
          leftOffset: -60,
          topOffset: 30,
          delay: 0,
          animationController: animationController,
        ),

        // Ribbon 2 - Lavender - Golden retriever
        _PetRibbon(
          color: const Color(0xFFE6E6FA), // Lavender
          petBackgroundColor: const Color(0xFFADD8E6), // Light blue
          petIcon: Icons.pets,
          leftOffset: -20,
          topOffset: 50,
          delay: 100,
          animationController: animationController,
        ),

        // Ribbon 3 - Orange (middle) - Brown rabbit
        _PetRibbon(
          color: const Color(0xFFFB930B), // Orange
          petBackgroundColor: const Color(0xFFF5DEB3), // Light beige
          petIcon: Icons.pets,
          leftOffset: 20,
          topOffset: 70,
          delay: 200,
          animationController: animationController,
        ),

        // Ribbon 4 - Light blue - Macaw parrot
        _PetRibbon(
          color: const Color(0xFFADD8E6), // Light blue
          petBackgroundColor: const Color(0xFFE6E6FA), // Lavender
          petIcon: Icons.pets,
          leftOffset: 60,
          topOffset: 50,
          delay: 300,
          animationController: animationController,
        ),

        // Ribbon 5 - Pink (far right) - Tuxedo cat
        _PetRibbon(
          color: const Color(0xFFFFB6C1), // Pink
          petBackgroundColor: const Color(0xFFFB930B), // Orange
          petIcon: Icons.pets,
          leftOffset: 100,
          topOffset: 30,
          delay: 400,
          animationController: animationController,
        ),
      ],
    );
  }
}

class _PetRibbon extends StatelessWidget {
  final Color color;
  final Color petBackgroundColor;
  final IconData petIcon;
  final double leftOffset;
  final double topOffset;
  final int delay;
  final AnimationController animationController;

  const _PetRibbon({
    required this.color,
    required this.petBackgroundColor,
    required this.petIcon,
    required this.leftOffset,
    required this.topOffset,
    required this.delay,
    required this.animationController,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animationController,
      builder: (context, child) {
        final animationValue = Curves.easeOut.transform(
          ((animationController.value * 1000 - delay) / 500).clamp(0.0, 1.0),
        );
        return Positioned(
          left: leftOffset + (1 - animationValue) * -200,
          top: topOffset + (1 - animationValue) * -100,
            child: Transform.rotate(
            angle: -0.35, // Diagonal angle
            child: Container(
              width: 100,
              height: 180,
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(18),
                border: Border(
                  bottom: BorderSide(color: Colors.black.withOpacity(0.3), width: 2),
                  right: BorderSide(color: Colors.black.withOpacity(0.3), width: 2),
                ),
              ),
              child: Stack(
                children: [
                  // Pet circle
                  Positioned(
                    left: 10,
                    top: 30,
                    child: Container(
                      width: 70,
                      height: 70,
                      decoration: BoxDecoration(
                        color: petBackgroundColor,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.black, width: 2.5),
                      ),
                      child: Icon(
                        petIcon,
                        size: 45,
                        color: Colors.white,
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
