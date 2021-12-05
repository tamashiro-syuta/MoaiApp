//
//  RecordMoaiInfoViewController.swift
//  MoaiApp
//
//  Created by 玉城秀大 on 2021/08/02.
//

import UIKit
import Firebase
import FSCalendar

//記録画面
class RecordMoaiInfoViewController: UIViewController,UITextFieldDelegate {
    
    let db = Firestore.firestore()
    
    var user:User?
    
    var moai:Moai?
    var moaiID:String?
    var newMembers:[ [String:Any] ] = []
    //メンバーの名前とスイッチを紐づけるための配列
//    var memberArray: [ [String:Any] ]?
    
    var nextMoai:MoaiRecord?
    var nextMoaiID:String?
    
    var newNextMoaiDate:Date?
    var newNextMoaiDateID:String?
    
    let calendarView = UIView()
    var choiceDateCalendar: FSCalendar = FSCalendar()
    var selectedDate: [Any]? = nil
    
    var datePicker = UIDatePicker()
    var getMoneyPersonPickerView = UIPickerView()
    
    
    @IBOutlet weak var paidPeopleSVHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var contentViewHeightConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var dateStackView: UIStackView!
    @IBOutlet weak var getMoneyPersonStackView: UIStackView!
    @IBOutlet weak var locationStackView: UIStackView!
    @IBOutlet weak var startTimeStackView: UIStackView!
    @IBOutlet weak var paidPeopleStackView: UIStackView!
    @IBOutlet weak var noteStackView: UIStackView!
    @IBOutlet weak var recordButtonStackView: UIStackView!
    @IBOutlet weak var recordButton: UIButton!
    
    
    @IBOutlet weak var dateTextField: UITextField!
    @IBOutlet weak var getMoneyPersonTextField: UITextField!
    @IBOutlet weak var locationTextField: UITextField!
    @IBOutlet weak var startTimeTextField: UITextField!
    @IBOutlet weak var noteTextField: UITextField!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.moaiID = self.user?.moais[1]
        
        self.setupCalendar()
        
        //PaidPeopleSVの高さを０に設定し、初期状態では見えなくする
        let paidPeopleSVHeight:CGFloat = 0
        paidPeopleSVHeightConstraint.constant = paidPeopleSVHeight
        let contentViewHeight = contentView.frame.height
        // 下の制約の「-100」はデフォルトで設定しているpaidPeopleSVの高さの部分を引いてる
        contentViewHeightConstraint.constant = contentViewHeight + paidPeopleSVHeight - 100
        
        //startTimeTextFieldの初期値の処理(DBの値を成形し文字列型に変換)
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        let startTime = formatter.string(from: self.nextMoai!.date.dateValue())
        
        choiceDateCalendar.delegate = self
        choiceDateCalendar.dataSource = self
        
        dateTextField.delegate = self
        noteTextField.delegate = self
        getMoneyPersonTextField.delegate = self
        locationTextField.delegate = self

        dateTextField.placeholder = DateUtils.MddEEEFromDate(date: self.nextMoai!.date.dateValue())
        noteTextField.placeholder = self.nextMoai?.note
        getMoneyPersonTextField.placeholder = self.nextMoai?.getMoneyPerson["name"] as! String
        locationTextField.placeholder = self.nextMoai?.location["name"] as! String
        startTimeTextField.placeholder = startTime
        
        getMoneyPersonPickerView.delegate = self
        
        setToolbar()

