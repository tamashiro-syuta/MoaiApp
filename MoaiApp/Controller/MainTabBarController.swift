

import Foundation
import UIKit

class MainTabBarController: UITabBarController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        if navigationController?.navigationBar.isHidden == false {
//            print("navBarは表示されてますよ")
//        }
        navigationController?.navigationBar.isHidden = true
        
        tabBarController?.tabBar.barTintColor = .rgb(red: 39, green: 49, blue: 69)
        
        //①ViewControllerのインスタンスの配列を作成
        var viewControllers: [UIViewController] = []
        
        //各ViewContorllerのインスタンスを作成（viewとcontrollerを紐付けて生成）
        let chatListStoryBoard = UIStoryboard(name: "ChatList", bundle: nil )
        let chatListVC = chatListStoryBoard.instantiateViewController(identifier: "Chat")
        
        let moaiStoryBoard = UIStoryboard(name: "Moai", bundle: nil )
        let moaiBaseVC = moaiStoryBoard.instantiateViewController(identifier: "Moai")
        
        let sampleMoaiStoryBoard = UIStoryboard(name: "Management", bundle: nil )
        let sampleMoaiVC = sampleMoaiStoryBoard.instantiateViewController(identifier: "Management")

        let mapStoryBoard = UIStoryboard(name: "Map", bundle: nil )
        let mapVC = mapStoryBoard.instantiateViewController(identifier: "MapViewController") 
        
        //各インスタンスのViewConrollerに対して、アイコンなどのTabBarItemを設定
        chatListVC.tabBarItem = UITabBarItem(tabBarSystemItem: .bookmarks, tag: 1)
        moaiBaseVC.tabBarItem = UITabBarItem(tabBarSystemItem: .contacts, tag: 2)
        sampleMoaiVC.tabBarItem = UITabBarItem(tabBarSystemItem: .contacts, tag: 3)
        mapVC.tabBarItem = UITabBarItem(tabBarSystemItem: .history, tag: 4)
        
        //配列に各ViewContollerをアペンド
        viewControllers.append(chatListVC)
        viewControllers.append(moaiBaseVC)
        viewControllers.append(sampleMoaiVC)
        viewControllers.append(mapVC)

        //selectedTabBar1()
        
        
        
        //setViewContorollerにViewControllersを渡す
        self.setViewControllers(viewControllers, animated: false)
        
    }
    
    private func selectedTabBar1() {
        navigationController?.setNavigationBarHidden(false, animated: true)
        navigationController?.navigationBar.barTintColor = .rgb(red: 39, green: 49, blue: 69)
        navigationItem.title = "トーク"
        navigationController?.navigationBar.titleTextAttributes = [.foregroundColor: UIColor.white]
        
        let rightBarButton = UIBarButtonItem(title: "新規チャット")
        let logoutBarButton = UIBarButtonItem(title: "ログアウト")
        
//        navigationController?.setNavigationBarHidden(false, animated: true)
        //navigationBarの右側にボタンをコードで追加
        navigationItem.rightBarButtonItem = rightBarButton
        navigationItem.rightBarButtonItem?.tintColor = .white
        navigationItem.leftBarButtonItem = logoutBarButton
        navigationItem.leftBarButtonItem?.tintColor = .white
    }
    
}
