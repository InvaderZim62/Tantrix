//
//  Extensions.swift
//  Tantrix
//
//  Created by Phil Stern on 7/31/21.
//

import UIKit

extension CGFloat {
    var rads: CGFloat {
        return self * .pi / 180
    }
    
    var degs: CGFloat {
        return self * 180 / .pi
    }
}

extension Double {
    var rads: Double {
        return self * .pi / 180
    }
    
    var degs: Double {
        return self * 180 / .pi
    }
    
    var CGrads: CGFloat {
        return CGFloat(self * .pi / 180)
    }
    
    var CGdegs: CGFloat {
        return CGFloat(self * 180 / .pi)
    }
}
