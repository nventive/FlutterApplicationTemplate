# UI Component Template

Use this template when creating reusable UI components in the Flutter application. This template ensures components follow the project's design system, are accessible, performant, and testable.

## Component Context
**Component Name**: [Specify the component name]
**Component Type**: [Basic Widget/Stateful Widget/Composite Widget/Layout Widget]
**Design System**: [Material/Cupertino/Custom]
**Reusability Level**: [Project-wide/Feature-specific/Page-specific]

## Component Design Principles

### 1. Follow Project Theme System
```dart
// Always use theme colors and typography
class ThemedButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final ButtonStyle? style;

  const ThemedButton({
    super.key,
    required this.text,
    this.onPressed,
    this.style,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return ElevatedButton(
      onPressed: onPressed,
      style: style ?? ElevatedButton.styleFrom(
        backgroundColor: theme.colorScheme.primary,
        foregroundColor: theme.colorScheme.onPrimary,
        textStyle: theme.textTheme.labelLarge,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      child: Text(text),
    );
  }
}
```

### 2. Implement Responsive Design
```dart
class ResponsiveCard extends StatelessWidget {
  final Widget child;
  final EdgeInsets? padding;
  final double? elevation;

  const ResponsiveCard({
    super.key,
    required this.child,
    this.padding,
    this.elevation,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Responsive padding based on screen size
        final responsivePadding = padding ?? EdgeInsets.all(
          constraints.maxWidth > 600 ? 24.0 : 16.0,
        );
        
        // Responsive elevation
        final responsiveElevation = elevation ?? (
          constraints.maxWidth > 600 ? 4.0 : 2.0
        );

        return Card(
          elevation: responsiveElevation,
          margin: EdgeInsets.zero,
          child: Padding(
            padding: responsivePadding,
            child: child,
          ),
        );
      },
    );
  }
}
```

## Component Categories and Examples

### Basic Input Components

#### Custom Text Field
```dart
class AppTextField extends StatelessWidget {
  final String? label;
  final String? hint;
  final String? initialValue;
  final String? errorText;
  final bool obscureText;
  final TextInputType keyboardType;
  final TextInputAction textInputAction;
  final ValueChanged<String>? onChanged;
  final VoidCallback? onEditingComplete;
  final FormFieldValidator<String>? validator;
  final TextEditingController? controller;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final bool enabled;
  final int? maxLines;
  final int? maxLength;

  const AppTextField({
    super.key,
    this.label,
    this.hint,
    this.initialValue,
    this.errorText,
    this.obscureText = false,
    this.keyboardType = TextInputType.text,
    this.textInputAction = TextInputAction.done,
    this.onChanged,
    this.onEditingComplete,
    this.validator,
    this.controller,
    this.prefixIcon,
    this.suffixIcon,
    this.enabled = true,
    this.maxLines = 1,
    this.maxLength,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label != null) ...[
          Text(
            label!,
            style: theme.textTheme.labelMedium?.copyWith(
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
        ],
        TextFormField(
          controller: controller,
          initialValue: controller == null ? initialValue : null,
          obscureText: obscureText,
          keyboardType: keyboardType,
          textInputAction: textInputAction,
          onChanged: onChanged,
          onEditingComplete: onEditingComplete,
          validator: validator,
          enabled: enabled,
          maxLines: maxLines,
          maxLength: maxLength,
          decoration: InputDecoration(
            hintText: hint,
            errorText: errorText,
            prefixIcon: prefixIcon,
            suffixIcon: suffixIcon,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: theme.colorScheme.outline),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: theme.colorScheme.outline),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(
                color: theme.colorScheme.primary,
                width: 2,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: theme.colorScheme.error),
            ),
            filled: true,
            fillColor: enabled 
              ? theme.colorScheme.surface 
              : theme.colorScheme.surfaceVariant.withOpacity(0.5),
          ),
        ),
      ],
    );
  }
}
```

