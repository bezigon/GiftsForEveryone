//
//  ResultsViewModel.swift
//  GiftsForEveryone
//
//  Created by bezigon on 2/4/20.
//  Copyright © 2020 bezigon. All rights reserved.
//

import Foundation
import RxRelay
import RxFlow

class ResultsViewModel: ServicesViewModel, Stepper {
    typealias Services = HasGiftService
    
    var services: Services!
    
    lazy var birthdate = {
        return services.giftsService.birthdate
    }()
    
    lazy var simulatedDate = {
        return services.giftsService.simulatedDate
    }()
    
    lazy var gender = {
        return services.giftsService.gender
    }()
    
    lazy var gifts = {
        return services.giftsService.gifts
    }()
    
    let steps = PublishRelay<Step>()
    
    func stringFromDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: date)
    }
    
    deinit {
        print("\(type(of: self)): \(#function)")
    }
}
