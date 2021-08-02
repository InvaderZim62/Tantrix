//
//  ViewController.swift
//  Tantrix
//
//  Created by Phil Stern on 7/31/21.
//

import UIKit

struct Constants {
    static let tileWidth = 130.0
    static let tileColor = #colorLiteral(red: 0.2745098174, green: 0.4862745106, blue: 0.1411764771, alpha: 1)
    static let rotationDeadband = 10.CGrads  // 10 degrees in radians (CGFloat)
}

class ViewController: UIViewController {

    var continuousAngle: CGFloat = 0.0
    
    let tiles: [Tile<UIColor>] = [
        Tile(number: 1, loopColor: .yellow, sideColors: [.blue, .red, .yellow, .yellow, .blue, .red]),
        Tile(number: 2, loopColor: .yellow, sideColors: [.yellow, .blue, .red, .red, .blue, .yellow]),
        Tile(number: 3, loopColor: .yellow, sideColors: [.blue, .yellow, .yellow, .red, .red, .blue]),
        Tile(number: 4, loopColor: .red, sideColors: [.red, .blue, .red, .yellow, .blue, .yellow]),
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        for index in 0..<4 {
            addTileView(index: index)
        }
    }
    
    // for now, this just creates a tile using the colors from tiles[index] and
    // places it tileWidth * (index + 1) pixels from top of screen
    private func addTileView(index: Int) {
        let frame = CGRect(x: 100, y: Constants.tileWidth * Double(index + 1), width: Constants.tileWidth, height: Constants.tileWidth * cos(30.rads))
        let tileView = TileView(frame: frame)
        tileView.sideColors = tiles[index].sideColors
        let rotate = UIRotationGestureRecognizer(target: self, action: #selector(handleRotate))
        tileView.addGestureRecognizer(rotate)
        view.addSubview(tileView)
    }
    
    // snap tile view rotation to 60 degree increments when with rotationDeadband of 60 degrees
    @objc func handleRotate(recognizer: UIRotationGestureRecognizer) {
        if let tileView = recognizer.view {
            if recognizer.state == .began {
                continuousAngle = atan2(tileView.transform.b, tileView.transform.a)  // current tileView angle
            }
            continuousAngle += recognizer.rotation
            var snappedAngle = continuousAngle
            let wrap60 = continuousAngle.truncatingRemainder(dividingBy: 60.CGrads)
            if abs(wrap60) < Constants.rotationDeadband {
                snappedAngle -= wrap60
            } else if abs(wrap60) > 60.CGrads - Constants.rotationDeadband {
                snappedAngle += (continuousAngle < 0 ? -1 : 1) * 60.CGrads - wrap60
            }
            tileView.transform = CGAffineTransform(rotationAngle: snappedAngle)
            recognizer.rotation = 0  // reset, to use incremental rotations
        }
    }
}