#### Custom Dropdown
```dart
class AppDropdown<T> extends StatelessWidget {
  final String? label;
  final String? hint;
  final T? value;
  final List<AppDropdownItem<T>> items;
  final ValueChanged<T?>? onChanged;
  final FormFieldValidator<T>? validator;
  final bool enabled;
  final String? errorText;

  const AppDropdown({
    super.key,
    this.label,
    this.hint,
    this.value,
    required this.items,
    this.onChanged,
    this.validator,
    this.enabled = true,
    this.errorText,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label != null) ...[
          Text(
            label!,
            style: theme.textTheme.labelMedium?.copyWith(
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
        ],
        DropdownButtonFormField<T>(
          value: value,
          hint: hint != null ? Text(hint!) : null,
          items: items.map((item) => DropdownMenuItem<T>(
            value: item.value,
            child: Row(
              children: [
                if (item.icon != null) ...[
                  Icon(item.icon, size: 20),
                  const SizedBox(width: 8),
                ],
                Expanded(child: Text(item.label)),
              ],
            ),
          )).toList(),
          onChanged: enabled ? onChanged : null,
          validator: validator,
          decoration: InputDecoration(
            errorText: errorText,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: theme.colorScheme.outline),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(
                color: theme.colorScheme.primary,
                width: 2,
              ),
            ),
            filled: true,
            fillColor: enabled 
              ? theme.colorScheme.surface 
              : theme.colorScheme.surfaceVariant.withOpacity(0.5),
          ),
        ),
      ],
    );
  }
}

class AppDropdownItem<T> {
  final T value;
  final String label;
  final IconData? icon;

  const AppDropdownItem({
    required this.value,
    required this.label,
    this.icon,
  });
}
```

### Display Components

#### Status Badge
```dart
enum BadgeType {
  success,
  warning,
  error,
  info,
  neutral,
}

class StatusBadge extends StatelessWidget {
  final String text;
  final BadgeType type;
  final IconData? icon;
  final VoidCallback? onTap;

  const StatusBadge({
    super.key,
    required this.text,
    required this.type,
    this.icon,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = _getBadgeColors(theme);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: colors.backgroundColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: colors.borderColor),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(
                icon,
                size: 16,
                color: colors.textColor,
              ),
              const SizedBox(width: 4),
            ],
            Text(
              text,
              style: theme.textTheme.labelSmall?.copyWith(
                color: colors.textColor,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  BadgeColors _getBadgeColors(ThemeData theme) {
    final colorScheme = theme.colorScheme;
    
    switch (type) {
      case BadgeType.success:
        return BadgeColors(
          backgroundColor: Colors.green.shade50,
          borderColor: Colors.green.shade200,
          textColor: Colors.green.shade800,
        );
      case BadgeType.warning:
        return BadgeColors(
          backgroundColor: Colors.orange.shade50,
          borderColor: Colors.orange.shade200,
          textColor: Colors.orange.shade800,
        );
      case BadgeType.error:
        return BadgeColors(
          backgroundColor: colorScheme.errorContainer,
          borderColor: colorScheme.error,
          textColor: colorScheme.onErrorContainer,
        );
      case BadgeType.info:
        return BadgeColors(
          backgroundColor: Colors.blue.shade50,
          borderColor: Colors.blue.shade200,
          textColor: Colors.blue.shade800,
        );
      case BadgeType.neutral:
        return BadgeColors(
          backgroundColor: colorScheme.surfaceVariant,
          borderColor: colorScheme.outline,
          textColor: colorScheme.onSurfaceVariant,
        );
    }
  }
}

class BadgeColors {
  final Color backgroundColor;
  final Color borderColor;
  final Color textColor;

  const BadgeColors({
    required this.backgroundColor,
    required this.borderColor,
    required this.textColor,
  });
}
```

#### Loading Indicator
```dart
class AppLoadingIndicator extends StatelessWidget {
  final String? message;
  final double size;
  final Color? color;
  final bool overlay;

  const AppLoadingIndicator({
    super.key,
    this.message,
    this.size = 24.0,
    this.color,
    this.overlay = false,
  });

  const AppLoadingIndicator.overlay({
    super.key,
    this.message,
    this.size = 32.0,
    this.color,
  }) : overlay = true;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final indicator = _buildIndicator(theme);

    if (overlay) {
      return Container(
        color: Colors.black54,
        child: Center(
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: indicator,
            ),
          ),
        ),
      );
    }

    return indicator;
  }

  Widget _buildIndicator(ThemeData theme) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: size,
          height: size,
          child: CircularProgressIndicator(
            strokeWidth: size > 30 ? 4.0 : 2.0,
            valueColor: AlwaysStoppedAnimation(
              color ?? theme.colorScheme.primary,
            ),
          ),
        ),
        if (message != null) ...[
          const SizedBox(height: 16),
          Text(
            message!,
            style: theme.textTheme.bodyMedium,
            textAlign: TextAlign.center,
          ),
        ],
      ],
    );
  }
}
```

