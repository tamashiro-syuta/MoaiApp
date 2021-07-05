//
//  FirstJoinViewController.swift
//  MoaiApp
//
//  Created by 玉城秀大 on 2021/06/25.
//

import UIKit
import Firebase
import FirebaseFirestore
import FirebaseAuth

class FirstJoinViewController: UIViewController {
    
    let db = Firestore.firestore()
    var myPassword = ""
    
    @IBOutlet weak var joinButton: UIButton!
    @IBOutlet weak var textField: UITextField!
    

    override func viewDidLoad() {
        super.viewDidLoad()

        setupView()
        
    }
    
    private func setupView() {
        
        joinButton.layer.cornerRadius = joinButton.frame.size.height / 3
        
        let toolbar = UIToolbar(frame: CGRect(x: 0, y: 0, width: view.frame.size.width, height: 50))
        //toolbarに表示させるアイテム
        let space = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: self, action: nil)
        let done = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(self.donePressed))
        let cancel = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(self.cancelPressed))
        toolbar.setItems([cancel , space, done ], animated: true)
        
        textField.inputAccessoryView = toolbar
        
    }

    
    @IBAction func join(_ sender: Any) {
        
        var dataGetJudge: Bool = false

        //mypasswodに入れた値と同じパスワードを持つ模合を探し出す
        db.collection("moais").whereField("password", isEqualTo: myPassword).getDocuments { (snaps, err) in
            if err != nil {
                print("エラーでした~~\(err)")
            }else {
                for document in snaps!.documents {
                    dataGetJudge = true
                    print("取れたデータがこちら！！！！！\n\(document.documentID) => \(document.data())")
                    //下のようにするとデータの中の値まで取得できる
                    //print(document.data()["password"]!)
                    
                    //アラートで「この模合で良いですか？」と確認させる
                    self.ConfirmationAlert(groupName: document.data()["groupName"] as! String)
                }
            }
            //もしdataGetJudgeがfalseのままだったら入力した値に該当する模合は存在しなかったことになる
            if dataGetJudge == false {
                self.NoMoaiAlert()
                print("そんな模合ねーよ！！！！")
            }
            
        }
    }
    
    @objc func donePressed() {
        myPassword = textField.text ?? ""
        print(myPassword)
        view.endEditing(true)
    }
    @objc func cancelPressed() {
        view.endEditing(true)
    }
    
    private func ConfirmationAlert(groupName: String) {
        let message = "グループ名：\(groupName)"
        let alert: UIAlertController = UIAlertController(title: "参加する模合で以下でお間違いありませんか？", message: message, preferredStyle:  UIAlertController.Style.alert)
        let joinAction: UIAlertAction = UIAlertAction(title: "参加", style: UIAlertAction.Style.default, handler:{
            // ボタンが押された時の処理を書く（クロージャ実装）
            (action: UIAlertAction!) -> Void in
            print("OK")
        })
        let cancelAction: UIAlertAction = UIAlertAction(title: "キャンセル", style: UIAlertAction.Style.cancel, handler:{
                // ボタンが押された時の処理を書く（クロージャ実装）
                (action: UIAlertAction!) -> Void in
                print("Cancel")
            })
        alert.addAction(cancelAction)
        alert.addAction(joinAction)
        present(alert, animated: true, completion: nil)
    }
    
    private func NoMoaiAlert() {
        let alert: UIAlertController = UIAlertController(title: "合言葉が違います。", message: "ど〜んまい⭐︎", preferredStyle:  UIAlertController.Style.alert)
        let OKAction: UIAlertAction = UIAlertAction(title: "OK", style: UIAlertAction.Style.cancel, handler:{
                // ボタンが押された時の処理を書く（クロージャ実装）
                (action: UIAlertAction!) -> Void in
                print("Cancel")
            })
        alert.addAction(OKAction)
        present(alert, animated: true, completion: nil)
    }
    
}
