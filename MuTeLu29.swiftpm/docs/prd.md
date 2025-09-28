# MuTeLu Product Requirements Document (PRD)

## Goals and Background Context

### Goals

• Enable users to discover and explore sacred places and temples in Thailand through location-based recommendations
• Provide comprehensive information about religious sites in both Thai and English languages  
• Create an engaging spiritual tourism experience through interactive features and gamification
• Build a merit points system to encourage participation in religious activities
• Deliver fortune-telling and spiritual guidance features based on Thai cultural traditions
• Support both iPhone and iPad platforms with iOS 18.1+ compatibility
• Establish foundation for future social features and e-commerce capabilities

### Background Context

MuTeLu (หมู่เทวดาลุ้น) addresses the growing need for a digital companion in spiritual tourism within Thailand. As traditional religious practices meet modern technology, there's a gap in the market for an application that respectfully combines sacred site exploration with interactive engagement. The app solves the problem of tourists and locals struggling to find appropriate temples and sacred places for their specific spiritual needs, while also providing cultural education through gamification and fortune-telling features rooted in Thai traditions. The current landscape shows fragmented information sources and lack of personalized recommendations for spiritual tourism, which MuTeLu aims to consolidate into a single, intelligent platform.

### Change Log

| Date | Version | Description | Author |
|------|---------|-------------|---------|
| 2025-09-27 | 1.0 | Initial PRD creation based on Project Brief | BMad Master |

## Requirements

### Functional

• **FR1**: The system shall authenticate users with email/password and maintain session state across app launches
• **FR2**: The system shall detect user's current location and display sacred places sorted by proximity (nearest first)
• **FR3**: The system shall provide detailed information for each sacred place in both Thai and English languages including name, description, opening hours, and religious significance
• **FR4**: The system shall recommend similar sacred places using cosine similarity algorithm based on place tags and user visit history
• **FR5**: The system shall allow users to check-in at sacred places when within valid GPS range and enforce cooldown periods between check-ins
• **FR6**: The system shall calculate and display both straight-line and actual route distances to sacred places using Apple Maps integration
• **FR7**: The system shall provide fortune-telling features including phone number analysis, daily shirt color recommendations, car plate analysis, house number fortune, tarot cards, and Seam Si
• **FR8**: The system shall track and display merit points earned through check-ins, game participation, and religious activities
• **FR9**: The system shall provide an offering game where users match items to monks with scoring and level progression
• **FR10**: The system shall display religious holiday banners and daily recommendations based on Buddhist calendar
• **FR11**: The system shall maintain user profiles with personal information, birth details, contact info, and accumulated merit points
• **FR12**: The system shall provide admin functionality to manage users, view check-in statistics, and edit member information
• **FR13**: The system shall display mantras, prayers, and wish-making instructions for various religious purposes
• **FR14**: The system shall maintain check-in history showing visited places with timestamps and locations
• **FR15**: The system shall support filtering and searching sacred places by tags such as temple type, deity, or purpose

### Non Functional

• **NFR1**: The app shall support iOS 18.1+ on both iPhone and iPad devices with responsive layouts
• **NFR2**: Location-based features shall provide results within 3 seconds of request
• **NFR3**: The app shall function offline for viewing previously loaded sacred place data
• **NFR4**: All fortune-telling calculations shall complete within 1 second
• **NFR5**: The recommendation engine shall process similarity calculations for up to 500 places within 2 seconds
• **NFR6**: User data shall be persisted locally using UserDefaults and remain available across app sessions
• **NFR7**: The app shall handle location permission denials gracefully with appropriate fallback functionality
• **NFR8**: UI text shall support both Thai and English with user-selectable language preference
• **NFR9**: The app shall maintain 60 FPS performance during game interactions and animations
• **NFR10**: Sacred place data shall be loaded from local JSON files with support for future remote updates
• **NFR11**: The check-in system shall validate location accuracy within 100 meters of sacred place coordinates
• **NFR12**: All images and assets shall be optimized for both standard and Retina displays

## User Interface Design Goals

### Overall UX Vision

Create a spiritually respectful yet modern interface that seamlessly blends traditional Thai religious aesthetics with intuitive mobile interactions. The design should evoke a sense of calm and reverence while maintaining playful elements for gamification features. Visual hierarchy should guide users naturally from discovery to engagement to spiritual fulfillment.

