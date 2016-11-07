//
//  DrawView.swift
//  TouchTracker
//
//  Created by Andy Wong on 11/6/16.
//  Copyright © 2016 Big Nerd Ranch. All rights reserved.
//

import UIKit

class DrawView: UIView {
    var currentLines = [NSValue: Line]()
    var finishedLines = [Line]()

    var currentCircle: Circle?
    var finishedCircles = [Circle]()

    @IBInspectable var finishedLineColor: UIColor = UIColor.black {
        didSet {
            setNeedsDisplay()
        }
    }

    @IBInspectable var currentLineColor: UIColor = UIColor.red {
        didSet {
            setNeedsDisplay()
        }
    }

    @IBInspectable var lineThickness: CGFloat = 10 {
        didSet {
            setNeedsDisplay()
        }
    }

    func strokeLine(_ line: Line) {
        let path = UIBezierPath()
        path.lineWidth = lineThickness
        path.lineCapStyle = .round

        path.move(to: line.begin)
        path.addLine(to: line.end)
        path.stroke()
    }

    func strokeCircle(_ circle: Circle) {
        let path = UIBezierPath(arcCenter: circle.center, radius: circle.radius, startAngle: 0, endAngle: CGFloat(2 * M_PI), clockwise: true)
        path.lineWidth = lineThickness
        path.stroke()
    }

    override func draw(_ rect: CGRect) {
        for line in finishedLines {
            let radians = atan2(abs(line.end.y - line.begin.y),
                                abs(line.end.x - line.begin.x))
            let degrees = radians * 180 / CGFloat(M_PI)

            UIColor(red: degrees / 45,
                    green: degrees / 90,
                    blue: 1 - degrees / 135,
                    alpha: 1.0).setStroke()

            strokeLine(line)
        }

        finishedLineColor.setStroke()
        for circle in finishedCircles {
            strokeCircle(circle)
        }

        currentLineColor.setStroke()
        for (_, line) in currentLines {
            strokeLine(line)
        }

        if let circle = currentCircle {
            strokeCircle(circle)
        }
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if touches.count == 2 {
            let touchesArray = Array(touches)
            let begin = touchesArray[0].location(in: self)
            let end = touchesArray[1].location(in: self)
            
            let center = CGPoint(x: (begin.x + end.x) / 2, y: (begin.y + end.y) / 2)
            let radius = hypot(abs(begin.x - end.x), abs(begin.y - end.y))
            
            let newCircle = Circle(center: center, radius: radius)
            currentCircle = newCircle
        } else {
            for touch in touches {
                let location = touch.location(in: self)
                let newLine = Line(begin: location, end: location)
                let key = NSValue(nonretainedObject: touch)
                
                currentLines[key] = newLine
            }
        }

        setNeedsDisplay()
    }

    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        if touches.count == 2 {
            let touchesArray = Array(touches)
            let begin = touchesArray[0].location(in: self)
            let end = touchesArray[1].location(in: self)

            let radius = hypot(abs(begin.x - end.x), abs(begin.y - end.y))
            
            currentCircle?.radius = radius
        } else {
            for touch in touches {
                let key = NSValue(nonretainedObject: touch)
                currentLines[key]?.end = touch.location(in: self)
            }
        }

        setNeedsDisplay()
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        if touches.count == 2 {
            if var circle = currentCircle {
                let touchesArray = Array(touches)
                let begin = touchesArray[0].location(in: self)
                let end = touchesArray[1].location(in: self)
                
                let radius = hypot(abs(begin.x - end.x), abs(begin.y - end.y))
                circle.radius = radius

                finishedCircles.append(circle)
                currentCircle = nil
            }
        } else {
            for touch in touches {
                let key = NSValue(nonretainedObject: touch)
                if var line = currentLines[key] {
                    line.end = touch.location(in: self)
                    
                    finishedLines.append(line)
                    currentLines.removeValue(forKey: key)
                }
            }
        }

        setNeedsDisplay()
    }

    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        currentLines.removeAll()
        currentCircle = nil

        setNeedsDisplay()
    }
}
