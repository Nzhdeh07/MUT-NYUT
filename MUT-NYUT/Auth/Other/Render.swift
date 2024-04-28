import Foundation
import UIKit


class SkewedRectangleViewLeft: UIView {
       override func draw(_ rect: CGRect) {
           let path = UIBezierPath()
           let cornerRadius: CGFloat = 20

                path.move(to: CGPoint(x: rect.minX + cornerRadius, y: rect.minY))
                path.addLine(to: CGPoint(x: rect.maxX, y: rect.minY + 100))
       
                path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY - cornerRadius))
                path.addArc(withCenter: CGPoint(x: rect.maxX - cornerRadius, y: rect.maxY - cornerRadius),
                            radius: cornerRadius,
                            startAngle: 0,
                            endAngle: CGFloat(Double.pi / 2),
                            clockwise: true)
           
                path.addLine(to: CGPoint(x: rect.minX + cornerRadius, y: rect.maxY))
                path.addArc(withCenter: CGPoint(x: rect.minX + cornerRadius, y: rect.maxY - cornerRadius),
                            radius: cornerRadius,
                            startAngle: CGFloat(Double.pi / 2),
                            endAngle: CGFloat(Double.pi),
                            clockwise: true)

                path.addLine(to: CGPoint(x: rect.minX, y: rect.minY + cornerRadius))
                path.addArc(withCenter: CGPoint(x: rect.minX + cornerRadius, y: rect.minY + cornerRadius),
                            radius: cornerRadius,
                            startAngle: CGFloat(Double.pi),
                            endAngle: CGFloat(3 * Double.pi / 2),
                            clockwise: true)

           let customColor = UIColor(red: 201.0/255.0, green: 52.0/255.0, blue: 0.0/255.0, alpha: 1.0)
           customColor.setFill()
           path.fill()

           UIColor.black.setStroke()
           path.lineWidth = 2.0
           path.stroke()
       }
   }
   
   
   class SkewedRectangleViewRight: UIView {
       override func draw(_ rect: CGRect) {
           let path = UIBezierPath()
           let cornerRadius: CGFloat = 20

                path.move(to: CGPoint(x: rect.minX, y: rect.minY + 100))
           
                path.addLine(to: CGPoint(x: rect.maxX - cornerRadius , y: rect.minY))
                path.addArc(withCenter: CGPoint(x: rect.maxX - cornerRadius, y: rect.minY + cornerRadius),
                               radius: cornerRadius,
                               startAngle: CGFloat(3 * Double.pi / 2),
                               endAngle: 0,
                               clockwise: true)
       
                path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY - cornerRadius))
                path.addArc(withCenter: CGPoint(x: rect.maxX - cornerRadius, y: rect.maxY - cornerRadius),
                            radius: cornerRadius,
                            startAngle: 0,
                            endAngle: CGFloat(Double.pi / 2),
                            clockwise: true)

                path.addLine(to: CGPoint(x: rect.minX + cornerRadius, y: rect.maxY))
                path.addArc(withCenter: CGPoint(x: rect.minX + cornerRadius, y: rect.maxY - cornerRadius),
                            radius: cornerRadius,
                            startAngle: CGFloat(Double.pi / 2),
                            endAngle: CGFloat(Double.pi),
                            clockwise: true)

                path.addLine(to: CGPoint(x: rect.minX, y: rect.minY + 100))

           let customColor = UIColor(red: 201.0/255.0, green: 52.0/255.0, blue: 0.0/255.0, alpha: 1.0)
           customColor.setFill()
           path.fill()

           path.lineWidth = 2.0
           UIColor.black.setStroke()
           path.stroke()
       }
   }



