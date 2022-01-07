//
//  RecordSavingViewController.swift
//  MoaiApp
//
//  Created by 玉城秀大 on 2021/11/13.
//

import UIKit
import Firebase

class RecordSavingViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var memberListStackView: UIStackView!
    @IBOutlet weak var submitStackView: UIStackView!
    @IBOutlet weak var memberListTableView: UITableView!
    @IBOutlet weak var recordButton: UIButton!
    
    @IBOutlet weak var memberListSVHeightConstraints: NSLayoutConstraint!
    @IBOutlet weak var memberListTVHeightConstraints: NSLayoutConstraint!
    
    var user:User?
    var moaiID:String?
    var recordDate:String?
    let db = Firestore.firestore()
    
    //模合全体のメンバー
    var members:[ [String:Any] ]?
    var savingAmount:Int?
    //積み立てをしているメンバー
    var savingMembers:[ [String:Any] ] = []
    
    //infoボタンのタップ時のアラート用
    var alertController: UIAlertController!
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.moaiID = self.user?.moais[1]
    
        for member in self.members! {
            if member["saving"] as! Int == 1 {
                savingMembers.append(member)
            }
        }
        print("~~~~~~~~~~~~~~~~~~~~~~~~~~~~~")
        print(savingMembers)

        memberListTableView.delegate = self
        memberListTableView.dataSource = self
        //セルを選択&スクロール不可
        memberListTableView.allowsSelection = false
        memberListTableView.isScrollEnabled = false

        setupView()
        
    }
    
    private func setupView() {
        // StackViewの高さ = cellの高さ(70) * 人数
        let memberListSVHeight:CGFloat = CGFloat(70 * (self.savingMembers.count) )
        self.memberListSVHeightConstraints.constant = memberListSVHeight
        self.memberListTVHeightConstraints.constant = memberListSVHeight
        
        recordButton.backgroundColor = .barColor()
        recordButton.layer.cornerRadius = 15

    }
    
    //ツールバーをセット
    private func setToolbar(textfield: UITextField) {
        //ツールバー
        let toolbar = UIToolbar(frame: CGRect(x: 0, y: 0, width: view.frame.size.width, height: 50))
        //toolbarに表示させるアイテム
        let space = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: self, action: nil)
        let done = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(self.donePressed))
        let cancel = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(self.cancelPressed))
        toolbar.setItems([cancel , space, done ], animated: true)
        
        textfield.inputAccessoryView = toolbar
    }
    
    @objc private func donePressed() {
        view.endEditing(true)
    }
    @objc private func cancelPressed() {
        view.endEditing(true)
    }
    @objc private func tappedButton(_ sender:UIButton) {
        print("ボタンのタグは\(sender.tag)だよ")
        print(sender)
        
        let button:UIButton = sender as! UIButton
        let buttonTypeNum = button.tag % 10  //払ったか払ってないかを判別するための番号
        let buttonPersonNum = (button.tag / 10) - 1  //そのボタンに対応する人の配列番号
        //ボタンに曇りガラスをかける
        tapToSetBlurEffect(button: button)
        
        // ◯ か × ならsavingMembersに"paid"に金額を追加(△押下時の整合性を保つため数字で保存)
        // △なら金額を入力させ、その値をsavingMembersの"paid"に金額を入れる
        switch buttonTypeNum {
        case 1:
            addPaid(personNum: buttonPersonNum , amount: self.savingAmount!)
        case 2:
            addPaid(personNum: buttonPersonNum, amount: 0)
        case 3:
            sankakuAlertAndPaid(personNum: buttonPersonNum, button: button)
        default:
            print("このプリント分が吐き出されているということは、何かしらエラーが起きているという事だ。")
        }
    }
    @objc private func tappedInfoButton(_ sender:UIButton) {
        print("infoボタンがタップされました。")
        let title = "各ボタンについて"
        let message = "積立額を払った人は'◯'" + "\n" + "払ってない人は'×'" + "\n" + "払ったが全額は払ってない人は'△'" + "\n" + "をタップしてください。"
        self.alert(title: title, message: message)
    }
    
    //曇りガラスをセット
    func tapToSetBlurEffect(button: UIButton) {
        //セルだけのタグ
        let cellTag = button.tag / 10
        //ボタンだけのタグ
        let buttonTag = button.tag % 10
        let cell = self.memberListTableView.viewWithTag(cellTag)
        let stackViewH = cell?.getSubView(checkClass: UIStackView.self)
        
        //stackViewのボタンにかかっているviewを取り除く
        for i in 0...2 {
            print("============================")
            //stackViewのボタンにかかっているviewを取り除く
            let buttonTag2 = Int(String(cellTag) + String(i + 1) )!
            let button2 = stackViewH?.viewWithTag(buttonTag2)
            let sample = button2?.viewWithTag(i + 1)
            print(button2!)
            print(sample)
            if let blur = button2?.viewWithTag(i + 1) {
                blur.removeFromSuperview()
            }
        }
        //△以外が押されて、かつ、△にサブビューがかかっているなら、サブビューを削除
        guard let sankakuButtonTag = Int(String(cellTag) + String(3) ) else {return}
        //押されたボタンの列の△ボタン
        let sankakuButton = stackViewH?.viewWithTag(sankakuButtonTag)
        if let sankakuAMount = sankakuButton?.viewWithTag(99) {
            sankakuAMount.removeFromSuperview()
        }
        
        //引数のボタンに曇りガラスを、その他のボタンには透明のviewをかける
        for i in 0...2 {
            
            let buttonTag2 = Int(String(cellTag) + String(i + 1) )!
            let button2 = stackViewH?.viewWithTag(buttonTag2)
            //タップしたボタンにだけblurをかける
            if buttonTag == (i + 1) {
                let blurEffect = UIBlurEffect(style: .extraLight)
                let blurEffectView = UIVisualEffectView(effect: blurEffect)
                blurEffectView.frame.size.height = 50
                blurEffectView.frame.size.width = self.memberListStackView.frame.width / 5 - 5
                blurEffectView.tag = i + 1
                button2?.addSubview(blurEffectView)
            }
        }
    }
    
    //払った人と、払った金額
    func addPaid(personNum:Int, amount:Int) {
        savingMembers[personNum]["amount"] = amount
        print("savingMembers[personNum]  --->  \(savingMembers[personNum])")
    }
    
    func sankakuAlertAndPaid(personNum:Int, button:UIButton) {
        var savingAmount:Int?
        alertController = UIAlertController(title: title,
                                    message: "金額を入力してください",
                                    preferredStyle: .alert)
        alertController.addTextField { (textField) in
            textField.delegate = self
            textField.keyboardType = .asciiCapableNumberPad
        }
        let cansel = UIAlertAction(title: "キャンセル", style: .cancel) { (action) in print("キャンセルがタップされたよん♪") }
        let ok = UIAlertAction(title: "OK", style: .default, handler: {[weak alertController] (action) -> Void in
            //textFeildは一つしか定義してないので、firstを決め打ちで指定
            guard let textField = alertController?.textFields?.first else {return}
            if textField.text == "" || textField.text == nil {
                self.alert(title: "金額が未入力です。", message: "")
            }else {
                savingAmount = Int(textField.text!)
                self.addPaid(personNum: personNum, amount: savingAmount!)
                
                //入力金額を画像の上に貼り付ける
                let outLength:CGFloat = ( (button.frame.size.width * 1.3) - (button.frame.size.width) ) / 2
                //ちょっとはみ出すように設定
                let frame = CGRect(x: -outLength , y: 0 , width: button.frame.size.width * 1.3, height: button.frame.size.height)
                let label = UILabel(frame: frame)
                label.tag = 99
                label.text = String(textField.text!) + "円"
                label.font = UIFont.boldSystemFont(ofSize: 20)
                label.textColor = UIColor.textColor()
                label.textAlignment = NSTextAlignment.center
                button.addSubview(label)
                
            }
        })
        alertController.addAction(cansel)
        alertController.addAction(ok)
        present(alertController, animated: true)
    }

    func alert(title:String, message:String) {
        alertController = UIAlertController(title: title,
                                    message: message,
                                    preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "OK",
                                    style: .default,
                                    handler: nil))
        present(alertController, animated: true)
    }
    
    @IBAction func pushReodeButton(_ sender: Any) {
        var paidAmounts: [ Dictionary<String,Any> ] = []
        for member in self.savingMembers {
            if member["amount"] == nil {
                print("記録してないやついるやんけ")
                alert(title: "記録してないやついるやんけ", message: "さっさとそこのボタン押してこんかい")
                return
            }else {
                //DBに保存用のデータ作成
                let id = member["id"] as! String
                let amount = member["amount"] as! Int
                let data: Dictionary<String, Any> = ["id": id, "amount": amount]
                paidAmounts.append(data)
            }
        }
        //DBに保存
        record(paidAmounts: paidAmounts, recordDate: self.recordDate!)
    }
    
    func record(paidAmounts: [ [String : Any] ], recordDate:String ) {
        let dic = ["paidAmounts": paidAmounts]
        self.db.collection("moais").document(moaiID!).collection("savings").document(recordDate).setData(dic) { (err) in
            if let err = err {
                print("エラーです。 ---->  \(err)")
                return
            }
            print("成功です〜ちゃんとデータ記録できました〜")
            self.alert(title: "記録が完了しました。", message: "")
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                self.navigationController?.popViewController(animated: true)
            }
        }
    }
    
}


