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
}