### Feedback Components

#### Error Widget
```dart
class ErrorDisplayWidget extends StatelessWidget {
  final String title;
  final String? message;
  final IconData? icon;
  final String? actionText;
  final VoidCallback? onAction;
  final bool showRetry;

  const ErrorDisplayWidget({
    super.key,
    required this.title,
    this.message,
    this.icon,
    this.actionText,
    this.onAction,
    this.showRetry = true,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final localizations = context.local;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon ?? Icons.error_outline,
              size: 64,
              color: theme.colorScheme.error,
            ),
            const SizedBox(height: 16),
            Text(
              title,
              style: theme.textTheme.headlineSmall?.copyWith(
                color: theme.colorScheme.onSurface,
              ),
              textAlign: TextAlign.center,
            ),
            if (message != null) ...[
              const SizedBox(height: 8),
              Text(
                message!,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),
            ],
            const SizedBox(height: 24),
            if (showRetry) ...[
              ThemedButton(
                text: actionText ?? localizations.retry,
                onPressed: onAction,
              ),
            ] else if (onAction != null) ...[
              ThemedButton(
                text: actionText ?? localizations.ok,
                onPressed: onAction,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
```

#### Empty State Widget  
```dart
class EmptyStateWidget extends StatelessWidget {
  final String title;
  final String? message;
  final IconData? icon;
  final Widget? illustration;
  final String? actionText;
  final VoidCallback? onAction;

  const EmptyStateWidget({
    super.key,
    required this.title,
    this.message,
    this.icon,
    this.illustration,
    this.actionText,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (illustration != null) ...[
              illustration!,
              const SizedBox(height: 16),
            ] else if (icon != null) ...[
              Icon(
                icon,
                size: 64,
                color: theme.colorScheme.onSurfaceVariant,
              ),
              const SizedBox(height: 16),
            ],
            Text(
              title,
              style: theme.textTheme.headlineSmall?.copyWith(
                color: theme.colorScheme.onSurface,
              ),
              textAlign: TextAlign.center,
            ),
            if (message != null) ...[
              const SizedBox(height: 8),
              Text(
                message!,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),
            ],
            if (onAction != null) ...[
              const SizedBox(height: 24),
              ThemedButton(
                text: actionText ?? 'Get Started',
                onPressed: onAction,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
```

### Layout Components

#### Section Header
```dart
class SectionHeader extends StatelessWidget {
  final String title;
  final String? subtitle;
  final Widget? action;
  final EdgeInsets padding;

  const SectionHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.action,
    this.padding = const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: padding,
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    subtitle!,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ],
            ),
          ),
          if (action != null) ...[
            const SizedBox(width: 16),
            action!,
          ],
        ],
      ),
    );
  }
}
```

#### Expandable Section
```dart
class ExpandableSection extends StatefulWidget {
  final String title;
  final Widget child;
  final bool initiallyExpanded;
  final IconData? leadingIcon;
  final Widget? trailing;

  const ExpandableSection({
    super.key,
    required this.title,
    required this.child,
    this.initiallyExpanded = false,
    this.leadingIcon,
    this.trailing,
  });

  @override
  State<ExpandableSection> createState() => _ExpandableSectionState();
}

class _ExpandableSectionState extends State<ExpandableSection>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _expandAnimation;
  bool _isExpanded = false;

  @override
  void initState() {
    super.initState();
    _isExpanded = widget.initiallyExpanded;
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _expandAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    );

    if (_isExpanded) {
      _controller.value = 1.0;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _toggleExpansion() {
    setState(() {
      _isExpanded = !_isExpanded;
      if (_isExpanded) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      children: [
        InkWell(
          onTap: _toggleExpansion,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                if (widget.leadingIcon != null) ...[
                  Icon(widget.leadingIcon, size: 20),
                  const SizedBox(width: 12),
                ],
                Expanded(
                  child: Text(
                    widget.title,
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                if (widget.trailing != null) ...[
                  widget.trailing!,
                  const SizedBox(width: 8),
                ],
                AnimatedRotation(
                  turns: _isExpanded ? 0.5 : 0,
                  duration: const Duration(milliseconds: 300),
                  child: const Icon(Icons.keyboard_arrow_down),
                ),
              ],
            ),
          ),
        ),
        SizeTransition(
          sizeFactor: _expandAnimation,
          child: widget.child,
        ),
      ],
    );
  }
}
```

