//
//  ViewController.swift
//  Tantrix
//
//  Created by Phil Stern on 7/31/21.
//
//  To do...
//  - have tile snap to nearest position/angle when done panning/rotating
//

import UIKit

struct Constants {
    static let tileBackgroundColor = #colorLiteral(red: 0, green: 0.5628422499, blue: 0.3188166618, alpha: 1)
    static let tileOutlineWidth: CGFloat = 1.0
    static let leftTileOffset: CGFloat = 20  // starting space between left tip of tile and left side of screen
    static let topTileOffset: CGFloat = 20  // starting space between top of tile and top of screen
    static let panningDeadband: CGFloat = 20.0  // how close before panning snaps into place, in points
    static let rotationDeadband = 14.CGrads  // how close before rotating snaps into place, in radians (CGFloat)
}

class ViewController: UIViewController {

    var tileWidth: CGFloat = 0.0
    var continuousAngle: CGFloat = 0.0
    var tileViews = [TileView]()

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
    
    var numberOfTilesInPlay = 4 {
        didSet {
            numberOfTilesLabel.text = "\(numberOfTilesInPlay)"
            let goalString = "Goal: Form a single \(loopColor.name!) loop"
            let range = (goalString as NSString).range(of: loopColor.name!)
            let attributedString = NSMutableAttributedString.init(string: goalString)
            attributedString.addAttribute(.foregroundColor, value: loopColor == .blue ? UIColor.white : .black, range: range)
            attributedString.addAttribute(.backgroundColor, value: loopColor, range: range)
            goalLabel.attributedText = attributedString
            resetTileViews()
        }
    }
    
    // MARK: - Computed properties
    
    var loopColor: UIColor {
        return tiles[numberOfTilesInPlay - 1].backColor  // loop color is back color of highest numbered tile in play
    }
    
    var tileHeight: CGFloat {
        return tileWidth * cos(30.CGrads)
    }
    
    var touchingTileDistance: CGFloat {  // distance between centers
        return tileHeight
    }
    
    // MARK: - Outlets

    @IBOutlet weak var stepper: UIStepper!  // select number of tiles
    @IBOutlet weak var numberOfTilesLabel: UILabel!
    @IBOutlet weak var goalLabel: UILabel!
    @IBOutlet weak var puzzleCompleteButton: UIButton!
    
