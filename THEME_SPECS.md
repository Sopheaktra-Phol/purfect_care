# Theme Specifications

This document defines the design system and theme specifications for the Purfect Care app, based on the Welcome Screen and Login Screen implementations.

## Color Palette

### Primary Colors
- **Background**: `Color(0xFFFEF9F5)` - Light beige background
- **White**: `Colors.white` - Used for cards and containers
- **Black**: `Colors.black` - Primary text color and button borders

### Accent Colors
- **Orange Primary**: `Color(0xFFFB930B)` - Primary action color (buttons, active states, links)
- **Decorative Peach**: `Color(0xFFFFE5D4)` - Decorative graphics (with opacity 0.4-0.5)

### Grey Scale
- **Grey 200**: `Colors.grey[200]` - Card borders
- **Grey 300**: `Colors.grey[300]` - Input field borders, dividers
- **Grey 400**: `Colors.grey[400]` - Secondary dividers
- **Grey 600**: `Colors.grey[600]` - Secondary text, labels, inactive states
- **Input Background**: `Color(0xFFF5F5F5)` - Light grey for input fields

### Text Colors
- **Primary Text**: `Colors.black` - Main headings and important text
- **Secondary Text**: `Colors.grey[600]` - Subtitles, descriptions, labels
- **Button Text**: `Colors.white` - Text on primary buttons
- **Link Text**: `Color(0xFFFB930B)` - Clickable links and active states

## Typography

### Font Family
- **Primary Font**: `'Poppins'` - Used throughout the entire application

### Font Sizes
- **Large Title**: `36px` (Welcome screen main title)
- **Title**: `32px` (Login screen title)
- **Button Text**: `18px` (Primary action buttons)
- **Body Text**: `16px` (Subtitle, input fields, body content)
- **Small Text**: `14px` (Links, secondary actions)
- **Footer Text**: `12px` (Terms, fine print)

### Font Weights
- **Bold**: `FontWeight.bold` - Main titles
- **Semi-Bold**: `FontWeight.w600` - Button text, active states
- **Medium**: `FontWeight.w500` - Subtitle emphasis
- **Normal**: `FontWeight.normal` - Body text, inactive states

### Line Heights
- **Title**: `1.2` - Tight spacing for headings
- **Body**: `1.5` - Comfortable reading for paragraphs

## Buttons

### Primary Button
- **Background**: `Color(0xFFFB930B)` (Orange)
- **Text Color**: `Colors.white`
- **Border**: `Colors.black`, width `1.5px`
- **Border Radius**: `12px`
- **Padding**: `vertical: 16px`
- **Font**: Poppins, `18px`, `FontWeight.w600`
- **Elevation**: `0` (flat design)

### Secondary Button (Outlined)
- **Border Color**: `Colors.grey[300]`, width `1.5px`
- **Text Color**: `Colors.black87` (for grey buttons) or `Color(0xFFFB930B)` (for orange buttons)
- **Border Radius**: `12px`
- **Padding**: `vertical: 16px`
- **Font**: Poppins, `16px`

### Toggle Buttons (Login/Sign Up)
- **Active**: `Color(0xFFFB930B)`, `FontWeight.bold`
- **Inactive**: `Colors.grey[600]`, `FontWeight.normal`
- **Font Size**: `18px`
- **Divider**: `Colors.grey[400]`

## Input Fields

### Text Input Fields
- **Background**: `Color(0xFFF5F5F5)` (Light grey)
- **Border Radius**: `12px`
- **Border Width**: `1.5px`
- **Border Color (Default)**: `Colors.grey[300]`
- **Border Color (Focused)**: `Color(0xFFFB930B)` (Orange), width `2px`
- **Text Style**: Poppins, `16px`
- **Label Style**: Poppins, `Colors.grey[600]`
- **Icon Color**: `Colors.grey`
- **Padding**: Standard Material padding

## Cards & Containers

### Main Card (Login Form)
- **Background**: `Colors.white`
- **Border Radius**: `24px`
- **Border**: `Colors.grey[200]`, width `1px`
- **Elevation**: `0` (flat design)
- **Padding**: `24px` all sides

