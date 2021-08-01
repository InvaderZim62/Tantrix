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
    var loopColor: Color
    var sideColors: [Color]
}