### Key Interaction Paradigms

• **Location-First Navigation**: Primary interactions driven by proximity and map-based discovery
• **Card-Based Information Architecture**: Sacred places and content presented as swipeable cards with progressive disclosure
• **Tab Navigation**: Bottom tab bar for main sections (Home, Discover, Games, Fortune, Profile)
• **Modal Presentations**: Fortune-telling results and check-in confirmations as immersive overlays
• **Gesture-Driven**: Swipe gestures for browsing places, pull-to-refresh for updates
• **Visual Feedback**: Haptic responses for merit point gains and successful check-ins

### Core Screens and Views

• **Greeting/Onboarding Screen** - Welcome with spiritual imagery and permission requests
• **Home Dashboard** - Nearby places grid, daily banner, quick access to fortune features  
• **Sacred Place Discovery** - Map view and list view toggle with filtering options
• **Place Detail View** - Full information, photos, check-in button, directions
• **Fortune Hub** - Grid of fortune-telling options with visual icons
• **Individual Fortune Screens** - Phone, shirt color, car plate, house number, tarot, Seam Si
• **Offering Game Screen** - Animated game board with monks and items
• **Merit Points Dashboard** - Progress visualization and achievement history
• **Profile/Settings** - User information, language toggle, admin access
• **Check-in History** - Timeline view of visited places
• **Knowledge Center** - Mantras, prayers, and religious information

### Accessibility: WCAG AA

Following WCAG AA standards for inclusive design ensuring the app is usable by people with disabilities, including proper color contrast ratios and VoiceOver support.

### Branding

• **Thai Traditional Aesthetics**: Gold and saffron color accents reminiscent of temple architecture
• **Sacred Geometry**: Incorporate traditional Thai patterns and mandala designs as decorative elements
• **Typography**: Clean sans-serif for UI with optional Thai traditional fonts for headers
• **Iconography**: Custom icons inspired by Buddhist and Thai religious symbols
• **Color Palette**: Warm earth tones with gold highlights, avoiding harsh contrasts to maintain peaceful ambiance
• **Imagery**: High-quality photography of actual sacred places with respectful composition

### Target Device and Platforms: Web Responsive

• **Primary**: Native iOS app for iPhone (all sizes from SE to Pro Max)
• **Secondary**: iPad support with adaptive layouts utilizing larger screen real estate
• **Minimum iOS**: 18.1+ taking advantage of latest SwiftUI capabilities
• **Orientation**: Portrait primary, landscape supported for iPad
• **No web version in MVP** - purely native iOS experience

## Technical Assumptions

### Repository Structure: Monorepo

Single repository containing all iOS app code, resources, and documentation in MuTeLu29.swiftpm package structure.

### Service Architecture

**Monolithic iOS Application** - All features integrated within a single iOS app bundle using SwiftUI's modular view composition. The app follows MVVM architecture pattern with ObservableObject for state management and Environment Objects for cross-view data sharing.

### Testing Requirements

**Unit + Integration Testing** - Unit tests for business logic (recommendation engine, fortune calculations, game mechanics), integration tests for location services and data loading, plus manual testing convenience methods for check-in validation and GPS simulation.

### Additional Technical Assumptions and Requests

• **Language & Framework**: Swift 5.9 with SwiftUI as the exclusive UI framework (no UIKit except where required by system APIs)
• **Minimum iOS Version**: iOS 18.1+ allowing use of latest SwiftUI features and APIs
• **Data Storage**: UserDefaults for user preferences and simple data, in-memory storage with ObservableObject for session data, local JSON files for sacred place database
• **Location Services**: CoreLocation for GPS positioning, MapKit for map display and route calculation
• **State Management**: Combine framework with @Published properties, @StateObject/@ObservedObject for view models, @EnvironmentObject for shared app state
• **Navigation**: Centralized MuTeLuFlowManager using enum-based screen definitions
• **Localization**: Built-in iOS localization for Thai/English support using Localizable.strings
• **Asset Management**: Asset catalogs for images with 2x/3x variants for different screen densities
• **Networking**: URLSession for future API integration (Phase 2), currently all data is local
• **Dependency Management**: Swift Package Manager for any third-party dependencies
• **Build System**: Xcode Cloud for CI/CD pipeline with automated TestFlight distribution
• **Code Organization**: Feature-based folder structure (Views/, Models/, Services/, etc.)
• **Error Handling**: Swift's Result type and do-catch for graceful error management
• **Performance**: Lazy loading for views and images, efficient list rendering with SwiftUI List
• **Security**: Keychain for sensitive data in future versions, no sensitive data stored in UserDefaults
• **Analytics**: Prepared for future Firebase/Analytics integration with abstracted tracking layer

