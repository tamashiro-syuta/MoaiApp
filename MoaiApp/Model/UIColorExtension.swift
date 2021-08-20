//
//  UIColorExtension.swift
//  ChatAppWithFirebase
//
//  Created by 玉城秀大 on 2021/05/09.
//

import UIKit

extension UIColor {
    
    static func rgb(red: CGFloat, green: CGFloat, blue: CGFloat) -> UIColor {
        return self.init(red: red / 255, green: green / 255, blue: blue / 255, alpha: 1)
    }
    
    static func rgba(red: CGFloat, green: CGFloat, blue: CGFloat, alpha: CGFloat) -> UIColor {
        return self.init(red: red / 255, green: green / 255, blue: blue / 255, alpha: alpha / 255)
    }
    
    static func textColor() -> UIColor {
        return self.init(red: 101 / 255, green: 112 / 255, blue: 112 / 255, alpha: 44 )
    }
    
    static func textColor2() -> UIColor {
        return self.init(red: 41 / 255, green: 95 / 255, blue: 97 / 255, alpha: 38 )
    }
    
    static func textColor3() -> UIColor {
        return self.init(red: 41 , green: 95 , blue: 97 , alpha: 38 )
    }
    
    static func barColor() -> UIColor {
        return self.init(red: 75 / 255, green: 176 / 255, blue: 179 / 255, alpha: 70 )
    }
    
}