        //受取人を除いたメンバーの数だけ配列にfalseを入れる
        newMembers = self.moai!.members
        for i in 0...(newMembers.count - 1) {
            newMembers[i]["payOrNot"] = false
        }
//        for i in 0..<memberArray!.count {
//            //Any型を許容する場合、IntやBoolは使えないので、stirngで"false"と指定する
//            memberArray?[i].updateValue("false", forKey: "payOrNot")
//        }
//        print("memberArrayの値　→→→ \(memberArray)")
    }
    
    private func setToolbar() {
        let toolbar = UIToolbar(frame: CGRect(x: 0, y: 0, width: view.frame.size.width, height: 50))
        //toolbarに表示させるアイテム
        let space = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: self, action: nil)
        let done = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(self.donePressed))
        let cancel = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(self.cancelPressed))
        toolbar.setItems([cancel , space, done ], animated: true)
        
        dateTextField.inputView = calendarView
        dateTextField.inputAccessoryView = toolbar
        
        noteTextField.inputAccessoryView = toolbar
        
        getMoneyPersonTextField.inputView = getMoneyPersonPickerView
        getMoneyPersonTextField.inputAccessoryView = toolbar
        
        locationTextField.inputAccessoryView = toolbar
        
        //datePickerの設定
        datePicker.frame = CGRect(x: 0, y: 0, width: view.frame.width, height: view.frame.height / 3)
        datePicker.datePickerMode = UIDatePicker.Mode.time
        datePicker.preferredDatePickerStyle = .wheels
        datePicker.timeZone = NSTimeZone.local
        datePicker.locale = NSLocale(localeIdentifier: "ja_JP") as Locale
        
        startTimeTextField.inputView = datePicker
        startTimeTextField.inputAccessoryView = toolbar
    }
    
    // 支払い済みの人をスイッチで記入する機能を、模合のメンバーに応じてど動的に配置する
    private func setupPaidPeopleSV(members: [ [String:Any] ]) {
        //paidPeopleSVのサブビューを削除（メソッドを複数回使用した時にサブビューが二重にならないように！）
        var subviews = paidPeopleStackView.subviews
        for subview in subviews {
            subview.removeFromSuperview()
        }
        //payOrNotの正誤を全てfalseに設定（PaidPeopleSVのビューを更新する際にこちらを変更しないと正しい処理にならないため）
        //全てのメンバーのpayOrNotをfalseにする
        for i in 0...newMembers.count - 1 {
            newMembers[i].updateValue(false, forKey: "payOrNot")
        }

        
        paidPeopleStackView.backgroundColor = .white
        //paidPeopleSVの高さの変更
        let paidPeopleSVHeight:CGFloat = CGFloat(60 * (self.moai?.members.count)! + 50)
        paidPeopleSVHeightConstraint.constant = paidPeopleSVHeight
        let contentViewHeight = contentView.frame.height
        // 下の制約の「-100」はデフォルトで設定しているpaidPeopleSVの高さの部分を引いてる
        contentViewHeightConstraint.constant = contentViewHeight + paidPeopleSVHeight - 100
        
        //paidPeopleStacViewにラベルを追加
        let label = UILabel()
        label.heightAnchor.constraint(equalToConstant: 50.0).isActive = true
        label.text = "模合代の支払いの有無"
        label.backgroundColor = .barColor()
        self.paidPeopleStackView.addArrangedSubview(label)
        
        
        //メンバーの数だけラベルとスイッチを配置
        for (i,member) in members.enumerated() {
            
            //memberが受取と一致しなかったら下の処理(ラベルとスイッチの設置)を行う
            if member["name"] as! String != self.getMoneyPersonTextField.text {
                print("\(member["name"])は、受取人じゃないから、ラベルとスイッチを貼るね〜〜〜〜")
                let stackViewFrame = CGRect(x: 0, y: 0, width: self.paidPeopleStackView.frame.width, height: 30)
                let stackViewH = UIStackView(frame: stackViewFrame)
                //水平方向に設定
                stackViewH.axis = .horizontal
                //横にバランスよく配置
                stackViewH.contentMode = .scaleToFill
                stackViewH.distribution = .fillEqually
                
                let label = UILabel()
                label.sizeToFit()
                label.textColor = .textColor()
                let paySwitchFrame = CGRect(x: 10, y: 20, width: 60, height: 30)
                let paySwitch = UISwitch(frame: paySwitchFrame)
                paySwitch.addTarget(self, action: #selector(self.changeSwitch), for: UIControl.Event.valueChanged)
                //UISwitchのタグ番号をメンバーの配列に沿うようにセット
                paySwitch.tag = i
                print("\(member["name"])のUIswitchのタグは\(paySwitch.tag)番です")
                label.text = member["name"] as! String
                paySwitch.onTintColor = UIColor.barColor()
                
                //stackViewにラベルとスイッチを追加
                stackViewH.addArrangedSubview(label)
                stackViewH.addArrangedSubview(paySwitch)
                
                //もとのstackViewにstackViewHを追加
                self.paidPeopleStackView.addArrangedSubview(stackViewH)
            }
        }
    }
    
    @objc func changeSwitch(sender: UISwitch) {
        //押された番号の配列の正誤を反転させる
        print("sender,tag -> \(sender.tag)")
        if newMembers[sender.tag]["payOrNot"] as? Bool == false {
            print("false --> true")
            newMembers[sender.tag].updateValue(true, forKey: "payOrNot")
            print(newMembers[sender.tag]["payOrNot"])
        }else {
            print("true --> false")
            newMembers[sender.tag].updateValue(false, forKey: "payOrNot")
            print(newMembers[sender.tag]["payOrNot"])
        }
        print("\(newMembers[sender.tag]["name"])の支払い状況 --> \(newMembers[sender.tag]["payOrNot"])")
//        if self.memberArray?[sender.tag]["payOrNot"] as! String == "false" {
//            print("false -> true")
//            self.memberArray?[sender.tag].updateValue("true", forKey: "payOrNot")
//            print(self.memberArray?[sender.tag]["payOrNot"])
//        }else {
//            print("true -> false")
//            self.memberArray?[sender.tag].updateValue("false", forKey: "payOrNot")
//            print(self.memberArray?[sender.tag]["payOrNot"])
//        }
//        print("\(memberArray?[sender.tag]["name"])の支払い状況は、\(memberArray?[sender.tag]["payOrNot"])です。")
//        print("memberArray -> \(memberArray)")
    }
    
    @IBAction func record(_ sender: Any) {
        print("ボタン押したよ")
        //nextのデータを値が更新されているもののみアップデートする
        var newDate:Timestamp = self.nextMoai!.date
        var newGetMoneyPerson:[String:String] = self.nextMoai!.getMoneyPerson
//        var newGetMoneyPersonID:String = self.nextMoai!.getMoneyPersonID
        var newLocation:[String:Any] = self.nextMoai!.location
        var newNote:String = self.nextMoai!.note
        
        print("ボタン押したよ")

        //テキストフィールドの値によって処理を変更
        if self.dateTextField.text != "" {
            //Date型のselectedDateの値をTimestamp型に変換
            let selectedDateTypeOfTimestamp = Timestamp(date: self.selectedDate?[0] as! Date )
            newDate = selectedDateTypeOfTimestamp
        }
        if self.getMoneyPersonTextField.text != "" {
            newGetMoneyPerson["name"] = self.getMoneyPersonTextField.text!
            for member in newMembers {
                if member["name"] as! String == self.getMoneyPersonTextField.text {
                    newGetMoneyPerson["id"] = member["id"]! as! String
                }
            }
        }
        if self.locationTextField.text != "" {
            newLocation["name"] = self.locationTextField.text!
        }
        if self.noteTextField.text != "" {
            newNote = self.noteTextField.text!
        }
        
        //未定の状態なら記録できないようにする
        if newGetMoneyPerson["name"] == "未定" || newGetMoneyPerson["id"] == "未定" || newLocation["name"] as! String == "未定" {
            print("未定の状態のやつあるから、記録しませーん")
            let alert: UIAlertController = UIAlertController(title: "'未定'の箇所があります。", message: nil, preferredStyle: UIAlertController.Style.alert)
            let OKAction: UIAlertAction = UIAlertAction(title: "OK", style: UIAlertAction.Style.cancel, handler:{
                // ボタンが押された時の処理を書く（クロージャ実装）
                (action: UIAlertAction!) -> Void in
                print("OK")
            })
            alert.addAction(OKAction)
            present(alert, animated: true, completion: nil)
        }
        
        //UISwitchの状態によって、支払い済みか未払いか判別する
        var paidsID: [String] = []
        var paidsName: [String] = []
        var unpaidsID:[String] = []
        var unpaidsName: [String] = []
        //メンバーを支払い済みかそうでないかを分ける
        for member in newMembers {
            if member["name"] as! String != self.getMoneyPersonTextField.text {
                print("member -> \(member)")
                //メンバーのpayOrNotじゃなくて、別の配列で判定する
                if member["payOrNot"] as! Bool == true {
                    paidsName.append(member["name"] as! String)
                    paidsID.append(member["id"] as! String)
                }else {
                    unpaidsName.append(member["name"] as! String)
                    unpaidsID.append(member["id"] as! String)
                }
                print("paidsName -> \(paidsName)")
                print("paidsID -> \(paidsID)")
                print("paidsName -> \(paidsName)")
                print("unpaidsID -> \(unpaidsID)")
            }
        }
        if unpaidsName.count == 0 {
            unpaidsName.append("なし")
        }
        
        print("paidsID　→→→→→　\(paidsID)")
        print("paidsName　→→→→→　\(paidsName)")
        print("unpaidsID　→→→→　\(unpaidsID)")
        print("unpaidsName　→→→→→　\(unpaidsName)")
        
        
        let changedInfo = "日付：\(DateUtils.MddEEEFromDate(date: newDate.dateValue()))" + "\n" + "模合代受け取り：\(newGetMoneyPerson["name"])" + "\n" + "場所：\(newLocation["name"]!)" + "\n" + "備考：\(newNote)" + "\n" + "支払い済み：\(paidsName.joined(separator: ","))" + "\n" + "未払い：\(unpaidsName.joined(separator: ","))"
        
        let alert: UIAlertController = UIAlertController(title: "以下の内容はでよろしいですか？", message: changedInfo, preferredStyle:  UIAlertController.Style.alert)
        let joinAction: UIAlertAction = UIAlertAction(title: "はい", style: UIAlertAction.Style.default, handler:{
            // ボタンが押された時の処理を書く（クロージャ実装）
            (action: UIAlertAction!) -> Void in
            
            //nextに入っていたデータをpastRecordに入れる
            self.addRecordToPastRecord(paidCount: paidsID.count, newDate: newDate, newGetMoneyPerson: newGetMoneyPerson, newLocation: newLocation, newNote: newNote, paidsID: paidsID, unpaidsID: unpaidsID)
            
            //nextにあったデータの削除
            self.removeNextMoaiInfo()
            
            //nextに新しいデータを入れる
            self.addNewRecordToNext()
            
            //元の画面に戻る
            self.navigationController?.popViewController(animated: true)
            
        })
        let cancelAction: UIAlertAction = UIAlertAction(title: "取り消し", style: UIAlertAction.Style.cancel, handler:{
            // ボタンが押された時の処理を書く（クロージャ実装）
            (action: UIAlertAction!) -> Void in
            print("Cancel")
        })
        alert.addAction(cancelAction)
        alert.addAction(joinAction)
        present(alert, animated: true, completion: nil)
    }
    
    @objc private func donePressed() {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        let date = formatter.string(from: datePicker.date)
        startTimeTextField.text = date
        view.endEditing(true)
    }
    
    @objc private func cancelPressed() {
        //編集中のものを消去
        if dateTextField.isEditing == true {
            dateTextField.text = ""
        }
        if noteTextField.isEditing == true {
            noteTextField.text = ""
        }
        if getMoneyPersonTextField.isEditing == true {
            getMoneyPersonTextField.text = ""
        }
        if locationTextField.isEditing == true {
            locationTextField.text = ""
        }
        if startTimeTextField.isEditing == true {
            startTimeTextField.text = ""
        }

        view.endEditing(true)
    }
    
    //DBにデータを保存するメソッド
    private func addRecordToPastRecord(paidCount: Int, newDate:Timestamp, newGetMoneyPerson:[String:String], newLocation:[String:Any], newNote:String, paidsID:[String], unpaidsID:[String]) {
        guard let moaiID = self.moaiID else {
            print("なんや知らんけど、moaiID取れて無いっすわ")
            return
        }
        
        let dic = [
            "amount": self.moai!.amount * paidCount, //模合の代金×払った人数
            "date":newDate,
            "getMoneyPerson":newGetMoneyPerson,
//            "getMoneyPersonID":newGetMoneyPersonID,
            "location":newLocation,
            "note": newNote,
            "paid":paidsID,
            "unpaid":unpaidsID
        ] as [String : Any]
        
        self.db.collection("moais").document(moaiID).collection("pastRecords").document(self.nextMoaiID!).setData(dic) { (err) in
            if let err = err {
                print("エラーでっせ　\(err)")
                return
            }
            print("模合データの記録に成功しました。")
        }
    }
   
    private func removeNextMoaiInfo() {
        guard let moaiID = self.moaiID else {
            print("なんや知らんけど、moaiID取れて無いっすわ")
            return
        }
        self.db.collection("moais").document(moaiID).collection("next").document(self.nextMoaiID!).delete { (err) in
            if let err = err {
                print("nextに保存されていたデータの削除に失敗しました。　\(err)")
                return
            }
            print("nextに保存されていたデータの削除に成功しました。")
        }
    }
    
    private func addNewRecordToNext() {
        guard let moaiID = self.moaiID else {
            print("なんや知らんけど、moaiID取れて無いっすわ")
            return
        }
        
        guard let moai = self.moai else {return}
        print("weekの値は\(moai.week) | dayの値は\(moai.day)")
        let weekAndDayArray:[Int] = moai.switchMoaiDate(weekNum: moai.week, weekDay: moai.day)
        
        self.newNextMoaiDate = DateUtils.returnNextMoaiDate(weekNum: weekAndDayArray[0], weekDay: weekAndDayArray[1])
        self.newNextMoaiDateID = DateUtils.stringFromDateoForSettingRecordID(date: self.newNextMoaiDate!)
        
        let dic = [
            "amount": 0,
            "date":newNextMoaiDate,
            "getMoneyPerson":"未定",
            "getMoneyPersonID":"未定",
            "locationName":"未定",
            "location":GeoPoint(latitude: 1, longitude: 1),
            "startTime":"20:00",
            "note":""
        ] as [String : Any]
        
        self.db.collection("moais").document(moaiID).collection("next").document(newNextMoaiDateID!).setData(dic) { (err) in
            if let err = err {
                print("エラーでっせ\(err)")
                return
            }
            print("新しくnextにデータを追加しました。")
            self.dismiss(animated: true, completion: nil)
        }
    }
}