### Navigation Components

#### Tab Bar
```dart
class AppTabBar extends StatelessWidget implements PreferredSizeWidget {
  final List<AppTab> tabs;
  final TabController? controller;
  final ValueChanged<int>? onTap;
  final bool isScrollable;

  const AppTabBar({
    super.key,
    required this.tabs,
    this.controller,
    this.onTap,
    this.isScrollable = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return TabBar(
      controller: controller,
      onTap: onTap,
      isScrollable: isScrollable,
      tabs: tabs.map((tab) => Tab(
        icon: tab.icon != null ? Icon(tab.icon) : null,
        text: tab.text,
        child: tab.child,
      )).toList(),
      labelColor: theme.colorScheme.primary,
      unselectedLabelColor: theme.colorScheme.onSurfaceVariant,
      indicatorColor: theme.colorScheme.primary,
      indicatorWeight: 3,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(48);
}

class AppTab {
  final String? text;
  final IconData? icon;
  final Widget? child;

  const AppTab({
    this.text,
    this.icon,
    this.child,
  }) : assert(text != null || icon != null || child != null);
}
```

#### Bottom Navigation
```dart
class AppBottomNavigation extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;
  final List<AppBottomNavItem> items;

  const AppBottomNavigation({
    super.key,
    required this.currentIndex,
    required this.onTap,
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: currentIndex,
      onTap: onTap,
      type: BottomNavigationBarType.fixed,
      items: items.map((item) => BottomNavigationBarItem(
        icon: Icon(item.icon),
        activeIcon: item.activeIcon != null 
          ? Icon(item.activeIcon) 
          : Icon(item.icon),
        label: item.label,
        tooltip: item.tooltip,
      )).toList(),
    );
  }
}

class AppBottomNavItem {
  final IconData icon;
  final IconData? activeIcon;
  final String label;
  final String? tooltip;

  const AppBottomNavItem({
    required this.icon,
    this.activeIcon,
    required this.label,
    this.tooltip,
  });
}
```

## Accessibility Implementation

### Screen Reader Support
```dart
class AccessibleCard extends StatelessWidget {
  final Widget child;
  final String? semanticsLabel;
  final String? semanticsHint;
  final VoidCallback? onTap;
  final bool excludeSemantics;

  const AccessibleCard({
    super.key,
    required this.child,
    this.semanticsLabel,
    this.semanticsHint,
    this.onTap,
    this.excludeSemantics = false,
  });

  @override
  Widget build(BuildContext context) {
    Widget card = Card(
      child: InkWell(
        onTap: onTap,
        child: child,
      ),
    );

    if (excludeSemantics) {
      return ExcludeSemantics(child: card);
    }

    return Semantics(
      label: semanticsLabel,
      hint: semanticsHint,
      button: onTap != null,
      child: card,
    );
  }
}
```

### Focus Management
```dart
class FocusableMenuItem extends StatefulWidget {
  final String text;
  final IconData? icon;
  final VoidCallback? onTap;
  final bool enabled;

  const FocusableMenuItem({
    super.key,
    required this.text,
    this.icon,
    this.onTap,
    this.enabled = true,
  });

  @override
  State<FocusableMenuItem> createState() => _FocusableMenuItemState();
}

class _FocusableMenuItemState extends State<FocusableMenuItem> {
  late final FocusNode _focusNode;
  bool _isFocused = false;

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode();
    _focusNode.addListener(_onFocusChange);
  }

  @override
  void dispose() {
    _focusNode.removeListener(_onFocusChange);
    _focusNode.dispose();
    super.dispose();
  }

  void _onFocusChange() {
    setState(() {
      _isFocused = _focusNode.hasFocus;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Focus(
      focusNode: _focusNode,
      child: GestureDetector(
        onTap: widget.enabled ? widget.onTap : null,
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: _isFocused 
              ? theme.colorScheme.surfaceVariant 
              : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
            border: _isFocused
              ? Border.all(color: theme.colorScheme.primary, width: 2)
              : null,
          ),
          child: Row(
            children: [
              if (widget.icon != null) ...[
                Icon(
                  widget.icon,
                  color: widget.enabled 
                    ? theme.colorScheme.onSurface
                    : theme.colorScheme.onSurface.withOpacity(0.4),
                ),
                const SizedBox(width: 12),
              ],
              Expanded(
                child: Text(
                  widget.text,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: widget.enabled 
                      ? theme.colorScheme.onSurface
                      : theme.colorScheme.onSurface.withOpacity(0.4),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
```

