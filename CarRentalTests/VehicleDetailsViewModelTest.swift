//
//  VehicleDetailsViewModelTest.swift
//  Car Rental
//
//  Created by Clineu Iansen Junior on 21/09/19.
//  Copyright © 2019 Clineu Iansen Junior. All rights reserved.
//

import XCTest
@testable import Car_Rental

class VehicleDetailsViewModelTest: XCTestCase {
    
    func testVehicleDetailsPresentation() {
        let exp = expectation(description: "Vehicle details presentation test")
        
        let viewModel = VehicleDetailsViewModel(vehicle: VehicleFactory.vehicleList().first!)
        viewModel.delegate = VehicleDetailsDelegateTest(exp: exp)
        viewModel.requestVehicleDetails()
        
        wait(for: [exp], timeout: 1.0)
    }
}


class VehicleDetailsDelegateTest: VehicleDetailsViewModelDelegate {
    
    let exp: XCTestExpectation
    init(exp: XCTestExpectation) {
        self.exp = exp
    }
    
    func presentVehicleDetails(model: VehicleDetailsPresenter) {
        guard let vehicle = VehicleFactory.vehicleList().first else { return }
        
        let expPercentage = "\(Int(vehicle.fuelLevel*100))%"
        XCTAssertEqual(expPercentage, model.fuelPercentage)
        XCTAssertEqual(model.fuelTypeIcon, UIImage.gasStationIcon)
        XCTAssertEqual(model.innerCleanliness, "vehicle_details.model.clean.regular".localizable)
        XCTAssertEqual(model.transmission, "vehicle_details.model.transmission.manual".localizable)
        
        exp.fulfill()
    }
}
