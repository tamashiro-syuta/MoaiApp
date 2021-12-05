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
    var pastRecordArray: [MoaiRecord]?  //古いデータが「0番目」、新しいのが「n番目」になってる
    var pastRecordIDStringArray: [String]?  // 20210417みたいな形で取り出してる
    var pastRecordIDDateArray: [String]?  //◯月◯日みたいな形で取り出してる
    var nextMoaiEntryArray: [Bool]? // ブーリアン型の配列
    var moaiMenbersNameList: [String] = [] //模合メンバーの名前の配列

    override func viewDidLoad() {
        super.viewDidLoad()

        // アイコンの色を変更できます！
        UITabBar.appearance().tintColor = .white
        // 背景色を変更できます！
        UITabBar.appearance().barTintColor = .barColor()
        
        //1秒後に処理(viewControllerを生成するのが早い説？？)
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            //ここに処理
//            self.setVC()
        }
        self.setVC()
        
    }
    
    private func setVC() {
        
        var VCArray = [UIViewController] ()
        
        let managementSB = UIStoryboard(name: "Management", bundle: nil)
        let managementVC = managementSB.instantiateViewController(withIdentifier: "Management")
        managementVC.tabBarItem = UITabBarItem(tabBarSystemItem: .search, tag: 1)
        
        let chatSB = UIStoryboard(name: "ChatList", bundle: nil)
        let chatVC = chatSB.instantiateViewController(withIdentifier: "Chat")
        chatVC.tabBarItem = UITabBarItem(tabBarSystemItem: .search, tag: 2)
        
        let pastMoaiSB = UIStoryboard(name: "PastMoai", bundle: nil)
        let pastMoaiVC = pastMoaiSB.instantiateViewController(withIdentifier: "PastMoai")
        pastMoaiVC.tabBarItem = UITabBarItem(tabBarSystemItem: .contacts, tag: 3)
        
        let mapSB = UIStoryboard(name: "Map", bundle: nil)
        let mapVC = mapSB.instantiateViewController(withIdentifier: "Map")
        mapVC.tabBarItem = UITabBarItem(tabBarSystemItem: .search, tag: 4)
        
        let savingsSB = UIStoryboard(name: "Savings", bundle: nil)
        let savingsVC = savingsSB.instantiateViewController(withIdentifier: "Savings")
        savingsVC.tabBarItem = UITabBarItem(tabBarSystemItem: .favorites, tag: 5)
        
        VCArray.append(managementVC)
        VCArray.append(chatVC)
        VCArray.append(pastMoaiVC)
        VCArray.append(mapVC)
        VCArray.append(savingsVC)
        
        self.setViewControllers(VCArray, animated: false)
        
    }

}
