import SwiftUI
import MapKit
import UIKit
import Combine // Add this import

// Add this class to hold the slider value
class SliderValue: ObservableObject {
    @Published var value: Double = 50.0
}

class MapViewController: UIViewController, CLLocationManagerDelegate {

  let mapView = MKMapView()
  let locationManager = CLLocationManager()

  override func viewDidLoad() {
    super.viewDidLoad()

    locationManager.delegate = self
    locationManager.requestWhenInUseAuthorization()
    locationManager.startUpdatingLocation()

    mapView.showsUserLocation = true
    view.addSubview(mapView)
  }

  override func viewDidLayoutSubviews() {
    super.viewDidLayoutSubviews()

    mapView.frame = view.bounds
  }

}

struct MapView: View {
    @ObservedObject private var mapModel = MapViewModel()
    let mapVC = MapViewController()
    @ObservedObject private var sliderValue = SliderValue() // Add this line to create an instance of SliderValue

    var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: 0) {
                Image("logo")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 90, height: 40, alignment: .center)
            }
            .frame(width: 214, height: 81)
            
            ZStack {
                let location = LocationManager()
                Map(coordinateRegion: $mapModel.region, showsUserLocation: true)
                    .accentColor(Color(.systemPurple))
                    .onAppear {
                        //mapModel.checkLocationServicesEnabled()
                        mapModel.updateRegionLocation()

                        location.setupLocationManager()
                    }
                
                VStack {
                    HStack {
                        Spacer()
                        VStack {
                            Slider(value: $sliderValue.value, in: 0...100, onEditingChanged: { editing in
                                if editing {
                                    // Slider is being edited
                                    print("Slider is being edited")
                                } else {
                                    regionRadiusglob = sliderValue.value
                                    print("Slider editing ended")
                                }
                            })
                                .frame(width: 100)
                                .padding(.trailing, 20)
                            Text("\(sliderValue.value, specifier: "%.2f")m")
                                .foregroundColor(.black)
                        }
                    }
                    Spacer()
                }
                .padding(.top, 20) // Adjust the padding to position the slider
            }
        }
        .padding(.top, 19)
        .padding(.bottom, 60)
        .frame(width: 375, height: 812)
        .background(Color.white)
    }

}

struct Map_Previews: PreviewProvider {
    static var previews: some View {
        MapView()
    }
}
