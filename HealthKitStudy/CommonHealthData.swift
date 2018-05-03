//
//  CommonHealthData.swift
//  HealthKitStudy
//
//  Created by Vitor Rodrigues on 02/05/2018.
//  Copyright © 2018 Vitor Rodrigues. All rights reserved.
//

import Foundation
import HealthKit

protocol JSONSerializable {
    func toJSON() -> [String: Any]
}

class CommonHealthData: NSObject, JSONSerializable {
    
    var healthKitItemIdentifier: String?
    var healthKitCategoryIdentifier: String?
    var healthKitSampleActivityType: String?
    
    
    var startDate: Date
    var endDate: Date
    
    override init() {
        startDate = Date()
        endDate = Date()
    }
    
    func toJSON() -> [String : Any] {
        var json = [String: Any]()
        
        json["startDate"] = startDate
        json["endDate"] = endDate
        
        return json
    }
}

class CategoryHealthData: CommonHealthData {
    var categoryType: Int = 0
    var category: String?
    var value: Double
    
    init(value: Double, category: String) {
        self.value = value
        self.category = category
        super.init()
    }
    
    override func toJSON() -> [String : Any] {
        var json = super.toJSON()
        json["value"] = value
        if let category = category {
            json["category"] = category
        }
        return json
    }
}

class QuantityHealthData: CommonHealthData {
    
    var value: Double
    var unit: String
    
    init(value: Double, unit: String) {
        self.value = value
        self.unit = unit
        super.init()
    }
    
    override func toJSON() -> [String : Any] {
        var json = super.toJSON()
        json["value"] = value
        json["unit"] = unit
        return json
    }
}

class WorkoutHealthData: CommonHealthData {
    
    class WorkoutEvent {
        var start: Date
        var end: Date
        var interval: TimeInterval = 0
        
        init(start: Date, end: Date) {
            self.start = start
            self.end = end
            interval = end.timeIntervalSince1970 - start.timeIntervalSince1970
        }
    }
    
    var healthKitActivityType: Int?
    var activityType: Int?
    var events: [WorkoutEvent]? = nil
    var type: Int = 0
    var duration: TimeInterval = 0.0
    var energyBurned: Double = 0.0
    var distance: Double = 0.0
    
    init(type: Int, duration: TimeInterval, energyBurned: Double, distance: Double) {
        self.type = type
        self.energyBurned = energyBurned
        self.distance = distance
        super.init()
    }
    
    override func toJSON() -> [String : Any] {
        var json = super.toJSON()
        json["type"] = type
        if let hkActivityType = healthKitActivityType {
            json["healthKitActivityType"] = hkActivityType
        }
        json["duration"] = duration
        json["totalEnergyBurned"] = energyBurned
        json["totalDistance"] = distance
        if let events = events, events.isEmpty == false {
            var jsonEvents = [[String: Any]]()
            for event in events {
                var json = [String: Any]()
                json["end"] = event.end
                json["interval"] = event.interval
                json["start"] = event.start
                jsonEvents.append(json)
            }
        }
        return json
    }
}
