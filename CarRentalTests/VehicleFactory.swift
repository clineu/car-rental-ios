//
//  VehicleFactory.swift
//  Car Rental
//
//  Created by Clineu Iansen Junior on 21/09/19.
//  Copyright © 2019 Clineu Iansen Junior. All rights reserved.
//

import Foundation
@testable import Car_Rental

class VehicleFactory {
    private static let modelsId = ["Model-1", "Model-2", "Model-3"]
    private static let modelIdentifiers = ["Model id 1", "Model id 2", "Model id 3"]
    private static let modelNames = ["Model name 1", "Model name 2", "Model name 3"]
    private static let names = ["Name 1", "Name 2", "Name 3"]
    private static let makes = ["Make 1", "Make 2", "Make 3"]
    private static let groups = ["Group 1", "Group 2", "Group 3"]
    private static let colors = ["Color 1", "Color 2", "Color 3"]
    private static let series = ["Serie 1", "Serie 2", "Serie 3"]
    private static let fuelType = [FuelType.petrol, FuelType.diesel, FuelType.eletric]
    private static let transmissions = [Transmission.manual, Transmission.manual, Transmission.automatic]
    private static let fuelLevels = [0.5, 0.1, 0.95]
    private static let licensePlates = ["Plate-1", "Plate-2", "Plate-3"]
    private static let latitudes = [1.0, 2.0, 3.0]
    private static let longitudes = [1.0, 2.0, 3.0]
    private static let cleanliness = [Cleanliness.regular, Cleanliness.veryClean, Cleanliness.clean]
    private static let carImageUrls = ["https://img.com/a.jpg", "https://img.com/b.jpg", "https://img.com/c.jpg"]
    
    static func vehicleList() -> [Vehicle] {
        var vehicles: [Vehicle] = []
        for i in 0..<modelsId.count {
            let vehicle = Vehicle(id: modelsId[i],
                                  modelIdentifier: modelIdentifiers[i],
                                  modelName: modelNames[i],
                                  name: names[i],
                                  make: makes[i],
                                  group: groups[i],
                                  color: colors[i],
                                  series: series[i],
                                  fuelType: fuelType[i],
                                  fuelLevel: fuelLevels[i],
                                  transmission: transmissions[i],
                                  licensePlate: licensePlates[i],
                                  latitude: latitudes[i],
                                  longitude: longitudes[i],
                                  innerCleanliness: cleanliness[i],
                                  carImageUrl: carImageUrls[i])
            vehicles.append(vehicle)
        }
        return vehicles
    }
}
