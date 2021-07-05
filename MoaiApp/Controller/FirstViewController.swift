//
//  FirstViewController.swift
//  MoaiApp
//
//  Created by 玉城秀大 on 2021/05/28.
//

import UIKit

class FirstViewController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()

        print("FirstViewControllerがロードされました。")
        tabBarController?.tabBar.barTintColor = .rgb(red: 39, green: 49, blue: 69)
        
    }

}
