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
    
    var moai:Moai?
    
    var userID:String?
    
    var user: User?
    
    var newNextMoaiDate:Date?
    var newNextMoaiDateID:String?
    
    var groupName:String?
    var week:String = ""
    var day:String = ""
    var amount:String?
    var password:String?
    var savingAmount:Int = 0  //実施しない場合は0を取る設定なので初期値として0を入れる
    let dataSource1 = ["第１","第２","第３","第４"]
    let dataSource2 = ["月曜日","火曜日","水曜日","木曜日","金曜日","土曜日","日曜日"]
    
    @IBOutlet weak var groupNameTextField: UITextField!
    @IBOutlet weak var dateTextField: UITextField!
    @IBOutlet weak var amountTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var savingsTextField: UITextField!
    
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
        savingsTextField.inputAccessoryView = toolbar
        
        amountTextField.keyboardType = UIKeyboardType.numberPad
        savingsTextField.keyboardType = UIKeyboardType.numberPad
    }
    
    @IBAction func create(_ sender: Any) {
        if groupNameTextField.text?.isEmpty == false &&
           dateTextField.text?.isEmpty == false &&
           amountTextField.text?.isEmpty == false &&
           passwordTextField.text?.isEmpty == false
        {
            
            let docData = [
                "groupName": groupName,
                "week": week,
                "day": day,
                "amount": amount,
                "createdAt": Timestamp(),
                "password": password,
                "menbers": [userID],
                "next": [false],
                "savingAmount": savingsTextField.text ?? 0
            ] as [String : Any]
            
            //新規模合グループ作成
            self.db.collection("moais").document().setData(docData) { (err) in
                if let err = err {
                    print("新規模合の作成に失敗。moaisコレクションに情報が保存されませんでした。\(err)")
                    return
                }else {
                    //グループの引っ張り出し方は、passwordとgroupNameが一致するやつ
                    //エラーがでない＝保存完了？だから、たぶん、ID引っ張ってきて大丈夫？
                    self.db.collection("moais").whereField("password", isEqualTo: self.password!).whereField("groupName", isEqualTo: self.groupName!).getDocuments { (querySnapshot, err) in
                        if let err = err {
                            print("エラーでましたあああああ　\(err)")
                            return
                        }
                        let data = querySnapshot?.documents.first
                        guard let moaiID = data?.documentID else {
                            print("模合のID取れんかった")
                            return
                        }
                        
                        //模合情報を格納
                        self.moai = Moai(dic: docData)
                        //nextの情報作成
                        self.fetchNextMoaiDate(moai: self.moai!, moaiID: moaiID)
                    }
                }
            }
            
        }else {
            pushAlert()
            return
        }
    }
    
    //ユーザー情報から模合情報を取得し、新しい模合情報を追加後、DBに戻す    
    private func fetchAndResetUserMoaiInfo(moaiID: String) {
        var moaisArray: [String] = self.user!.moais
        moaisArray.append(moaiID)
        self.db.collection("users").document(self.userID!).updateData(["moais":moaisArray]) { (err) in
            if let err = err {
                print("エラーでっせ　\(err)")
                return
            }
            print("作成した模合の情報をユーザー情報用のDBに保存成功！！")
            // ~~~~~~~~~~~~~~~~~~~~~~ firebaseに保存された後に画面遷移する ~~~~~~~~~~~~~~~~~~~~~~~
            self.pushManagementVC()
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
    
    
    //画面遷移は、navigationのrootVCをtabBarControllerに上書き
    //まあ、やり方は、おいおい考えていきますわ〜〜〜〜〜〜〜〜〜〜〜〜〜〜〜〜〜〜〜〜〜〜〜〜〜〜〜〜〜〜〜〜〜〜〜〜〜〜〜
    private func pushManagementVC() {
        print("タブバーに画面遷移するよ")
        let tabBarController = standardTabBarController()
        self.navigationController?.navigationBar.isHidden = true
        
        self.navigationController?.pushViewController(tabBarController, animated: true)
    }
    
    private func fetchNextMoaiDate(moai:Moai, moaiID:String) {
        let weekAndDayArray:[Int] = moai.switchMoaiDate(weekNum: moai.week, weekDay: moai.day)
        
        self.newNextMoaiDate = DateUtils.returnNextMoaiDate(weekNum: weekAndDayArray[0], weekDay: weekAndDayArray[1])
        self.newNextMoaiDateID = DateUtils.stringFromDateoForSettingRecodeID(date: self.newNextMoaiDate!)
        
        let dic = [
            "date":self.newNextMoaiDate,
            "getMoneyPerson":"未定",
            "getMoneyPersonID":"未定",
            "location":"未定",
            "startTime":"20:00"
        ] as [String : Any]
        
        self.db.collection("moais").document(moaiID).collection("next").document(newNextMoaiDateID!).setData(dic) { (err) in
            if let err = err {
                print("エラーでっせ\(err)")
                return
            }
            print("新しくnextにデータを追加しました。")
        }
        //ユーザー情報から模合情報を取得し、新しい模合情報を追加後、DBに戻す
        self.fetchAndResetUserMoaiInfo(moaiID: moaiID)
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
