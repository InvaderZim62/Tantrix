//
//  TileView.swift
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

import UIKit

class TileView: UIView {
    
    var sideColors = [UIColor]()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        isOpaque = false  // makes background clear, instead of black
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func draw(_ rect: CGRect) {
        drawHexagon()
        drawCurves()
    }
    
    private func drawHexagon() {
        let center = CGPoint(x: bounds.midX, y: bounds.midY)
        let hexagon = UIBezierPath()
        hexagon.move(to: CGPoint(x: center.x + bounds.width / 2 * sin(-30.CGrads),
                                 y: center.y - bounds.width / 2 * cos(-30.CGrads)))
        for angleDegrees in stride(from: 30.0, through: 330.0, by: 60.0) {
            let angleRadians = angleDegrees.CGrads
            hexagon.addLine(to: CGPoint(x: center.x + bounds.width / 2 * sin(angleRadians),
                                        y: center.y - bounds.width / 2 * cos(angleRadians)))
        }
        Constants.tileColor.setFill()
        hexagon.fill()
    }
    
    private func drawCurves() {
        let center = CGPoint(x: bounds.midX, y: bounds.midY)
        let sideRadius = bounds.width / 2 * cos(30.CGrads)  // from center to midpoint of side
        var sideMidPoints = [CGPoint]()
        var controlPoints = [CGPoint]()  // half way between center and sideMidPoints
        for angleDegrees in stride(from: 0.0, through: 320.0, by: 60.0) {
            let angleRadians = angleDegrees.CGrads
            let sideMidPoint = CGPoint(x: center.x + sideRadius * sin(angleRadians),
                                       y: center.y - sideRadius * cos(angleRadians))
            sideMidPoints.append(sideMidPoint)
            let controlPoint = CGPoint(x: center.x + sideRadius / 2 * sin(angleRadians),
                                       y: center.y - sideRadius / 2 * cos(angleRadians))
            controlPoints.append(controlPoint)
        }
        for color in [UIColor.yellow, .blue, .red] {
            let connectingSides = sideColors.indices.filter { sideColors[$0] == color }
            let curve = UIBezierPath()
            curve.move(to: sideMidPoints[connectingSides[0]])
            curve.addCurve(to: sideMidPoints[connectingSides[1]],
                           controlPoint1: controlPoints[connectingSides[0]],
                           controlPoint2: controlPoints[connectingSides[1]])
            curve.lineWidth = bounds.width / 10
            color.setStroke()
            curve.stroke()
        }
    }
}