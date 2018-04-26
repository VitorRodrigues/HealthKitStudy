//
//  HealthKitBaseViewController.swift
//  HealthKitStudy
//
//  Created by Vitor Rodrigues on 26/04/2018.
//  Copyright © 2018 Vitor Rodrigues. All rights reserved.
//

import UIKit
import HealthKit

class HealthKitBaseViewController: UIViewController {
    let healthStore = HKHealthStore()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        guard HKHealthStore.isHealthDataAvailable() else {
            self.showWarningLabel(text:"Health Kit unavailable")
            return
        }
        // Do any additional setup after loading the view.
        
        
    }

    internal func prepareReading(types: Set<HKObjectType>) {
        guard HKHealthStore.isHealthDataAvailable() else { return }
        
        healthStore.requestAuthorization(toShare: nil, read: types) { (granted, error) in
            guard granted else {
                self.showWarningLabel(text:"We're not authorized to see HealthKit data")
                return
            }
            self.showWarningLabel(text:"Loading data...")
            self.readStoreData()
        }
    }
    
    final func showWarningLabel(text: String?) {
        DispatchQueue.main.async {
            self.view.viewWithTag(999)?.removeFromSuperview()
            guard let text = text else { return }
            let label = UILabel()
            label.tag = 999
            label.translatesAutoresizingMaskIntoConstraints = false
            label.text = text
            self.view.addSubview(label)
            label.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
            label.centerYAnchor.constraint(equalTo: self.view.centerYAnchor).isActive = true
        }
    }
    
    func readStoreData() {
    }

}
