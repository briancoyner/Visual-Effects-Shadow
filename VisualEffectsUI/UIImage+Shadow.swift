//
//  Created by Brian M Coyner on 5/11/17.
//

import Foundation
import UIKit
import CoreGraphics

public struct Shadow {
    let offset: CGSize
    let blur: CGFloat
    let color: UIColor
    
    public init(offset: CGSize, blur: CGFloat, color: UIColor) {
        self.offset = offset
        self.blur = blur
        self.color = color
    }
}

extension UIImage {
    
    public static func resizableShadowImage(
        withSideLength sideLength: CGFloat,
        cornerRadius: CGFloat,
        shadow: Shadow,
        shouldDrawCapInsets: Bool = false
    ) -> UIImage {
        
        // The image is a square, which makes it easier to set up the cap insets.
        //
        // Note: this implementation assumes an offset of CGSize(0, 0)
        
        let lengthAdjustment = sideLength + (shadow.blur * 2.0)
        let graphicContextSize = CGSize(width: lengthAdjustment, height: lengthAdjustment)
        
        // Note: the image is transparent
        UIGraphicsBeginImageContextWithOptions(graphicContextSize, false, UIScreen.main.scale)
        let context = UIGraphicsGetCurrentContext()!
        defer {
            UIGraphicsEndImageContext()
        }
        
        let roundedRect = CGRect(x: shadow.blur, y: shadow.blur, width: sideLength, height: sideLength)
        let shadowPath = UIBezierPath(roundedRect: roundedRect, cornerRadius: cornerRadius)
        
        context.saveGState()
        context.addRect(context.boundingBoxOfClipPath)
        context.addPath(shadowPath.cgPath)
        context.clip(using: .evenOdd)
        
        let color = shadow.color.cgColor
        
        context.setStrokeColor(color)
        context.addPath(shadowPath.cgPath)
        context.setShadow(offset: shadow.offset, blur: shadow.blur, color: color)
        context.fillPath()
        context.restoreGState()
        
        let capInset = cornerRadius + shadow.blur
        
        if shouldDrawCapInsets {
            let debugRect = CGRect(origin: CGPoint(x: 0.0, y: 0.0), size: graphicContextSize)
            
            context.setStrokeColor(UIColor.purple.cgColor)
            context.beginPath()
            
            // horizontal top line
            context.move(to: CGPoint(x: debugRect.origin.x, y: debugRect.origin.y + capInset))
            context.addLine(to: CGPoint(x: debugRect.size.width + capInset, y: debugRect.origin.y + capInset))
            
            // horizontal bottom line
            context.move(to: CGPoint(x: debugRect.origin.x, y: debugRect.size.height - capInset))
            context.addLine(to: CGPoint(x: debugRect.size.width + capInset, y: debugRect.size.height - capInset))
            
            // vertical left line
            context.move(to: CGPoint(x: debugRect.origin.x + capInset, y: debugRect.origin.y))
            context.addLine(to: CGPoint(x: debugRect.origin.x + capInset, y: debugRect.size.height))
            
            // vertical right line
            context.move(to: CGPoint(x: debugRect.size.width - capInset, y: debugRect.origin.y))
            context.addLine(to: CGPoint(x: debugRect.size.width - capInset, y: debugRect.size.height))
            
            context.strokePath()
            
            context.addRect(debugRect.insetBy(dx: 0.5, dy: 0.5))
            context.setStrokeColor(UIColor.red.cgColor)
            context.strokePath()
        }
        
        let image = UIGraphicsGetImageFromCurrentImageContext()!
        
        let edgeInsets = UIEdgeInsets(top: capInset, left: capInset, bottom: capInset, right: capInset)
        return image.resizableImage(withCapInsets: edgeInsets, resizingMode: .tile) // you can play around with `.stretch`, too.
    }
}
