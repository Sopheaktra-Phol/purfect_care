// Get Flutter's UI components (buttons, containers, etc.)
import 'package:flutter/material.dart';
// Get storage to remember if user has seen this screen before
import 'package:shared_preferences/shared_preferences.dart';
import 'login_screen.dart';

// This is the welcome screen widget - it can change over time (needed for animations)
class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  // Create the state object that manages this screen
  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

// This class manages the welcome screen's data and behavior
class _WelcomeScreenState extends State<WelcomeScreen>
    with SingleTickerProviderStateMixin {
  // Controller that runs the animations for the pet ribbons
  late AnimationController _animationController;
  // Key to save in storage - remembers if user completed onboarding
  static const String _onboardingKey = 'onboarding_completed_v2';

  // This runs once when the screen first appears
  @override
  void initState() {
    super.initState();
    // Create animation controller - it will run for 1.2 seconds
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    // Start the animation right away
    _animationController.forward();
  }

  // This runs when the screen is removed - clean up resources
  @override
  void dispose() {
    // Stop the animation to free up memory
    _animationController.dispose();
    super.dispose();
  }

  // Called when user taps "Create Account" button
  void _navigateToSignUp() {
    _completeOnboarding(true);
  }

  // Called when user taps "Sign in" link
  void _navigateToLogin() {
    _completeOnboarding(false);
  }

  // Saves that user saw this screen and goes to login screen
  Future<void> _completeOnboarding(bool isSignUp) async {
    // Get the storage
    final prefs = await SharedPreferences.getInstance();
    // Save that onboarding is done (so it won't show again)
    await prefs.setBool(_onboardingKey, true);
    // Check if screen is still active (user didn't leave)
    if (mounted) {
      // Use a custom page route with smooth transition
      Navigator.of(context).pushReplacement(
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) => LoginScreen(
            initialMode: isSignUp ? LoginMode.signUp : LoginMode.login,
          ),
          transitionDuration: const Duration(milliseconds: 500),
          reverseTransitionDuration: const Duration(milliseconds: 300),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            // Fade in animation for login screen
            final fadeAnimation = Tween<double>(
              begin: 0.0,
              end: 1.0,
            ).animate(
              CurvedAnimation(
                parent: animation,
                curve: const Interval(0.0, 0.8, curve: Curves.easeOut),
              ),
            );
            
            // Slide up animation for login screen
            final slideAnimation = Tween<Offset>(
              begin: const Offset(0.0, 0.2), // Start 20% down
              end: Offset.zero, // End at normal position
            ).animate(
              CurvedAnimation(
                parent: animation,
                curve: const Interval(0.0, 1.0, curve: Curves.easeOutCubic),
              ),
            );
            
            // Fade out the welcome screen (using secondaryAnimation)
            final fadeOutAnimation = Tween<double>(
              begin: 1.0,
              end: 0.0,
            ).animate(
              CurvedAnimation(
                parent: secondaryAnimation,
                curve: const Interval(0.0, 0.5, curve: Curves.easeIn),
              ),
            );
            
            // Combine slide up and fade in for the new screen
            return SlideTransition(
              position: slideAnimation,
              child: FadeTransition(
                opacity: fadeAnimation,
                child: child,
              ),
            );
          },
        ),
      );
    }
  }

  // This builds what the screen looks like
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFEF9F5), // Light beige background color
      body: _WelcomePageWidget(
        onNext: _navigateToSignUp, // What to do when "Create Account" is tapped
        onSignIn: _navigateToLogin, // What to do when "Sign in" is tapped
        animationController: _animationController, // Pass animation controller to children
      ),
    );
  }
}

// This widget arranges the welcome page layout
class _WelcomePageWidget extends StatelessWidget {
  final VoidCallback onNext; // Function to call when "Create Account" is tapped
  final VoidCallback onSignIn; // Function to call when "Sign in" is tapped
  final AnimationController animationController; // Controls the animations

  const _WelcomePageWidget({
    required this.onNext,
    required this.onSignIn,
    required this.animationController,
  });