## Performance Optimization

### Efficient List Item
```dart
class OptimizedListItem extends StatelessWidget {
  final String title;
  final String? subtitle;
  final Widget? leading;
  final Widget? trailing;
  final VoidCallback? onTap;

  const OptimizedListItem({
    super.key,
    required this.title,
    this.subtitle,
    this.leading,
    this.trailing,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    // Use const where possible for better performance
    return ListTile(
      leading: leading,
      title: Text(title),
      subtitle: subtitle != null ? Text(subtitle!) : null,
      trailing: trailing,
      onTap: onTap,
      // Enable efficient scrolling
      dense: true,
    );
  }
}
```

### Cached Network Image
```dart
class AppNetworkImage extends StatelessWidget {
  final String imageUrl;
  final double? width;
  final double? height;
  final BoxFit fit;
  final Widget? placeholder;
  final Widget? errorWidget;

  const AppNetworkImage({
    super.key,
    required this.imageUrl,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.placeholder,
    this.errorWidget,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Image.network(
      imageUrl,
      width: width,
      height: height,
      fit: fit,
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) return child;
        
        return placeholder ?? Container(
          width: width,
          height: height,
          color: theme.colorScheme.surfaceVariant,
          child: const Center(
            child: CircularProgressIndicator(),
          ),
        );
      },
      errorBuilder: (context, error, stackTrace) {
        return errorWidget ?? Container(
          width: width,
          height: height,
          color: theme.colorScheme.errorContainer,
          child: Icon(
            Icons.error_outline,
            color: theme.colorScheme.onErrorContainer,
          ),
        );
      },
      // Enable caching
      cacheWidth: width?.toInt(),
      cacheHeight: height?.toInt(),
    );
  }
}
```

## Component Testing

### Widget Tests
```dart
// test/presentation/components/themed_button_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';

void main() {
  group('ThemedButton', () {
    testWidgets('should display text correctly', (tester) async {
      // Arrange
      const buttonText = 'Test Button';
      bool tapped = false;

      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ThemedButton(
              text: buttonText,
              onPressed: () => tapped = true,
            ),
          ),
        ),
      );

      // Assert
      expect(find.text(buttonText), findsOneWidget);
      expect(find.byType(ElevatedButton), findsOneWidget);

      // Test interaction
      await tester.tap(find.byType(ThemedButton));
      expect(tapped, isTrue);
    });

    testWidgets('should be disabled when onPressed is null', (tester) async {
      // Arrange & Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ThemedButton(
              text: 'Disabled Button',
              onPressed: null, // Disabled
            ),
          ),
        ),
      );

      // Assert
      final button = tester.widget<ElevatedButton>(find.byType(ElevatedButton));
      expect(button.onPressed, isNull);
    });

    testWidgets('should apply custom style', (tester) async {
      // Arrange
      final customStyle = ElevatedButton.styleFrom(
        backgroundColor: Colors.red,
      );

      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ThemedButton(
              text: 'Custom Button',
              style: customStyle,
              onPressed: () {},
            ),
          ),
        ),
      );

      // Assert
      final button = tester.widget<ElevatedButton>(find.byType(ElevatedButton));
      expect(button.style, equals(customStyle));
    });

    testWidgets('should respect theme colors', (tester) async {
      // Arrange
      final customTheme = ThemeData(
        colorScheme: const ColorScheme.light(
          primary: Colors.purple,
          onPrimary: Colors.white,
        ),
      );

      // Act
      await tester.pumpWidget(
        MaterialApp(
          theme: customTheme,
          home: Scaffold(
            body: ThemedButton(
              text: 'Themed Button',
              onPressed: () {},
            ),
          ),
        ),
      );

      // Assert - Button should use theme colors
      expect(find.byType(ThemedButton), findsOneWidget);
    });
  });
}
```

