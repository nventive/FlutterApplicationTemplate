# GitHub Copilot Prompt Templates

This directory contains comprehensive prompt templates designed to help developers work effectively with GitHub Copilot in this Flutter application template. These templates follow the project's established MVVM + Clean Architecture patterns and coding standards.

## Quick Setup

1. **Configure GitHub Copilot**: Make sure you have GitHub Copilot enabled in your IDE
2. **Read the Instructions**: Review [copilot-instructions.md](../copilot-instructions.md) for project-specific patterns
3. **Choose a Template**: Select the appropriate template for your task from the list below
4. **Follow the Template**: Copy and paste the relevant sections into your Copilot chat or comments

## Available Templates

### 🏗️ [Feature Development](feature-development.md)
**Use when**: Creating new features following the MVVM + Clean Architecture pattern
- Complete feature implementation guide
- Data models, repositories, services, and ViewModels
- UI components and navigation setup
- Testing and dependency injection

### 🐛 [Bug Fix](bug-fix.md)  
**Use when**: Debugging and fixing issues systematically
- Systematic debugging approach
- Layer-specific debugging strategies
- Error reproduction and testing
- Performance and memory issue diagnosis

### 🔧 [Refactoring](refactoring.md)
**Use when**: Improving code structure while preserving functionality
- Safe refactoring practices
- Architecture pattern improvements
- Performance optimization during refactoring
- Testing during code changes

### 🧪 [Testing](testing.md)
**Use when**: Writing comprehensive tests for your code
- Unit, widget, and integration testing
- Mock implementations and test data factories
- Performance and accessibility testing
- CI/CD test integration

### 🎨 [UI Component](ui-component.md)
**Use when**: Creating reusable UI components
- Design system compliance
- Responsive and accessible components
- Performance-optimized widgets
- Component testing strategies

### 🌐 [API Integration](api-integration.md)
**Use when**: Integrating with REST APIs or external services
- Repository pattern with Retrofit
- Error handling and authentication
- Caching and performance optimization
- Network testing and mocking

### ⚡ [Performance Optimization](performance-optimization.md)
**Use when**: Improving app performance and responsiveness
- UI rendering optimization
- Memory management
- Network and database performance
- Performance monitoring and testing

## How to Use These Templates

### Method 1: Direct Copy-Paste
1. Open the relevant template file
2. Copy the sections you need
3. Paste into GitHub Copilot chat or code comments
4. Follow the step-by-step instructions

### Method 2: Reference in Comments
```dart
// Using GitHub Copilot Feature Development Template
// Create a user management service following the repository pattern
// with proper error handling and stream-based state management
```

### Method 3: Copilot Chat Integration
In GitHub Copilot chat, reference templates like this:
```
@workspace Using the API Integration template, help me create a repository for managing user data with proper error handling and caching.
```

## Template Structure

Each template follows this consistent structure:

1. **Context Section**: Describes when and how to use the template
2. **Implementation Steps**: Step-by-step instructions with code examples
3. **Architecture Patterns**: How to follow the project's established patterns
4. **Testing Guidelines**: How to test the implemented code
5. **Performance Considerations**: Optimization tips and best practices
6. **Common Pitfalls**: Anti-patterns to avoid
7. **Checklists**: Validation steps to ensure quality

## Best Practices

### ✅ Do
- Read the [copilot-instructions.md](../copilot-instructions.md) first
- Choose the most appropriate template for your task
- Follow the step-by-step instructions in order
- Adapt the examples to your specific use case
- Use the checklists to validate your implementation
- Test your code thoroughly

### ❌ Don't
- Skip the architecture guidelines
- Modify the established patterns without good reason
- Ignore the testing requirements
- Copy code without understanding it
- Forget to handle error cases
- Skip performance considerations

## Contributing to Templates

If you find improvements or need additional templates:

1. **For improvements**: Create a PR with your suggested changes
2. **For new templates**: Follow the existing template structure
3. **For questions**: Open an issue with the `copilot-templates` label

## Project Architecture Reminder

This Flutter template uses:
- **MVVM Pattern**: Custom ViewModel base class with property change notification
- **Clean Architecture**: Access (data) → Business (logic) → Presentation (UI) layers
- **Dependency Injection**: GetIt service locator pattern
- **Repository Pattern**: Retrofit-based API integration
- **State Management**: RxDart streams with reactive UI
- **Testing**: Unit tests, widget tests, and integration tests

## IDE Integration

### VS Code
1. Install the GitHub Copilot extension
2. Use `Ctrl+I` (or `Cmd+I`) to open Copilot chat
3. Reference templates with `@workspace` mentions

### Android Studio/IntelliJ
1. Install the GitHub Copilot plugin
2. Use the Copilot tool window
3. Copy template content into chat

## Template Updates

These templates are living documents that evolve with the project:
- Templates are updated when architecture patterns change
- New templates are added for emerging development patterns
- Examples are kept current with the latest project structure

For the most up-to-date templates, always refer to the main branch of this repository.

---

**Need Help?** 
- Check the [project documentation](../../doc/) for architecture details
- Review existing code examples in the `src/app/lib/` directory
- Open an issue if templates need clarification or improvements