  @override
  Widget build(BuildContext context) {
    // Stack lets us put things on top of each other
    return Stack(
      children: [
        // Top half of screen - shows animated pet ribbons
        Positioned(
          top: 0, // At the very top
          left: 0, // At the very left
          right: 0, // At the very right (spans full width)
          height: MediaQuery.of(context).size.height * 0.5, // Takes up 50% of screen height
          child: _PetRibbonsSection(animationController: animationController),
        ),

        // Bottom half of screen - shows white box with text and buttons
        Positioned(
          bottom: 0, // At the very bottom
          left: 0,
          right: 0,
          height: MediaQuery.of(context).size.height * 0.55, // Takes up 55% of screen (overlaps a bit)
          child: Container(
            decoration: const BoxDecoration(
              color: Colors.white, // White background
              borderRadius: BorderRadius.vertical(
                top: Radius.circular(30), // Rounded top corners
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
      // Stack all the ribbons on top of each other
      return Stack(
        clipBehavior: Clip.none, // Let ribbons extend beyond screen edges
        children: [
        // First ribbon - Dog (leftmost, starts animating first)
        _PetRibbon(
          color: const Color(0xFFF1BFC9), // Pink color
          leftOffset: -70, // Position from left (negative = off screen to the left)
          topOffset: -100, // Position from top (negative = starts above screen)
          height: 320, // How tall the ribbon is
          petImagePath: 'assets/images/pets/dog.png', // Dog image file
          petBackgroundColor: const Color(0xFFF8BE7A), // Orange circle behind dog
          petImageX: 45, // Where to put the dog image horizontally
          petImageY: 265, // Where to put the dog image vertically
          delay: 0, // No delay - starts animating immediately
          animationController: animationController,
        ),
        
        // Second ribbon - Cat (starts 100ms later)
        _PetRibbon(
          color: const Color(0xFFD7C0DE), // Purple color
          leftOffset: 40, // Further right than dog
          topOffset: -100,
          height: 380, // Taller than dog
          petImagePath: 'assets/images/pets/cat.png',
          petBackgroundColor: const Color(0xFFC0E3E7), // Light blue circle
          petImageX: 45,
          petImageY: 325, // Lower on the ribbon
          delay: 100, // Waits 100ms before starting
          animationController: animationController,
        ),
        
        // Third ribbon - Rabbit (middle, tallest, most noticeable)
        _PetRibbon(
          color: const Color(0xFFFDB568), // Orange color
          leftOffset: 150, // In the middle
          topOffset: -100,
          height: 440, // Tallest ribbon
          petImagePath: 'assets/images/pets/rabbit.png',
          petBackgroundColor: const Color(0xFFFBEAD2), // Beige circle
          petImageX: 45,
          petImageY: 385,
          delay: 200, // Waits 200ms before starting
          animationController: animationController,
        ),
        
        // Fourth ribbon - Bird
        _PetRibbon(
          color: const Color(0xFFBFE3E6), // Light blue color
          leftOffset: 220, // Further right
          topOffset: -100,
          height: 320, // Same height as dog
          petImagePath: 'assets/images/pets/bird.png',
          petBackgroundColor: const Color(0xFFD1C5DB), // Purple circle
          petImageX: 45,
          petImageY: 265,
          delay: 300, // Waits 300ms before starting
          animationController: animationController,
        ),
        
        // Fifth ribbon - Hamster (rightmost, shortest)
        _PetRibbon(
          color: const Color(0xFFFFC0C0), // Light pink color
          leftOffset: 295, // Rightmost position
          topOffset: -100,
          height: 220, // Shortest ribbon
          petImagePath: 'assets/images/pets/hamster.png',
          petBackgroundColor: const Color(0xFFFCBD80), // Orange circle
          petImageX: 45,
          petImageY: 165, // Higher on the ribbon
          delay: 400, // Waits 400ms before starting (last to animate)
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
  final String? petImagePath;
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
    this.petImagePath,
    this.petBackgroundColor,
    this.petImageX,
    this.petImageY,
    required this.delay,
    required this.animationController,
  });

  @override
  Widget build(BuildContext context) {
    // This rebuilds the widget every time the animation updates
    return AnimatedBuilder(
      animation: animationController,
      builder: (context, child) {
        // Figure out how far through this ribbon's animation we are
        final totalDuration = animationController.duration!.inMilliseconds; // Total time: 1200ms
        final delayMs = delay; // This ribbon's delay (0, 100, 200, etc.)
        // Calculate progress: 0.0 = not started, 1.0 = finished
        final animationProgress = ((animationController.value * totalDuration - delayMs) / 600).clamp(0.0, 1.0);
        
        // Make the ribbon animation smooth (starts fast, slows down)
        final stripAnimation = Curves.easeOutCubic.transform(animationProgress);
        // Calculate where ribbon should be horizontally (slides in from left)
        final stripX = leftOffset + (1 - stripAnimation) * -200;
        // Calculate where ribbon should be vertically (slides down from top)
        final stripY = topOffset + (1 - stripAnimation) * -200;
        // How visible the ribbon is (0 = invisible, 1 = fully visible)
        final stripOpacity = stripAnimation;
        
        // Pet image starts animating 200ms after ribbon starts
        final iconDelay = delayMs + 200;
        // Calculate pet image animation progress
        final iconProgress = ((animationController.value * totalDuration - iconDelay) / 400).clamp(0.0, 1.0);
        // Make pet image animation smooth
        final iconAnimation = Curves.easeOut.transform(iconProgress);
        // How visible the pet image is
        final iconOpacity = iconAnimation;
        // How big the pet image is (starts at 50% size, grows to 100%)
        final iconScale = 0.5 + (iconAnimation * 0.5);
        
        // Position the ribbon at the calculated location
        return Positioned(
          left: stripX, // Horizontal position (changes during animation)
          top: stripY, // Vertical position (changes during animation)
          child: Opacity(
            opacity: stripOpacity, // Fade in/out effect
            child: Transform.rotate(
              angle: -28 * 3.14159 / 180, // Rotate -28 degrees (tilted to the left)
              child: Stack(
                clipBehavior: Clip.none, // Let pet image extend beyond ribbon
                children: [
                  // The actual ribbon (colored rectangle)
                  Container(
                    width: 90, // Ribbon width
                    height: height, // Ribbon height (varies per ribbon)
                    decoration: BoxDecoration(
                      color: color, // Ribbon color
                      borderRadius: BorderRadius.circular(60), // Rounded ends (pill shape)
                      boxShadow: [
                        // Big shadow for depth
                        BoxShadow(
                          color: Colors.black.withOpacity(0.15),
                          offset: const Offset(0, 4), // Shadow is 4px below
                          blurRadius: 12, // Soft shadow
                          spreadRadius: 0,
                        ),
                        // Small shadow for detail
                        BoxShadow(
                          color: Colors.black.withOpacity(0.08),
                          offset: const Offset(0, 2), // Closer shadow
                          blurRadius: 6,
                          spreadRadius: 0,
                        ),
                      ],
                      gradient: LinearGradient(
                        begin: Alignment.topLeft, // Gradient starts at top-left
                        end: Alignment.bottomRight, // Ends at bottom-right
                        colors: [
                          color, // Full color at top
                          color.withOpacity(0.85), // Slightly faded at bottom
                        ],
                      ),
                    ),
                  ),
                  // Pet image circle (only show if we have all the info)
                  if (petImagePath != null && petBackgroundColor != null && petImageX != null && petImageY != null)
                    Positioned(
                      left: petImageX! - 35, // Center the 70px circle (35 is half of 70)
                      top: petImageY! - 35,
                      child: Opacity(
                        opacity: iconOpacity, // Fade in effect
                        child: Transform.scale(
                          scale: iconScale, // Grow from 50% to 100% size
                          child: Container(
                            width: 70, // Circle size
                            height: 70,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle, // Make it circular
                              color: petBackgroundColor, // Background color
                            ),
                            child: ClipOval(
                              child: Image.asset(
                                petImagePath!, // Load the pet image
                                width: 70,
                                height: 70,
                                fit: BoxFit.cover, // Fill the circle, crop if needed
                                cacheWidth: 140, // Optimize for high-res screens
                                cacheHeight: 140,
                                errorBuilder: (context, error, stackTrace) {
                                  // If image fails to load, show a pet icon instead
                                  debugPrint('Error loading image: $petImagePath - $error');
                                  return Container(
                                    color: petBackgroundColor,
                                    child: const Icon(
                                      Icons.pets, // Generic pet icon
                                      size: 45,
                                      color: Colors.white,
                                    ),
                                  );
                                },
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
    // Put decorative graphics behind the main content
    return Stack(
      children: [
        // Background decorations (circles, icons)
        _DecorativeGraphics(),

        // Main content (text and buttons)
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0), // Add space around edges
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween, // Push content to top and bottom
            children: [
              // Title and subtitle section (takes up available space)
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center, // Center vertically
                  crossAxisAlignment: CrossAxisAlignment.start, // Align to left
                  children: [
                    // Main title text
                    const Text(
                      'Caring for your pet,\nOne reminder at a time.', // \n creates a line break
                      style: TextStyle(
                        fontFamily: 'Poppins', // Use Poppins font
                        fontSize: 28, // Large text
                        fontWeight: FontWeight.bold, // Bold text
                        color: Colors.black,
                        height: 1.2, // Space between lines
                      ),
                    ),
                    const SizedBox(height: 16), // Gap between title and subtitle
                    // Subtitle text
                    Text(
                      'Everything your pet needs\nright on time.',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 16, // Smaller than title
                        color: Colors.grey[600], // Gray color
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32), // Gap before button

              // "Create Account" button
              SizedBox(
                width: double.infinity, // Make button full width
                child: ElevatedButton(
                  onPressed: onNext, // What happens when tapped
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFB930B), // Orange background
                    foregroundColor: Colors.white, // White text
                    padding: const EdgeInsets.symmetric(vertical: 16), // Top/bottom padding
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12), // Rounded corners
                      side: const BorderSide(color: Colors.black, width: 1.5), // Black border
                    ),
                    elevation: 0, // No shadow (flat design)
                  ),
                  child: const Text(
                    'Create Account',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 18,
                      fontWeight: FontWeight.w600, // Semi-bold
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 16), // Gap before sign-in link

              // "Sign in" clickable text
              GestureDetector(
                onTap: onSignIn, // What happens when tapped
                child: RichText(
                  text: TextSpan(
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 14,
                      color: Colors.grey[600], // Gray for most text
                    ),
                    children: [
                      const TextSpan(text: 'Already have an account ? '), // Regular gray text
                      TextSpan(
                        text: 'Sign in', // Orange text to show it's clickable
                        style: TextStyle(
                          color: const Color(0xFFFB930B), // Orange color
                          fontWeight: FontWeight.w600, // Bold
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16), // Bottom padding
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

// Draws a partial circle (about 3/4 of a circle) for decoration
class _IncompleteCirclePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    // Set up how to draw (color, style, thickness)
    final paint = Paint()
      ..color = const Color(0xFFFFE5D4).withOpacity(0.4) // Light peach, semi-transparent
      ..style = PaintingStyle.stroke // Just the outline, not filled
      ..strokeWidth = 2.5; // Line thickness

    // Define the circle area
    final rect = Rect.fromLTWH(0, 0, size.width, size.height);
    // Draw an arc (partial circle) - about 270 degrees
    canvas.drawArc(rect, 0, 4.7, false, paint);
  }

  // Never needs to redraw (shape doesn't change)
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// Draws a filled triangle pointing upward
class _TrianglePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    // Set up how to draw
    final paint = Paint()
      ..color = const Color(0xFFFFE5D4).withOpacity(0.5) // Light peach
      ..style = PaintingStyle.fill; // Filled triangle

    // Draw a triangle: point at top, base at bottom
    final path = Path()
      ..moveTo(size.width / 2, 0) // Start at top center
      ..lineTo(0, size.height) // Draw line to bottom left
      ..lineTo(size.width, size.height) // Draw line to bottom right
      ..close(); // Connect back to start

    // Draw the triangle
    canvas.drawPath(path, paint);
  }

  // Never needs to redraw
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// Check if user has seen the welcome screen before
Future<bool> isOnboardingCompleted() async {
  final prefs = await SharedPreferences.getInstance(); // Get storage
  return prefs.getBool('onboarding_completed_v2') ?? false; // Return true if saved, false otherwise
}

// Reset onboarding status (useful for testing)
Future<void> resetOnboarding() async {
  final prefs = await SharedPreferences.getInstance(); // Get storage
  await prefs.remove('onboarding_completed_v2'); // Delete the saved value
}
