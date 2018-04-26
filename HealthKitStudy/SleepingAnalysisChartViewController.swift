//
//  SleepingAnalysisChartViewController.swift
//  HealthKitStudy
//
//  Created by Vitor Rodrigues on 24/04/2018.
//  Copyright © 2018 Vitor Rodrigues. All rights reserved.
//

import UIKit
import HealthKit
import Charts

class SleepingAnalysisChartViewController: HealthKitBaseViewController {
    
    let dateFormatter = DateFormatter()
    
    let sleepingCategoryType = HKObjectType.categoryType(forIdentifier: .sleepAnalysis)!
    
    var allData: [HKCategorySample]? = nil
    
    var chartView: BarChartView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        chartView = BarChartView()
        chartView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(chartView)
        chartView.topAnchor.constraint(equalTo: view.topAnchor, constant: 24).isActive = true
        chartView.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 24).isActive = true
        view.rightAnchor.constraint(equalTo: chartView.rightAnchor, constant: 24).isActive = true
        view.bottomAnchor.constraint(equalTo: chartView.bottomAnchor, constant: 24).isActive = true
        guard HKHealthStore.isHealthDataAvailable() else {
            chartView.noDataText = "Health Kit not available"
            return
        }
        chartView.noDataText = "No sleeping data available"
        
        
        let readTypes: Set<HKObjectType> = [ sleepingCategoryType ]
        
        healthStore.requestAuthorization(toShare: nil, read: readTypes) { (granted, error) in
            guard granted else {
                self.chartView.noDataText = "We're not authorized to see HealthKit data"
                return
            }
            self.chartView.noDataText = "Loading data..."
            self.readStoreData()
        }
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
        guard let allData = allData else { return }
        let cal = Calendar.current
        //        let yAxisTimeIntervalInBed = allData.compactMap {
        //            return $0.endDate.timeIntervalSince1970 - $0.startDate.timeIntervalSince1970
        //        }
        let samplesByDate = Dictionary.init(grouping: allData) { (sample) -> Date in
            let cleanDateComps = cal.dateComponents([.day, .month, .year], from: sample.startDate)
            return cal.date(from: cleanDateComps)!
        }
        
        //        let dataEntries = samplesByDate.compactMap { samples -> TimeInterval in
        //            var totalInBed: TimeInterval = 0
        //            samples.value.forEach { sample in
        //                totalInBed += (sample.endDate.timeIntervalSince1970 - sample.startDate.timeIntervalSince1970)
        //            }
        //            return totalInBed
        //        }
        
        var index = 0
        let entries = samplesByDate.compactMap { dictionary -> BarChartDataEntry in
            
            let yValues = dictionary.value.compactMap { ($0.endDate.timeIntervalSince1970 - $0.startDate.timeIntervalSince1970)/3600 }
            let xValue = Double(index)
            index += 1
            let data = BarChartDataEntry.init(x: xValue, yValues: yValues)
            return data
        }
        
        let dataSet = ChartDataSet(values: entries, label: "In-Bed Time")
        let chartData = ChartData(dataSet: dataSet)
        
        let xAxis = chartView.xAxis
        xAxis.drawLabelsEnabled = true
        xAxis.drawGridLinesEnabled = true
        xAxis.drawLimitLinesBehindDataEnabled = true
        xAxis.labelPosition = .bottom
        xAxis.labelFont = .systemFont(ofSize: 10)
        xAxis.granularity = 1
        xAxis.labelCount = 3
        xAxis.valueFormatter = DayAxisValueFormatter.init(mappedEntries: Array(samplesByDate.keys).sorted())
        
        let yAxis = chartView.leftAxis
        yAxis.drawLabelsEnabled = true
        yAxis.drawGridLinesEnabled = true
        yAxis.drawLimitLinesBehindDataEnabled = true
        
        DispatchQueue.main.async {
            self.chartView.data = chartData
        }
    }
    
}
