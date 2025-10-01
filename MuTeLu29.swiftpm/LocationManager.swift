import Foundation
import CoreLocation
import UIKit

class LocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    private let locationManager = CLLocationManager()

    @Published var userLocation: CLLocation?
    @Published var authorizationStatus: CLAuthorizationStatus = .notDetermined
    @Published var errorMessage: String?

    // MARK: - Debug Mock Location
    #if DEBUG
    @Published var useMockLocation = false
    @Published var mockLocationName = "Chulalongkorn"

    private let mockLocations: [String: CLLocation] = [
        "Chulalongkorn": CLLocation(latitude: 13.7563, longitude: 100.5018),
        "Two Kings": CLLocation(latitude: 13.73841, longitude: 100.53170),
        "Siam Square": CLLocation(latitude: 13.7465, longitude: 100.5349),
        "Tiger Shrine": CLLocation(latitude: 13.73398, longitude: 100.52720),
        "Wat Khaek Silom": CLLocation(latitude: 13.72427, longitude: 100.52291),
        "Areeya Daily": CLLocation(latitude: 13.846261, longitude: 100.612597)
    ]
    #endif

    override init() {
        super.init()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest

        // ตรวจสอบ status ปัจจุบัน
        authorizationStatus = locationManager.authorizationStatus

        // เริ่มต้นตาม status
        handleAuthorizationStatus(locationManager.authorizationStatus)
    }

    // ✅ เพิ่ม: จัดการเมื่อ authorization เปลี่ยน
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        authorizationStatus = manager.authorizationStatus
        print("🔐 Authorization changed: \(statusToString(authorizationStatus))")
        if let loc = manager.location {
            print("   Current location: lat=\(loc.coordinate.latitude), lng=\(loc.coordinate.longitude)")
        }
        handleAuthorizationStatus(manager.authorizationStatus)
    }

    // ✅ เพิ่ม: ตรวจสอบและดำเนินการตาม status
    private func handleAuthorizationStatus(_ status: CLAuthorizationStatus) {
        errorMessage = nil // reset error

        switch status {
        case .notDetermined:
            // ขอสิทธิ์ครั้งแรก
            locationManager.requestWhenInUseAuthorization()

        case .authorizedWhenInUse, .authorizedAlways:
            // ได้รับอนุญาตแล้ว -> เริ่ม update
            locationManager.startUpdatingLocation()

        case .denied:
            // User ปฏิเสธ
            errorMessage = "กรุณาเปิดใช้งานการเข้าถึงตำแหน่งในการตั้งค่า"

        case .restricted:
            // ถูกจำกัดโดยระบบ (Parental Controls)
            errorMessage = "การเข้าถึงตำแหน่งถูกจำกัดโดยระบบ"

        @unknown default:
            errorMessage = "สถานะการเข้าถึงตำแหน่งไม่ถูกต้อง"
        }
    }

    // ✅ เพิ่ม: ฟังก์ชันสำหรับเปิดการตั้งค่า
    func openSettings() {
        if let url = URL(string: UIApplication.openSettingsURLString) {
            UIApplication.shared.open(url)
        }
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        #if DEBUG
        // ✅ ถ้าเปิด mock mode → ใช้ mock location
        if useMockLocation, let mockLoc = mockLocations[mockLocationName] {
            print("🧪 Using MOCK location: \(mockLocationName)")
            print("   Coordinates: lat=\(mockLoc.coordinate.latitude), lng=\(mockLoc.coordinate.longitude)")
            userLocation = mockLoc
            errorMessage = nil
            return
        }
        #endif

        guard let location = locations.first else { return }

        let lat = location.coordinate.latitude
        let lng = location.coordinate.longitude

        print("📍 Location update received:")
        print("   Coordinates: lat=\(lat), lng=\(lng)")
        print("   Accuracy: ±\(location.horizontalAccuracy)m")
        print("   On Simulator: \(isRunningOnSimulator())")

        // ✅ ตรวจสอบว่าอยู่ในประเทศไทย
        if !isInThailand(location.coordinate) {
            if isRunningOnSimulator() {
                print("⚠️ SIMULATOR LOCATION OUTSIDE THAILAND!")
                print("   → Set custom location in Xcode:")
                print("      Debug > Simulate Location > Custom Location...")
                print("      Or use GPX files: Bangkok_Chula.gpx")
                print("      Or enable Mock Location in Profile > Debug Settings")
                errorMessage = "กรุณาตั้งค่าตำแหน่งใน Simulator เป็นกรุงเทพฯ"
            } else {
                print("⚠️ Real device location outside Thailand")
                errorMessage = "ตำแหน่งปัจจุบันอยู่นอกประเทศไทย"
            }
            // ไม่ update userLocation
            return
        }

        // ✅ Location valid → update
        print("✅ Valid Thailand location - updating userLocation")
        userLocation = location
        errorMessage = nil
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        if let clError = error as? CLError {
            switch clError.code {
            case .denied:
                errorMessage = "กรุณาอนุญาตการเข้าถึงตำแหน่งในการตั้งค่า"
            case .locationUnknown:
                errorMessage = "ไม่สามารถระบุตำแหน่งได้ กรุณาลองใหม่อีกครั้ง"
            case .network:
                errorMessage = "เครือข่ายมีปัญหา กรุณาตรวจสอบการเชื่อมต่อ"
            default:
                errorMessage = "ไม่สามารถดึงตำแหน่งได้: \(error.localizedDescription)"
            }
        } else {
            errorMessage = "เกิดข้อผิดพลาด: \(error.localizedDescription)"
        }
        print("❌ Location Error: \(error)")
    }

    // MARK: - Mock Location Control
    #if DEBUG
    /// บังคับ trigger location update เมื่อเปลี่ยน mock location
    func triggerMockLocationUpdate() {
        guard useMockLocation, let mockLoc = mockLocations[mockLocationName] else { return }
        print("🧪 Manually triggering mock location update: \(mockLocationName)")
        userLocation = mockLoc
        errorMessage = nil
    }
    #endif

    // MARK: - Helper Functions
    private func isRunningOnSimulator() -> Bool {
        #if targetEnvironment(simulator)
        return true
        #else
        return false
        #endif
    }

    private func statusToString(_ status: CLAuthorizationStatus) -> String {
        switch status {
        case .notDetermined: return "Not Determined"
        case .restricted: return "Restricted"
        case .denied: return "Denied"
        case .authorizedAlways: return "Always"
        case .authorizedWhenInUse: return "When In Use"
        @unknown default: return "Unknown"
        }
    }

    private func isInThailand(_ coord: CLLocationCoordinate2D) -> Bool {
        return coord.latitude >= 5.0 && coord.latitude <= 21.0 &&
               coord.longitude >= 97.0 && coord.longitude <= 106.0
    }
}
