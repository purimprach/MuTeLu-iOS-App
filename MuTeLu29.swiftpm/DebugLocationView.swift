#if DEBUG
import SwiftUI
import CoreLocation

struct DebugLocationView: View {
    @EnvironmentObject var locationManager: LocationManager
    @EnvironmentObject var language: AppLanguage

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Header
            HStack {
                Image(systemName: "ant.circle.fill")
                    .foregroundColor(.orange)
                    .font(.title2)
                Text("Debug Location Settings")
                    .font(.headline)
                    .foregroundColor(.orange)
            }

            Divider()

            // Toggle Mock Location
            Toggle(isOn: $locationManager.useMockLocation) {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Use Mock Location")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                    Text("Override real GPS with preset locations")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            .tint(.orange)
            .onChange(of: locationManager.useMockLocation) { _, newValue in
                if newValue {
                    locationManager.triggerMockLocationUpdate()
                }
            }

            // Mock Location Picker
            if locationManager.useMockLocation {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Select Location")
                        .font(.caption)
                        .foregroundColor(.secondary)

                    Picker("Mock Location", selection: $locationManager.mockLocationName) {
                        Text("🏛️ Chulalongkorn").tag("Chulalongkorn")
                        Text("👑 Two Kings").tag("Two Kings")
                        Text("🛍️ Siam Square").tag("Siam Square")
                        Text("🐯 Tiger Shrine").tag("Tiger Shrine")
                        Text("🕉️ Wat Khaek").tag("Wat Khaek Silom")
                        Text("🏘️ Areeya Daily").tag("Areeya Daily")
                    }
                    .pickerStyle(.menu)
                    .onChange(of: locationManager.mockLocationName) { _, _ in
                        locationManager.triggerMockLocationUpdate()
                    }
                }
                .padding(.vertical, 4)
            }

            // Current Location Display
            if let loc = locationManager.userLocation {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Current Location")
                        .font(.caption)
                        .foregroundColor(.secondary)

                    HStack {
                        Image(systemName: "location.fill")
                            .foregroundColor(.green)
                            .font(.caption)
                        Text(String(format: "%.6f, %.6f", loc.coordinate.latitude, loc.coordinate.longitude))
                            .font(.system(.caption, design: .monospaced))
                            .foregroundColor(.primary)
                    }
                }
            } else {
                HStack {
                    Image(systemName: "location.slash")
                        .foregroundColor(.red)
                        .font(.caption)
                    Text("No location available")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }

            // Error Message
            if let error = locationManager.errorMessage {
                HStack(alignment: .top, spacing: 8) {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .foregroundColor(.red)
                        .font(.caption)
                    Text(error)
                        .font(.caption)
                        .foregroundColor(.red)
                }
            }

            // Info
            Text("⚠️ This panel only appears in DEBUG builds")
                .font(.caption2)
                .foregroundColor(.secondary)
                .padding(.top, 8)
        }
        .padding()
        .background(Color.orange.opacity(0.08))
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.orange.opacity(0.3), lineWidth: 1)
        )
    }
}

#Preview {
    DebugLocationView()
        .environmentObject(LocationManager())
        .environmentObject(AppLanguage())
        .padding()
}
#endif