extension RecordSavingViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return savingMembers.count
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        //セルにタグをつける
        cell.tag = indexPath.row + 1
        //セルにstackViewを配置
        setupStackView(row: indexPath.row, cell: cell)
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70
    }
    
    private func setupStackView(row:Int,cell:UITableViewCell) {
        let member = savingMembers[row]
        //stackViewを宣言
        let stackViewFrame = CGRect(x: 0, y: 0, width: self.memberListStackView.frame.width, height: 60)
        let stackViewH = UIStackView(frame: stackViewFrame)
        stackViewH.tag = row + 1
        //コードでstackViewにconstraintsをつける方法
        stackViewH.isLayoutMarginsRelativeArrangement = true
        stackViewH.directionalLayoutMargins = NSDirectionalEdgeInsets(top: 10, leading: 10, bottom: 0, trailing: 10)
        //水平方向に指定
        stackViewH.axis = .horizontal
        //横に均等に配置
        stackViewH.contentMode = .scaleToFill
        stackViewH.distribution = .fillEqually
        
        stackViewH.backgroundColor = .white
        
        //stackViewHにラベルとテキストフィールドを配置
        let label = UILabel()
        label.sizeToFit()
        label.textColor = .textColor()
        label.text = member["name"] as? String
        label.textAlignment = .center
        stackViewH.addArrangedSubview(label)
        
        //stackViewにボタンを配置
        for i in 0...2 {
            let button = UIButton()
            button.frame = CGRect(x: 0, y: 0, width: stackViewH.frame.width / 5, height: 60)
            
            //ボタンのタグからSVを判別し、メソッドで利用するために文字として結合させてる
            let buttonTagAsString = String(row + 1) + String(i + 1) //メンバーが１０人以上だとエラーになる
            let buttonTag:Int = Int(buttonTagAsString)!
            button.tag = buttonTag
            button.layer.borderWidth = 1
            button.layer.borderColor = UIColor.lightGray.cgColor
            button.addTarget(self,action: #selector(self.tappedButton(_ :)),for: .touchUpInside)
            
            var image = UIImage()
            //ボタンにタグつけ（メソッドに引数をつけて、それをタグで判別したいから）
            switch i + 1 {
            case 1:
                image = UIImage(named: "maru")!
            case 2:
                image = UIImage(named: "batu")!
            case 3:
                image = UIImage(named: "sankaku")!
            default:
                return
            }
            button.setImage(image, for: .normal)
            stackViewH.addArrangedSubview(button)
        }
        
        //インフォメーションマークを配置
        let infoButton = UIButton()
        let info:UIImage = UIImage(named: "info")!
        infoButton.setImage(info, for: .normal)
        stackViewH.addArrangedSubview(infoButton)
        infoButton.addTarget(self,action: #selector(self.tappedInfoButton(_ :)),for: .touchUpInside)
        
        //もとのstackViewにstackViewHを追加
        cell.addSubview(stackViewH)
    }
    
}

//子クラスの取得
extension UIView {
    func getSubView(checkClass : AnyClass) -> AnyObject? {
        //子のViewを取得
        for subView in self.subviews {
            //その子のViewが引数のクラスだったらそのオブジェクトを返す
            if type(of: subView) == checkClass {
                return subView
            } else {
                //違ったら下のViewを再起的にチェックし、見つかったらそのViewを返す
                if let view = subView.getSubView(checkClass : checkClass ) {
                    return view
                }
            }
        }
        return nil
    }
}
