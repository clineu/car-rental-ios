//
//  ViewController.swift
//  Car Rental
//
//  Created by Clineu Iansen Junior on 17/09/19.
//  Copyright © 2019 Clineu Iansen Junior. All rights reserved.
//

import UIKit
import MapKit
import Kingfisher

class VehiclesListViewController: UIViewController {
    private let markerAnnotationIdentifier = "VehicleAnnotation"
    private let vehicleCellIdentifier = "VehicleListTableViewCell"
    private let mapClusterIdentifier = "DefaultCluster"
    private let detailsAnimation = UIViewPropertyAnimator(duration: 0.5, dampingRatio: 0.7)
    private var currentDetailsVC: VehicleDetailsViewController?
    private let refreshControl = UIRefreshControl()
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var mapView: MKMapView!
    
    lazy var viewModel: VehicleListViewModelProtocol = {
        let service = SixtVehiclesService()
        let vm = VehiclesListViewModel(service: service)
        vm.delegate = self
        return vm
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureTableView()
        configureMapView()
        
        viewModel.requestVehicleList()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
    }

    func configureMapView() {
        mapView.register(MKMarkerAnnotationView.self, forAnnotationViewWithReuseIdentifier: markerAnnotationIdentifier)
        mapView.delegate = self
    }
    
    func configureTableView() {
        tableView.dataSource = self
        tableView.delegate = self
        tableView.tableFooterView = UIView(frame: .zero)
        
        containerView.layer.cornerRadius = 10
        containerView.layer.masksToBounds = true
        containerView.clipsToBounds = true
        
        let nib = UINib(nibName: "VehicleListTableViewCell", bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: vehicleCellIdentifier)
     
        refreshControl.addTarget(self, action: #selector(didStartRefreshControl), for: .valueChanged)
        tableView.refreshControl = refreshControl
    }
    
    @objc func didStartRefreshControl() {
        refreshControl.beginRefreshing()
        viewModel.requestVehicleList()
    }
    
    func addVehicleAnnotation(vehicles: [Vehicle]) {
        let annotations = vehicles
            .map { CarAnnotation(vehicle: $0) }
        
        DispatchQueue.main.async {
            self.mapView.removeAnnotations(self.mapView.annotations)
            self.mapView.addAnnotations(annotations)
            self.mapView.showAnnotations(annotations, animated: true)
        }
    }
}

extension VehiclesListViewController: VehicleListViewModelDelegate {

    func didLoadVehiclesList(result: Result<[Vehicle], ServiceError>) {
        tableView.removeCenterLabelView()
        
        switch result {
        case .success(let vehicles):
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
            self.addVehicleAnnotation(vehicles: vehicles)
            
        case .failure(let error):
            self.tableView.addCenterLabelView(text: error.localizedDescription)
        }
    }
    
    func isLoading(loading: Bool) {
        DispatchQueue.main.async {
            if loading && !self.refreshControl.isRefreshing {
                self.tableView.startLoading()
            } else if !loading {
                self.tableView.stopLoading()
                self.refreshControl.endRefreshing()
            }
        }
    }
    
    func scrollTo(indexPath: IndexPath) {
        tableView.scrollToRow(at: indexPath, at: .top, animated: true)
    }

    func presentVehicleDetails(vehicle: Vehicle) {
        let viewModel = VehicleDetailsViewModel(vehicle: vehicle)
        let vehicleDetailsVC = VehicleDetailsViewController(viewModel: viewModel)
        vehicleDetailsVC.delegate = self
        
        self.currentDetailsVC = vehicleDetailsVC
        self.addChild(vehicleDetailsVC)
        
        let vehicleDetailsView = vehicleDetailsVC.view
        
        let finalPosition: CGPoint = {
            let minY = view.frame.size.height - 320
            let yPosition = min(view.frame.size.height/2, minY)
            let finalPosition = CGPoint(x: 0, y: yPosition)
            return finalPosition
        }()
        
        let initialPosition = CGPoint(x: 0, y: view.frame.size.height)
        vehicleDetailsView?.frame = CGRect(origin: initialPosition, size: view.frame.size)
        vehicleDetailsView?.alpha = 0.7
        view.addSubview(vehicleDetailsVC.view)
        
        detailsAnimation.addAnimations {
            vehicleDetailsView?.frame = CGRect(origin: finalPosition, size: self.view.frame.size)
            vehicleDetailsView?.alpha = 1.0
        }
        detailsAnimation.startAnimation()
    }
    
