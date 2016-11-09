//
//  DrawView.swift
//  TouchTracker
//
//  Created by Andy Wong on 11/6/16.
//  Copyright © 2016 Big Nerd Ranch. All rights reserved.
//

import UIKit

class DrawView: UIView, UIGestureRecognizerDelegate {
    var currentLines = [NSValue: Line]()
    var finishedLines = [Line]()
    var selectedLineIndex: Int? {
        didSet {
            if selectedLineIndex == nil {
                let menu = UIMenuController.shared
                menu.setMenuVisible(false, animated: true)
            }
        }
    }

    var moveRecognizer: UIPanGestureRecognizer!

    var currentCircle: Circle?
    var finishedCircles = [Circle]()

    var permanentLineColor: UIColor?

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

    override var canBecomeFirstResponder: Bool { return true }

    func indexOfLineAtPoint(_ point: CGPoint) -> Int? {
        for (index, line) in finishedLines.enumerated() {
            let begin = line.begin
            let end = line.end

            for t in stride(from: 0 as CGFloat, to: 1.0, by: 0.05) {
                let x = begin.x + ((end.x - begin.x) * t)
                let y = begin.y + ((end.y - begin.y) * t)

                if hypot(x - point.x, y - point.y) < 20.0 {
                    return index
                }
            }
        }

        return nil
    }

    func deleteLine(_ sender: AnyObject) {
        if let index = selectedLineIndex {
            finishedLines.remove(at: index)
            selectedLineIndex = nil

            setNeedsDisplay()
        }
    }

    func doubleTap(_ gestureRecognizer: UIGestureRecognizer) {
        selectedLineIndex = nil

        currentLines.removeAll(keepingCapacity: false)
        finishedLines.removeAll(keepingCapacity: false)
        setNeedsDisplay()
    }

    func tap(_ gestureRecognizer: UIGestureRecognizer) {
        let point = gestureRecognizer.location(in: self)
        selectedLineIndex = indexOfLineAtPoint(point)

        let menu = UIMenuController.shared

        if selectedLineIndex != nil {
            becomeFirstResponder()

            let deleteItem = UIMenuItem(title: "Delete", action: #selector(DrawView.deleteLine(_:)))
            menu.menuItems = [deleteItem]

            menu.setTargetRect(CGRect(x: point.x, y: point.y, width: 2, height: 2), in: self)
            menu.setMenuVisible(true, animated: true)
        } else {
            menu.setMenuVisible(false, animated: true)
        }

        setNeedsDisplay()
    }

    func longPress(_ gestureRecognizer: UIGestureRecognizer) {
        if gestureRecognizer.state == .began {
            let point = gestureRecognizer.location(in: self)
            selectedLineIndex = indexOfLineAtPoint(point)

            if selectedLineIndex != nil {
                currentLines.removeAll(keepingCapacity: false)
            }
        } else if gestureRecognizer.state == .ended {
            selectedLineIndex = nil
        }

        setNeedsDisplay()
    }

    func moveLine(_ gestureRecognizer: UIPanGestureRecognizer) {
        if let index = selectedLineIndex, index != indexOfLineAtPoint(gestureRecognizer.location(in: self)) {
            if gestureRecognizer.state == .began {
                selectedLineIndex = nil
            }
        }

        if let index = selectedLineIndex {
            if gestureRecognizer.state == .changed {
                let translation = gestureRecognizer.translation(in: self)

                finishedLines[index].begin.x += translation.x
                finishedLines[index].begin.y += translation.y
                finishedLines[index].end.x += translation.x
                finishedLines[index].end.y += translation.y

                gestureRecognizer.setTranslation(.zero, in: self)

                setNeedsDisplay()
            }
        } else {
            let velocity = gestureRecognizer.velocity(in: self)
            let speed = hypot(abs(velocity.x), abs(velocity.y))
            lineThickness = sqrt(speed)
            return
        }
    }

    func updateFinishedLineColor(_ button: UIButton) {
        permanentLineColor = button.backgroundColor!
        (button.superview as! UIStackView).removeFromSuperview()
    }

    func showColorPalette(_ gestureRecognizer: UISwipeGestureRecognizer) {
        let colors: [UIColor] = [.red, .blue, .green]
        let colorPalette = UIStackView()
        colorPalette.axis = .horizontal
        colorPalette.alignment = .fill
        colorPalette.distribution = .fillEqually
        colorPalette.spacing = 5
        colorPalette.translatesAutoresizingMaskIntoConstraints = false

        for color in colors {
            let button = UIButton()
            button.backgroundColor = color
            button.addTarget(self, action: #selector(DrawView.updateFinishedLineColor(_:)), for: .touchUpInside)
            colorPalette.addArrangedSubview(button)
        }

        addSubview(colorPalette)
        colorPalette.heightAnchor.constraint(equalToConstant: 44).isActive = true
        colorPalette.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 8).isActive = true
        colorPalette.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -8).isActive = true
        colorPalette.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -8).isActive = true
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)

        let doubleTapRecognizer = UITapGestureRecognizer(target: self, action: #selector(DrawView.doubleTap(_:)))
        doubleTapRecognizer.numberOfTapsRequired = 2
        doubleTapRecognizer.delaysTouchesBegan = true
        addGestureRecognizer(doubleTapRecognizer)

        let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(DrawView.tap(_:)))
        tapRecognizer.delaysTouchesBegan = true
        tapRecognizer.require(toFail: doubleTapRecognizer)
        addGestureRecognizer(tapRecognizer)

        let longPressRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(DrawView.longPress(_:)))
        addGestureRecognizer(longPressRecognizer)

        moveRecognizer = UIPanGestureRecognizer(target: self, action: #selector(DrawView.moveLine(_:)))
        moveRecognizer.delegate = self
        moveRecognizer.cancelsTouchesInView = false
        addGestureRecognizer(moveRecognizer)

        let swipeRecognizer = UISwipeGestureRecognizer(target: self, action: #selector(DrawView.showColorPalette(_:)))
        swipeRecognizer.direction = .up
        swipeRecognizer.numberOfTouchesRequired = 3
        addGestureRecognizer(swipeRecognizer)
    }

    func strokeLine(_ line: Line) {
        let path = UIBezierPath()
        path.lineWidth = line.thickness ?? lineThickness
        path.lineCapStyle = .round

        path.move(to: line.begin)
        path.addLine(to: line.end)
        path.stroke()
    }

    func strokeCircle(_ circle: Circle) {
        let path = UIBezierPath(arcCenter: circle.center, radius: circle.radius, startAngle: 0, endAngle: CGFloat(2 * M_PI), clockwise: true)
        path.lineWidth = 10
        path.stroke()
    }

    override func draw(_ rect: CGRect) {
        for line in finishedLines {
            line.color!.setStroke()
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

        if let index = selectedLineIndex {
            UIColor.green.setStroke()
            let selectedLine = finishedLines[index]
            strokeLine(selectedLine)
        }

        if let circle = currentCircle {
            strokeCircle(circle)
        }
    }

    // MARK: - Touch Event Handlers

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
                let newLine = Line(begin: location, end: location, thickness: nil, color: nil)
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
                    line.thickness = lineThickness

                    if let color = permanentLineColor {
                        line.color = color
                    } else {
                        let radians = atan2(abs(line.end.y - line.begin.y),
                                            abs(line.end.x - line.begin.x))
                        let degrees = radians * 180 / CGFloat(M_PI)
                        
                        line.color = UIColor(red: degrees / 45,
                                             green: degrees / 90,
                                             blue: 1 - degrees / 135,
                                             alpha: 1.0)
                    }

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

    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}
