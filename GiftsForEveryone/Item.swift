//
//  Item.swift
//  GiftsForEveryone
//
//  Created by bezigon on 2/4/20.
//  Copyright © 2020 bezigon. All rights reserved.
//

import Foundation

enum Gift {
    case lego // children 7-12 on birthday
    case chocolate(size: ChocolateSize, color: ChocolateColor) // children 7-12 on new year
    case orange // children 7-12 on new year
    case book // everyone on birthday
    case socks // boys on 23 february
    case flowers // girls on 8 march
    case none(Reason)
}

enum ChocolateSize {
    case big
}

enum ChocolateColor {
    case black
}

enum Reason {
    case leapYear
}
