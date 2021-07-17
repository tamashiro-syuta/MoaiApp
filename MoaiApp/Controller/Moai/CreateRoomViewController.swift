//
//  CreateRoomViewController.swift
//  MoaiApp
//
//  Created by 玉城秀大 on 2021/06/25.
//

import UIKit
import Firebase
import FirebaseFirestore
import FirebaseAuth

class CreateRoomViewController: UIViewController {
    
    let db = Firestore.firestore()
    let userID = Auth.auth().currentUser!.uid as String
    
    var user: User?
    
    var groupName:String?
    var week:String = ""
    var day:String = ""
    var amount:String?
    var password:String?
    let dataSource1 = ["第１","第２","第３","第４"]
    let dataSource2 = ["月曜日","火曜日","水曜日","木曜日","金曜日","土曜日","日曜日"]
    
    @IBOutlet weak var groupNameTextField: UITextField!
    @IBOutlet weak var dateTextField: UITextField!
    @IBOutlet weak var amountTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    let pickerView1 = UIPickerView()
    let pickerView2 = UIPickerView()
    
    @IBOutlet weak var createButton: UIButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupViews()
        
    }
    
    private func setupViews() {
        createButton.layer.cornerRadius = createButton.frame.size.height / 3
        
        pickerView1.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.size.width, height: pickerView1.bounds.size.height)
        pickerView1.delegate = self
        pickerView2.delegate = self
        pickerView1.dataSource = self
        pickerView2.dataSource = self
        
        let vi = UIView(frame: pickerView1.bounds)
        vi.backgroundColor = UIColor.gray
        vi.addSubview(pickerView1)
        
        dateTextField.inputView = vi

        let toolbar = UIToolbar(frame: CGRect(x: 0, y: 0, width: view.frame.size.width, height: 50))
        //toolbarに表示させるアイテム
        let space = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: self, action: nil)
        let done = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(self.donePressed))
        let cancel = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(self.cancelPressed))
        toolbar.setItems([cancel , space, done ], animated: true)

        groupNameTextField.inputAccessoryView = toolbar
        dateTextField.inputAccessoryView = toolbar
        amountTextField.inputAccessoryView = toolbar
        passwordTextField.inputAccessoryView = toolbar
        
        amountTextField.keyboardType = UIKeyboardType.numberPad
    }
    
    @IBAction func create(_ sender: Any) {
        if groupNameTextField.text?.isEmpty == false &&
           dateTextField.text?.isEmpty == false &&
           amountTextField.text?.isEmpty == false &&
           passwordTextField.text?.isEmpty == false
        {
//            groupName = groupNameTextField.text
//            date = dateTextField.text
//            amount = amountTextField.text
//            password = passwordTextField.text
            
            let docData = [
                "groupName": groupName,
                "week": week,
                "day": day,
                "amount": amount,
                "createdAt": Timestamp(),
                "password": password,
                "menbers": [userID],
                "next": [false]
            ] as [String : Any]
            
            //新規模合グループ作成
            self.db.collection("moais").document().setData(docData) { (err) in
                if err != nil {
                    print("moaisコレクションに情報が保存されませんでした。\(err)")
                    return
                }else {
                    //エラーがでない＝保存完了？だから、たぶん、ID引っ張ってきて大丈夫？
                    self.db.collection("moais").whereField("password", isEqualTo: self.password).whereField("menbers", isEqualTo: [self.userID]).getDocuments { (querySnapshot, err) in
                        if let err = err {
                            print("エラーでましたあああああ　\(err)")
                            return
                        }
                        let data = querySnapshot?.documents.first
                        guard let moaiID = data?.documentID else {
                            print("模合のID取れんかった")
                            return
                        }
                        //ユーザー情報から模合情報を取得し、新しい模合情報を追加後、DBに戻す
                        self.fetchAndResetUserMoaiInfo(moaiID: moaiID)
                    }
                    
                    // ~~~~~~~~~~~~~~~~~~~~~~ firebaseに保存された時の処理(画面遷移) ~~~~~~~~~~~~~~~~~~~~~~~
                }
            }
            
        }else {
            pushAlert()
            return
        }
    }
    
    //ユーザー情報から模合情報を取得し、新しい模合情報を追加後、DBに戻す
    private func fetchAndResetUserMoaiInfo(moaiID: String) {
        self.db.collection("users").document(self.userID).getDocument { (snapshot, err) in
            if let err = err {
                print("エラーが出ました \(err)")
                return
            }
            let dic = snapshot?.data()
            self.user = User(dic: dic!)
            var moaisArray: [String] = self.user!.moais
            moaisArray.append(moaiID)
            self.db.collection("users").document(self.userID).updateData(["moais":moaisArray]) { (err) in
                if let err = err {
                    print("エラーでっせ　\(err)")
                    return
                }
                print("DBに保存成功！！")
            }
        }
    }
    
    
    
    private func pushAlert() {
        // ① UIAlertControllerクラスのインスタンスを生成
        // タイトル, メッセージ, Alertのスタイルを指定する
        // 第3引数のpreferredStyleでアラートの表示スタイルを指定する
        let alert: UIAlertController = UIAlertController(title: "空欄あり", message: "必須項目を埋めてください", preferredStyle:  UIAlertController.Style.alert)
        // ② Actionの設定
        // Action初期化時にタイトル, スタイル, 押された時に実行されるハンドラを指定する
        // 第3引数のUIAlertActionStyleでボタンのスタイルを指定する
        // OKボタン
        let defaultAction: UIAlertAction = UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler:{
            // ボタンが押された時の処理を書く（クロージャ実装）
            (action: UIAlertAction!) -> Void in
            print("OK")
        })
        // ③ UIAlertControllerにActionを追加
        alert.addAction(defaultAction)
        // ④ Alertを表示
        present(alert, animated: true, completion: nil)
    }
}







