//
//  OverlayVIew.swift
//  Homepwner
//
//  Created by Andy Wong on 11/3/16.
//  Copyright © 2016 Big Nerd Ranch. All rights reserved.
//

import UIKit

class OverlayView: UIView {
    override func draw(_ rect: CGRect) {
        let circlePath = UIBezierPath(ovalIn: rect)

        let linePath = UIBezierPath()
        linePath.move(to: CGPoint(x: rect.width / 2, y: 0))
        linePath.addLine(to: CGPoint(x: rect.width / 2, y: rect.height))

        linePath.move(to: CGPoint(x: 0, y: rect.height / 2))
        linePath.addLine(to: CGPoint(x: rect.width, y: rect.height / 2))

        UIColor.yellow.setStroke()
        circlePath.stroke()
        linePath.stroke()
    }
}
