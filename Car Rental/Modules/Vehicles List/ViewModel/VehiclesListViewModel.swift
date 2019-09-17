//
//  VehiclesListViewModel.swift
//  Car Rental
//
//  Created by Clineu Iansen Junior on 20/09/19.
//  Copyright © 2019 Clineu Iansen Junior. All rights reserved.
//

import Foundation

protocol VehicleListViewModelDelegate {
    func didLoadVehiclesList(result: Result<[Vehicle], ServiceError>)
    func isLoading(loading: Bool)
    func scrollTo(indexPath: IndexPath)
    func presentVehicleDetails(vehicle: Vehicle)
}

protocol VehicleListViewModelProtocol {
    var delegate: VehicleListViewModelDelegate? { get set }
    var vehicles: [Vehicle] { get set }
    
    func requestVehicleList()
    func requestDetailsFor(vehicle: Vehicle)
}

class VehiclesListViewModel: VehicleListViewModelProtocol {
    var delegate: VehicleListViewModelDelegate?
    var vehicles: [Vehicle] = []
    
    let service: VehiclesService
    init(service: VehiclesService) {
        self.service = service
    }
    
    func requestVehicleList() {
        delegate?.isLoading(loading: true)
        service.requestVehiclesList { [weak self] (result) in
            self?.delegate?.didLoadVehiclesList(result: result)
            self?.delegate?.isLoading(loading: false)
            
            switch result {
            case .success(let vehicles):
                self?.vehicles = vehicles
            default: break
            }
        }
    }
    
    func requestDetailsFor(vehicle: Vehicle) {
        delegate?.presentVehicleDetails(vehicle: vehicle)
        
        guard let index = vehicles.firstIndex(where: { $0.id == vehicle.id }) else { return }
        let indexPath = IndexPath(row: index, section: 0)
        delegate?.scrollTo(indexPath: indexPath)
    }
}