extension RecordMoaiInfoViewController: FSCalendarDelegate,FSCalendarDataSource {
    
    //カレンダーの設定
    private func setupCalendar() {
        
        self.choiceDateCalendar.frame = CGRect(x: 0, y: 0, width: view.frame.size.width, height: (view.frame.size.height / 2) - 50 )
        
        choiceDateCalendar.scrollDirection = .horizontal
        choiceDateCalendar.locale = Locale(identifier: "ja")
        choiceDateCalendar.appearance.headerTitleFont = UIFont.systemFont(ofSize: 20) //ヘッダーテキストサイズ
        choiceDateCalendar.appearance.headerDateFormat = "yyyy年M月"
        choiceDateCalendar.appearance.headerMinimumDissolvedAlpha = 0 //先月、来月のアルファ値
        choiceDateCalendar.appearance.titleWeekendColor = .red //週末、休日の色
        
        let calendarToolbar = UIToolbar(frame: CGRect(x: 0, y: 0, width: view.frame.size.width, height: 40))
        //toolbarに表示させるアイテム
        let space = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: self, action: nil)
        let nextMonthButton = UIBarButtonItem(barButtonSystemItem: .fastForward , target: self, action: #selector(self.nextMonth(_:)))
        let previousMonthButton = UIBarButtonItem(barButtonSystemItem: .rewind, target: self, action: #selector(self.previousMonth(_:)))
        calendarToolbar.setItems([previousMonthButton , space, nextMonthButton ], animated: true)
        //UIToolBarを透明にする
        calendarToolbar.barTintColor = UIColor.white
        calendarToolbar.isTranslucent = true
        calendarToolbar.setBackgroundImage(UIImage(), forToolbarPosition: UIBarPosition.any, barMetrics: UIBarMetrics.default)
        calendarToolbar.setShadowImage(UIImage(), forToolbarPosition: UIBarPosition.any)
        
        self.calendarView.frame = CGRect(x: 0, y: 0, width: view.frame.size.width, height: (view.frame.size.height / 2) - 25 )
        self.calendarView.backgroundColor = .white
        self.calendarView.addSubview(choiceDateCalendar)
        self.calendarView.addSubview(calendarToolbar)
    }
    
    //日付を選択した時の処理
    func calendar(_ calendar: FSCalendar, didSelect date: Date, at monthPosition: FSCalendarMonthPosition) {
        // 処理
        self.selectedDate = [date , DateUtils.MddEEEFromDate(date: date)]
        dateTextField.text = selectedDate?[1] as! String
        
        print("selectedDateは\(selectedDate)")
    }
    
    @objc func previousMonth(_ sender: Any) {
        choiceDateCalendar.setCurrentPage(getPreviousMonth(date: choiceDateCalendar.currentPage), animated: true)
    }
    
    @objc func nextMonth(_ sender: Any) {
        choiceDateCalendar.setCurrentPage(getNextMonth(date: choiceDateCalendar.currentPage), animated: true)
    }
    
    func getNextMonth(date:Date)->Date {
        return  Calendar.current.date(byAdding: .month, value: 1, to:date)!
    }

    func getPreviousMonth(date:Date)->Date {
        return  Calendar.current.date(byAdding: .month, value: -1, to:date)!
    }
}


extension RecordMoaiInfoViewController: UIPickerViewDelegate,UIPickerViewDataSource {
    
