# HTML to Flutter UI Conversion Plan

## 🎯 Goal
Convert the exact HTML report styling to Flutter widgets with pixel-perfect accuracy.

---

## 📊 Current HTML Style Analysis

### **Background**
- **Body**: Linear gradient `135deg, #667eea 0%, #764ba2 100%`
- **Padding**: 1rem top/bottom, 20px left/right margins

### **Header Card** (`.header`)
- **Background**: White
- **Border Radius**: 16px
- **Padding**: 1.1rem
- **Box Shadow**: `0 16px 50px rgba(0, 0, 0, 0.28)`
- **Margin Bottom**: 1rem

#### **Header Top Section** (`.header-top`)
- **Layout**: Flex row with gap 0.75rem
- **Title** (`h1`):
  - Font size: 1.2rem (≈19.2px)
  - Color: #2d3748
  - Icon: 🧪 emoji (1.5rem = 24px)
  - Gap between icon and text: 0.6rem
- **Timestamps** (`.header-timestamps`):
  - Position: margin-left auto (right side)
  - Display: flex with gap 0.4rem
  - **Each chip** (`.header-chip`):
    - Background: `rgba(236, 241, 248, 0.9)`
    - Padding: 0.3rem 0.6rem
    - Border radius: 16px
    - Box shadow: `0 6px 18px rgba(76, 81, 191, 0.1)`
    - **Label**:
      - Font size: 0.52rem (≈8.3px)
      - Text transform: UPPERCASE
      - Letter spacing: 0.55px
      - Color: #5a6b82
    - **Value**:
      - Font size: 0.7rem (≈11.2px)
      - Color: #1a202c

#### **Stats Section** (`.stats`)
- **Layout**: Flex wrap with gap 0.45rem
- **Margin top**: 0.75rem from header-top

#### **Stat Cards** (`.stat-card`)
- **Base**:
  - Background: `linear-gradient(135deg, #667eea 0%, #764ba2 100%)`
  - Color: white
  - Padding: 0.4rem 0.75rem
  - Border radius: 999px (pill shape)
  - Gap: 0.45rem between number and label
  - Box shadow: `0 6px 16px rgba(0, 0, 0, 0.18)`
  - Min height: 2.1rem
  - Hover: `translateY(-2px)`, shadow `0 10px 24px rgba(0, 0, 0, 0.22)`
- **Variants**:
  - **Passed**: `linear-gradient(135deg, #11998e 0%, #38ef7d 100%)`
  - **Failed**: `linear-gradient(135deg, #ee0979 0%, #ff6a00 100%)`
  - **Golden**: `linear-gradient(135deg, #f6d365 0%, #fda085 100%)` with color `#553c02`
- **Number** (`h3`):
  - Font size: 0.95rem (≈15.2px)
  - Font weight: 700
- **Label** (`p`):
  - Font size: 0.58rem (≈9.3px)
  - Opacity: 0.9
  - Text transform: UPPERCASE
  - Letter spacing: 0.85px

---

### **Scenario Cards** (`.scenario-card`)
- **Background**: White
- **Border radius**: 18px
- **Box shadow**: `0 20px 60px rgba(0, 0, 0, 0.3)`
- **Border left**: 6px solid
  - Default: #4c51bf
  - Passed: #38ef7d
  - Failed: #ff6a00
- **Hover**: 
  - Transform: `translateY(-10px)`
  - Shadow: `0 30px 80px rgba(0, 0, 0, 0.4)`
- **Gap between cards**: 1.15rem

#### **Scenario Header** (`.scenario-header`)
- **Padding**: 0.72rem 1rem
- **Border bottom**: 2px solid #e2e8f0
- **Background gradients**:
  - **Passed**: `linear-gradient(135deg, rgba(17, 153, 142, 0.12) 0%, rgba(56, 239, 125, 0.12) 100%)`
  - **Failed**: `linear-gradient(135deg, rgba(238, 9, 121, 0.12) 0%, rgba(255, 106, 0, 0.12) 100%)`

#### **Scenario Title** (`.scenario-title`)
- **Font size**: 1.05rem (≈16.8px)
- **Font weight**: 600
- **Color**: #1a202c
- **Gap**: 0.4rem

#### **Toggle Icon** (`.scenario-toggle-icon`)
- **Size**: 1.3rem × 1.3rem
- **Color**: #4c51bf
- **Font size**: 0.85rem
- **Rotation**: 90deg when open
- **Transition**: 0.2s ease

