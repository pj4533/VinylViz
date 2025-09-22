# VinylViz

<img src="assets/vinylviz_option1_2048.png" alt="VinylViz Logo" width="400"/>

## Transform Music Listening into Interactive Discovery

VinylViz is an AI-powered music visualization and discovery platform that turns passive listening into an engaging, interactive journey. By combining stunning audio-reactive visuals with conversational AI, VinylViz helps you discover music you never knew you needed to hear.

## 🎯 Project Vision

VinylViz reimagines how we experience and discover music by creating an intelligent companion that learns your tastes through natural interaction. Think of it as having a knowledgeable music friend who watches visualizations with you, shares fascinating stories, asks what you like, and suggests incredible deep cuts based on your preferences.

## 📱 Platform Status

### iOS (In Active Development) 🚧
The iOS app is currently being built as the primary platform for the new VinylViz experience, featuring:
- **Real-time music identification** via ShazamKit
- **Interactive AI conversations** about the music you're listening to
- **Binary-choice questions** to learn your preferences
- **Personalized recommendations** that go beyond mainstream suggestions
- **Stunning audio-reactive visualizations** that respond to the music
- **Apple Music integration** for seamless library management

### visionOS (Legacy - Functional) ✅
The visionOS app remains available as the original passive visualization experience:
- Immersive 3D audio visualizations
- Spatial computing environment
- Beautiful, meditative visual experience
- **Note**: This version has not yet been updated with the new AI-powered features

### tvOS (Planned) 📋
Future expansion for living room experiences

## 🌟 Key Features

### Active Listening Experience
- **Automatic Song Recognition**: Identifies whatever is playing around you
- **AI Music Companion**: An enthusiastic but laid-back "friend" with encyclopedic music knowledge
- **Interactive Questions**: Simple A/B choices that help the AI learn your tastes
- **Progressive Learning**: Gets smarter about your preferences over time

### Discovery Engine
- **Deep Recommendations**: Surfaces obscure gems alongside accessible favorites
- **Contextual Suggestions**: Based on specific elements you enjoy (fuzzy guitars, synth textures, etc.)
- **Apple Music Integration**: Preview, save, and play recommendations instantly

### Visual Experience
- **Audio-Reactive Animations**: Visuals that pulse and flow with the music
- **Multiple Visualization Modes**: Different styles for different moods
- **Performance Optimized**: Smooth 60+ FPS animations

## 🛠 Technology Stack

- **SwiftUI** - Native Apple platform UI
- **ShazamKit** - Music identification
- **OpenAI API** - Conversational AI and recommendations
- **Apple MusicKit** - Music library integration
- **Core Audio** - Real-time audio analysis
- **RealityKit** - visionOS 3D visualizations

## 🚀 Getting Started

### iOS Development
```bash
cd iOS/
# Open Xcode project (to be created)
# Configure API keys for OpenAI and Apple Music
# Build and run on device or simulator
```

### visionOS Development
```bash
cd visionOS/
# Open VinylViz.xcodeproj in Xcode
# Build for visionOS Simulator or device
# See visionOS/CLAUDE.md for detailed instructions
```

## 📖 Documentation

- **[Multiplatform Update Plan](docs/vinylviz_multiplatform_update.md)** - Detailed expansion strategy
- **[Development Guide](CLAUDE.md)** - Project-wide development guidelines
- **[visionOS Guide](visionOS/CLAUDE.md)** - Vision Pro specific documentation

## 🎨 Design Philosophy

VinylViz believes that music discovery should be:
- **Engaging** - Not just passive consumption
- **Personal** - Learns what makes your ears happy
- **Deep** - Goes beyond top 40 and "similar artists"
- **Fun** - Like listening with a knowledgeable friend
- **Beautiful** - Visuals that enhance the experience

## 🔮 Roadmap

### Phase 1: iOS Foundation (Current)
- ✅ Project architecture and planning
- 🚧 Core iOS app development
- 🚧 ShazamKit integration
- 🚧 OpenAI conversation engine
- ⏳ Basic visualizations

### Phase 2: Discovery Features
- ⏳ Preference learning system
- ⏳ Recommendation engine
- ⏳ Apple Music integration
- ⏳ Advanced visualizations

### Phase 3: Platform Expansion
- ⏳ Update visionOS with AI features
- ⏳ tvOS development
- ⏳ Cross-device preference sync
- ⏳ Social features

## 📄 License

VinylViz is released under the MIT License. See [LICENSE](LICENSE) for details.
