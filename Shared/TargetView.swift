//
//  TargetView.swift
//  Randomize Your Life
//
//  Created by Hannes Furmans on 19.06.22.
//

import SwiftUI
import MapKit

struct RouteStep: View {
    var step: MKRoute.Step
    var id: Int
    
    var body: some View {
        VStack {
            Text("\(step.instructions)")
                .padding([.bottom], 10)
                .font(.system(size: 20))
            Text("Distance: \(Int(step.distance))m")
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
    
    var body: some View {
        VStack {
            Text("ETA: \(self.ETA)")
            List {
                if let r = route {
                    ForEach(r.steps.enumerated()
                        .filter({ e in
                            let m = e.element
                                .instructions
                                .isEmpty
                            return !m
                        })
                        .map({ e in
                        RouteStep(step: e.element, id: e.offset)
                    }), id: \.id) { step in
                        step
                    }
                }
            }
        }.task {
            do {
                target = try await fetchRandomTarget(radius: self.radius, categories: self.selections, region: self.region)
                if let t = target {
                    let eta = try await getETA(item: t, transportType: self.transportType.toTransportType())
                    ETA = "\(eta)s"
                    route = try await getRoute(item: t, transportType: self.transportType.toTransportType())
                } else {
                    print("No target found")
                }
            } catch {
                print("Failed with \(error)")
            }
        }
        .navigationTitle("Directions")
    }
}


