//
//  JudgeUserInMoaiViewController.swift
//  MoaiApp
//
//  Created by 玉城秀大 on 2021/07/21.
//

import UIKit
import Firebase
import PKHUD

//ユーザーが模合に入ってるかいないかで画面遷移する（UserDefaultを使用しているので変数にuserを入れなくても大丈夫）
class JudgeUserInMoaiViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationController?.navigationBar.barTintColor = .rgb(red: 39, green: 49, blue: 69)
        navigationController?.navigationBar.titleTextAttributes = [.foregroundColor: UIColor.white]
        
        if UserDefaults.standard.bool(forKey: "userInMoai") == true {
            print("Managementに画面遷移")
            self.pushManagementVC()
        }else {
            print("MoaiBaseに画面遷移")
            self.pushMoaiBaseVC()
        }
    }
    
    //ManagementVCに画面遷移
    private func pushManagementVC() {
        print("画面遷移しまーーーーーーーーーーーーーーーす")
        let storyboard = UIStoryboard(name: "Management", bundle: nil)
        let ManagementVC = storyboard.instantiateViewController(withIdentifier: "ManagementViewController") as! ManagementViewController
        ManagementVC.navigationItem.hidesBackButton = true
        self.navigationController?.pushViewController(ManagementVC, animated: true)
    }
    
    //moai.storyboardに画面遷移
    private func pushMoaiBaseVC() {
        print("MoaiBaseVCに画面遷移しまーす")
        let storyboard = UIStoryboard(name: "Moai", bundle: nil)
        let MoaiBaseVC = storyboard.instantiateViewController(withIdentifier: "MoaiBaseViewController") as! MoaiBaseViewController
        MoaiBaseVC.navigationItem.hidesBackButton = true  // navigationの戻るボタンを非表示
        self.navigationController?.pushViewController(MoaiBaseVC, animated: true)
    }
}
