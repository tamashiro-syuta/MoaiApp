//
//  LoginViewController.swift
//  ChatAppWithFirebase
//
//  Created by 玉城秀大 on 2021/05/18.
//

import UIKit
import Firebase
import PKHUD

class LoginViewController: UIViewController {
    
    
    
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var dontHaveAccountButton: UIButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        loginButton.layer.cornerRadius = 8

        dontHaveAccountButton.addTarget(self, action: #selector(tappedDontHaveAccountButton), for: .touchUpInside)
        loginButton.addTarget(self, action: #selector(tappedLoginbutton), for: .touchUpInside)
        
    }
    
    @objc private func tappedDontHaveAccountButton() {
        //下の画面(signup)への画面遷移
        self.navigationController?.popViewController(animated: true)
    }
    
    @objc private func tappedLoginbutton() {
        guard let email = emailTextField.text else {return}
        guard let password = passwordTextField.text else {return}
        
        HUD.show(.progress)
        print(password)
        print(email)
        Auth.auth().signIn(withEmail: email, password: password) { (res, err) in
            if let err = err {
                print("ログインに失敗しました。\(err)")
                HUD.hide()
                return
            }
            
            HUD.hide()
            print("ログインに成功しました。")
            
            //chatListViewが呼ばれる度にchatroomの情報を更新していると無駄に通信して良くないので
            //再ログインした時にログイン画面にいく手前のviewの情報を取得し、そこのメソッドを呼ぶ
            //こうすることで、ログインした時だけデータをロードする仕様
            self.pushManagementVC()
        }
        
    }
    
    private func pushManagementVC() {
        print("タブバーに画面遷移するよ")
        let tabBarController = standardTabBarController()
        self.navigationController?.navigationBar.isHidden = true
        
        self.navigationController?.pushViewController(tabBarController, animated: true)
    }
    
    //画面をタップするとテキストフィールドの編集を終わらせてくれる処理
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }

}
