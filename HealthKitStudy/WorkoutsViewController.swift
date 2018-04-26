//
//  WorkoutsViewController.swift
//  HealthKitStudy
//
//  Created by Vitor Rodrigues on 26/04/2018.
//  Copyright © 2018 Vitor Rodrigues. All rights reserved.
//

import UIKit
import HealthKit

class WorkoutsViewController: HealthKitBaseViewController {

    let workoutType = HKWorkoutType.workoutType()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        prepareReading(types: [workoutType])
    }
    
    override func readStoreData() {
        do {
            
        } catch {
            
        }
    }

}
