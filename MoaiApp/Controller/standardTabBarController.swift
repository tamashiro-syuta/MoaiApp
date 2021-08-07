//
//  standardTabBarController.swift
//  MoaiApp
//
//  Created by 玉城秀大 on 2021/08/04.
//

import UIKit

class standardTabBarController: UITabBarController {
    
    var user: User?
    var moai: Moai?
    var nextMoai: MoaiRecord? //次回の模合の情報
    var nextMoaiID: String?
    var pastRecodeArray: [MoaiRecord]?  //古いデータが「0番目」、新しいのが「n番目」になってる
    var pastRecodeIDStringArray: [String]?  // 20210417みたいな形で取り出してる
    var pastRecodeIDDateArray: [String]?  //◯月◯日みたいな形で取り出してる
    var nextMoaiEntryArray: [Bool]? // ブーリアン型の配列
    var moaiMenbersNameList: [String] = [] //模合メンバーの名前の配列

    override func viewDidLoad() {
        super.viewDidLoad()

        // アイコンの色を変更できます！
        UITabBar.appearance().tintColor = .white
        // 背景色を変更できます！
        UITabBar.appearance().barTintColor = .barColor()
        
    }

}
