//
//  HealthAdapter.swift
//  HealthKitStudy
//
//  Created by Vitor Rodrigues on 02/05/2018.
//  Copyright © 2018 Vitor Rodrigues. All rights reserved.
//

import Foundation
import HealthKit

class HealthConverter {
    
    func convert(quantity: HKQuantitySample, unit: HKUnit) -> CommonHealthData {
//        let value = quantity.quantity.doubleValue(for: unit)
//        let unit = unit.unitString
//        let data = QuantityHealthData(value: value, unit: unit)
//        
//        data.startDate = quantity.startDate
//        data.endDate = quantity.endDate
//        
        return convert(startDate: quantity.startDate,
                       endDate: quantity.endDate,
                       quantity: quantity.quantity,
                       unit: unit)
    }
    
    func convert(startDate:Date, endDate: Date, quantity: HKQuantity, unit: HKUnit) -> CommonHealthData {
        let value = quantity.doubleValue(for: unit)
        let unit = unit.unitString
        let data = QuantityHealthData(value: value, unit: unit)
        
        data.startDate = startDate
        data.endDate = endDate
        
        return data
    }
    
    func convert(category: HKCategorySample) -> CommonHealthData {
        let god = CategoryHealthData(value: Double(category.value), category: category.categoryType.identifier)
        god.categoryType = 1
        return god
    }
    
    func convert(workout: HKWorkout) -> CommonHealthData {
        let startDate = workout.startDate
        let endDate = workout.endDate
        
        let activityType = Int(workout.workoutActivityType.rawValue)
        let duration = workout.duration
        let energyBurned = workout.totalEnergyBurned?.doubleValue(for: HKUnit.kilocalorie()) ?? 0
        let distance = workout.totalDistance?.doubleValue(for: HKUnit.meter()) ?? 0
        
        let workoutData = WorkoutHealthData(type: activityType, duration: duration, energyBurned: energyBurned, distance: distance)
        
        let durationItem = QuantityHealthData(value: duration, unit: "s")
        durationItem.startDate = startDate
        durationItem.endDate = endDate
        
        if #available(iOS 11.0, *) {
            if let events = workout.workoutEvents, events.isEmpty == false {
                var eventsData = [WorkoutHealthData.WorkoutEvent]()
                for event in events {
                    let newEvent = WorkoutHealthData.WorkoutEvent(start: event.dateInterval.start, end: event.dateInterval.end)
                    newEvent.interval = event.dateInterval.duration
                    eventsData.append(newEvent)
                }
            }
        }
        
        return workoutData
    }
}
