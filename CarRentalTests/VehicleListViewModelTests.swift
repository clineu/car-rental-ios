//
//  VehicleListViewModelTests.swift
//  Car Rental
//
//  Created by Clineu Iansen Junior on 21/09/19.
//  Copyright © 2019 Clineu Iansen Junior. All rights reserved.
//

import XCTest
@testable import Car_Rental

class VehicleListViewModelTests: XCTestCase {
    
    var service: MockVehicleService!
    var viewModel: VehiclesListViewModel!
    
    override func setUp() {
        service = MockVehicleService()
        viewModel = VehiclesListViewModel(service: service)
    }
    
    func testVehicleListRequest() {
        let exp = expectation(description: "Success return vehicle list from service")
        
        viewModel.delegate = VehicleListViewModelDelegateTest(loadVehiclesExp: exp)
        viewModel.requestVehicleList()
        
        wait(for: [exp], timeout: 1)
    }
    
    func testVehicleListLoading() {
        let exp = expectation(description: "Test isLoading delegate callback")
        
        viewModel.delegate = VehicleListViewModelDelegateTest(isLoadingExp: exp)
        viewModel.requestVehicleList()
        
        wait(for: [exp], timeout: 1)
    }
    
    func testVehicleListPresentDetails() {
        let vehicleListExp = expectation(description: "Vehicle list loading")
        let presentDetailsExp = expectation(description: "Present vehicle delegate callback")
        let scrollToExp = expectation(description: "Scroll to indexPath delegate callback")
        
        viewModel.delegate = VehicleListViewModelDelegateTest(loadVehiclesExp: vehicleListExp,
                                                              presentDetailsExp: presentDetailsExp,
                                                              scrollToExp: scrollToExp)
        viewModel.requestVehicleList()
        
        wait(for: [vehicleListExp], timeout: 1)
        
        guard let vehicle = viewModel.vehicles.first else {
            XCTFail("Vehicle list should not be empty")
            return
        }
        
        viewModel.requestDetailsFor(vehicle: vehicle)
        wait(for: [presentDetailsExp, scrollToExp], timeout: 1)
    }
}

class VehicleListViewModelDelegateTest: VehicleListViewModelDelegate {
    
    let loadVehiclesExp: XCTestExpectation?
    let isLoadingExp: XCTestExpectation?
    let presentDetailsExp: XCTestExpectation?
    let scrollToExp: XCTestExpectation?
    
    init(loadVehiclesExp: XCTestExpectation? = nil,
         isLoadingExp: XCTestExpectation? = nil,
         presentDetailsExp: XCTestExpectation? = nil,
         scrollToExp: XCTestExpectation? = nil)
    {
        self.loadVehiclesExp = loadVehiclesExp
        self.isLoadingExp = isLoadingExp
        self.presentDetailsExp = presentDetailsExp
        self.scrollToExp = scrollToExp
    }
    
    func didLoadVehiclesList(result: Result<[Vehicle], ServiceError>) {
        switch result {
        case .success(let vehicles):
            XCTAssertEqual(vehicles.count, 3, "List count should be 3")
        default:
            XCTFail("Result should be success")
        }
        loadVehiclesExp?.fulfill()
    }
    
    var firtPass = true
    func isLoading(loading: Bool) {
        if firtPass && loading { // Loading value should be true in first pass
            firtPass = false
        } else if !firtPass && !loading { // Loading value should be false in second pass
            isLoadingExp?.fulfill()
        } else {
            XCTFail("Loading delegate is not working propertly")
        }
    }
    
    func scrollTo(indexPath: IndexPath) {
        XCTAssertEqual(indexPath.row, 0, "Should return first indexPath")
        scrollToExp?.fulfill()
    }
    
    func presentVehicleDetails(vehicle: Vehicle) {
        presentDetailsExp?.fulfill()
    }
}

class MockVehicleService: VehiclesService {
    
    func requestVehiclesList(completion: @escaping (Result<[Vehicle], ServiceError>) -> Void) {
        let vehicles = VehicleFactory.vehicleList()
        completion(.success(vehicles))
    }
    
}
