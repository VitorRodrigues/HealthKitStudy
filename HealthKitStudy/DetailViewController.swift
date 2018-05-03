//
//  DetailViewController.swift
//  HealthKitStudy
//
//  Created by Vitor Rodrigues on 4/19/18.
//  Copyright © 2018 Vitor Rodrigues. All rights reserved.
//

import UIKit
import HealthKit

class ProfileViewController: HealthKitBaseViewController {

    @IBOutlet weak var detailDescriptionLabel: UILabel!

    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var ageLabel: UILabel!
    @IBOutlet weak var birthdayLabel: UILabel!
    @IBOutlet weak var genderLabel: UILabel!
    @IBOutlet weak var heightLabel: UILabel!
    @IBOutlet weak var weightLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        guard HKHealthStore.isHealthDataAvailable() else { return }
        
        let readTypes: Set<HKObjectType> = [
            HKObjectType.characteristicType(forIdentifier: .dateOfBirth)!,
            HKObjectType.characteristicType(forIdentifier: .biologicalSex)!,
            HKObjectType.quantityType(forIdentifier: .height)!,
            HKObjectType.quantityType(forIdentifier: .bodyMass)!
        ]
        
        prepareReading(types: readTypes)
    }
    
    override func readStoreData() {
        
        DispatchQueue.main.async {
            do {
                let sex = try self.healthStore.biologicalSex()
                switch sex.biologicalSex {
                case .female:
                    self.genderLabel.text = "Feminino"
                case .male:
                    self.genderLabel.text = "Masculino"
                case .other:
                    self.genderLabel.text = "Outro"
                case .notSet:
                    self.genderLabel.text = "Não Definido"
                }
            } catch {
                self.genderLabel.text = "N/A"
            }
            
            
            do {
                var components: DateComponents
                if #available(iOS 10.0, *) {
                    components = try self.healthStore.dateOfBirthComponents()
                } else {
                    let birthDate = try self.healthStore.dateOfBirth()
                    components = Calendar.current.dateComponents([.day, .month,.year, .calendar], from: birthDate)
                }
                
                if let birthDate = Calendar.current.date(from: components) {
                    let formatter = DateFormatter()
                    formatter.dateFormat = "dd/MM/yyyy"
                    let text = formatter.string(from: birthDate)
                    self.birthdayLabel.text = text
                    
                    let yearComp = Calendar.current.dateComponents([.year], from: birthDate, to: Date())
                    self.ageLabel.text = "\(yearComp.year!) anos"
                } else {
                    self.birthdayLabel.text = "Não definido"
                    self.ageLabel.text = "--"
                }
            } catch {
                self.birthdayLabel.text = "N/A"
                self.ageLabel.text = "--"
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
                        let heightFormatter = NumberFormatter()
                        heightFormatter.numberStyle = .decimal
                        heightFormatter.maximumFractionDigits = 2
                        heightFormatter.minimumFractionDigits = 2
                        
                        let meterUnit = HKUnit.init(from: LengthFormatter.Unit.meter)
                        let lengthFormatter = LengthFormatter()
                        lengthFormatter.unitStyle = .short
                        lengthFormatter.numberFormatter = heightFormatter
                        
                        
                        let height = lastHeight.quantity.doubleValue(for: meterUnit)
                        self.heightLabel.text = lengthFormatter.string(fromValue: height, unit: LengthFormatter.Unit.meter)
                        
                    } else {
                        self.heightLabel.text = "Sem altura"
                    }
                }
                
                self.healthStore.execute(query)
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
                
                self.healthStore.execute(query)
            }
        
        }
    }
    


}

