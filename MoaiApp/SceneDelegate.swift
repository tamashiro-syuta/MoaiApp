//
//  SceneDelegate.swift
//  ChatAppWithFirebase
//
//  Created by 玉城秀大 on 2021/05/09.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?


    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {

        let window = UIWindow(windowScene: scene as! UIWindowScene)
        self.window = window
        
        // ページを格納する配列
        var viewControllers: [UIViewController] = []
        
        //各ViewContorllerのインスタンスを作成（viewとcontrollerを紐付けて生成）
        let chatListStoryBoard = UIStoryboard(name: "ChatList", bundle: nil )
        let chatListVC = chatListStoryBoard.instantiateViewController(identifier: "Chat")
        
        let judgeUserInMoaiStoryboard =  UIStoryboard(name: "JudgeUserInMoai", bundle: nil)
        let judgeUserInMoaiVC = judgeUserInMoaiStoryboard.instantiateViewController(identifier: "JudgeUserInMoai")
        
        let mapStoryBoard = UIStoryboard(name: "Map", bundle: nil )
        let mapVC = mapStoryBoard.instantiateViewController(identifier: "Map")
        
        //各インスタンスのViewConrollerに対して、アイコンなどのTabBarItemを設定
        chatListVC.tabBarItem = UITabBarItem(tabBarSystemItem: .bookmarks, tag: 1)
        judgeUserInMoaiVC.tabBarItem = UITabBarItem(tabBarSystemItem: .contacts, tag: 2)
        mapVC.tabBarItem = UITabBarItem(tabBarSystemItem: .history, tag: 3)
        
        //配列に各ViewContollerをアペンド
        viewControllers.append(chatListVC)
        viewControllers.append(judgeUserInMoaiVC)
        viewControllers.append(mapVC)
        
        let tabBarController = UITabBarController()
        tabBarController.setViewControllers(viewControllers, animated: false)
        
        window.rootViewController = tabBarController
        window.makeKeyAndVisible()
        
        
        guard let _ = (scene as? UIWindowScene) else { return }
    }

    func sceneDidDisconnect(_ scene: UIScene) {
        // Called as the scene is being released by the system.
        // This occurs shortly after the scene enters the background, or when its session is discarded.
        // Release any resources associated with this scene that can be re-created the next time the scene connects.
        // The scene may re-connect later, as its session was not necessarily discarded (see `application:didDiscardSceneSessions` instead).
    }

    func sceneDidBecomeActive(_ scene: UIScene) {
        // Called when the scene has moved from an inactive state to an active state.
        // Use this method to restart any tasks that were paused (or not yet started) when the scene was inactive.
    }

    func sceneWillResignActive(_ scene: UIScene) {
        // Called when the scene will move from an active state to an inactive state.
        // This may occur due to temporary interruptions (ex. an incoming phone call).
    }

    func sceneWillEnterForeground(_ scene: UIScene) {
        // Called as the scene transitions from the background to the foreground.
        // Use this method to undo the changes made on entering the background.
    }

    func sceneDidEnterBackground(_ scene: UIScene) {
        // Called as the scene transitions from the foreground to the background.
        // Use this method to save data, release shared resources, and store enough scene-specific state information
        // to restore the scene back to its current state.
    }


}