    // MARK: - Start of code
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tileWidth = 0.15 * view.bounds.width + 64
        numberOfTilesInPlay = 4
        stepper.value = Double(numberOfTilesInPlay)
        resetTileViews()
    }
    
    private func resetTileViews() {
        puzzleCompleteButton.isHidden = true
        tileViews.forEach { $0.removeFromSuperview() }
        tileViews.removeAll()
        for index in 0..<numberOfTilesInPlay {
            addTileView(index: index)
        }
    }
    
    // create tile using the colors from tiles[index] and place left to right, top to bottom
    private func addTileView(index: Int) {
        let col = index.isEven ? -1 : 1
        let row = Int(Double(index) / 2)
        let topSpace: CGFloat = 40
        let heightOver5 = (view.bounds.height - topSpace) / 5.6
        let tileView = TileView(frame: CGRect(x: 0, y: 0, width: tileWidth, height: tileHeight))
        tileView.center = CGPoint(x: view.bounds.midX + (tileWidth / 2 + 20) * CGFloat(col),
                                  y: topSpace + heightOver5 * CGFloat(row + 1))
        tileView.sideColors = tiles[index].sideColors
        let pan = UIPanGestureRecognizer(target: self, action: #selector(handlePan))
        tileView.addGestureRecognizer(pan)
        let rotate = UIRotationGestureRecognizer(target: self, action: #selector(handleRotate))
        tileView.addGestureRecognizer(rotate)
        tileViews.append(tileView)
        view.addSubview(tileView)
    }
    
    // snap tile view position to even tile-spacing increments when within panningDeadband
    @objc func handlePan(recognizer: UIPanGestureRecognizer) {
        if let tileView = recognizer.view as? TileView{
            switch recognizer.state {
            case .began:
                puzzleCompleteButton.isHidden = true
                view.bringSubviewToFront(tileView)
            case .changed:
                // snap x position
                let continuousX = recognizer.location(in: view).x
                let quarterWidth = tileView.bounds.width / 4
                let snappedX = snap(continuousX, to: 3 * quarterWidth, deadband: Constants.panningDeadband, offset: 2 * quarterWidth + Constants.leftTileOffset)
                tileView.center.x = snappedX
                // snap y position
                let continuousY = recognizer.location(in: view).y
                let halfHeight = tileView.bounds.height / 2
                let snappedY = snap(continuousY, to: halfHeight, deadband: Constants.panningDeadband, offset: halfHeight + Constants.topTileOffset)
                tileView.center.y = snappedY
            case .ended:
                // when done moving, snap to nearest point by setting deadband = half range
                // snap x position
                let continuousX = recognizer.location(in: view).x
                let quarterWidth = tileView.bounds.width / 4
                let snappedX = snap(continuousX, to: 3 * quarterWidth, deadband: 3 * quarterWidth / 2, offset: 2 * quarterWidth + Constants.leftTileOffset)
                tileView.center.x = snappedX
                // snap y position
                let continuousY = recognizer.location(in: view).y
                let halfHeight = tileView.bounds.height / 2
                let snappedY = snap(continuousY, to: halfHeight, deadband: halfHeight / 2, offset: halfHeight + Constants.topTileOffset)
                tileView.center.y = snappedY
                
                if isPuzzleComplete() {
                    puzzleCompleteButton.isHidden = false
                    view.bringSubviewToFront(puzzleCompleteButton)
                }
            default:
                break
            }
        }
    }
    
    // snap tile view rotation to 60 degree increments when within rotationDeadband
    @objc func handleRotate(recognizer: UIRotationGestureRecognizer) {
        if let tileView = recognizer.view as? TileView {
            switch recognizer.state {
            case .began:
                puzzleCompleteButton.isHidden = true
                view.bringSubviewToFront(tileView)
                continuousAngle = tileView.angle
            case .changed:
                continuousAngle += recognizer.rotation
                let snappedAngle = snap(continuousAngle, to: 60.CGrads, deadband: Constants.rotationDeadband, offset: 0)
                tileView.transform = CGAffineTransform(rotationAngle: snappedAngle)
                recognizer.rotation = 0  // reset, to use incremental rotations
            case .ended:
                // when done moving, snap to nearest angle by setting deadband = half range
                continuousAngle += recognizer.rotation
                let snappedAngle = snap(continuousAngle, to: 60.CGrads, deadband: 30.CGrads, offset: 0)
                tileView.transform = CGAffineTransform(rotationAngle: snappedAngle)
                
                if isPuzzleComplete() {
                    puzzleCompleteButton.isHidden = false
                    view.bringSubviewToFront(puzzleCompleteButton)
                }
            default:
                break
            }
        }
    }
    
    private func snap(_ value: CGFloat, to range: CGFloat, deadband: CGFloat, offset: CGFloat) -> CGFloat {
        var snappedValue = value
        let wrap = (value - offset).truncatingRemainder(dividingBy: range)  // modulo range
        if abs(wrap) < deadband {
            snappedValue -= wrap
        } else if abs(wrap) > range - deadband {
            snappedValue += (value - offset < 0 ? -1 : 1) * range - wrap
        }
        return snappedValue
    }
    
    // puzzle is complete if loop color can be traced through all adjecent tileViews
    private func isPuzzleComplete() -> Bool {
        var tilesChecked = 0
        var testTileView = tileViews[0]
        var pastLoopColorSide = 0
        repeat {
            let testTileLoopColorSides = testTileView.rotatedSideColors.indices.filter { testTileView.rotatedSideColors[$0] == loopColor }
            let loopColorSide = testTileLoopColorSides[0] == pastLoopColorSide ? testTileLoopColorSides[1] : testTileLoopColorSides[0]
            let sideAngle = CGFloat(Tile<Any>.angleOf(side: loopColorSide))  // radians
            let neighboringCenter = testTileView.center + CGPoint(x: touchingTileDistance * sin(sideAngle),
                                                                  y: -touchingTileDistance * cos(sideAngle))
            let neighboringTileView = tileViews.filter {
                abs($0.center.x - neighboringCenter.x) < Constants.panningDeadband / 2 &&
                abs($0.center.y - neighboringCenter.y) < Constants.panningDeadband / 2
            }.first
            if let neighboringTileView = neighboringTileView, neighboringTileView.rotatedSideColors[Tile<Any>.oppositeSide(loopColorSide)] == loopColor {
                testTileView = neighboringTileView
                pastLoopColorSide = Tile<Any>.oppositeSide(loopColorSide)
                tilesChecked += 1
            } else {
                break
            }
        } while testTileView != tileViews[0]
        
        return tilesChecked == numberOfTilesInPlay
    }
    
    // MARK: - Actions
    
    @IBAction func stepperChanged(_ sender: UIStepper) {
        numberOfTilesInPlay = Int(sender.value)
    }
    
    @IBAction func puzzleCompleteButtonPressed(_ sender: UIButton) {
        puzzleCompleteButton.isHidden = true
    }
}