    //列数
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    //行数
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
//        return memberArray!.count
        return (self.moai?.members.count)!
    }
    
    //表示内容
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
//        return memberArray![row]["name"] as! String
        return self.moai?.members[row]["name"] as? String
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
//        self.getMoneyPersonTextField.text = memberArray![row]["name"] as! String
//        //PaidSVに選択されたユーザー以外の名前とスイッチを配置
//        self.setupPaidPeopleSV(members: memberArray!)
        self.getMoneyPersonTextField.text = self.moai?.members[row]["name"] as? String
        self.setupPaidPeopleSV(members: newMembers)
    }
}


enum BorderPosition {
    case top, left, right, bottom
}

extension UIView {

    /// viewに枠線を表示する
    /// - Parameters:
    ///   - width: 太さ
    ///   - color: 色
    ///   - position: 場所
    func addBorder(width: CGFloat, color: UIColor, position: BorderPosition) {
        let border = CALayer()

        switch position {
        case .top:
            border.frame = CGRect(x: 0, y: 0, width: self.frame.width, height: width)
            border.backgroundColor = color.cgColor
            self.layer.addSublayer(border)
        case .left:
            border.frame = CGRect(x: 0, y: 0, width: width, height: self.frame.height)
            border.backgroundColor = color.cgColor
            self.layer.addSublayer(border)
        case .right:
            border.frame = CGRect(x: self.frame.width - width, y: 0, width: width, height: self.frame.height)
            border.backgroundColor = color.cgColor
            self.layer.addSublayer(border)
        case .bottom:
            border.frame = CGRect(x: 0, y: self.frame.height - width, width: self.frame.width, height: width)
            border.backgroundColor = color.cgColor
            self.layer.addSublayer(border)
        }
    }
}

//配列から値を指定して削除できる拡張機能
extension Array where Element: Equatable {
    mutating func remove(value: Element) {
        if let i = self.index(of: value) {
            self.remove(at: i)
        }
    }
}
