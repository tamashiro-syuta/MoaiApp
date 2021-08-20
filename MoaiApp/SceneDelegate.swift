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
    
    var tabBarController: UITabBarController?
    
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {

        let window = UIWindow(windowScene: scene as! UIWindowScene)
        self.window = window
        window.backgroundColor = .white
        
        //user情報の判別
        let userExists = confirmLoginUser()
        if userExists == true {
            //サインアップ画面に画面遷移
            print("サインアップします")
            //ログインしてないときの処理
            //tabBarにログインをpresentする
            let storyboard = UIStoryboard(name: "SignUp", bundle: nil)
            let SignUpVC = storyboard.instantiateViewController(withIdentifier: "SignUpViewController")
            //signUpViewControllerをナビゲーションの最初の画面にし、それを定数navに格納
            let nav = UINavigationController(rootViewController: SignUpVC)
            nav.modalPresentationStyle = .fullScreen
            window.rootViewController = nav
            window.makeKeyAndVisible() //こいつないと、viewが真っ黒になる
            
        }else {
            //タブバーに画面遷移
            print("タブバーにいくんごよ〜〜")
            
            tabBarController = standardTabBarController()
            window.rootViewController = self.tabBarController
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
            self.tabBarController?.view.addSubview(animationBaseView)
            animationView.play{ (finished) in
                print("アニメーション終了したので、viewを消去します。")
                //アニメーションを削除
                animationBaseView.removeFromSuperview()
            }
            //rootVCにtabBarControllerを設定
            window.rootViewController = self.tabBarController
            window.makeKeyAndVisible()
        }
        guard let _ = (scene as? UIWindowScene) else { return }
    }
    
    private func confirmLoginUser() -> Bool {
        if Auth.auth().currentUser?.uid == nil {
            return true
        }else {
            return false
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
