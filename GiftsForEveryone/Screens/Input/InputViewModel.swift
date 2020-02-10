//
//  InputViewModel.swift
//  GiftsForEveryone
//
//  Created by bezigon on 2/3/20.
//  Copyright © 2020 bezigon. All rights reserved.
//

import Foundation
import RxRelay
import RxSwift
import RxCocoa
import RxFlow

//{
//    info =     {
//        page = 1;
//        results = 1;
//        seed = 036f1122b396d6db;
//        version = "1.3";
//    };
//    results =     (
//                {
//            dob =             {
//                age = 36;
//                date = "1984-03-12T21:06:58.062Z";
//            };
//            gender = female;
//        }
//    );
//}

struct User: Codable {
    struct Dob: Codable {
        let age: Int
        let date: Date
    }
    let dob: Dob
    let gender: String
}

struct Results: Codable {
    let results: [User]
}

enum InputViewModelError: Error {
    case internalError
    case inputError(String)
}

extension InputViewModelError: LocalizedError {
    var errorDescription: String? {
        switch self {
        case .internalError:
            return "Internal error"
        case .inputError(let text):
            return "Error in input data (\(text))"
        }
    }
}

class InputViewModel: ServicesViewModel, Stepper {
    typealias Services = HasGiftService
    
    var services: Services! {
        didSet {
            user
                .compactMap { $0 }
                .map { $0.dob.date }
                .bind(to: birthdate)
                .disposed(by: bag)
            
            user
                .compactMap { $0 }
                .map { $0.gender }
                .bind(to: gender)
                .disposed(by: bag)
            
            Observable.combineLatest(birthdate, simulatedDate, gender)
                .debug()
                .bind { [unowned self] in self.prepareGifts($0) }
                .disposed(by: bag)
        }
    }
    
    let steps = PublishRelay<Step>()
    
    lazy var session = URLSession(configuration: .default)
    
    private let user = BehaviorRelay<User?>(value: nil)
    
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
    
    private let bag = DisposeBag()
    
    func randomizeInput() {
        
        let urlString = "https://randomuser.me/api/?inc=gender,dob"
        guard let url = URL(string: urlString) else {
            self.steps.accept(AppStep.alertWithError(InputViewModelError.internalError))
            return
        }
        
        let request = URLRequest(url: url)
        
        self.session.rx.data(request: request)
            .catchError { [unowned self] (error) -> Observable<Data> in
                self.steps.accept(AppStep.alertWithError(error))
                return .empty()
            }
            .flatMapLatest { (data) -> Observable<User> in
                return .create { (observer) -> Disposable in
                    let disposable = Disposables.create()
                    
                    let decoder = JSONDecoder()
                    
                    decoder.dateDecodingStrategy = .custom({ (decoder) -> Date in
                        let container = try decoder.singleValueContainer()
                        let string = try container.decode(String.self)
                        print(string)
                        let formatter = ISO8601DateFormatter()
                        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
                        guard let date = formatter.date(from: string) else {
                            throw DecodingError.dataCorruptedError(in: container, debugDescription: "")
                        }
                        return date
                    })
                    
                    let result = Result {
                        try decoder.decode(Results.self, from: data)
                    }
                    
                    switch result {
                    case .success(let results):
                        guard let user = results.results.first else {
                            observer.onError(InputViewModelError.internalError)
                            return disposable
                        }
                        observer.onNext(user)
                        observer.onCompleted()
                    case .failure(let error):
                        observer.onError(error)
                    }
                    
                    return disposable
                    
                }
            }
            .catchError { (error) -> Observable<User> in
                self.steps.accept(AppStep.alertWithError(error))
                return .empty()
            }
            .bind(to: user)
            .disposed(by: bag)
    }
    
    private func prepareGifts(_ tuple: (Date, Date, String)) {
        let (birthdate, simulatedDate, gender) = tuple
        
        guard let year1 = Calendar.current.dateComponents([.year], from: birthdate).year,
            let year2 = Calendar.current.dateComponents([.year], from: simulatedDate).year, year1 < year2 else {
                steps.accept(AppStep.alertWithError(InputViewModelError.inputError("birthdate is newer than simulatedDate")))
                return
        }
        
        guard let year = Calendar.current.dateComponents([.year], from: simulatedDate).year, !((year % 4 == 0) && (year % 100 != 0) || (year % 400 == 0)) else {
            print("LEAP YEAR!!!")
            
            gifts.accept([.none(.leapYear)])
            return
        }
        
        var gifts: [Gift] = []
        
        let birthdateComponents = Calendar.current.dateComponents([.month, .day], from: birthdate)
        let simulatedComponents = Calendar.current.dateComponents([.month, .day], from: simulatedDate)
        
        if let yrs_7 = Calendar.current.date(byAdding: .year, value: 7, to: birthdate), let yrs_12 = Calendar.current.date(byAdding: .year, value: 12, to: birthdate) {
            
            if (yrs_7 ... yrs_12).contains(simulatedDate) {
                print("CHILD BETWEEN 7-12!!!")
                
                if birthdateComponents == simulatedComponents {
                    print("CHILD BIRTHDAY!!!")
                    gifts.append(.lego)
                }
                
                if simulatedComponents.month == 1 && simulatedComponents.day == 1 {
                    print("CHILD NEW YEAR!!!")
                    gifts.append(.chocolate(size: .big, color: .black))
                    gifts.append(.orange)
                }
            }
        }
        
        if birthdateComponents == simulatedComponents {
            print("EVERYONE BIRTHDAY!!!")
            gifts.append(.book)
        }
        
        if gender == "male", simulatedComponents.month == 2, simulatedComponents.day == 23 {
            print("23 FEBRUARY!!!")
            gifts.append(.socks)
        }
        
        if gender == "female", simulatedComponents.month == 3, simulatedComponents.day == 8 {
            print("8 MARCH!!!")
            gifts.append(.flowers)
        }
        
        self.gifts.accept(gifts)
    }
    
    deinit {
        print("\(type(of: self)): \(#function)")
    }
}