#### **Scenario Chips** (`.scenario-chip`)
- **Background**: `rgba(255, 255, 255, 0.9)`
- **Padding**: 0.16rem 0.32rem
- **Border radius**: 16px
- **Box shadow**: `0 6px 18px rgba(76, 81, 191, 0.12)`
- **Min width**: 4.2rem
- **Gap**: 0.15rem between label and value
- **Label**:
  - Font size: 0.52rem (≈8.3px)
  - Text transform: UPPERCASE
  - Letter spacing: 0.55px
  - Color: #5a6b82
- **Value**:
  - Font size: 0.72rem (≈11.5px)
  - Color: #1a202c
- **Variants**:
  - **Total**: `rgba(102, 126, 234, 0.16)` with color #3c3fa3
  - **Passed**: `rgba(56, 239, 125, 0.18)` with color #067a4d
  - **Failed**: `rgba(255, 107, 107, 0.2)` with color #c53030
  - **Subtle**: `rgba(236, 241, 248, 0.8)` with color #4a5568

#### **Scenario Status Badge** (`.scenario-status`)
- **Padding**: 0.18rem 0.4rem
- **Border radius**: 16px
- **Font weight**: 700
- **Text transform**: UPPERCASE
- **Letter spacing**: 0.8px
- **Font size**: 0.62rem (≈9.9px)
- **Min width**: 4.5rem
- **Icon**: ✅ for passed (0.85rem), ❌ for failed
- **Colors**:
  - **Passed**: Background `rgba(56, 239, 125, 0.24)`, text #067a4d
  - **Failed**: Background `rgba(255, 107, 107, 0.26)`, text #c24024

---

## 🎨 Flutter Conversion Checklist

### ✅ Phase 1: Background
- [ ] Update Scaffold background to match exact gradient
  - Start: `#667eea`
  - End: `#764ba2`
  - Angle: 135 degrees (topLeft to bottomRight)

### ✅ Phase 2: Header Card
- [ ] Replace current header with white card
- [ ] Add border radius 16px
- [ ] Add box shadow: `0 16px 50px rgba(0, 0, 0, 0.28)`
- [ ] Set padding to 1.1rem (≈17.6px)

