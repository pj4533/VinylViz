# VinylViz Development Guide

## Build & Test Commands
- Build: `xcodebuild -project VinylViz.xcodeproj -scheme VinylViz -destination "platform=visionOS Simulator,name=Apple Vision Pro" build`
- Run: `xcodebuild -project VinylViz.xcodeproj -scheme VinylViz -destination "platform=visionOS Simulator,name=Apple Vision Pro" run`
- Test: `xcodebuild -project VinylViz.xcodeproj -scheme VinylViz -destination "platform=visionOS Simulator,name=Apple Vision Pro" test`
- Test single class: `xcodebuild -project VinylViz.xcodeproj -scheme VinylViz -destination "platform=visionOS Simulator,name=Apple Vision Pro" test -only-testing:VinylVizTests/TestClassName`

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