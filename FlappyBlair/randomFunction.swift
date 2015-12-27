//
//  randomFunction.swift
//  FlappyBlair
//
//  Created by Suyaib Ahmed on 12/19/15.
//  Copyright © 2015 MBHS Smartphone Programming Club. All rights reserved.
//

import Foundation
import CoreGraphics

public extension CGFloat{
    
    public static func random()->CGFloat{
        
        return CGFloat(Float(arc4random()) / 0xFFFFFFFF)
        
    }
    public static func random(min min : CGFloat, max : CGFloat) -> CGFloat{
        
        return CGFloat.random() * (max - min) + min
        
    }
}