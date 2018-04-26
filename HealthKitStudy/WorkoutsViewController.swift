//
//  WorkoutsViewController.swift
//  HealthKitStudy
//
//  Created by Vitor Rodrigues on 26/04/2018.
//  Copyright © 2018 Vitor Rodrigues. All rights reserved.
//

import UIKit
import HealthKit

class WorkoutsViewController: HealthKitBaseViewController, UITableViewDataSource {

    let workoutType = HKWorkoutType.workoutType()
    let runningDistanceType = HKObjectType.quantityType(forIdentifier: HKQuantityTypeIdentifier.distanceWalkingRunning)
    let runningStepsType = HKObjectType.quantityType(forIdentifier: HKQuantityTypeIdentifier.stepCount)
    let dateFormatter = DateFormatter()
    let numberFormatter = NumberFormatter()
    
    @IBOutlet weak var tableView: UITableView!
    
    var data: [HKWorkout] = [] {
        didSet {
            tableView.reloadData()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        dateFormatter.dateFormat = "dd/MM/yyyy"
        numberFormatter.maximumFractionDigits = 2
        prepareReading(types: [workoutType])
        tableView.dataSource = self
    }
    
    override func readStoreData() {
        
        let workoutPredicate = HKQuery.predicateForWorkouts(with: .running)
        
        let query = HKSampleQuery(sampleType: workoutType, predicate: nil, limit: 0, sortDescriptors: nil) { (query, sample, error) in
            guard let samples = sample as? [HKWorkout] else { return }
            DispatchQueue.main.async {
                self.data = samples
            }
        }
        
        healthStore.execute(query)
        
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return data.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        let cellData = data[indexPath.row]
        
        let measure = EnergyFormatter()
        measure.numberFormatter = numberFormatter
        let kcalBurned = measure.string(fromValue: cellData.totalEnergyBurned!.doubleValue(for: HKUnit.kilocalorie()), unit: EnergyFormatter.Unit.kilocalorie)
        
        let time = 
        
        cell.textLabel?.text = "Dur: \(cellData.duration) | \(kcalBurned)"
        cell.detailTextLabel?.text = "\(cellData.startDate)-\(cellData.endDate)"
        return cell
    }
    
}
