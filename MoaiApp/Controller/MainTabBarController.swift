

import Foundation
import UIKit

class MainTabBarController: UITabBarController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        if navigationController?.navigationBar.isHidden == false {
//            print("navBarは表示されてますよ")
//        }
        navigationController?.navigationBar.isHidden = false
        
        tabBarController?.tabBar.barTintColor = .rgb(red: 39, green: 49, blue: 69)
        
        //①ViewControllerのインスタンスの配列を作成
        var viewControllers: [UIViewController] = []
        
        //各ViewContorllerのインスタンスを作成（viewとcontrollerを紐付けて生成）
        let chatListStoryBoard = UIStoryboard(name: "ChatList", bundle: nil )
        let chatListViewController = chatListStoryBoard.instantiateViewController(identifier: "ChatListViewController")
        
        let moaiStoryBoard = UIStoryboard(name: "Moai", bundle: nil )
        let moaiBaseViewController = moaiStoryBoard.instantiateViewController(identifier: "MoaiBaseViewController")
        
        let sampleMoaiStoryBoard = UIStoryboard(name: "Management", bundle: nil )
        let sampleMoaiViewController = sampleMoaiStoryBoard.instantiateViewController(identifier: "ManagementViewController")

        
        //各インスタンスのViewConrollerに対して、アイコンなどのTabBarItemを設定
        chatListViewController.tabBarItem = UITabBarItem(tabBarSystemItem: .bookmarks, tag: 1)
        moaiBaseViewController.tabBarItem = UITabBarItem(tabBarSystemItem: .contacts, tag: 2)
        sampleMoaiViewController.tabBarItem = UITabBarItem(tabBarSystemItem: .contacts, tag: 3)
        
        //配列に各ViewContollerをアペンド
        viewControllers.append(chatListViewController)
        viewControllers.append(moaiBaseViewController)
        viewControllers.append(sampleMoaiViewController)

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