### Component Integration Tests
```dart
// test/presentation/components/app_text_field_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';

void main() {
  group('AppTextField', () {
    testWidgets('should validate input correctly', (tester) async {
      // Arrange
      String? validationError;
      
      String? validator(String? value) {
        if (value == null || value.isEmpty) {
          return 'Field is required';
        }
        return null;
      }

      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Form(
              child: AppTextField(
                label: 'Test Field',
                validator: validator,
              ),
            ),
          ),
        ),
      );

      // Trigger validation
      final formState = tester.state<FormState>(find.byType(Form));
      final isValid = formState.validate();

      // Assert
      expect(isValid, isFalse);
      expect(find.text('Field is required'), findsOneWidget);
    });

    testWidgets('should handle text input', (tester) async {
      // Arrange
      String inputValue = '';
      
      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AppTextField(
              label: 'Test Field',
              onChanged: (value) => inputValue = value,
            ),
          ),
        ),
      );

      await tester.enterText(find.byType(TextFormField), 'Test Input');
      await tester.pump();

      // Assert
      expect(inputValue, equals('Test Input'));
      expect(find.text('Test Input'), findsOneWidget);
    });
  });
}
```

## Component Documentation

### Component Usage Examples
```dart
/// Usage examples for ThemedButton component
/// 
/// Basic usage:
/// ```dart
/// ThemedButton(
///   text: 'Click me',
///   onPressed: () => print('Button pressed'),
/// )
/// ```
/// 
/// With custom style:
/// ```dart
/// ThemedButton(
///   text: 'Custom Button',
///   style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
///   onPressed: () => handleCustomAction(),
/// )
/// ```
/// 
/// Disabled state:
/// ```dart
/// ThemedButton(
///   text: 'Disabled',
///   onPressed: null, // Disabled when null
/// )
/// ```
class ThemedButton extends StatelessWidget {
  // Implementation...
}
```

## Component Checklist

### Design & UX
- [ ] **Follows design system** colors, typography, and spacing
- [ ] **Responsive design** works on different screen sizes
- [ ] **Loading states** are handled appropriately
- [ ] **Error states** are clearly communicated
- [ ] **Empty states** provide helpful guidance
- [ ] **Animations** are smooth and purposeful

### Accessibility
- [ ] **Screen reader support** with proper semantics
- [ ] **Keyboard navigation** works correctly
- [ ] **Focus management** is implemented
- [ ] **Color contrast** meets WCAG guidelines
- [ ] **Touch targets** are at least 44px
- [ ] **Text scaling** works with system settings

### Performance
- [ ] **Const constructors** used where possible
- [ ] **Widget rebuilds** are minimized
- [ ] **Memory usage** is optimized
- [ ] **Large lists** use builders
- [ ] **Images** are optimized and cached
- [ ] **Animations** are performant

### Testing
- [ ] **Unit tests** cover business logic
- [ ] **Widget tests** verify UI behavior
- [ ] **Integration tests** check component interactions
- [ ] **Edge cases** are tested
- [ ] **Error scenarios** are covered
- [ ] **Accessibility testing** is included

### Code Quality
- [ ] **Documentation** is comprehensive
- [ ] **API surface** is minimal and focused
- [ ] **Error handling** is robust
- [ ] **Null safety** is properly implemented
- [ ] **Type safety** is maintained
- [ ] **Code style** follows project conventions

## Common Component Anti-Patterns

1. **God Components** - Keep components focused and single-purpose
2. **Prop Drilling** - Use state management for deep data passing
3. **Tight Coupling** - Make components reusable and independent
4. **Missing Error Handling** - Always handle edge cases gracefully
5. **Poor Performance** - Optimize for smooth scrolling and responsiveness
6. **Inaccessible Components** - Always consider users with disabilities
7. **Inconsistent Styling** - Follow the established design system

## Component Library Organization

```
lib/presentation/components/
├── buttons/
│   ├── themed_button.dart
│   └── icon_button.dart
├── inputs/
│   ├── app_text_field.dart
│   └── app_dropdown.dart
├── display/
│   ├── status_badge.dart
│   └── loading_indicator.dart
├── feedback/
│   ├── error_widget.dart
│   └── empty_state.dart
├── layout/
│   ├── section_header.dart
│   └── expandable_section.dart
└── navigation/
    ├── app_tab_bar.dart
    └── bottom_navigation.dart
```

This organization helps maintain consistency and makes components easy to find and use across the application.