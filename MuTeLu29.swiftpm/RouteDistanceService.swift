import Foundation
import MapKit
import CoreLocation

struct RouteDistanceResult {
    let place: SacredPlace
    let meters: CLLocationDistance?   // nil = ไม่มีข้อมูล
}

enum TransportMode {
    case driving
    case walking
}

actor RouteDistanceService {
    static let shared = RouteDistanceService()
    
    func batchDistances(
        from origin: CLLocationCoordinate2D,
        places: [SacredPlace],
        mode: TransportMode = .driving
    ) async -> [RouteDistanceResult] {
        var results: [RouteDistanceResult] = []
        for place in places {
            let d = await distance(
                from: origin,
                to: CLLocationCoordinate2D(latitude: place.latitude, longitude: place.longitude),
                preferred: mode
            )
            results.append(RouteDistanceResult(place: place, meters: d))
            try? await Task.sleep(nanoseconds: 150_000_000) // ลด rate-limit
        }
        return results
    }
    
    private func distance(
        from origin: CLLocationCoordinate2D,
        to destination: CLLocationCoordinate2D,
        preferred: TransportMode
    ) async -> CLLocationDistance? {
        // ✅ Validate coordinates
        guard isValidBangkokCoordinate(origin) && isValidBangkokCoordinate(destination) else {
            print("⚠️ Invalid coordinates - origin: (\(origin.latitude), \(origin.longitude)), dest: (\(destination.latitude), \(destination.longitude))")
            return nil
        }

        // Try preferred mode route
        if let d = await routeDistance(origin: origin, destination: destination, transport: preferred.mapKitType) {
            return d
        }

        // Try walking mode as fallback
        if preferred != .walking,
           let d = await routeDistance(origin: origin, destination: destination, transport: .walking) {
            return d
        }

        // Fallback to straight-line distance with validation
        let straight = CLLocation(latitude: origin.latitude, longitude: origin.longitude)
            .distance(from: CLLocation(latitude: destination.latitude, longitude: destination.longitude))

        // ✅ Sanity check: Bangkok max ~50km diameter
        guard straight.isFinite && straight >= 0 && straight < 50_000 else {
            print("⚠️ Unrealistic straight-line distance: \(straight) meters")
            return nil
        }

        print("ℹ️ Using straight-line fallback for distance calculation: \(straight) meters")
        return straight
    }
    
    private func routeDistance(
        origin: CLLocationCoordinate2D,
        destination: CLLocationCoordinate2D,
        transport: MKDirectionsTransportType
    ) async -> CLLocationDistance? {
        guard origin.latitude.isFinite, origin.longitude.isFinite,
              destination.latitude.isFinite, destination.longitude.isFinite,
              !(origin.latitude == destination.latitude && origin.longitude == destination.longitude) else {
            return nil
        }
        
        let source = MKMapItem(placemark: MKPlacemark(coordinate: origin))
        let dest   = MKMapItem(placemark: MKPlacemark(coordinate: destination))
        
        let request = MKDirections.Request()
        request.source = source
        request.destination = dest
        request.transportType = transport
        
        let directions = MKDirections(request: request)
        
        return await withCheckedContinuation { cont in
            directions.calculate { response, error in
                if let route = response?.routes.first {
                    let dist = route.distance

                    // ✅ Log route success
                    print("✅ Route found: \(dist) meters")

                    // ✅ Validate route distance
                    if !dist.isFinite || dist < 0 || dist > 1_000_000 {
                        print("⚠️ Abnormal route distance: \(dist) meters")
                        cont.resume(returning: nil)
                    } else {
                        cont.resume(returning: dist)
                    }
                } else {
                    if let error = error {
                        print("❌ Route calculation failed: \(error.localizedDescription)")
                    }
                    cont.resume(returning: nil)
                }
            }
        }
    }
}

private extension TransportMode {
    var mapKitType: MKDirectionsTransportType {
        switch self {
        case .driving: return .automobile
        case .walking: return .walking
        }
    }
}

private extension RouteDistanceService {
    func isValidBangkokCoordinate(_ coord: CLLocationCoordinate2D) -> Bool {
        // Bangkok bounds: lat 13.5-14.0°N, lng 100.3-100.9°E
        return coord.latitude.isFinite && coord.longitude.isFinite &&
               coord.latitude >= 13.5 && coord.latitude <= 14.0 &&
               coord.longitude >= 100.3 && coord.longitude <= 100.9
    }
}
