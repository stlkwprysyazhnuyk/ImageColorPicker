//
//  ColorNameAnalyzer.swift
//  ReDress
//
//  Created by Igor Prysyazhnyuk on 7/25/16.
//  Copyright © 2016 Steelkiwi. All rights reserved.
//

import UIKit

struct ColorComponent {
    var red: CGFloat
    var green: CGFloat
    var blue: CGFloat
    var alpha: CGFloat
    
    init(color: UIColor) {
        let colorComponents = CGColorGetComponents(color.CGColor)
        red = colorComponents[0]
        green = colorComponents[1]
        blue = colorComponents[2]
        alpha = colorComponents[3]
    }
}

public class ColorNameRecognizer {
    static let colorsFileName = "colors"
    static let colorsFileExtension = "txt"
    static var colorsNames = [String]()
    static var colorsComponentsMap = [String: ColorComponent]()
    
    static var colorsCount: Int {
        return colorsNames.count
    }
    
    static func colorFromHex(hex: String) -> UIColor {
        var cString:String = hex.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet() as NSCharacterSet).uppercaseString
        
        if cString.hasPrefix("#") {
            cString = cString.substringFromIndex(cString.startIndex.advancedBy(1))
        }
        
        if (cString.characters.count) != 6 {
            return UIColor.grayColor()
        }
        
        var rgbValue:UInt32 = 0
        NSScanner(string: cString).scanHexInt(&rgbValue)
        
        return UIColor(
            red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
            green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
            blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
            alpha: CGFloat(1.0)
        )
    }
    
    public static func loadColors() {
        guard let path = NSBundle(forClass: self).pathForResource(colorsFileName, ofType: colorsFileExtension) else {
            fatalError("\(colorsFileName).\(colorsFileExtension) not found")
        }
        colorsComponentsMap.removeAll()
        do {
            let text = try String(contentsOfFile: path, encoding: NSUTF8StringEncoding)
            let colorsDescriptions = text.componentsSeparatedByString("\n")
            
            for colorDescription in colorsDescriptions {
                guard !colorDescription.hasPrefix("#") && !colorDescription.isEmpty else { continue }
                let nameAndHex = colorDescription.componentsSeparatedByString("\t")
                if nameAndHex.count < 2 { fatalError("Color name and hex in txt must be separated by 1 tab") }
                
                let color = colorFromHex(nameAndHex[1])
                colorsNames.append(nameAndHex[0])
                colorsComponentsMap[nameAndHex[0]] = ColorComponent(color: color)
            }
        } catch {
            fatalError("Can't load \(colorsFileName) file")
        }
    }
    
    public static func getColorName(color: UIColor) -> String {
        if colorsComponentsMap.count == 0 { loadColors() }
        
        let inputColorComponents = ColorComponent(color: color)
        
        var colorName = "Undefined"
        var minDifference = CGFloat.max
        
        for (colorNameEl, colorComponents) in colorsComponentsMap {
            let squarePower: CGFloat = 2
            let dRed = pow(inputColorComponents.red - colorComponents.red, squarePower)
            let dGreen = pow(inputColorComponents.green - colorComponents.green, squarePower)
            let dBlue = pow(inputColorComponents.blue - colorComponents.blue, squarePower)
            
            let difference = sqrt(dRed + dGreen + dBlue)
            if difference < minDifference {
                minDifference = difference
                colorName = colorNameEl
            }
        }
        
        return colorName
    }
    
    public static func getNearColorsNames(colorName: String, count: Int) -> [String] {
        var nearColorsNames = [String]()
        guard count > 0 else { fatalError("Count should be greater than 0") }
        if let colorIndex = colorsNames.indexOf(colorName) {
            let halfCount = count / 2
            var startIndex = colorIndex - halfCount
            if startIndex < 0 { startIndex = 0 }
            var endIndex = colorIndex + halfCount
            if endIndex >= colorsCount { endIndex = colorsCount - 1 }
            if halfCount == 0 { endIndex = colorIndex }
            nearColorsNames = Array(colorsNames[startIndex...endIndex])
        }
        
        return nearColorsNames
    }
    
    public static func getColor(colorName: String) -> UIColor? {
        guard let colorComponent = colorsComponentsMap[colorName] else { return nil }
        return UIColor(red: colorComponent.red, green: colorComponent.green, blue: colorComponent.blue, alpha: colorComponent.alpha)
    }
}