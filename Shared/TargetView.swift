//
//  TargetView.swift
//  Randomize Your Life
//
//  Created by Hannes Furmans on 19.06.22.
//

import SwiftUI
import MapKit
import UIKit
import UberRides

struct MapView: UIViewRepresentable {
    
    let step: MKRoute.Step
    
    
    func makeUIView(context: Context) -> MKMapView {
        let mapView = MKMapView()
        mapView.showsUserLocation = true
        mapView.delegate = context.coordinator
        mapView.region = MKCoordinateRegion(self.step.polyline.boundingMapRect)
        mapView.addOverlay(self.step.polyline)
        mapView.isUserInteractionEnabled = false
        return mapView
    }
    
    
    func updateUIView(_ view: MKMapView, context: Context) {}
    
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
}



class Coordinator: NSObject, MKMapViewDelegate {
    var parent: MapView
    
    init(_ parent: MapView) {
        self.parent = parent
    }
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        if let routePolyline = overlay as? MKPolyline {
            let renderer = MKPolylineRenderer(polyline: routePolyline)
            renderer.strokeColor = UIColor.systemBlue
            renderer.lineWidth = 5
            return renderer
        }
        return MKOverlayRenderer()
    }
}

struct RouteStep: View {
    var step: MKRoute.Step
    var id: Int
    var target: MKMapItem?
    var lastStep: Int
    
    var body: some View {
        
        VStack {
            Text("\(step.instructions)")
                .padding([.bottom], 10)
                .font(.system(size: 20))
            Text("Distance: \(Int(step.distance))m")
            MapView(step:  self.step)
                .frame(height: 400)
            if lastStep - 1 == id {
                Text("You are at your destiniation")
                Text("You are looking for: \(target!.name!)")
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
    }
}

struct TargetView: View {
    @Binding var region: MKCoordinateRegion
    @Binding var radius: Double
    @Binding var selections: [MKPointOfInterestCategory]
    @Binding var transportType: TransportType
    @State var ETA: String = "not calculated"
    @State var target: MKMapItem? = nil
    @State var route: MKRoute? = nil
    @State var errorAlertActive = false
    @State var errorAlertError: Error? = nil
    
    var body: some View {
        alert("Error occurd", isPresented: $errorAlertActive) {
            Text("Error occurd during lookup: \(errorAlertError!.localizedDescription)")
        }
        
        ScrollView {
            Text("ETA: \(self.ETA)")
            
            HStack {
                if transportType == .Automobile {
                    if let t = target {
                        Button("Ride with Uber") {
                            let builder = RideParametersBuilder()
                            builder.dropoffLocation = t.placemark.location!
                            builder.dropoffNickname = t.name
                            let rideParameters = builder.build()
                            let deeplink = RequestDeeplink(rideParameters: rideParameters, fallbackType: .mobileWeb)
                            deeplink.execute()
                        }
                    }
                }
            }
            
            Button("Open in Maps") {
                if let t = target {
                    var launchOptions: [String : Any] = [:]
                    switch transportType {
                    case .Automobile:
                        launchOptions[MKLaunchOptionsDirectionsModeKey] = MKLaunchOptionsDirectionsModeDriving
                    case .Walking:
                        launchOptions[MKLaunchOptionsDirectionsModeKey] = MKLaunchOptionsDirectionsModeWalking
                    case .Transit:
                        launchOptions[MKLaunchOptionsDirectionsModeKey] = MKLaunchOptionsDirectionsModeTransit
                    }
                    t.openInMaps(launchOptions: launchOptions)
                }
            }
            
            List {
                if let r = route {
                    let count = r.steps.count
                    ForEach(r.steps.enumerated()
                        .filter({ e in
                            let m = e.element
                                .instructions
                                .isEmpty
                            return !m
                        })
                            .map({ e in
                                RouteStep(step: e.element, id: e.offset, target: self.target, lastStep: count)
                            }), id: \.id) { step in
                                
                                step
                            }
                }
            }
        }.task {
            do {
                target = try await fetchRandomTarget(radius: self.radius, categories: self.selections, region: self.region)
                if let t = target {
                    async let etaResult = try await getETA(item: t, transportType: self.transportType.toTransportType())
                    
                    async let routeResult = try await getRoute(item: t, transportType: self.transportType.toTransportType())
                    let eta = try await etaResult
                    ETA = "\(eta)s"
                    route = try await routeResult
                } else {
                    
                    print("No target found")
                }
            } catch {
                self.errorAlertError = error
                self.errorAlertActive = true
                print("Failed with \(error)")
            }
        }
        .navigationTitle("Directions")
    }
}