## Epic List

**Epic 1: Foundation & Core Stabilization**
*Establish development infrastructure, fix critical issues, and ensure core user authentication and profile management work flawlessly*

**Epic 2: Location Services & Sacred Place Discovery**  
*Complete the location-based discovery system with check-in functionality, recommendations, and place details*

**Epic 3: Fortune & Spiritual Guidance Features**
*Finalize all fortune-telling features including phone, shirt color, car plate, house number, tarot, and Seam Si with proper calculations and UI*

**Epic 4: Gamification & Merit System**
*Implement the offering game, merit points tracking, achievements, and reward mechanics*

**Epic 5: Knowledge & Content Delivery**
*Complete the mantras, prayers, wish details, and educational content sections with proper localization*

## Epic 1: Foundation & Core Stabilization

**Goal**: Establish robust development infrastructure, resolve existing check-in cooldown issues, and ensure user authentication and profile management work flawlessly. This epic delivers a stable foundation with proper error handling, data persistence, and a working user system that all other features depend upon.

### Story 1.1: Development Infrastructure Setup

As a developer,
I want a properly configured development environment with CI/CD pipeline,
so that code changes can be tested and deployed reliably.

#### Acceptance Criteria
1: Xcode project builds without warnings for iOS 18.1+ targets
2: Git repository has proper .gitignore and branch protection rules
3: Swift Package Manager dependencies are locked and documented
4: Xcode Cloud pipeline configured for automated TestFlight builds
5: Development, staging, and production environment configurations established

### Story 1.2: Fix Check-in Cooldown System

As a user,
I want the check-in cooldown to work properly with clear feedback,
so that I understand when I can check-in at places again.

#### Acceptance Criteria
1: Check-in cooldown prevents duplicate check-ins within defined time period (1 hour default)
2: UI displays remaining cooldown time in user-friendly format
3: Check-in button shows disabled state during cooldown with countdown
4: System persists cooldown data across app launches
5: Cooldown is tracked per place (can check-in at different places)

### Story 1.3: User Authentication Flow

As a new user,
I want to register and login with email/password,
so that my profile and progress are saved.

#### Acceptance Criteria
1: Registration form validates email format and password strength
2: Login persists session using UserDefaults/Keychain
3: "Remember Me" option keeps user logged in
4: Logout clears session and returns to login screen
5: Appropriate error messages for invalid credentials

### Story 1.4: Profile Management Enhancement

As a registered user,
I want to manage my profile information completely,
so that the app can provide personalized experiences.

#### Acceptance Criteria
1: Edit profile form includes all fields from Member model
2: Birth date/time picker with Thai Buddhist calendar support
3: Profile changes persist immediately using MemberStore
4: Optional fields (car plate, house number) can be added/removed
5: Profile completion percentage shown to encourage full profiles

## Epic 2: Location Services & Sacred Place Discovery

**Goal**: Complete the location-based discovery system enabling users to find nearby sacred places, view detailed information, get directions, and check-in when visiting. This epic delivers the core value proposition of spiritual tourism guidance.

### Story 2.1: Location Permission & GPS Management

As a user,
I want the app to request and handle location permissions properly,
so that location features work when I allow them.

#### Acceptance Criteria
1: Location permission requested with clear explanation of usage
2: App functions with limited features if location denied
3: Settings deep-link provided if user changes mind
4: GPS accuracy indicator shown when location active
5: Manual location selection fallback available

### Story 2.2: Sacred Place Discovery Interface

As a user,
I want to discover sacred places through list and map views,
so that I can find places of interest nearby or in specific areas.

