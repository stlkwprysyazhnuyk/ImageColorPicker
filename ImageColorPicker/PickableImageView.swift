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
    var size: CGFloat = 40 {
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
    
    private func setColorSelectorData() {
        colorSelector.setData(self, delegate: self)
    }
    
    private func setColorSelectorSize() {
        colorSelector.frame.size.width = size
        colorSelector.frame.size.height = size
    }
    
    private func initialize() {
        userInteractionEnabled = true
        setColorSelectorSize()
        colorSelector.center = center
        addSubview(colorSelector)
        setDataForColorSelector()
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