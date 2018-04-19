//
//  DetailViewController.swift
//  HealthKitStudy
//
//  Created by Vitor Rodrigues on 4/19/18.
//  Copyright © 2018 Vitor Rodrigues. All rights reserved.
//

import UIKit
import HealthKit

class ProfileViewController: UIViewController {

    @IBOutlet weak var detailDescriptionLabel: UILabel!

    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var ageLabel: UILabel!
    @IBOutlet weak var birthdayLabel: UILabel!
    @IBOutlet weak var genderLabel: UILabel!
    @IBOutlet weak var heightLabel: UILabel!
    @IBOutlet weak var weightLabel: UILabel!
    
    
    let healthStore = HKHealthStore()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        guard HKHealthStore.isHealthDataAvailable() else { return }
        
        let readTypes: Set<HKObjectType> = [
            HKObjectType.characteristicType(forIdentifier: .dateOfBirth)!,
            HKObjectType.characteristicType(forIdentifier: .biologicalSex)!,
            HKObjectType.quantityType(forIdentifier: .height)!,
            HKObjectType.quantityType(forIdentifier: .bodyMass)!
        ]
        
        healthStore.requestAuthorization(toShare: nil, read: readTypes) { (granted, error) in
            guard granted else { return }
            self.readStoreData()
        }
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func readStoreData() {
        do {
            let sex = try healthStore.biologicalSex()
            switch sex.biologicalSex {
            case .female:
                genderLabel.text = "Feminino"
            case .male:
                genderLabel.text = "Masculino"
            case .other:
                genderLabel.text = "Outro"
            case .notSet:
                genderLabel.text = "Não Definido"
            }
        } catch {
            genderLabel.text = "N/A"
        }
        
        
        do {
            var components: DateComponents
            if #available(iOS 10.0, *) {
                components = try healthStore.dateOfBirthComponents()
            } else {
                let birthDate = try healthStore.dateOfBirth()
                components = Calendar.current.dateComponents([.day, .month,.year, .calendar], from: birthDate)
            }
            
            if let birthDate = Calendar.current.date(from: components) {
                let formatter = DateFormatter()
                formatter.dateFormat = "dd/MM/yyyy"
                let text = formatter.string(from: birthDate)
                birthdayLabel.text = text
                
                let yearComp = Calendar.current.dateComponents([.year], from: birthDate, to: Date())
                ageLabel.text = "\(yearComp.year!) anos"
            } else {
                birthdayLabel.text = "Não definido"
                ageLabel.text = "--"
            }
        } catch {
            birthdayLabel.text = "N/A"
            ageLabel.text = "--"
        }
        
        // GET LASTEST HEIGHT
        do {
            let heightSample = HKObjectType.quantityType(forIdentifier: .height)!
//            HKObjectType.quantityType(forIdentifier: .bodyMass)!
            
            let lastTimeSort = NSSortDescriptor(key: HKSampleSortIdentifierEndDate,  ascending: false)
            
            let query = HKSampleQuery(sampleType: heightSample, predicate: nil, limit: 1, sortDescriptors: [lastTimeSort]) { (query, samples, error) in
                guard let samples = samples else {
                    self.heightLabel.text = "N/A"
                    return
                }
                
                if let lastHeight = samples.first as? HKQuantitySample {
                    let cmUnit = HKUnit.init(from: LengthFormatter.Unit.centimeter)
                    let height = lastHeight.quantity.doubleValue(for: cmUnit)
                    let heightFormatter = NumberFormatter()
                    heightFormatter.numberStyle = .decimal
                    heightFormatter.maximumFractionDigits = 2
                    heightFormatter.minimumFractionDigits = 2
                    heightFormatter.positiveSuffix = "m"
                    self.heightLabel.text = heightFormatter.string(from: NSNumber(value: height))
                } else {
                    self.heightLabel.text = "Sem altura"
                }
            }
            
            healthStore.execute(query)
        }
        
        // GET LASTEST WEIGHT
        do {
            let weightSample = HKObjectType.quantityType(forIdentifier: .bodyMass)!
            
            let lastTimeSort = NSSortDescriptor(key: HKSampleSortIdentifierEndDate,  ascending: false)
            
            let query = HKSampleQuery(sampleType: weightSample, predicate: nil, limit: 1, sortDescriptors: [lastTimeSort]) { (query, samples, error) in
                guard let samples = samples else {
                    self.weightLabel.text = "N/A"
                    return
                }
                
                if let lastWeight = samples.first as? HKQuantitySample {
                    let kgUnit = HKUnit.gramUnit(with: HKMetricPrefix.kilo)
                    let height = lastWeight.quantity.doubleValue(for: kgUnit)
                    let weightFormatter = NumberFormatter()
                    weightFormatter.numberStyle = .decimal
                    weightFormatter.maximumFractionDigits = 1
                    weightFormatter.positiveSuffix = "kg"
                    self.weightLabel.text = weightFormatter.string(from: NSNumber(value: height))
                } else {
                    self.weightLabel.text = "Sem altura"
                }
            }
            
            healthStore.execute(query)
        }
        
    }
    


}