    func dismissVehicleDetails() {
        let finalFrame = CGPoint(x: 0, y: view.frame.size.height)
        let view = currentDetailsVC?.view
        detailsAnimation.addAnimations {
            view?.frame.origin = finalFrame
            view?.alpha = 0.7
        }
        detailsAnimation.addCompletion { (_) in
            view?.removeFromSuperview()
        }
        detailsAnimation.startAnimation()
    }
    
}

extension VehiclesListViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.vehicles.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: vehicleCellIdentifier) as? VehicleListTableViewCell else {
            fatalError("Invalid reusable identifier for VehicleListTableViewCell class")
        }
        let vehicle = viewModel.vehicles[indexPath.row]
        cell.configureWith(vehicle: vehicle)
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 90
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let vehicle = viewModel.vehicles[indexPath.row]
        let annotation = mapView.annotations
            .compactMap { $0 as? CarAnnotation }
            .first(where: { $0.vehicle.id == vehicle.id })
        guard let ann = annotation else { return }
        mapView.selectAnnotation(ann, animated: true)
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
}

extension VehiclesListViewController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        guard
            let annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: markerAnnotationIdentifier,
                                                                       for: annotation) as? MKMarkerAnnotationView else {
                                                                        return nil
        }
        
        if let annotation = annotation as? CarAnnotation {
            return configure(annotationView: annotationView, forVehicleAnnotation: annotation)
        }
        
        if let annotation = annotation as? MKClusterAnnotation {
            return configure(annotationView: annotationView, forClusterAnnotation: annotation)
        }
        
        return nil
    }
    
    func configure(annotationView: MKMarkerAnnotationView, forClusterAnnotation annotation: MKClusterAnnotation) -> MKAnnotationView {
        annotationView.annotation = annotation
        annotationView.markerTintColor = .black
        annotationView.canShowCallout = false
        return annotationView
    }
    
    func configure(annotationView: MKMarkerAnnotationView, forVehicleAnnotation annotation: CarAnnotation) -> MKAnnotationView {
        let image: UIImage = annotation.vehicle.fuelType == FuelType.eletric
                ? .eletricCarIcon
                : .fuelCarIcon
        annotationView.glyphImage = image
        annotationView.glyphTintColor = .white
        annotationView.markerTintColor = .black
        annotationView.annotation = annotation
        annotationView.displayPriority = .required
        annotationView.clusteringIdentifier = mapClusterIdentifier
        return annotationView
    }
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        guard let coordinate = view.annotation?.coordinate else { return }
        centerToCoordinate(coordinate: coordinate)
        
        guard let annotation = view.annotation as? CarAnnotation else { return }
        viewModel.requestDetailsFor(vehicle: annotation.vehicle)
    }
    
    func mapView(_ mapView: MKMapView, didDeselect view: MKAnnotationView) {
        dismissVehicleDetails()
    }
    
    func centerToCoordinate(coordinate: CLLocationCoordinate2D) {
        var span = MKCoordinateSpan(latitudeDelta: 0.02, longitudeDelta: 0.02)
        if mapView.region.span.latitudeDelta < span.latitudeDelta &&
            mapView.region.span.longitudeDelta < span.longitudeDelta {
            span = mapView.region.span
        }
        let region = MKCoordinateRegion(center: coordinate, span: span)
        mapView.setRegion(region, animated: true)
    }
}

extension VehiclesListViewController: VehicleDetailsDelegate {
    func vehicleDetailsdidPressCloseButton(_ vehicleDetails: VehicleDetailsViewController) {
        for annotation in mapView.selectedAnnotations {
            mapView.deselectAnnotation(annotation, animated: true)
        }
        dismissVehicleDetails()
    }
}

class CarAnnotation: NSObject, MKAnnotation {
    var coordinate: CLLocationCoordinate2D
    var title: String?
    var subtitle: String?
    var vehicle: Vehicle
    
    init(vehicle: Vehicle) {
        self.vehicle = vehicle
        
        let coordinate = CLLocationCoordinate2D(latitude: vehicle.latitude, longitude: vehicle.longitude)
        self.coordinate = coordinate
        
        self.title = vehicle.name
        self.subtitle = vehicle.modelName
    }
}
