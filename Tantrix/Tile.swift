//
//  Tile.swift
//  Tantrix
//
//  Created by Phil Stern on 7/31/21.
//
//  sideColors:
//      _0_
//   5 /   \ 1
//   4 \___/ 2
//       3
//

import Foundation

struct Tile<Color> {
    var number: Int  // tile number
    var backColor: Color
    var sideColors: [Color]
    
    static func angleOf(side: Int) -> Double {  // returns angle in radians
        return 60.rads * Double(side)
    }
    
    static func oppositeSide(_ side: Int) -> Int {
        return (side + 3) % 6
    }
}
