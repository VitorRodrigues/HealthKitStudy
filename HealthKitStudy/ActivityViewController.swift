//
//  ActivityViewController.swift
//  HealthKitStudy
//
//  Created by Vitor Rodrigues on 24/04/2018.
//  Copyright © 2018 Vitor Rodrigues. All rights reserved.
//

import UIKit
import HealthKit

class ActivityViewController: HealthKitBaseViewController {

    @IBOutlet weak var tableView: UITableView!
    
    var anchor: HKQueryAnchor? {
        get {
            guard let data = UserDefaults.standard.object(forKey: "anchorHealthKit") as? Data else { return nil }
            return NSKeyedUnarchiver.unarchiveObject(with: data) as? HKQueryAnchor
        }
        set {
            if let data = newValue {
                let data = NSKeyedArchiver.archivedData(withRootObject: data)
                UserDefaults.standard.set(data,forKey: "anchorHealthKit")
            } else {
                UserDefaults.standard.removeObject(forKey: "anchorHealthKit")
            }
            UserDefaults.standard.synchronize()
        }
    }
    
    let distanceWalkingSample = HKSampleType.quantityType(forIdentifier: .distanceWalkingRunning)!
    let stepCountSample = HKSampleType.quantityType(forIdentifier: .stepCount)!
    let activityBurnedSamples = HKSampleType.quantityType(forIdentifier: .activeEnergyBurned)!
    let dateFormatter = DateFormatter()
    var data: [(String, String)] = [] {
        didSet {
            if data.isEmpty == false {
                showWarningLabel(text: nil)
            }
            DispatchQueue.main.async {   
                self.tableView.reloadData()
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
       
        dateFormatter.dateFormat = "dd/MM/yyyy"
        var readTypes: Set<HKObjectType> = [
            distanceWalkingSample,
            stepCountSample,
            activityBurnedSamples
//            HKSampleType.quantityType(forIdentifier: .appleExerciseTime)!
        ]
        
        if #available(iOS 9.3, *) {
            readTypes.insert(HKSampleType.activitySummaryType())
        }
        
        tableView.dataSource = self
        prepareReading(types: readTypes)
    }
    
    override func readStoreData() {
        do {
            
            let query = HKSampleQuery(sampleType: stepCountSample, predicate: nil, limit: 0, sortDescriptors: nil) { (query, samples, error) in
                guard error == nil else { return }
                guard let samples = samples as? [HKQuantitySample], samples.isEmpty == false else {
                    return
                }
                let startDates = samples.map { $0.startDate }
                let endDates = samples.map { $0.endDate }
                let minDate = startDates.min()!
                let maxDate = endDates.max()!
                
                let stepUnit = HKUnit.count()
                let allSteps = samples.map({ $0.quantity.doubleValue(for: stepUnit) }).reduce(0, { $0 + $1 })
                
                let title = "You have \(Int(allSteps)) recorded steps"
                let detail = "\(self.dateFormatter.string(from: minDate)) - \(self.dateFormatter.string(from: maxDate))"
                
                self.data.append((title, detail))
            }
            
            
            healthStore.execute(query)
        }
        
        
        do {
            let query = HKAnchoredObjectQuery(type: distanceWalkingSample, predicate: nil, anchor: nil, limit: 0) { (query, samples, deleted, newAnchor, error) in
                guard error == nil else { return }
                self.anchor = newAnchor
                guard let samples = samples as? [HKQuantitySample], samples.isEmpty == false else {
                    return
                }
                
                let maxDate =  samples.compactMap { $0.endDate }.max()!
                let distanceUnit = HKUnit.meterUnit(with: .kilo)
                let allDistance = samples.map({ $0.quantity.doubleValue(for: distanceUnit) }).reduce(0, { $0 + $1 })
                
                let distanceFormatter = NumberFormatter()
                distanceFormatter.allowsFloats = true
                distanceFormatter.numberStyle = .decimal
                distanceFormatter.maximumFractionDigits = 2
                let formatter = LengthFormatter()
                formatter.unitStyle = .medium
                formatter.numberFormatter = distanceFormatter
                let distance = formatter.string(fromValue: allDistance, unit: LengthFormatter.Unit.kilometer)
                let title = "All distance: \(distance)"
                let detail = "up to \(self.dateFormatter.string(from: maxDate))"
                
                self.data.append((title, detail))
            }
            
            
            healthStore.execute(query)
        }
        
        do {
            
            let query = HKStatisticsQuery(quantityType: activityBurnedSamples, quantitySamplePredicate: nil, options: .cumulativeSum) { (query, statistics, error) in
                guard error == nil else { return }
                guard let statistic = statistics,
                let sumQuantity = statistic.sumQuantity() else {
                    return
                }
                
                let unit = HKUnit.kilocalorie()
                let title = "\(sumQuantity.doubleValue(for: unit)) \(unit.unitString)"
                let detail = "\(self.dateFormatter.string(from: statistic.startDate)) - \(self.dateFormatter.string(from: statistic.endDate))"
                
                self.data.append((title, detail))
            }
            
            
            healthStore.execute(query)
        }
    }

}

extension ActivityViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return data.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        let cellData = data[indexPath.row]
        cell.textLabel?.text = cellData.0
        cell.detailTextLabel?.text = cellData.1
        return cell
    }
}
