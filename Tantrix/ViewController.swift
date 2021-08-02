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
    static let leftTileOffset: CGFloat = 20  // space between left tip of tile and left side of screen
    static let topTileOffset: CGFloat = 20  // space between top of tile and top of screen
    static let panningDeadband: CGFloat = 20.0  // how close before panning snaps into place in points
    static let rotationDeadband = 10.CGrads  // how close before rotating snaps into place in radians (CGFloat)
}

class ViewController: UIViewController {

    var continuousAngle: CGFloat = 0.0
    var continuousX: CGFloat = 0.0
    var continuousY: CGFloat = 0.0

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
        let pan = UIPanGestureRecognizer(target: self, action: #selector(handlePan))
        tileView.addGestureRecognizer(pan)
        let rotate = UIRotationGestureRecognizer(target: self, action: #selector(handleRotate))
        tileView.addGestureRecognizer(rotate)
        view.addSubview(tileView)
    }
    
    // snap tile view position to even tile-spacing increments when with panningDeadband
    @objc func handlePan(recognizer: UIPanGestureRecognizer) {
        if let tileView = recognizer.view {
            if recognizer.state == .began {
                continuousX = tileView.center.x
                continuousY = tileView.center.y
            }
            // snap x position
            continuousX = recognizer.location(in: view).x
            let quarterWidth = tileView.bounds.width / 4
            let snappedX = snap(continuousX, to: 3 * quarterWidth, deadband: Constants.panningDeadband, offset: 2 * quarterWidth + Constants.leftTileOffset)
            tileView.center.x = snappedX
            // snap y position
            continuousY = recognizer.location(in: view).y
            let halfHeight = tileView.bounds.height / 2
            let snappedY = snap(continuousY, to: halfHeight, deadband: Constants.panningDeadband, offset: halfHeight + Constants.topTileOffset)
            tileView.center.y = snappedY
        }
    }
    
    // snap tile view rotation to 60 degree increments when with rotationDeadband
    @objc func handleRotate(recognizer: UIRotationGestureRecognizer) {
        if let tileView = recognizer.view {
            if recognizer.state == .began {
                continuousAngle = atan2(tileView.transform.b, tileView.transform.a)  // current tileView angle
            }
            continuousAngle += recognizer.rotation
            let snappedAngle = snap(continuousAngle, to: 60.CGrads, deadband: Constants.rotationDeadband, offset: 0)
            tileView.transform = CGAffineTransform(rotationAngle: snappedAngle)
            recognizer.rotation = 0  // reset, to use incremental rotations
        }
    }
    
    private func snap(_ property: CGFloat, to range: CGFloat, deadband: CGFloat, offset: CGFloat) -> CGFloat {
        var snappedProperty = property
        let wrap = (property - offset).truncatingRemainder(dividingBy: range)
        if abs(wrap) < deadband {
            snappedProperty -= wrap
        } else if abs(wrap) > range - deadband {
            snappedProperty += (property - offset < 0 ? -1 : 1) * range - wrap
        }
        return snappedProperty
    }
}

