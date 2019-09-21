//
//  VehicleListCellViewModel.swift
//  Car Rental
//
//  Created by Clineu Iansen Junior on 21/09/19.
//  Copyright © 2019 Clineu Iansen Junior. All rights reserved.
//

import UIKit

class VehicleListCellViewModel {
    let vehicle: Vehicle
    
    init(vehicle: Vehicle) {
        self.vehicle = vehicle
    }
    
    func createListCellModel() -> VehicleListModel {
        return VehicleListModel(title: vehicle.name,
                                licensePlace: vehicle.licensePlate,
                                model: vehicle.modelName,
                                imageURL: URL(string: vehicle.carImageUrl),
                                placeholder: .carPlaceholderImage)
    }
}

struct VehicleListModel {
    let title: String
    let licensePlace: String
    let model: String
    let imageURL: URL?
    let placeholder: UIImage
}
