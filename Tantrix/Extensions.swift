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

// from: https://stackoverflow.com/questions/44672594
// usage: print(UIColor.red.name)
extension UIColor {
    var name: String? {
        switch self {
        case UIColor.black: return "black"
        case UIColor.darkGray: return "dark gray"
        case UIColor.lightGray: return "light gray"
        case UIColor.white: return "white"
        case UIColor.gray: return "gray"
        case UIColor.red: return "red"
        case UIColor.green: return "green"
        case UIColor.blue: return "blue"
        case UIColor.cyan: return "cyan"
        case UIColor.yellow: return "yellow"
        case UIColor.magenta: return "magenta"
        case UIColor.orange: return "orange"
        case UIColor.purple: return "purple"
        case UIColor.brown: return "brown"
        default: return nil
        }
    }
}
