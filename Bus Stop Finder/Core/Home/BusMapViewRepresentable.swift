//
//  BusMapViewRepresentable.swift
//  Bus Stop Finder
//
//  Created by jeff wong on 2022-12-29.
//

import MapKit
import SwiftUI

struct BusMapViewRepresentable: UIViewRepresentable{
    let mapView = MKMapView()
    let locationManager = LocationManager()
    @Binding var results: [BusStopModel]
    @Binding var isAnnotationSelected:Bool
    @Binding var selectedAnnotation: MKPointAnnotation
    
    func makeUIView(context: Context) -> some UIView {
        mapView.delegate = context.coordinator
        mapView.isRotateEnabled = false
        mapView.showsUserLocation = true
        mapView.userTrackingMode = .follow
        let compassBtn = MKCompassButton(mapView: mapView)
        compassBtn.frame.origin = CGPoint(x: 340, y: 55)
        compassBtn.compassVisibility = .visible
        mapView.addSubview(compassBtn)
        return mapView
    }
    
    func updateUIView(_ uiView: UIViewType, context: Context) {
    }
    
    func makeCoordinator() -> MapCoordinator {
        return MapCoordinator(parent: self)
    }
}

extension BusMapViewRepresentable{
    class MapCoordinator: NSObject, MKMapViewDelegate{
        let parent:BusMapViewRepresentable
        
        init(parent: BusMapViewRepresentable) {
            self.parent = parent
            super.init()
        }
        
        func mapView(_ mapView: MKMapView, didUpdate userLocation: MKUserLocation) {
            let region = MKCoordinateRegion(
                center: CLLocationCoordinate2D(
                    latitude: userLocation.coordinate.latitude,
                    longitude: userLocation.coordinate.longitude),
                span: MKCoordinateSpan(
                    latitudeDelta: 0.005,
                    longitudeDelta: 0.005)
            )
            createBusStopList(userLocation: userLocation)
            parent.mapView.setRegion(region, animated: true)
        }
        
        // MARK: Helpers
        
        /// Whenever an MKPointAnnotation is selected, the function first deselects the previously selected annotation by making self.parent.isAnnotationSelected
        /// false. Then it converts the parent's selected Annoation to the correct one while switching the parent's isAnnotationSelected to true.
        ///
        /// - Parameters:
        ///     - _mapView: our current parent MKMapVIew
        ///     - didSelect: the Selected MKPointAnnotation
        func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
            withAnimation{
                self.parent.isAnnotationSelected = false
            }
            self.parent.selectedAnnotation = (view.annotation as? MKPointAnnotation)!
            withAnimation{
                self.parent.isAnnotationSelected = true
            }
        }
        
        /// Using Translink's own Real-time Transit Information, this functions uses the user's current location to produce a list of every bus stop within
        /// 1000 meters. Once the http get call is successful, the response object is decoded into a list of BusStopModels. The list is then set as the
        /// parent's result parameter and the addStopAnnotation function is called
        /// (https://www.translink.ca/about-us/doing-business-with-translink/app-developer-resources/rtti)
        ///
        /// - Parameters:
        ///     - userLocation: The current location of the user (MKUserLocation)
        func createBusStopList(userLocation: MKUserLocation){
            let API_Key: String = "pFrncMHWZCb8dy0xp0Ih"
            let userLatitdude = String(format:"%.5f", userLocation.coordinate.latitude)
            let userLongitude = String(format:"%.5f", userLocation.coordinate.longitude)
            let url = URL(string: "http://api.translink.ca/RTTIAPI/V1/stops?apiKey="
                          + API_Key +
                          "&lat=" + userLatitdude +
                          "&long=" + userLongitude + "&radius=1000")!
            var request = URLRequest(url: url)
            request.setValue("application/JSON", forHTTPHeaderField: "accept")
            request.httpMethod = "GET"
            let task = URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
                guard let data = data, error == nil else {
                    print(error ?? "Unknown error")
                    return
                }
                do {
                    let responseObject = try JSONDecoder().decode([BusStopModel].self, from: data)
                    DispatchQueue.main.async {
                        self?.parent.results = responseObject
                        self?.addStopAnnotation()
                    }
                } catch let parseError {
                    print(parseError)
                }
            }
            task.resume()
        }
        
        /// Filters out any BusStopModel in parent's result parameter that doesn't have any routes (inactive). Then the function creates a MKPointAnnotion
        /// for any of the remaining BusStopModels. The stop's route numbers are used as the title and the bus stop numbers are used as the subtitle.
        func addStopAnnotation(){
            self.parent.results = self.parent.results.filter{$0.Routes != ""}
            for stop in self.parent.results{
                let anno = MKPointAnnotation()
                anno.coordinate = CLLocationCoordinate2D(latitude: stop.Latitude, longitude: stop.Longitude)
                self.parent.mapView.addAnnotation(anno)
                anno.title = String(stop.Routes)
                anno.subtitle = String(stop.StopNo)
            }
        }
        
    }
}
