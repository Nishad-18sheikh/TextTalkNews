//
//  UIViewExtenstion.swift
//  TextalkNews
//
//  Created by gwl on 06/05/22.
//

import Foundation
import UIKit
extension UIView {
    enum EdgeDirection { case left, right, none }
    func mask(with style: EdgeDirection) {
        let center = style.center(of: bounds)
        let path: UIBezierPath = .init()
        path.move(to: center)
        path.addArc(withCenter: center, radius: bounds.height / 2, startAngle: style.angle.start, endAngle: style.angle.end, clockwise: style.isClockwise)

        let maskLayer: CAShapeLayer = .init()
        maskLayer.frame = bounds
        maskLayer.path  = path.cgPath
        layer.mask = style == .none ? nil : maskLayer
    }
    enum Corner: Int {
        case bottomRight = 0,
             topRight,
             bottomLeft,
             topLeft
    }
    private func parseCorner(corner: Corner) -> CACornerMask.Element {
        let corners: [CACornerMask.Element] = [.layerMaxXMaxYCorner,
                                               .layerMaxXMinYCorner,
                                               .layerMinXMaxYCorner,
                                               .layerMinXMinYCorner]
        return corners[corner.rawValue]
    }
    private func createMask(corners: [Corner]) -> UInt {
        return corners.reduce(0, { (a, b) -> UInt in
            return a + parseCorner(corner: b).rawValue
        })
    }
    func roundCornersInCircle(color: UIColor = .white, borderWidth: Double = 1.2) {
        let corners: [Corner] = [.bottomRight, .topRight, .bottomLeft, .topLeft]
        layer.cornerRadius = self.frame.height/2
        let maskedCorners: CACornerMask = CACornerMask(rawValue: createMask(corners: corners))
        layer.borderColor = color.cgColor
        layer.borderWidth = CGFloat(borderWidth)
        layer.maskedCorners = maskedCorners
    }
    func roundCorners(corners: [Corner] = [.bottomRight, .topRight, .bottomLeft, .topLeft], amount: CGFloat = 5) {
        layer.cornerRadius = amount
        let maskedCorners: CACornerMask = CACornerMask(rawValue: createMask(corners: corners))
        layer.maskedCorners = maskedCorners
    }
    func setViewCornerRadius(radius: CGFloat, boarderWidth: Double, boarderColor: UIColor) {
        layer.cornerRadius = radius
        layer.borderWidth = CGFloat(boarderWidth)
        layer.borderColor = boarderColor.cgColor
    }
    func roundCornersWithColor(corners: [Corner] = [.bottomRight, .topRight, .bottomLeft, .topLeft], amount: CGFloat = 5, color: UIColor, borderWidth: Double) {
        layer.cornerRadius = amount
        let maskedCorners: CACornerMask = CACornerMask(rawValue: createMask(corners: corners))
        layer.maskedCorners = maskedCorners
        layer.borderColor = color.cgColor
        layer.borderWidth = CGFloat(borderWidth)
    }
    func addShadow(corner: Corner, color: UIColor = .black, opacity: Float = 0.5, radius: CGFloat = 5.0) {
        switch corner {
        case .bottomLeft, .bottomRight:
            addShadow(offset: CGSize(width: 0, height: 10), color: color, opacity: opacity, radius: radius)
        case .topLeft, .topRight:
            addShadow(offset: CGSize(width: 0, height: -3), color: color, opacity: opacity, radius: radius)
        }
    }
    func addShadow(offset: CGSize, color: UIColor = .black, opacity: Float = 0.5, radius: CGFloat = 5.0) {
        self.layer.masksToBounds = false
        self.layer.shadowColor = color.cgColor
        self.layer.shadowOffset = offset
        self.layer.shadowOpacity = opacity
        self.layer.shadowRadius = radius
    }
}
extension UIView.EdgeDirection {
    var angle: (start: CGFloat, end: CGFloat) {
        switch self {
        case .left, .right: return (start: .pi + (.pi / 2), end: .pi / 2)
        case .none: return (start: 0, end: 0)
        }
    }

    var isClockwise: Bool {
        switch self {
        case .left: return false
        default:    return true
        }
    }

    func center(of bounds: CGRect) -> CGPoint {
        switch self {
        case .left: return CGPoint(x: bounds.width, y: bounds.height / 2)
        default:    return CGPoint(x: 0, y: bounds.height / 2)
        }
    }
}
