//
//  CategorySelector.swift
//  Randomize Your Life
//
//  Created by Hannes Furmans on 19.06.22.
//

import SwiftUI
import MapKit

struct SelectorPreview: Hashable {
    var name: String
    var category: MKPointOfInterestCategory
    
    static let all: [Self] = [
        .airport,
        .amusementPark,
        .aquarium,
        .atm,
        .bakery,
        .bank,
        .beach,
        .brewery,
        .cafe,
        .campground,
        .carRental,
        .evCharger,
        .fireStation,
        .fitnessCenter,
        .foodMarket,
        .gasStation,
        .hospital,
        .hotel,
        .laundry,
        .library,
        .marina,
        .movieTheatre
    ]
    
    init(name: String, category: MKPointOfInterestCategory) {
        self.name = name
        self.category = category
    }
    
    static let airport = Self.init(name: "Airport", category: MKPointOfInterestCategory.airport)
    static let amusementPark = Self.init(name: "Amusement Park", category: MKPointOfInterestCategory.amusementPark)
    static let aquarium = Self.init(name: "Aquarium", category: MKPointOfInterestCategory.aquarium)
    static let atm = Self.init(name: "ATM", category: MKPointOfInterestCategory.atm)
    static let bakery = Self.init(name: "Bakery", category: MKPointOfInterestCategory.bakery)
    static let bank = Self.init(name: "Bank", category: MKPointOfInterestCategory.bank)
    static let beach = Self.init(name: "Beach", category: MKPointOfInterestCategory.beach)
    static let brewery = Self.init(name: "Brewery", category: MKPointOfInterestCategory.brewery)
    static let cafe = Self.init(name: "Cafe", category: MKPointOfInterestCategory.cafe)
    static let campground = Self.init(name: "Campground", category: MKPointOfInterestCategory.campground)
    static let carRental = Self.init(name: "Car Rental", category: MKPointOfInterestCategory.carRental)
    static let evCharger = Self.init(name: "Ev Charger", category: MKPointOfInterestCategory.evCharger)
    static let fireStation = Self.init(name: "Fire Station", category: MKPointOfInterestCategory.fireStation)
    static let fitnessCenter = Self.init(name: "Fitness Center", category: MKPointOfInterestCategory.fitnessCenter)
    static let foodMarket = Self.init(name: "Food Market", category: MKPointOfInterestCategory.foodMarket)
    static let gasStation = Self.init(name: "Gas Station", category: MKPointOfInterestCategory.gasStation)
    static let hospital = Self.init(name: "Hospital", category: MKPointOfInterestCategory.hospital)
    static let hotel = Self.init(name: "Hotel", category: MKPointOfInterestCategory.hotel)
    static let laundry = Self.init(name: "Laundry", category: MKPointOfInterestCategory.laundry)
    static let library = Self.init(name: "Library", category: MKPointOfInterestCategory.library)
    static let marina = Self.init(name: "Marina", category: MKPointOfInterestCategory.marina)
    static let movieTheatre = Self.init(name: "Movie Theatre", category: MKPointOfInterestCategory.movieTheater)
    // more are missing
}

struct MultipleSelectionRow: View {
    var title: String
    var isSelected: Bool
    var action: () -> Void

    var body: some View {
        Button(action: self.action) {
            HStack {
                Text(self.title)
                Spacer()
                if self.isSelected {
                    Image(systemName: "checkmark")
                }
            }
        }
    }
}


struct CategorySelector: View {
    @State private var items: [SelectorPreview] = SelectorPreview.all
    
    @Binding var selections: [MKPointOfInterestCategory]
    
    var body: some View {
        List {
            ForEach(self.items, id: \.self) { item in
                MultipleSelectionRow(title: item.name, isSelected: self.selections.contains(item.category)) {
                    if self.selections.contains(item.category) {
                        self.selections.removeAll(where: { $0 == item.category })
                    } else {
                        self.selections.append(item.category)
                    }
                }
            }
        }.navigationTitle("Select Category")

    }
}

struct CategorySelector_Previews: PreviewProvider {
    @State var selections: [MKPointOfInterestCategory] = []
    
    static var previews: some View {
        Group {
            CategorySelector(selections: .constant([]))
        }
    }
}
