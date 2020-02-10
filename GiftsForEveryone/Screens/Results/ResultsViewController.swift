//
//  ResultsViewController.swift
//  GiftsForEveryone
//
//  Created by bezigon on 2/4/20.
//  Copyright © 2020 bezigon. All rights reserved.
//

import UIKit
import Reusable
import RxSwift

class ResultsViewController: UIViewController, StoryboardBased, ViewModelBased {
    
    var viewModel: ResultsViewModel!
    
    @IBOutlet var birthdateLabel: UILabel!
    @IBOutlet var genderLabel: UILabel!
    @IBOutlet var simulatedDateLabel: UILabel!
    @IBOutlet var giftsLabel: UILabel!
    
    private let bag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupBindings()
    }
    
    private func setupBindings() {
        viewModel.birthdate
            .map { [unowned self] in self.viewModel.stringFromDate($0) }
            .bind(to: birthdateLabel.rx.text)
            .disposed(by: bag)
        
        viewModel.gender
            .bind(to: genderLabel.rx.text)
            .disposed(by: bag)
        
        viewModel.simulatedDate
            .map { [unowned self] in self.viewModel.stringFromDate($0) }
            .bind(to: simulatedDateLabel.rx.text)
            .disposed(by: bag)
        
        viewModel.gifts
            .map { (gifts) -> [String] in
                return gifts.map { (gift) -> String in
                    switch gift {
                    case .lego:
                        return "lego"
                    case .chocolate:
                        return "chocolate"
                    case .orange:
                        return "orange"
                    case .book:
                        return "book"
                    case .socks:
                        return "socks"
                    case .flowers:
                        return "flowers"
                    case .none(let reason):
                        switch reason {
                        case .leapYear:
                            return "(empty, leap year)"
                        }
                    }
                }
            }
            .map { (gifts) -> String in
                return gifts.count > 0 ? gifts.joined(separator: ", ") : "(empty)"
            }
            .bind(to: giftsLabel.rx.text)
            .disposed(by: bag)
    }
    
    deinit {
        print("\(type(of: self)): \(#function)")
    }
}
