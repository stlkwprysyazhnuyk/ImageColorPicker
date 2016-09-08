//
//  PickableImageView.swift
//  ImageColorPicker
//
//  Created by Igor Prysyazhnyuk on 9/6/16.
//  Copyright © 2016 Steelkiwi. All rights reserved.
//

import UIKit

public class PickableImageView: UIImageView, ColorSelectorDelegate {
    
    @IBInspectable
    public var colorSelectorSize: CGFloat = 64 {
        didSet {
            setColorSelectorSize()
        }
    }
    
    private let colorSelector = ColorSelector()
    public var delegate: ColorSelectorDelegate?
    private var didColorSelectorMove = false
    
    public override var image: UIImage? {
        didSet {
            setColorSelectorData()
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        initialize()
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initialize()
    }
    
    override init(image: UIImage?) {
        super.init(image: image)
        initialize()
    }
    
    override init(image: UIImage?, highlightedImage: UIImage?) {
        super.init(image: image, highlightedImage: highlightedImage)
        initialize()
    }
    
    private func setColorSelectorData() {
        colorSelector.setData(self, delegate: self)
    }
    
    private func setColorSelectorSize() {
        colorSelector.frame.size.width = colorSelectorSize
        colorSelector.frame.size.height = colorSelectorSize
    }
    
    private func initialize() {
        userInteractionEnabled = true
        setColorSelectorData()
        setColorSelectorSize()
        colorSelector.center = center
        addSubview(colorSelector)
    }
    
    public override func layoutSubviews() {
        setColorSelectorData()
        if !didColorSelectorMove { colorSelector.center = center }
    }
    
    public func colorCaptured(color: UIColor) {
        delegate?.colorCaptured(color)
    }
    
    public func colorSelectorMoved() {
        didColorSelectorMove = true
        delegate?.colorSelectorMoved?()
    }
}