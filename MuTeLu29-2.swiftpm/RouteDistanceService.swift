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
        if let d = await routeDistance(origin: origin, destination: destination, transport: preferred.mapKitType) {
            return d
        }
        if preferred != .walking,
           let d = await routeDistance(origin: origin, destination: destination, transport: .walking) {
            return d
        }
        let straight = CLLocation(latitude: origin.latitude, longitude: origin.longitude)
            .distance(from: CLLocation(latitude: destination.latitude, longitude: destination.longitude))
        return straight.isFinite ? straight : nil
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
                    cont.resume(returning: route.distance)
                } else {
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
