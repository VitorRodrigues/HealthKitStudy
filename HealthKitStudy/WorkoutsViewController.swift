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
        dateFormatter.dateFormat = "dd/MM/yyyy hh:mm"
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

    override func exportData() {
        guard data.isEmpty == false else { return }
        let file = "workouts.json"
        var dir: URL
        if #available(iOS 10.0, *) {
            dir = FileManager.default.temporaryDirectory
        } else {
            // Fallback on earlier versions
            dir = URL(fileURLWithPath: NSTemporaryDirectory(), isDirectory: true)
        }
        let fileURL = dir.appendingPathComponent(file)
        if FileManager().fileExists(atPath: fileURL.absoluteString) {
            let ac = UIActivityViewController(activityItems: [fileURL], applicationActivities: nil)
            present(ac, animated: true, completion: nil)
            return
        }
        
        let converter = HealthConverter()
        let datas = data.compactMap { converter.convert(workout: $0) }
        let json = datas.compactMap{ $0.toJSON() }
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: json, options: JSONSerialization.WritingOptions.prettyPrinted)
            
            //writing
            try jsonData.write(to: fileURL, options: .atomicWrite)
            
            let ac = UIActivityViewController(activityItems: [fileURL], applicationActivities: nil)
            present(ac, animated: true, completion: nil)
            
        } catch (let error) {
            print("Error: \(error.localizedDescription)")
        }
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
        var workoutIcon: String
        switch cellData.workoutActivityType {
        case .archery:
            workoutIcon = "🏹"
        case .running, .walking:
            workoutIcon = "🏃‍♂️"
        default:
            workoutIcon = "🏋️‍♂️"
        }
        
        cell.textLabel?.text = "⏱: \(format(duration: cellData.duration)) | \(kcalBurned) burned 🔥... \(workoutIcon)(\(cellData.workoutActivityType.rawValue))"
        cell.detailTextLabel?.text = "\(dateFormatter.string(from: cellData.startDate))-\(dateFormatter.string(from: cellData.endDate))"
        return cell
    }
    
    func format(duration: TimeInterval) -> String {
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.day, .hour, .minute, .second]
        formatter.unitsStyle = .short
        
//        formatter.maximumUnitCount = 2
        
        return formatter.string(from: duration)!
    }
}
