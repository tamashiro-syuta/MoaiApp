//
//  standardTabBarController.swift
//  MoaiApp
//
//  Created by 玉城秀大 on 2021/08/04.
//

import UIKit

class standardTabBarController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // アイコンの色を変更できます！
        UITabBar.appearance().tintColor = .white
        // 背景色を変更できます！
        UITabBar.appearance().barTintColor = .barColor()
        
    }

}
