//
//  AppFlow.swift
//  GiftsForEveryone
//
//  Created by bezigon on 2/3/20.
//  Copyright © 2020 bezigon. All rights reserved.
//

import Foundation
import RxRelay
import RxFlow

enum AppStep: Step {
    case inputScreenIsRequired
    case resultsScreenIsRequired
    case resultsScreenIsDone
    case alertWithError(Error)
}

class AppStepper: Stepper {
    let steps = PublishRelay<Step>()
    
    var initialStep: Step {
        return AppStep.inputScreenIsRequired
    }
}

class AppFlow {
    private lazy var rootViewController: UINavigationController = {
        let viewController = UINavigationController()
//        viewController.setNavigationBarHidden(true, animated: false)
        return viewController
    }()
    
    private let services: AppServices
    
    init(services: AppServices) {
        self.services = services
    }
    
    deinit {
        print("\(type(of: self)): \(#function)")
    }
}

extension AppFlow: Flow {
    var root: Presentable {
        return rootViewController
    }
    
    func navigate(to step: Step) -> FlowContributors {
        guard let step = step as? AppStep else { return .none }
        switch step {
        case .inputScreenIsRequired:
            return navigateToInputScreen()
        case .resultsScreenIsRequired:
            return navigateToResultsScreen()
        case .alertWithError(let error):
            return presentAlertWithError(error)
        default:
            return .none
        }
    }
    
    private func navigateToInputScreen() -> FlowContributors {
        let viewModel = InputViewModel()
        let viewController = InputViewController.instantiate(withViewModel: viewModel, andServices: services)
        
        viewController.title = "Input"
        
        rootViewController.pushViewController(viewController, animated: true)
        
        return .one(flowContributor: .contribute(withNextPresentable: viewController, withNextStepper: viewModel))
    }
    
    private func navigateToResultsScreen() -> FlowContributors {
        let viewModel = ResultsViewModel()
        let viewController = ResultsViewController.instantiate(withViewModel: viewModel, andServices: services)
        
        viewController.title = "Results"
        
        rootViewController.pushViewController(viewController, animated: true)
        
        return .one(flowContributor: .contribute(withNextPresentable: viewController, withNextStepper: viewModel))
    }
    
    private func presentAlertWithError(_ error: Error)  -> FlowContributors {
        let viewController = UIAlertController(title: nil,
                                               message: error.localizedDescription,
                                               preferredStyle: .alert)
        
        let dismissAction = UIAlertAction(title: "Dismiss", style: .cancel, handler: nil)
        viewController.addAction(dismissAction)
        
        rootViewController.present(viewController, animated: true, completion: nil)
        
        return .none
    }
}
