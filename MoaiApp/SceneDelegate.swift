//
//  SceneDelegate.swift
//  ChatAppWithFirebase
//
//  Created by 玉城秀大 on 2021/05/09.
//

import UIKit
import Firebase
import FirebaseAuth
import Lottie

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?
    
    let tabBarController = standardTabBarController()

    
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {

        let window = UIWindow(windowScene: scene as! UIWindowScene)
        self.window = window
        window.backgroundColor = .white
        
//        //tabBarにViewControllerをセット
        self.setVCToTabBarControler(tabBarController: self.tabBarController)
        //rootVCにtabBarControllerを設定
        window.rootViewController = self.tabBarController
        window.makeKeyAndVisible()
        
        //user情報の判別
        confirmLoginUser(tabBarController: tabBarController)
        
        //アニメーションの追加
        let animationView = AnimationView(name: "loading")
        let animationBaseView = UIView() //アニメーション動作中の背景用のview
        
        animationBaseView.frame = CGRect(x: 0, y: 0, width: window.frame.size.width, height: window.frame.size.height)
        animationBaseView.backgroundColor = .white
        animationView.frame = CGRect(x: 0, y: 0, width: window.frame.size.width, height: window.frame.size.height)
        animationBaseView.addSubview(animationView)
        animationView.contentMode = .scaleAspectFit
        animationView.loopMode = .repeat(2)
        
        //windowにアニメーションを追加
        window.addSubview(animationBaseView)
        animationView.play{ (finished) in
            print("アニメーション終了したので、viewを消去します。")
            //アニメーションを削除
            animationBaseView.removeFromSuperview()
        }
        
        guard let _ = (scene as? UIWindowScene) else { return }
    }
    
    private func setVCToTabBarControler(tabBarController: UITabBarController) {
        // ページを格納する配列(navigationController用)
        var NavControllers: [UIViewController] = []
        
        //各ViewContorllerのインスタンスを作成（viewとcontrollerを紐付けて生成）
        let chatListStoryBoard = UIStoryboard(name: "ChatList", bundle: nil )
        let chatListNav = chatListStoryBoard.instantiateViewController(withIdentifier: "Chat")
        
        let managementStoryboard =  UIStoryboard(name: "Management", bundle: nil)
        let managementNav = managementStoryboard.instantiateViewController(withIdentifier: "Management")
        
        let mapStoryBoard = UIStoryboard(name: "Map", bundle: nil )
        let mapNav = mapStoryBoard.instantiateViewController(withIdentifier: "Map")
        
        //各インスタンスのViewConrollerに対して、アイコンなどのTabBarItemを設定
        chatListNav.tabBarItem = UITabBarItem(tabBarSystemItem: .bookmarks, tag: 1)
        managementNav.tabBarItem = UITabBarItem(tabBarSystemItem: .contacts, tag: 2)
        mapNav.tabBarItem = UITabBarItem(tabBarSystemItem: .history, tag: 3)
        
        //配列に各ViewContollerをアペンド
        NavControllers.append(chatListNav)
        NavControllers.append(managementNav)
        NavControllers.append(mapNav)
        
        tabBarController.setViewControllers(NavControllers, animated: false)
    }
    
    private func confirmLoginUser(tabBarController: UITabBarController) {
        if Auth.auth().currentUser?.uid == nil {
            //ログインしてないときの処理
            print("まだユーザー登録していないやん、こいつ")
            //tabBarにログインをpresentする
            let storyboard = UIStoryboard(name: "SignUp", bundle: nil)
            let signUpViewController = storyboard.instantiateViewController(withIdentifier: "SignUpViewController")
            //signUpViewControllerをナビゲーションの最初の画面にし、それを定数navに格納
            let nav = UINavigationController(rootViewController: signUpViewController)
            nav.modalPresentationStyle = .fullScreen
            window?.rootViewController = nav
//                .present(nav, animated: true, completion: nil)
        }
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

