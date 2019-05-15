//
//  RandomFunction.swift
//  Trevor
//
//  Created by Thomas Perritt on 19/12/2018.
//  Copyright © 2018 Thomas Perritt. All rights reserved.
//

import Foundation
import CoreGraphics

public extension CGFloat{
    
    static func random() -> CGFloat{
        return CGFloat(Float(arc4random()) / 0xFFFFFFFF)
    }
    static func random(min : CGFloat, max : CGFloat) -> CGFloat{
        return CGFloat.random() * (max - min) + min
    }
}

public extension Int{
    
    static func random() -> Int{
        return Int(round(Float(arc4random()) / 0xFFFFFFFF))
    }
    static func random(min : Int, max : Int) -> Int{
        return Int.random() * (max - min) + min
    }
}
