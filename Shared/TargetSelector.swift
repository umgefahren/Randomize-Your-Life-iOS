//
//  TargetSelector.swift
//  Randomize Your Life
//
//  Created by Hannes Furmans on 19.06.22.
//

import Foundation
import MapKit
import CoreLocation

private func fetchItems(radius: Double, categories: [MKPointOfInterestCategory], region: MKCoordinateRegion) async throws -> [MKMapItem] {
    let filter = MKPointOfInterestFilter.init(including: categories)
    let request = MKLocalPointsOfInterestRequest.init(center:  region.center, radius: radius * 1000)
    request.pointOfInterestFilter = filter
    
    let search = MKLocalSearch.init(request: request)
    let result = try await search.start()
    return result.mapItems
}

func fetchRandomTarget(radius: Double, categories: [MKPointOfInterestCategory], region: MKCoordinateRegion) async throws -> MKMapItem? {
    let choices = try await fetchItems(radius: radius, categories: categories, region: region)
    return choices.randomElement()
}

private func formulateRequest(item: MKMapItem, transportType: MKDirectionsTransportType) -> MKDirections.Request {
    let request = MKDirections.Request()
    let source = MKMapItem.forCurrentLocation()
    request.destination = item
    request.source = source
    request.transportType = transportType
    
    if transportType == .transit {
        request.departureDate = Date.now
    }
    
    return request
}

func getETA(item: MKMapItem, transportType: MKDirectionsTransportType) async throws -> TimeInterval {
    let request = formulateRequest(item: item, transportType: transportType)
    let search = MKDirections.init(request: request)
    let eta = try await search.calculateETA()
    return eta.expectedTravelTime
}

func getRoute(item: MKMapItem, transportType: MKDirectionsTransportType) async throws -> MKRoute {
    let request = formulateRequest(item: item, transportType: transportType)
    let search = MKDirections.init(request: request)
    let directions = try await search.calculate()
    let route = directions.routes[0]
    
    return route
}
