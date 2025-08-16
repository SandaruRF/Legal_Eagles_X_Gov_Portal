# Triathalon Gov Portal - Onboarding Screen

This Flutter application implements the first onboarding page based on the Figma design provided.

## Features Implemented

### First Onboarding Page
- **Title**: "Gov Portal" with bold styling
- **Background**: Decorative background image positioned as per design
- **Main Illustration**: Central illustration image
- **Language Selection**: Three language options with interactive selection
  - සිංහල (Sinhala)
  - தமிழ் (Tamil) 
  - English (default selected)
- **Get Started Button**: Orange gradient button with shadow effect

### Design Details
- **Layout**: Stack-based layout matching Figma specifications
- **Colors**: 
  - Orange gradient: #8C1F28 to #FF5B00
  - Primary orange: #FF5B00
  - Text colors as specified in design
- **Typography**: Currently using system fonts (can be replaced with custom fonts)
- **Interactive Elements**: 
  - Language selection with visual feedback
  - Button with press handling

## Project Structure

```
lib/
├── main.dart                 # App entry point
└── screens/
    └── onboarding_screen.dart # First onboarding page implementation

assets/
└── images/
    ├── background_top.png    # Background decoration image
    └── main_illustration.png # Main central illustration
```

## Setup Instructions

1. **Install Flutter Dependencies**:
   ```bash
   flutter pub get
   ```

2. **Run the Application**:
   ```bash
   flutter run
   ```

## Customization

### Adding Custom Fonts
To use the exact fonts from the Figma design:

1. Add font files to `assets/fonts/` directory
2. Update `pubspec.yaml` to include font definitions
3. Update text styles in `onboarding_screen.dart` to use custom fonts

### Language Functionality
The language selection is currently visual only. To implement full localization:

1. Add flutter_localizations dependency
2. Create localization files for each language
3. Implement language switching logic

### Navigation
The "Get Started" button currently prints to console. To add navigation:

1. Create additional screens
2. Implement proper routing
3. Add navigation logic to button press handler

## Notes

- Images are automatically downloaded from Figma and placed in the assets folder
- The layout is responsive and follows the exact positioning from the Figma design
- Color values and styling match the design specifications
- The English language option shows selected state with white background

## Next Steps

1. Add remaining onboarding screens
2. Implement proper navigation flow
3. Add localization support
4. Include custom fonts for better design fidelity
5. Add animations and transitions
