//
//  GiftService.swift
//  GiftsForEveryone
//
//  Created by Vladimir Gonta on 2/8/20.
//  Copyright © 2020 bezigon. All rights reserved.
//

import Foundation
import RxRelay

protocol HasGiftService {
    var giftsService: GiftService { get }
}

class GiftService {
    let birthdate = BehaviorRelay<Date>(value: Date())
    let simulatedDate = BehaviorRelay<Date>(value: Date())
    let gender = BehaviorRelay<String>(value: "male")
    let gifts = BehaviorRelay<[Gift]>(value: [])
}