extension CreateRoomViewController: UIPickerViewDelegate,UIPickerViewDataSource,UITextFieldDelegate {
    
    // UIViewPickerの列(横方向)数を指定
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 2
    }
    
    // UIViewPickerの行(縦方向)数を指定
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        switch component {
        //１列目の行数
        case 0:
            return dataSource1.count
        //２列目の行数
        case 1:
            return dataSource2.count
        default:
            return 0
        }
    }
    
    // UIViewPickerの幅のサイズを返すメソッド
        func pickerView(_ pickerView: UIPickerView, widthForComponent component:Int) -> CGFloat {
            switch component {
            //1列目の幅
            case 0:
                return (UIScreen.main.bounds.size.width-20)/2
            //2列目の幅
            case 1:
                return (UIScreen.main.bounds.size.width-20)/2
            default:
                return (UIScreen.main.bounds.size.width-20)/2
            }
        }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        switch component {
        case 0:
            return dataSource1[row]
        case 1:
            return dataSource2[row]
        default:
            return "error"
        }
    }
    
    // UIViewPickerのrowが選択された時のメソッド
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        switch component {
        // 1列目が選択された時
        case 0:
            week = dataSource1[row]
            print("週の列に \(dataSource1[row]) が選択された。")
        // 2列目が選択された時
        case 1:
            day = dataSource2[row]
            print("曜日の列に \(dataSource2[row]) が選択された。")
        default:
            break
        }
    }
    
    @objc func donePressed() {
        dateTextField.text = week + day
        print(amountTextField.text)
        print(groupNameTextField.text)
        print(dateTextField.text)
        print(passwordTextField.text)
        //week,dayは、上のpickerViewでもう変数に値が入っている
        groupName = groupNameTextField.text
        amount = amountTextField.text
        password = passwordTextField.text
        view.endEditing(true)
    }
    @objc func cancelPressed() {
        view.endEditing(true)
    }
    
}
