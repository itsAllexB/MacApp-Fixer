# Contributing to MacApp Fixer

Thank you for considering contributing to MacApp Fixer!

## 🐛 Found a Bug?

If you found a bug, please open an issue with:
- A clear description of the problem
- Steps to reproduce
- Expected vs actual behavior
- Your macOS version
- Screenshots if applicable

## 💡 Have an Idea?

Have a feature request or suggestion? Open an issue and describe:
- What problem it solves
- How it should work
- Any examples or mockups

## 🔧 Want to Contribute Code?

### Development Setup

1. **Fork and clone the repository**
   ```bash
   git clone
   cd macapp-fixer
   ```

2. **Build and run**
   ```bash
   swift run
   ```

3. **Make your changes**
   - Keep the code clean and well-documented
   - Follow Swift best practices
   - Test your changes thoroughly

4. **Test your changes**
   ```bash
   swift build
   swift run
   ```

5. **Submit a pull request**
   - Fork the repo
   - Create a feature branch (`git checkout -b feature/amazing-feature`)
   - Commit your changes (`git commit -m 'Add amazing feature'`)
   - Push to the branch (`git push origin feature/amazing-feature`)
   - Open a Pull Request

### Code Style

- Use Swift 6.0 features where appropriate
- Follow Apple's [Swift API Design Guidelines](https://swift.org/documentation/api-design-guidelines/)
- Keep the UI modern and consistent with macOS design patterns
- Add comments for complex logic

### Project Structure

```
macapp-fixer/
├── Package.swift           # Swift Package Manager config
├── Sources/
│   ├── MacAppFixerApp.swift    # Main app entry point
│   ├── ContentView.swift       # Main UI
│   └── Resources/              # Images, assets, etc.
└── README.md
```

## 📝 Documentation

If you're adding a new feature, please update the README.md with:
- What the feature does
- How to use it
- Any relevant examples

## ✅ Pull Request Checklist

- [ ] Code builds without errors
- [ ] Tested on macOS 15.0+
- [ ] Updated README.md (if needed)
- [ ] Follows Swift style guidelines
- [ ] No compiler warnings

## 🙏 Thank You!

Every contribution, no matter how small, is appreciated! ❤️
