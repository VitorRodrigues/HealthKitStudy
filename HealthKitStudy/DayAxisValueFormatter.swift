//
//  DayAxisValueFormatter.swift
//  ChartsDemo-iOS
//
//  Created by Jacob Christie on 2017-07-09.
//  Copyright © 2017 jc. All rights reserved.
//

import Foundation
import Charts

public class DayAxisValueFormatter: NSObject, IAxisValueFormatter {
    
    let dateFormatter = DateFormatter()
    let mappedDates: [Date]
    init(mappedEntries: [Date]) {
        dateFormatter.dateFormat = "dd/MM"
        mappedDates = mappedEntries
    }
    
    public func stringForValue(_ value: Double, axis: AxisBase?) -> String {
        let index = Int(value)
        guard index >= 0 && index < mappedDates.count else { return "?" }
        let date = mappedDates[index]
        return dateFormatter.string(from: date)
    }
}
