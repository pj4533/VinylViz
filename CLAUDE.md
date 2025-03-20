# VinylViz Development Guide

## Build & Test Commands
- Open project: `open VinylViz.xcodeproj`
- Build: Cmd+B or Product > Build in Xcode
- Run: Cmd+R or Product > Run in Xcode
- Test: Cmd+U or Product > Test in Xcode
- Run single test: Cmd+U with cursor in test method or Product > Test Selected

## Code Style Guidelines
- **Imports**: Group imports (Foundation, SwiftUI, RealityKit) with RealityKit-specific imports last
- **Naming**: Use descriptive camelCase for variables, PascalCase for types
- **Documentation**: Use /// for property and method documentation
- **Error Handling**: Use do/catch blocks with specific error messages printed to console
- **Async**: Use Swift concurrency (async/await) for asynchronous operations
- **Logging**: Use print statements with class/method prefix (e.g., "AudioInputMonitor::startEngine()")
- **SwiftUI**: Prefer environment over direct injection when appropriate
- **Access Control**: Mark helpers as private, public API as internal (default)
- **Comments**: Use // for implementation comments, /// for documentation