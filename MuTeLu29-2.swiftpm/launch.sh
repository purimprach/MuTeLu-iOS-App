#!/bin/bash

# MuTeLu App Launcher Script
# This script helps launch the MuTeLu Swift Playground app

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
NC='\033[0m' # No Color

# Project configuration
PROJECT_PATH="/Volumes/Datas/Projects/MuTeLu/MuTeLu29.swiftpm"
PROJECT_NAME="Mu Te Lu"

# Function to print colored output
print_message() {
    local color=$1
    local message=$2
    echo -e "${color}${message}${NC}"
}

# Function to print header
print_header() {
    echo ""
    print_message $PURPLE "=========================================="
    print_message $PURPLE "$1"
    print_message $PURPLE "=========================================="
    echo ""
}

# Function to check if Xcode is installed
check_xcode() {
    if ! command -v xcodebuild &> /dev/null; then
        print_message $RED "❌ Xcode is not installed"
        print_message $YELLOW "Please install Xcode from the App Store"
        exit 1
    fi
    print_message $GREEN "✅ Xcode is installed"
}

# Function to check if Swift Playgrounds is installed
check_playgrounds() {
    if [ -d "/Applications/Swift Playgrounds.app" ] || [ -d "/Applications/Playgrounds.app" ]; then
        print_message $GREEN "✅ Swift Playgrounds is installed"
        return 0
    else
        print_message $YELLOW "⚠️  Swift Playgrounds is not installed (optional)"
        return 1
    fi
}

# Function to launch with Xcode
launch_xcode() {
    print_header "Launching with Xcode"
    print_message $BLUE "Opening project in Xcode..."
    
    if [ -d "$PROJECT_PATH" ]; then
        open "$PROJECT_PATH"
        print_message $GREEN "✅ Project opened in Xcode"
        echo ""
        print_message $YELLOW "📱 To run the app:"
        print_message $YELLOW "   1. Select a simulator from the device menu"
        print_message $YELLOW "   2. Press Cmd+R or click the ▶️ button"
        echo ""
    else
        print_message $RED "❌ Project not found at: $PROJECT_PATH"
        exit 1
    fi
}

# Function to launch with Swift Playgrounds
launch_playgrounds() {
    print_header "Launching with Swift Playgrounds"
    
    if check_playgrounds; then
        print_message $BLUE "Opening project in Swift Playgrounds..."
        open -a "Swift Playgrounds" "$PROJECT_PATH" 2>/dev/null || open -a "Playgrounds" "$PROJECT_PATH" 2>/dev/null
        print_message $GREEN "✅ Project opened in Swift Playgrounds"
    else
        print_message $RED "❌ Swift Playgrounds is not installed"
        print_message $YELLOW "Install from: https://apps.apple.com/app/swift-playgrounds/id908519492"
    fi
}

# Function to launch iOS Simulator
launch_simulator() {
    print_header "Launching iOS Simulator"
    
    print_message $BLUE "Opening iOS Simulator..."
    open -a Simulator
    
    # Wait for simulator to boot
    sleep 3
    
    # List available devices
    print_message $YELLOW "Available simulators:"
    xcrun simctl list devices | grep -E "iPhone|iPad" | grep -v unavailable | head -10
    
    print_message $GREEN "✅ Simulator launched"
    echo ""
    print_message $YELLOW "💡 Now open the project in Xcode and run it on the simulator"
}

# Function to build project
build_project() {
    print_header "Building Project"
    
    print_message $BLUE "Building $PROJECT_NAME..."
    
    cd "$PROJECT_PATH"
    
    # Try to build with swift build first
    if swift build 2>/dev/null; then
        print_message $GREEN "✅ Build successful"
    else
        print_message $YELLOW "⚠️  Direct build not supported for iOS apps"
        print_message $YELLOW "Please use Xcode to build and run"
    fi
}

# Function to show project info
show_info() {
    print_header "Project Information"
    
    print_message $BLUE "📁 Project: $PROJECT_NAME"
    print_message $BLUE "📍 Location: $PROJECT_PATH"
    
    if [ -f "$PROJECT_PATH/Package.swift" ]; then
        print_message $GREEN "✅ Package.swift found"
        
        # Extract some info from Package.swift
        print_message $YELLOW "\n📦 Package Details:"
        grep -E "name:|platforms:|\.iOS" "$PROJECT_PATH/Package.swift" | head -5
    fi
    
    # Count Swift files
    local swift_count=$(find "$PROJECT_PATH" -name "*.swift" -not -path "*/.*" | wc -l)
    print_message $YELLOW "\n📊 Statistics:"
    print_message $YELLOW "   Swift files: $swift_count"
    
    # Check for resources
    if [ -d "$PROJECT_PATH/Resources" ]; then
        local resource_count=$(find "$PROJECT_PATH/Resources" -type f | wc -l)
        print_message $YELLOW "   Resource files: $resource_count"
    fi
    
    if [ -d "$PROJECT_PATH/Assets.xcassets" ]; then
        print_message $YELLOW "   ✅ Assets catalog found"
    fi
}

# Function to show menu
show_menu() {
    print_header "🏛️ MuTeLu App Launcher"
    
    print_message $PURPLE "Choose an option:"
    echo ""
    print_message $BLUE "  1) 🛠️  Open in Xcode (Recommended)"
    print_message $BLUE "  2) 🎮 Open in Swift Playgrounds"
    print_message $BLUE "  3) 📱 Launch iOS Simulator only"
    print_message $BLUE "  4) 🔨 Build project"
    print_message $BLUE "  5) ℹ️  Show project info"
    print_message $BLUE "  6) 🚪 Exit"
    echo ""
    
    read -p "Enter your choice (1-6): " choice
    
    case $choice in
        1)
            launch_xcode
            ;;
        2)
            launch_playgrounds
            ;;
        3)
            launch_simulator
            ;;
        4)
            build_project
            ;;
        5)
            show_info
            show_menu
            ;;
        6)
            print_message $GREEN "👋 Goodbye!"
            exit 0
            ;;
        *)
            print_message $RED "Invalid choice. Please try again."
            show_menu
            ;;
    esac
}

# Function for quick launch (with arguments)
quick_launch() {
    case $1 in
        xcode)
            launch_xcode
            ;;
        playgrounds)
            launch_playgrounds
            ;;
        simulator)
            launch_simulator
            ;;
        build)
            build_project
            ;;
        info)
            show_info
            ;;
        *)
            print_message $RED "Unknown command: $1"
            print_message $YELLOW "Available commands: xcode, playgrounds, simulator, build, info"
            exit 1
            ;;
    esac
}

# Main execution
main() {
    # Check requirements
    check_xcode
    
    # If argument provided, quick launch
    if [ $# -gt 0 ]; then
        quick_launch $1
    else
        # Show interactive menu
        show_menu
    fi
}

# Show usage if --help
if [ "$1" == "--help" ] || [ "$1" == "-h" ]; then
    print_header "MuTeLu App Launcher Help"
    echo "Usage: $0 [command]"
    echo ""
    echo "Commands:"
    echo "  xcode       - Open in Xcode"
    echo "  playgrounds - Open in Swift Playgrounds"
    echo "  simulator   - Launch iOS Simulator"
    echo "  build       - Build project"
    echo "  info        - Show project info"
    echo ""
    echo "Examples:"
    echo "  $0              # Show interactive menu"
    echo "  $0 xcode        # Open directly in Xcode"
    echo "  $0 simulator    # Launch simulator"
    exit 0
fi

# Run main function
main "$@"