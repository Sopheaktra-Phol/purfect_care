import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

// Loading screen that shows when the app starts
class SplashScreen extends StatefulWidget {
  final Widget? child; // Not used right now, but keeping it for future
  
  const SplashScreen({super.key, this.child});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    // Fade in animation - takes 1.5 seconds
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
    // Goes from invisible (0) to fully visible (1)
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeIn),
    );
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: Center(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Loading image - fallback to pet icon if it doesn't load
              Image.asset(
                'assets/images/loading.png',
                width: 200,
                height: 200,
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) {
                  return Icon(
                    Icons.pets,
                    size: 120,
                    color: AppTheme.neutralGrey,
                  );
                },
              ),
              const SizedBox(height: 40),
              _AnimatedLoadingText(),
            ],
          ),
        ),
      ),
    );
  }
}

// Shows "loading..." with dots that cycle through 1, 2, 3
class _AnimatedLoadingText extends StatefulWidget {
  @override
  State<_AnimatedLoadingText> createState() => _AnimatedLoadingTextState();
}

class _AnimatedLoadingTextState extends State<_AnimatedLoadingText> 
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    // Loop every 1.2 seconds
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final progress = _controller.value;
        
        // Split the animation into 3 parts to show different dot counts
        int dotCount = 1;
        if (progress < 0.33) {
          dotCount = 1; // loading.
        } else if (progress < 0.66) {
          dotCount = 2; // loading..
        } else {
          dotCount = 3; // loading...
        }

        return Text(
          'loading${'.' * dotCount}',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w500,
            color: AppTheme.textPrimary,
            letterSpacing: 1.2,
            fontFamily: 'Poppins',
          ),
        );
      },
    );
  }
}
