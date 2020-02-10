//
//  ViewModel+Extensions.swift
//  GiftsForEveryone
//
//  Created by bezigon on 2/3/20.
//  Copyright © 2020 bezigon. All rights reserved.
//

import Foundation
import Reusable

/// General protocol for View Model.
protocol ViewModel {
}

/// A protocol expanding ViewModel protocol.
///
/// Used to inject `services`.
protocol ServicesViewModel: ViewModel {
    
    associatedtype Services
    
    var services: Services! { get set }
}

/// A protocol for Views.
///
/// Used to inject `viewModel`.
protocol ViewModelBased: class {
    
    associatedtype ViewModelType: ViewModel
    
    var viewModel: ViewModelType! { get set }
}

extension ViewModelBased where Self: StoryboardBased & UIViewController {
    
    static func instantiate<ViewModelType>(withViewModel viewModel: ViewModelType) -> Self where ViewModelType == Self.ViewModelType {
        let viewController = Self.instantiate()
        viewController.viewModel = viewModel
        return viewController
    }
}

extension ViewModelBased where Self: StoryboardBased & UIViewController, ViewModelType: ServicesViewModel {
    
    static func instantiate<ViewModelType, ServicesType>(withViewModel viewModel: ViewModelType, andServices services: ServicesType) -> Self
        where ViewModelType == Self.ViewModelType, ServicesType == Self.ViewModelType.Services {
            let viewController = Self.instantiate()
            viewController.viewModel = viewModel
            viewController.viewModel.services = services
            return viewController
    }
}
