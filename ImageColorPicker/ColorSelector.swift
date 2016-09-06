//
//  ColorSelector.swift
//  ImageColorPicker
//
//  Created by Igor Prysyazhnyuk on 6/27/16.
//  Copyright © 2016 Steelkiwi. All rights reserved.
//

import UIKit

@objc public protocol ColorSelectorDelegate {
    func colorCaptured(color: UIColor)
    optional func colorSelectorMoved()
}

public class ColorSelector: UIView {
    
    @IBInspectable
    public var borderWidth: CGFloat = 2 {
        didSet {
            layer.borderWidth = borderWidth
        }
    }
    @IBInspectable
    public var borderColor: UIColor = UIColor.whiteColor() {
        didSet {
            layer.borderColor = borderColor.CGColor
        }
    }
    
    private var image: UIImage?
    private var delegate: ColorSelectorDelegate?
    private var positionConstraintsDeactivated = false
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        initialize()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initialize()
    }
    
    private func initialize() {
        clipsToBounds = true
        layer.borderWidth = borderWidth
        layer.borderColor = borderColor.CGColor
    }
    
    override public func layoutSubviews() {
        super.layoutSubviews()
        layer.cornerRadius = frame.width / 2
    }
    
    public func setData(imageView: UIImageView?, delegate: ColorSelectorDelegate?) {
        self.image = imageView?.takeSnapshot()
        self.delegate = delegate
        captureColor()
    }
    
    override public func touchesMoved(touches: Set<UITouch>, withEvent event: UIEvent?) {
        if let touch = touches.first {
            let location = touch.locationInView(superview)
            disactivatePositionConstraints()
            translatesAutoresizingMaskIntoConstraints = true
            center = location
            captureColor()
            superview?.endEditing(true)
            delegate?.colorSelectorMoved?()
        }
    }
    
    private func disactivatePositionConstraints() {
        guard !positionConstraintsDeactivated, let constraints = superview?.constraints else { return }
        for constraint in constraints {
            if constraint.firstItem as! NSObject == self {
                constraint.active = false
            }
        }
        positionConstraintsDeactivated = true
    }
    
    func captureColor() {
        if let image = image {
            let scale = image.scale
            let croppedImage = image.crop((frame.origin.x) * scale, y: (frame.origin.y) * scale, width: frame.height * scale, height: frame.width * scale)
            let capturedColor = croppedImage?.averageColor()
            if let capturedColor = capturedColor {
                delegate?.colorCaptured(capturedColor)
            }
        }
    }
}

extension UIView {
    func takeSnapshot() -> UIImage {
        UIGraphicsBeginImageContext(self.bounds.size);
        let context = UIGraphicsGetCurrentContext();
        self.layer.renderInContext(context!)
        let screenShot = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        return screenShot
    }
}

extension UIImage {
    func averageColor() -> UIColor {
        let rgba = UnsafeMutablePointer<CUnsignedChar>.alloc(4)
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let info = CGBitmapInfo(rawValue: CGImageAlphaInfo.PremultipliedLast.rawValue)
        let context = CGBitmapContextCreate(rgba, 1, 1, 8, 4, colorSpace, info.rawValue)
        CGContextDrawImage(context, CGRectMake(0, 0, 1, 1), self.CGImage)
        
        if rgba[3] > 0 {
            let alpha: CGFloat = CGFloat(rgba[3]) / 255.0
            let multiplier: CGFloat = alpha / 255.0
            return UIColor(red: CGFloat(rgba[0]) * multiplier, green: CGFloat(rgba[1]) * multiplier, blue: CGFloat(rgba[2]) * multiplier, alpha: alpha)
        } else {
            return UIColor(red: CGFloat(rgba[0]) / 255.0, green: CGFloat(rgba[1]) / 255.0, blue: CGFloat(rgba[2]) / 255.0, alpha: CGFloat(rgba[3]) / 255.0)
        }
    }
    
    func crop(x: CGFloat, y: CGFloat, width: CGFloat, height: CGFloat) -> UIImage? {
        let cropRect = CGRectMake(x, y, width, height)
        // Draw new image in current graphics context
        var croppedImage: UIImage?
        if let cgImage = CGImageCreateWithImageInRect(CGImage, cropRect) {
            croppedImage = UIImage(CGImage: cgImage)
        }
        return croppedImage
    }
}