### Welcome Screen Bottom Card
- **Background**: `Colors.white`
- **Border Radius**: `30px` (top corners only)
- **No border or elevation**

## Spacing

### Common Spacing Values
- **Extra Small**: `8px` - Tight spacing between related elements
- **Small**: `12px` - Spacing between title and subtitle
- **Medium**: `16px` - Standard spacing between form fields
- **Large**: `20px` - Spacing before form cards
- **Extra Large**: `24px` - Card padding, spacing between major sections
- **XXL**: `32px` - Large vertical spacing

### Layout Spacing
- **Screen Padding**: `24px` (horizontal padding for main content)
- **Card Padding**: `24px` (internal padding for cards)

## Border Radius

- **Small**: `12px` - Buttons, input fields
- **Medium**: `18px` - Ribbon decorations
- **Large**: `24px` - Form cards
- **Extra Large**: `30px` - Welcome screen bottom card (top corners)

## Shadows

- **Card Shadow**: Minimal or none (flat design)
- **Icon Shadow**: `BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 20, offset: Offset(0, 10))` - Only for decorative elements

## Decorative Elements

### Ribbon Colors (Welcome Screen)
- **Pink**: `Color(0xFFFFB6C1)`
- **Lavender**: `Color(0xFFE6E6FA)`
- **Orange**: `Color(0xFFFB930B)`
- **Light Blue**: `Color(0xFFADD8E6)`

### Decorative Graphics
- **Color**: `Color(0xFFFFE5D4)` (Peach)
- **Opacity**: `0.4` to `0.5`
- **Border Width**: `2.5px`

## Animation

### Fade Transition
- **Duration**: `800ms` (Welcome screen) to `1000ms` (Login screen)
- **Curve**: `Curves.easeIn`

### Ribbon Animation
- **Duration**: `800ms`
- **Curve**: `Curves.easeOut`
- **Stagger Delay**: `100ms` increments

## Design Principles

1. **Flat Design**: Minimal elevation, subtle borders
2. **Consistent Typography**: Poppins font family throughout
3. **Color Consistency**: Orange (`#FB930B`) for all primary actions
4. **Spacing Harmony**: Consistent padding and margins
5. **Rounded Corners**: All interactive elements have rounded corners (12px standard)
6. **Black Borders**: Primary buttons have black borders for definition
7. **Light Background**: Beige background (`#FEF9F5`) for warmth
8. **White Cards**: Clean white cards on beige background for contrast

## Usage Examples

### Primary Button
```dart
ElevatedButton(
  style: ElevatedButton.styleFrom(
    backgroundColor: const Color(0xFFFB930B),
    foregroundColor: Colors.white,
    padding: const EdgeInsets.symmetric(vertical: 16),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(12),
      side: const BorderSide(color: Colors.black, width: 1.5),
    ),
    elevation: 0,
  ),
  child: const Text(
    'Button Text',
    style: TextStyle(
      fontFamily: 'Poppins',
      fontSize: 18,
      fontWeight: FontWeight.w600,
    ),
  ),
)
```

### Input Field
```dart
TextFormField(
  style: const TextStyle(
    fontFamily: 'Poppins',
    fontSize: 16,
  ),
  decoration: InputDecoration(
    labelText: 'Label',
    labelStyle: TextStyle(
      fontFamily: 'Poppins',
      color: Colors.grey[600],
    ),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(color: Colors.grey[300]!, width: 1.5),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: Color(0xFFFB930B), width: 2),
    ),
    filled: true,
    fillColor: const Color(0xFFF5F5F5),
  ),
)
```

### Card Container
```dart
Card(
  elevation: 0,
  color: Colors.white,
  shape: RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(24),
    side: BorderSide(color: Colors.grey[200]!, width: 1),
  ),
  child: Padding(
    padding: const EdgeInsets.all(24.0),
    child: // Content
  ),
)
```

## Notes

- All measurements are in logical pixels
- Colors should be defined as constants for consistency
- The theme emphasizes a warm, friendly, and modern aesthetic
- Accessibility: Ensure sufficient contrast ratios (black text on beige background, white text on orange buttons)

