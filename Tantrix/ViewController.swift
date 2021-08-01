//
//  ViewController.swift
//  Tantrix
//
//  Created by Phil Stern on 7/31/21.
//

import UIKit

struct Constants {
    static let tileColor = #colorLiteral(red: 0.2745098174, green: 0.4862745106, blue: 0.1411764771, alpha: 1)
}

class ViewController: UIViewController {

    let tiles: [Tile<UIColor>] = [
        Tile(number: 1, loopColor: .yellow, sideColors: [.blue, .red, .yellow, .yellow, .blue, .red]),
        Tile(number: 2, loopColor: .yellow, sideColors: [.yellow, .blue, .red, .red, .blue, .yellow]),
        Tile(number: 3, loopColor: .yellow, sideColors: [.blue, .yellow, .yellow, .red, .red, .blue]),
        Tile(number: 4, loopColor: .red, sideColors: [.red, .blue, .red, .yellow, .blue, .yellow]),
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidLayoutSubviews() {
        for index in 0..<4 {
            addTileView(index: index)
        }
    }
    
    private func addTileView(index: Int) {
        let frame = CGRect(x: 100, y: 100 * Double(index + 1), width: 100, height: 100 * cos(30.0 * .pi / 180))
        let tileView = TileView(frame: frame)
        tileView.sideColors = tiles[index].sideColors
        view.addSubview(tileView)
    }
}