#### Acceptance Criteria
1: List view shows places sorted by distance with key info
2: Map view displays pins for all sacred places
3: Toggle between list/map views maintains selection
4: Search bar filters by name in both languages
5: Filter chips for tags (temple, shrine, statue, etc.)

### Story 2.3: Sacred Place Detail Screen

As a user,
I want to view comprehensive information about each sacred place,
so that I can decide if I want to visit and know what to expect.

#### Acceptance Criteria
1: Display all SacredPlace model fields in organized sections
2: Photo gallery with pinch-to-zoom support
3: Opening hours with current status (open/closed)
4: Tap address to open in Apple Maps
5: Share button to send place info to others

### Story 2.4: Real-time Distance & Directions

As a user,
I want accurate distance information and directions to sacred places,
so that I can plan my visits effectively.

#### Acceptance Criteria
1: Show both straight-line and actual route distance
2: Calculate route using RouteDistanceService with Apple Maps
3: Display estimated travel time for driving/walking
4: "Get Directions" opens turn-by-turn navigation
5: Distance updates when user location changes significantly

### Story 2.5: Check-in at Sacred Places

As a user,
I want to check-in when I visit sacred places,
so that I can track my spiritual journey and earn merit points.

#### Acceptance Criteria
1: Check-in button enabled only when within 100m radius
2: Successful check-in shows confirmation with points earned
3: Check-in record created with timestamp and location
4: Merit points added to user total immediately
5: Check-in history updated with new visit

## Epic 3: Fortune & Spiritual Guidance Features

**Goal**: Finalize all fortune-telling features providing users with culturally authentic spiritual guidance through various methods. This epic delivers the engaging spiritual content that differentiates the app from basic location guides.

### Story 3.1: Phone Number Fortune Analysis

As a user,
I want to receive fortune analysis based on my phone number,
so that I can understand its spiritual significance.

#### Acceptance Criteria
1: Input validates Thai phone number format (10 digits)
2: Analysis algorithm sums digits and provides interpretation
3: Display lucky/unlucky number meanings from numberMeaning.json
4: Results show in both Thai and English
5: Save analyzed number to profile if desired

### Story 3.2: Daily Shirt Color Recommendation

As a user,
I want to know my lucky shirt color for each day,
so that I can dress appropriately for good fortune.

#### Acceptance Criteria
1: Calculate color based on birth date and current day
2: Display color with visual swatch and meaning
3: Show traditional Thai day color associations
4: Provide weekly view of upcoming colors
5: Set optional daily reminder notification (Phase 2 prep)

### Story 3.3: Car License Plate Analysis

As a user,
I want to analyze my car's license plate for fortune,
so that I can understand if it brings good luck.

#### Acceptance Criteria
1: Input accepts Thai license plate format
2: Parse numbers and calculate fortune score
3: Provide detailed interpretation of number combinations
4: Suggest alternative numbers if current is unlucky
5: Save plate number to profile for quick access

### Story 3.4: House Number Fortune

As a user,
I want to analyze my house number's spiritual significance,
so that I can understand its influence on my home life.

#### Acceptance Criteria
1: Accept various house number formats (with letters/subunits)
2: Extract numeric values for calculation
3: Provide feng shui and numerology interpretations
4: Suggest remedies for unlucky numbers
5: Compare multiple addresses if user has several properties

### Story 3.5: Tarot Card Reading

As a user,
I want to receive tarot card readings,
so that I can gain spiritual insights about my questions.

#### Acceptance Criteria
1: Animated card shuffle and selection interface
2: Multiple spread types (1-card, 3-card, Celtic cross)
3: Card meanings adapted to Buddhist/Thai context
4: Save reading history with date and question
5: Share reading results as image

### Story 3.6: Seam Si (Sacred Lottery)

As a user,
I want to perform Seam Si fortune telling,
so that I can receive traditional Thai spiritual guidance.

#### Acceptance Criteria
1: Animated stick/ball selection from container
2: Display corresponding fortune from database
3: Provide detailed interpretation and advice
4: Option to draw again after reading
5: Track frequency of drawings for patterns

## Epic 4: Gamification & Merit System

**Goal**: Implement the complete offering game and merit points system to encourage user engagement through meaningful spiritual activities. This epic delivers the gamification layer that drives retention and repeated app usage.

