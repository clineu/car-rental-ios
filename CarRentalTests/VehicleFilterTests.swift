//
//  VehicleFilterTests.swift
//  Car RentalTests
//
//  Created by Clineu Iansen Junior on 21/09/19.
//  Copyright © 2019 Clineu Iansen Junior. All rights reserved.
//

import XCTest
@testable import Car_Rental

class VehicleFilterTests: XCTestCase {

    var viewModel: VehicleFilterViewModel!
    
    override func setUp() {
        viewModel = VehicleFilterViewModel(filter: VehicleFilter())
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testSelectTransmission() {
        let isSelected = viewModel.didSelectTransmission(transmission: .automatic)
        XCTAssertTrue(isSelected, "Automatic transmission should be selected")
        
        let contains = viewModel.vehicleFilter.transmission.contains(.automatic)
        XCTAssertTrue(contains, "Transmission array should contains automatic transmission")
        
        let notSelected = viewModel.didSelectTransmission(transmission: .automatic)
        XCTAssertFalse(notSelected, "Automatic transmission should not be selected")
        
        let notContains = viewModel.vehicleFilter.transmission.contains(.automatic)
        XCTAssertFalse(notContains, "Transmission array should not contains automatic transmission")
    }
    
    func testSelectFuelType() {
        let isSelected = viewModel.didSelectFuelType(fuelType: .eletric)
        XCTAssertTrue(isSelected, "Eletric should be selected")
        
        let contains = viewModel.vehicleFilter.fuelType.contains(.eletric)
        XCTAssertTrue(contains, "Fuel type array should contains eletric type")
        
        let notSelected = viewModel.didSelectFuelType(fuelType: .eletric)
        XCTAssertFalse(notSelected, "Eletric should not be selected")
        
        let notContains = viewModel.vehicleFilter.fuelType.contains(.eletric)
        XCTAssertFalse(notContains, "Fuel type array should not contains eletric type")
    }
    
    func testSelectCleanliness() {
        let isSelected = viewModel.didSelectCleanliness(cleanliness: .clean)
        XCTAssertTrue(isSelected, "Clean should be selected")
        
        let contains = viewModel.vehicleFilter.cleanliness.contains(.clean)
        XCTAssertTrue(contains, "Cleanliness array should contains clean type")
        
        let notSelected = viewModel.didSelectCleanliness(cleanliness: .clean)
        XCTAssertFalse(notSelected, "Clean should not be selected")
        
        let notContains = viewModel.vehicleFilter.cleanliness.contains(.clean)
        XCTAssertFalse(notContains, "Cleanliness array should not contains clean type")
    }
    
    func testResetFilter() {
        _ = viewModel.didSelectCleanliness(cleanliness: .clean)
        _ = viewModel.didSelectFuelType(fuelType: .diesel)
        _ = viewModel.didSelectFuelType(fuelType: .eletric)
        _ = viewModel.didSelectTransmission(transmission: .automatic)
        viewModel.vehicleFilter.fuelLevel = 1.0
        
        viewModel.resetFilter()
        
        let filter = viewModel.vehicleFilter
        XCTAssertEqual(filter.cleanliness.count, 0, "Cleanliness array should be empty")
        XCTAssertEqual(filter.fuelType.count, 0, "Fuel type array should be empty")
        XCTAssertEqual(filter.transmission.count, 0, "Transmission array should be empty")
        XCTAssertNil(filter.fuelLevel, "Fuel level value should be nil")
    }
}
