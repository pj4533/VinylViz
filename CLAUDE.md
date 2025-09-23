# VinylViz Development Guide

## Project Overview
VinylViz is a multiplatform music visualization and discovery application that combines audio-reactive visuals with AI-powered music knowledge and recommendations. The project is transitioning from a passive visionOS visualization experience to an active, interactive music discovery platform across Apple devices.

### Quick Summary
VinylViz transforms music listening into an interactive experience by:
1. **Identifying** songs in real-time using ShazamKit
2. **Visualizing** audio with stunning reactive graphics
3. **Conversing** with an AI music buddy that shares facts and asks preference questions
4. **Learning** user tastes through simple A/B choice questions
5. **Discovering** personalized music recommendations from mainstream to obscure gems

The iOS app features three main tabs: Live Listening (real-time visualizations + AI chat), Suggestions (personalized recommendations), and Settings.

### Full Project Documentation
For complete details about the project vision, architecture, and implementation plans, see: **`docs/vinylviz_multiplatform_update.md`**

## Project Structure
- **visionOS/**: Original immersive visualization experience for Apple Vision Pro
- **iOS/**: Active listening experience with AI-powered discovery (primary focus)
- **docs/**: Project documentation and planning documents

## Key Technologies
- **ShazamKit**: Automatic song identification
- **OpenAI API**: Conversational AI for music facts and recommendations
- **Apple Music/MusicKit**: Library integration and music playback
- **Core Audio**: Real-time audio analysis for visualizations

## Development Philosophy
- **Active Engagement**: Transform passive listening into interactive discovery
- **AI Personality**: "Stoned friend with encyclopedic music knowledge" - knowledgeable but approachable
- **Simple Interactions**: Binary choices only (A or B) for all user questions
- **Progressive Learning**: System gets smarter about user preferences over time
- **Deep Discovery**: Surface obscure gems alongside accessible recommendations

## Platform-Specific Guidelines

### iOS Development
- **Target iOS 26** - Always use the latest Apple APIs and SwiftUI features
- Focus on responsive touch interactions
- Optimize visualizations for mobile performance
- Design for both portrait and landscape orientations
- Implement background audio handling appropriately
- Consider battery optimization for long listening sessions

### visionOS Development
- See visionOS/CLAUDE.md for Vision Pro specific guidelines
- Maintain existing immersive experience
- Consider future integration with iOS preference data

## Code Style Guidelines (All Platforms)
- **API Usage**: Always use the latest Apple APIs available in iOS 26/visionOS 2
- **Imports**: Group imports logically (Foundation, SwiftUI, third-party)
- **Naming**: Use descriptive camelCase for variables, PascalCase for types
- **Documentation**: Use /// for public API documentation
- **Error Handling**: Comprehensive error handling with user-friendly messages
- **Async**: Use Swift concurrency (async/await) throughout
- **Logging**: Structured logging using OSLog framework
- **Architecture**: Clean separation of concerns (UI, Business Logic, Data)

## AI Integration Guidelines
- **OpenAI Prompting**: Maintain consistent personality across all interactions
- **Question Generation**: Maximum 10 words, always binary choice
- **Fact Delivery**: Short, punchy, interesting - never overwhelming
- **Recommendations**: Balance familiarity with discovery, adapt to user engagement level
- **Context Preservation**: Maintain conversation context within listening sessions

## Data Management
- **User Preferences**: Store locally with proper encryption
- **Question History**: Track all interactions for preference learning
- **Recommendation Cache**: Store recent suggestions for offline access
- **Privacy First**: Never share user data without explicit consent

## Testing Approach
- Unit tests for preference learning algorithms
- Integration tests for API connections (ShazamKit, OpenAI, MusicKit)
- UI tests for critical user flows
- Performance tests for visualization smoothness

## Build & Deploy
- Each platform has its own Xcode project/workspace
- Use Swift Package Manager for shared dependencies
- Follow platform-specific build instructions in respective folders
- Ensure all API keys are properly configured in environment

## Important Reminders
- Never commit API keys or secrets to the repository
- Test on real devices when possible (especially for audio features)
- Consider accessibility from the start (VoiceOver, Dynamic Type)
- Respect Apple's Human Interface Guidelines per platform
- Keep visualizations performant to maintain 60+ FPS

## Current Development Status
- ✅ visionOS: Complete and functional
- 🚧 iOS: In active development
- 📋 tvOS: Planned for future

## Documentation
- See `docs/vinylviz_multiplatform_update.md` for detailed expansion plans
- Platform-specific documentation in respective folders
- API integration guides in docs folder as needed