//
//  ViewController.swift
//  Tantrix
//
//  Created by Phil Stern on 7/31/21.
//

import UIKit

struct Constants {
    static let tileWidth = 130.0
    static let tileColor = #colorLiteral(red: 0, green: 0.5628422499, blue: 0.3188166618, alpha: 1)
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
        Tile(number: 1, backColor: .yellow, sideColors: [.blue, .red, .yellow, .yellow, .blue, .red]),  // colors clockwise from top
        Tile(number: 2, backColor: .yellow, sideColors: [.yellow, .blue, .red, .red, .blue, .yellow]),
        Tile(number: 3, backColor: .yellow, sideColors: [.blue, .yellow, .yellow, .red, .red, .blue]),
        Tile(number: 4, backColor: .red, sideColors: [.red, .blue, .red, .yellow, .blue, .yellow]),
        Tile(number: 5, backColor: .red, sideColors: [.yellow, .red, .blue, .blue, .red, .yellow]),
        Tile(number: 6, backColor: .blue, sideColors: [.blue, .yellow, .blue, .red, .yellow, .red]),
        Tile(number: 7, backColor: .red, sideColors: [.yellow, .red, .blue, .blue, .yellow, .red]),
        Tile(number: 8, backColor: .blue, sideColors: [.red, .yellow, .blue, .blue, .red, .yellow]),
        Tile(number: 9, backColor: .yellow, sideColors: [.blue, .red, .blue, .yellow, .red, .yellow]),
        Tile(number: 10, backColor: .blue, sideColors: [.red, .blue, .yellow, .yellow, .red, .blue])
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        for index in 0..<10 {
            addTileView(index: index)
        }
    }
    
    // create tile using the colors from tiles[index] and place left to right, top to bottom
    private func addTileView(index: Int) {
        let col = index % 2 == 0 ? 0 : 1  // even: 0, odd: 1
        let row = Int(Double(index) / 2)
        let frame = CGRect(x: 50 + Double(160 * col), y: 40 + Double(120 * row), width: Constants.tileWidth, height: Constants.tileWidth * cos(30.rads))
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

