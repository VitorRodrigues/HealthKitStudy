//
//  SleepingAnalysisViewController.swift
//  HealthKitStudy
//
//  Created by Vitor Rodrigues on 24/04/2018.
//  Copyright © 2018 Vitor Rodrigues. All rights reserved.
//

import UIKit
import HealthKit


class SleepingAnalysisViewController: HealthKitBaseViewController {
    let dateFormatter = DateFormatter()
    let timeFormatter = DateFormatter()
    
    let sleepingCategoryType = HKObjectType.categoryType(forIdentifier: .sleepAnalysis)!
    
    var allData: [HKCategorySample]? = nil
    var dateGroupedSamples: [Date: [HKCategorySample]]? = nil
    var dateSections: [Date] = []
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.tableFooterView = UIView()
        guard HKHealthStore.isHealthDataAvailable() else {
            showWarningLabel(text:"Health Kit unavailable")
            return
        }
        timeFormatter.dateFormat = "HH'h' mm'm'"
        dateFormatter.dateFormat = "dd/MM"
        let readTypes: Set<HKObjectType> = [ sleepingCategoryType ]
        prepareReading(types: readTypes)
    }
    
    override func readStoreData() {
        
        // GET LASTEST ANALYSIS
        do {
            let lastTimeSort = NSSortDescriptor(key: HKSampleSortIdentifierStartDate,  ascending: true)
            
            let query = HKSampleQuery(sampleType: sleepingCategoryType, predicate: nil, limit: 0, sortDescriptors: [lastTimeSort]) { (query, samples, error) in
                guard let samples = samples as? [HKCategorySample] else {
                    return
                }
                
                // Only inbed/asleep data
                self.allData = samples.filter({ $0.value == HKCategoryValueSleepAnalysis.inBed.rawValue || $0.value == HKCategoryValueSleepAnalysis.asleep.rawValue })
                self.showSleepingData()
            }
            
            healthStore.execute(query)
        }
        
    }
    
    func showSleepingData() {
        guard let allData = allData, allData.isEmpty == false else {
            showWarningLabel(text:"No sleeping data available")
            return
        }
        let cal = Calendar.current
        let samplesByDate = Dictionary.init(grouping: allData) { (sample) -> Date in
            let cleanDateComps = cal.dateComponents([.day, .month, .year], from: sample.startDate)
            return cal.date(from: cleanDateComps)!
        }
        
        dateGroupedSamples = samplesByDate
        dateSections = Array(samplesByDate.keys).sorted()
        DispatchQueue.main.async {
            self.showWarningLabel(text: nil)
            self.tableView.dataSource = self
            self.tableView.reloadData()
        }
    }
    
    override func exportData() {
        guard let data = allData else { return }
        let file = "sleeping.json"
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
        let datas = data.compactMap { converter.convert(category: $0) }
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
}

extension SleepingAnalysisViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return dateSections.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let samples = dateGroupedSamples else { return 0 }
        let date = dateSections[section]
        return samples[date]?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        let date = dateSections[indexPath.section]
        
        guard let sample = dateGroupedSamples?[date]?[indexPath.row] else {
            cell.textLabel?.text = "-- INVALID DATA --"
            cell.detailTextLabel?.text = "--"
            return cell
        }
        
        cell.textLabel?.text = "\(dateFormatter.string(from: sample.startDate)) - \(dateFormatter.string(from: sample.endDate))"
        let delta = sample.endDate.timeIntervalSince1970 - sample.startDate.timeIntervalSince1970
        let diffTime = Date(timeIntervalSince1970: delta)
        let status = sample.value == HKCategoryValueSleepAnalysis.asleep.rawValue ? "Sleeping" : "In Bed"
        cell.detailTextLabel?.text = "\(timeFormatter.string(from: diffTime)) \(status)"
        return cell
    }
}