### ✅ Phase 3: Header Top Section
- [ ] Create Row with 🧪 emoji (24px)
- [ ] Add title "Flutter Self Testing Report" (19.2px, bold, #2d3748)
- [ ] Position timestamps on right with Spacer()
- [ ] Style timestamp chips:
  - Background: `rgba(236, 241, 248, 0.9)`
  - Border radius: 16px
  - Shadow: `0 6px 18px rgba(76, 81, 191, 0.1)`
  - Label: 8.3px, uppercase, #5a6b82
  - Value: 11.2px, #1a202c

### ✅ Phase 4: Stat Cards
- [ ] Convert metric badges to pill-shaped cards
- [ ] Apply gradient backgrounds:
  - Default: Purple gradient `#667eea → #764ba2`
  - Passed: Green gradient `#11998e → #38ef7d`
  - Failed: Red gradient `#ee0979 → #ff6a00`
  - Golden: Orange gradient `#f6d365 → #fda085`
- [ ] Set number size to 15.2px, weight 700
- [ ] Set label size to 9.3px, uppercase, 0.85px letter-spacing
- [ ] Add shadow: `0 6px 16px rgba(0, 0, 0, 0.18)`
- [ ] Add hover animation (translateY -2px)

### ✅ Phase 5: Scenario Cards
- [ ] Update card background to pure white
- [ ] Set border radius to 18px
- [ ] Add large shadow: `0 20px 60px rgba(0, 0, 0, 0.3)`
- [ ] Add 6px left border (color based on status)
- [ ] Add hover animation: translateY(-10px), larger shadow

### ✅ Phase 6: Scenario Headers
- [ ] Add gradient backgrounds based on status
  - Passed: Green gradient with 12% opacity
  - Failed: Red gradient with 12% opacity
- [ ] Set padding: 0.72rem 1rem (≈11.5px 16px)
- [ ] Add 2px bottom border (#e2e8f0)
- [ ] Position toggle icon (1.3rem, #4c51bf)
- [ ] Add 90deg rotation animation on expand

### ✅ Phase 7: Scenario Chips
- [ ] Create small chip widgets with:
  - Background: `rgba(255, 255, 255, 0.9)`
  - Border radius: 16px
  - Shadow: `0 6px 18px rgba(76, 81, 191, 0.12)`
  - Min width: 4.2rem
- [ ] Style labels (8.3px, uppercase, #5a6b82)
- [ ] Style values (11.5px, #1a202c)
- [ ] Add variant colors for total/passed/failed

### ✅ Phase 8: Status Badges
- [ ] Create pill-shaped status badges
- [ ] Add emojis (✅/❌) at 0.85rem
- [ ] Set font size: 9.9px, weight 700, uppercase
- [ ] Add 0.8px letter spacing
- [ ] Apply variant colors with backgrounds

### ✅ Phase 9: Footer
- [ ] Replace current footer with centered white text
- [ ] Set opacity: 0.8
- [ ] Font size: 0.8rem (≈12.8px)
- [ ] Margin top: 2rem

### ✅ Phase 10: Polish & Animations
- [ ] Add all hover effects (translateY, shadows)
- [ ] Add transition durations (0.2s-0.3s)
- [ ] Verify all color values exact match
- [ ] Test responsive behavior

---

## 🎨 Color Palette Reference

### Gradients
```dart
// Background
LinearGradient(
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
  colors: [Color(0xFF667eea), Color(0xFF764ba2)],
)

// Stats Default
LinearGradient(
  colors: [Color(0xFF667eea), Color(0xFF764ba2)],
)

// Stats Passed
LinearGradient(
  colors: [Color(0xFF11998e), Color(0xFF38ef7d)],
)

// Stats Failed
LinearGradient(
  colors: [Color(0xFFee0979), Color(0xFFff6a00)],
)

// Stats Golden
LinearGradient(
  colors: [Color(0xFFf6d365), Color(0xFFfda085)],
)

// Scenario Passed Header
LinearGradient(
  colors: [
    Color(0xFF11998e).withValues(alpha: 0.12),
    Color(0xFF38ef7d).withValues(alpha: 0.12),
  ],
)

// Scenario Failed Header
LinearGradient(
  colors: [
    Color(0xFFee0979).withValues(alpha: 0.12),
    Color(0xFFff6a00).withValues(alpha: 0.12),
  ],
)
```

### Solid Colors
```dart
// Header title
Color(0xFF2d3748)

// Timestamp label
Color(0xFF5a6b82)

// Timestamp value, chip value
Color(0xFF1a202c)

// Toggle icon
Color(0xFF4c51bf)

// Scenario border passed
Color(0xFF38ef7d)

// Scenario border failed
Color(0xFFff6a00)

// Chip backgrounds (with alpha)
Color(0xFFecf1f8).withValues(alpha: 0.9) // Timestamp chips
Color(0xFFffffff).withValues(alpha: 0.9) // Scenario chips
```

### Box Shadows
```dart
// Header card
BoxShadow(
  color: Colors.black.withValues(alpha: 0.28),
  blurRadius: 50,
  offset: Offset(0, 16),
)

// Stat cards
BoxShadow(
  color: Colors.black.withValues(alpha: 0.18),
  blurRadius: 16,
  offset: Offset(0, 6),
)

// Scenario cards
BoxShadow(
  color: Colors.black.withValues(alpha: 0.3),
  blurRadius: 60,
  offset: Offset(0, 20),
)

// Scenario chips
BoxShadow(
  color: Color(0xFF4c51bf).withValues(alpha: 0.12),
  blurRadius: 18,
  offset: Offset(0, 6),
)
```

---

## 📝 Implementation Priority

1. **Critical** (Phase 1-4): Background, header card, timestamps, stat badges
2. **High** (Phase 5-7): Scenario cards, headers, chips
3. **Medium** (Phase 8-9): Status badges, footer
4. **Polish** (Phase 10): Animations, hover effects

---

## 🧪 Testing Checklist

- [ ] Side-by-side comparison with HTML report
- [ ] Screenshot comparison at same viewport size
- [ ] Verify all colors match exactly (use color picker)
- [ ] Check all font sizes (use browser dev tools)
- [ ] Test hover animations
- [ ] Test expand/collapse animations
- [ ] Verify spacing matches (use ruler tool)
- [ ] Test on different screen sizes

---

## 📐 Size Conversion Reference

| rem/px | Flutter (16px base) |
|--------|---------------------|
| 0.3rem | 4.8px               |
| 0.4rem | 6.4px               |
| 0.45rem| 7.2px               |
| 0.52rem| 8.3px               |
| 0.58rem| 9.3px               |
| 0.6rem | 9.6px               |
| 0.62rem| 9.9px               |
| 0.64rem| 10.2px              |
| 0.7rem | 11.2px              |
| 0.72rem| 11.5px              |
| 0.75rem| 12px                |
| 0.8rem | 12.8px              |
| 0.85rem| 13.6px              |
| 0.95rem| 15.2px              |
| 1.05rem| 16.8px              |
| 1.1rem | 17.6px              |
| 1.15rem| 18.4px              |
| 1.2rem | 19.2px              |
| 1.3rem | 20.8px              |
| 1.5rem | 24px                |
