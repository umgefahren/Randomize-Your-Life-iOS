//
//  SettingsView.swift
//  Randomize Your Life
//
//  Created by Hannes Furmans on 19.06.22.
//

import SwiftUI
import MapKit
import CoreLocation

enum TransportType: CaseIterable, Identifiable {
    case Automobile
    case Walking
    case Transit
    
    var id: Self { self }
    
    
    func toTransportType() -> MKDirectionsTransportType {
        switch self {
        case .Automobile:
            return MKDirectionsTransportType.automobile
        case .Walking:
            return MKDirectionsTransportType.walking
        case .Transit:
            return MKDirectionsTransportType.transit
        }
    }
    
    func toView() -> some View {
        switch self {
        case .Automobile:
            return HStack {
                Image(systemName: "car")
            }
        case .Transit:
            return HStack {
                Image(systemName: "tram")
            }
        case .Walking:
            return HStack {
                Image(systemName: "figure.walk")
            }
        }
    }
}

struct SettingsView: View {
    @State private var region = MKCoordinateRegion()
    @State var location = CLLocationCoordinate2D()
    @State var radius = 2.0
    @State var selections: [MKPointOfInterestCategory] = SelectorPreview.all.map({ e in
        e.category
    })
    @State var transportType: TransportType = .Transit
    
    var body: some View {
        let handler = CLLocationManager.init()
        let _ = handler.requestWhenInUseAuthorization()
        NavigationView {
            ScrollView {
                VStack {
                    Map(coordinateRegion: $region, interactionModes: .zoom, showsUserLocation: true, userTrackingMode: .constant(MapUserTrackingMode.follow))
                        .frame(height: 400, alignment: .topLeading)
                    
                    VStack {
                        Text("Radius: \(Int(radius))km")
                        Slider(value: $radius, in: 0...10)
                            .padding()
                        
                        Picker("Transport", selection: $transportType) {
                            ForEach(TransportType.allCases) { t in
                                t.toView()
                            }
                        }.pickerStyle(.segmented)
                            .padding()
                        
                        NavigationLink(destination: CategorySelector(selections: $selections)) {
                            HStack {
                                Text("Categories")
                                Spacer()
                                Text("\(selections.count) selected")
                            }
                            .padding([.leading, .trailing], 20)
                            
                        }
                    }
                    NavigationLink(destination: TargetView(region: self.$region, radius: self.$radius, selections: self.$selections, transportType: $transportType)) {
                        Text("Go")
                        Image(systemName: "dice")
                    }
                    .frame(width: 200, alignment: .center)
                    .padding()
                    .foregroundColor(Color.black)
                    .background(Color.blue)
                    .cornerRadius(8)
                    Spacer()
                }
            }.navigationTitle("Random Location")
        }
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        
        SettingsView()
        
    }
}