### Story 4.1: Merit Points Tracking System

As a user,
I want to earn and track merit points from my spiritual activities,
so that I can measure my spiritual progress.

#### Acceptance Criteria
1: Points awarded for check-ins, game completion, daily login
2: Running total displayed in profile and main menu
3: Point history shows all earning events with timestamps
4: Different point values for different activities
5: Weekly/monthly point summaries available

### Story 4.2: Offering Game Core Mechanics

As a user,
I want to play the offering game matching items to monks,
so that I can learn about Buddhist offerings while having fun.

#### Acceptance Criteria
1: Drag-and-drop items to correct monks
2: Timer countdown creates urgency
3: Score multiplier for consecutive correct matches
4: Lives system with game over state
5: Smooth animations at 60 FPS

### Story 4.3: Offering Game Progression

As a user,
I want to progress through increasingly challenging game levels,
so that the game remains engaging over time.

#### Acceptance Criteria
1: 10+ levels with increasing difficulty
2: More monks and items at higher levels
3: Shorter time limits as difficulty increases
4: Unlock new offering types at milestones
5: Level selection screen to replay completed levels

### Story 4.4: Game Rewards & Achievements

As a user,
I want to earn rewards and achievements from game performance,
so that I feel recognized for my progress.

#### Acceptance Criteria
1: Merit points awarded based on score and level
2: Achievement badges for milestones (first perfect, 10 streak, etc.)
3: Daily challenges with bonus rewards
4: Leaderboard preparation (local only for MVP)
5: Visual celebration animations for achievements

### Story 4.5: Game Polish & Sound

As a user,
I want polished game experience with sound effects,
so that the game feels professional and engaging.

#### Acceptance Criteria
1: Sound effects for drag, drop, correct, wrong actions
2: Background music appropriate to temple atmosphere
3: Settings to control sound/music volume
4: Haptic feedback for interactions
5: Particle effects for successful offerings

## Epic 5: Knowledge & Content Delivery

**Goal**: Complete the educational and content sections providing users with mantras, prayers, and religious knowledge in both languages. This epic delivers the educational value that helps users understand and participate in Thai Buddhist culture.

### Story 5.1: Mantra Library

As a user,
I want to access a library of Buddhist mantras and prayers,
so that I can learn and practice them properly.

#### Acceptance Criteria
1: Categorized list of mantras (daily, protection, prosperity, etc.)
2: Display in Thai script with romanization
3: Audio pronunciation guides (Phase 2 prep)
4: Meaning and usage explanation for each
5: Bookmark favorite mantras for quick access

### Story 5.2: Wish & Prayer Instructions

As a user,
I want to learn proper ways to make wishes at different sacred places,
so that I can follow appropriate customs.

#### Acceptance Criteria
1: Place-specific wish-making instructions
2: General Buddhist prayer guidelines
3: Offering item recommendations per place type
4: Do's and don'ts for temple etiquette
5: Visual guides for hand positions and bowing

### Story 5.3: Religious Calendar & Events

As a user,
I want to know about Buddhist holy days and events,
so that I can participate in religious activities.

#### Acceptance Criteria
1: Display Buddhist calendar with holy days marked
2: Explanation of each holy day's significance
3: Recommended activities for each holy day
4: Temple events from places in database
5: Reminder settings for important days (Phase 2 prep)

### Story 5.4: Content Localization Completion

As a developer,
I want all content properly localized in Thai and English,
so that users can use the app in their preferred language.

#### Acceptance Criteria
1: All UI strings in Localizable.strings files
2: Language toggle in settings persists selection
3: Sacred place data displays in selected language
4: Fortune results available in both languages
5: RTL support for any Arabic numerals in Thai mode

### Story 5.5: Help & Onboarding

As a new user,
I want help understanding app features and Thai religious customs,
so that I can use the app effectively regardless of my background.

#### Acceptance Criteria
1: First-launch onboarding explains key features
2: Contextual help buttons on complex screens
3: FAQ section covering common questions
4: Glossary of Buddhist/Thai religious terms
5: Contact support option for additional help

---

*Document Version: 1.0*  
*Created: 2025-09-27*  
*Status: Draft - Pending Checklist Review*