import MapKit

final class RouteDistanceService {
    static let shared = RouteDistanceService()
    private init() {}
    
    enum Mode { case driving, walking }
    
    struct Result {
        let place: SacredPlace
        let meters: Double
        let seconds: Double
    }
    
    func batchDistances(
        from origin: CLLocationCoordinate2D,
        places: [SacredPlace],
        mode: Mode
    ) async -> [Result] {
        await withTaskGroup(of: Result.self, returning: [Result].self) { group in
            for p in places {
                // ⬇️ ใช้ตรง ๆ เพราะ lat/lon เป็น Double ไม่ใช่ Optional
                let lat = p.latitude
                let lon = p.longitude
                let dest = CLLocationCoordinate2D(latitude: lat, longitude: lon)
                
                group.addTask {
                    let req = MKDirections.Request()
                    req.source = MKMapItem(placemark: MKPlacemark(coordinate: origin))
                    req.destination = MKMapItem(placemark: MKPlacemark(coordinate: dest))
                    req.transportType = (mode == .walking) ? .walking : .automobile
                    
                    do {
                        // API ที่ถูกต้องสำหรับ async/await
                        let response = try await MKDirections(request: req).calculate()
                        let routes = response.routes
                        let best = routes.min(by: { $0.distance < $1.distance })
                        
                        let meters: Double  = best?.distance ?? .infinity
                        let seconds: Double = best?.expectedTravelTime ?? .infinity
                        
                        return Result(place: p, meters: meters, seconds: seconds)
                    } catch {
                        return Result(place: p, meters: .infinity, seconds: .infinity)
                    }
                }
            }
            
            // รวมผลลัพธ์จาก task group
            var results: [Result] = []
            for await r in group { results.append(r) }
            return results
        }
    }
}
