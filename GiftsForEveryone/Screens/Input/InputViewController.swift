//
//  InputViewController.swift
//  GiftsForEveryone
//
//  Created by bezigon on 2/3/20.
//  Copyright © 2020 bezigon. All rights reserved.
//

import UIKit
import Reusable
import RxSwift
import RxCocoa

class InputViewController: UIViewController, StoryboardBased, ViewModelBased {
    
    var viewModel: InputViewModel!
    
    @IBOutlet var birthdatePicker: UIDatePicker!
    @IBOutlet var genderLabel: UILabel!
    @IBOutlet var genderSegmentedControl: UISegmentedControl!
    @IBOutlet var simulatedDatePicker: UIDatePicker!
    @IBOutlet var randomizeInputButton: UIButton!
    @IBOutlet var receiveButton: UIButton!
    
    private let bag = DisposeBag()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupBindings()
        
        randomizeInputButton.sendActions(for: .touchUpInside)
    }
    
    private func setupBindings() {
        
        viewModel.birthdate
            .bind(to: birthdatePicker.rx.date)
            .disposed(by: bag)
        
        viewModel.gender
            .bind(to: genderLabel.rx.text)
            .disposed(by: bag)
        
        viewModel.gender
            .map({ (gender) -> Int in
                switch gender {
                case "male":
                    return 0
                case "female":
                    return 1
                default:
                    fatalError()
                }
            })
            .bind(to: genderSegmentedControl.rx.value)
            .disposed(by: bag)
        
        birthdatePicker.rx.date
            .bind(to: viewModel.birthdate)
            .disposed(by: bag)
        
        simulatedDatePicker.rx.date
            .bind(to: viewModel.simulatedDate)
            .disposed(by: bag)
        
        genderSegmentedControl.rx.value
            .map { (value) -> String in
                switch value {
                case 0:
                    return "male"
                case 1:
                    return "female"
                default:
                    fatalError()
                }
            }
            .bind(to: viewModel.gender)
            .disposed(by: bag)
        
        randomizeInputButton.rx.tap
            .bind { [unowned self] in self.viewModel.randomizeInput() }
            .disposed(by: bag)
        
        receiveButton.rx.tap
            .map { AppStep.resultsScreenIsRequired }
            .bind(to: viewModel.steps)
            .disposed(by: bag)
    }
    
    deinit {
        print("\(type(of: self)): \(#function)")
    }

}
