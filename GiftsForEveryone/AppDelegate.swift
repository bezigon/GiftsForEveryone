//
//  AppDelegate.swift
//  GiftsForEveryone
//
//  Created by bezigon on 2/3/20.
//  Copyright © 2020 bezigon. All rights reserved.
//

import UIKit
import RxSwift
import RxFlow


@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    
    private let coordinator = FlowCoordinator()
    
    private lazy var appServices = AppServices(giftsService: GiftService())
    
    private let bag = DisposeBag()

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        guard let window = self.window else { return false }
        
        coordinator.rx.willNavigate
            .catchError { _ in .empty() }
            .bind { (flow, step) in print("will navigate to flow=\(flow) and step=\(step)") }
            .disposed(by: bag)
        
        let appFlow = AppFlow(services: appServices)
        
        Flows.whenReady(flow1: appFlow) { (root) in
            window.rootViewController = root
            window.makeKeyAndVisible()
        }
        
        coordinator.coordinate(flow: appFlow, with: AppStepper())
        
        return true
    }
    
}

struct AppServices: HasGiftService {
    let giftsService: GiftService
}
