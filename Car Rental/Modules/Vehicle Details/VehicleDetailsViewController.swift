//
//  VehicleDetailsViewController.swift
//  Car Rental
//
//  Created by Clineu Iansen Junior on 20/09/19.
//  Copyright © 2019 Clineu Iansen Junior. All rights reserved.
//

import UIKit
import Kingfisher

protocol VehicleDetailsDelegate: class {
    func vehicleDetailsdidPressCloseButton(_ vehicleDetails: VehicleDetailsViewController)
}

class VehicleDetailsViewController: UIViewController {

    @IBOutlet weak var licensePlateLabel: UILabel!
    @IBOutlet weak var driverLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var backgroundImageView: UIImageView!
    @IBOutlet weak var carImageView: UIImageView!
    @IBOutlet weak var fuelImageView: UIImageView!
    @IBOutlet weak var fuelLevelLabel: UILabel!
    @IBOutlet weak var gearboxTypeLabel: UILabel!
    @IBOutlet weak var cleanlinessLabel: UILabel!
    
    var viewModel: VehicleDetailsViewModel?
    weak var delegate: VehicleDetailsDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.view.layer.cornerRadius = 10
        self.view.layer.masksToBounds = true
        self.view.clipsToBounds = true
        
        self.viewModel?.requestVehicleDetails()
    }
    
    init(viewModel: VehicleDetailsViewModel) {
        super.init(nibName: "VehicleDetailsViewController", bundle: nil)
        
        self.viewModel = viewModel
        self.viewModel?.delegate = self
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    @IBAction func didPressCloseButton() {
        delegate?.vehicleDetailsdidPressCloseButton(self)
    }
}

extension VehicleDetailsViewController: VehicleDetailsViewModelDelegate {
    
    func presentVehicleDetails(model: VehicleDetailsPresenter) {
        self.titleLabel.text = model.title
        self.licensePlateLabel.text = model.licensePlate
        self.driverLabel.text = model.driverName
        self.backgroundImageView.image = model.backgroundImage
        self.carImageView.kf.setImage(with: model.vehicleImageURL, placeholder: model.vehiclePlaceholderImage)
        self.fuelImageView.image = model.fuelTypeIcon
        self.fuelLevelLabel.text = model.fuelPercentage
        self.gearboxTypeLabel.text = model.transmission
        self.cleanlinessLabel.text = model.innerCleanliness
    }
}
