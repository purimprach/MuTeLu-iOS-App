import SwiftUI
import MapKit

struct MapSnapshotView: View {
    let latitude: Double
    let longitude: Double
    let placeName: String
    
    var body: some View {
        let coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        let region = MKCoordinateRegion(
            center: coordinate,
            span: MKCoordinateSpan(latitudeDelta: 0.005, longitudeDelta: 0.005)
        )
        
        Map(position: .constant(.region(region))) {
            Marker(placeName, coordinate: coordinate)
        }
    }
}
