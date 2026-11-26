//
//  Number+Ext.swift
//  BaseSwiftUI
//
//  Created by Vu The Anh on 24/4/26.
//

import CoreFoundation

extension Double {
    var cgFloat: CGFloat {
        get {
            return CGFloat(self)
        }
    }
    
    func roundTo(places: Double) -> Double {
        let divisor = pow(10.0, places)
        return (self * divisor).rounded() / divisor
    }
}
