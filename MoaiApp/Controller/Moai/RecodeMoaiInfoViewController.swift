//
//  RecodeMoaiInfoViewController.swift
//  MoaiApp
//
//  Created by 玉城秀大 on 2021/08/02.
//

import UIKit
import Firebase
import FSCalendar

//詳細画面
class RecodeMoaiInfoViewController: UIViewController,UITextFieldDelegate {
    
    let db = Firestore.firestore()
    
    var user:User?
    
    var moai:Moai?
    var moaiID:String?
    var moaiMenbersNameList:[String]?
    
    var nextMoai:MoaiRecord?
    var nextMoaiID:String?
    
    var newNextMoaiDate:Date?
    var newNextMoaiDateID:String?
    
    let calendarView = UIView()
    var choiceDateCalendar: FSCalendar = FSCalendar()
    var selectedDate: [Any]? = nil
    
    var getMoneyPersonPickerView = UIPickerView()
    var startTimePickerView = UIPickerView()
    let sampleArray:Array = ["","1","2","3","4","5","6"]
    
    @IBOutlet weak var recodeStackView: UIStackView!
    @IBOutlet weak var dateStackView: UIStackView!
    @IBOutlet weak var startTimeStackView: UIStackView!
    @IBOutlet weak var getMoneyPersonStackView: UIStackView!
    @IBOutlet weak var locationStackView: UIStackView!
    @IBOutlet weak var recodeButtonStackView: UIStackView!
    @IBOutlet weak var recodeButton: UIButton!
    
    
    @IBOutlet weak var dateTextField: UITextField!
    @IBOutlet weak var startTimeTextField: UITextField!
    @IBOutlet weak var getMoneyPersonTextField: UITextField!
    @IBOutlet weak var locationTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setupStackViews()
        
        self.moaiID = self.user?.moais[1]
        
        self.setupCalendar()
        
        choiceDateCalendar.delegate = self
        choiceDateCalendar.dataSource = self
        
        dateTextField.delegate = self
        startTimeTextField.delegate = self
        getMoneyPersonTextField.delegate = self
        locationTextField.delegate = self

        dateTextField.placeholder = DateUtils.stringFromDate(date: self.nextMoai!.date.dateValue())
        startTimeTextField.placeholder = self.nextMoai?.startTime
        getMoneyPersonTextField.placeholder = self.nextMoai?.getMoneyPerson
        locationTextField.placeholder = self.nextMoai?.locationName
        
        getMoneyPersonPickerView.delegate = self
        getMoneyPersonPickerView.tag = 1
        startTimePickerView.delegate = self
        startTimePickerView.tag = 2
        
        let toolbar = UIToolbar(frame: CGRect(x: 0, y: 0, width: view.frame.size.width, height: 50))
        //toolbarに表示させるアイテム
        let space = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: self, action: nil)
        let done = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(self.donePressed))
        let cancel = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(self.cancelPressed))
        toolbar.setItems([cancel , space, done ], animated: true)
        
        dateTextField.inputView = calendarView
        dateTextField.inputAccessoryView = toolbar
        
        startTimeTextField.inputView = startTimePickerView
        startTimeTextField.inputAccessoryView = toolbar
        
        getMoneyPersonTextField.inputView = getMoneyPersonPickerView
        getMoneyPersonTextField.inputAccessoryView = toolbar
        
        locationTextField.inputAccessoryView = toolbar
        
    }
    
    private func setupStackViews() {
        
        //costraintをコードで設定(詳しくは、レイアウトを書いている紙をチェック！！！)
        let viewHeight = UIScreen.main.bounds.size.height
        let viewWidth = UIScreen.main.bounds.size.width
        print("viewHeightの値は\(viewHeight)")
        print("viewWidthの値は\(viewWidth)")
        print("UIScreen.main.bounds.sizeは\(UIScreen.main.bounds.size)")
        
        //AutoresizingMaskをAutoLayoutの制約に置き換えるかどうか指定する値(必ずfalse)
        recodeStackView.translatesAutoresizingMaskIntoConstraints = false
        
        recodeStackView.heightAnchor.constraint(equalToConstant: viewHeight * 2 / 3).isActive = true
        recodeStackView.widthAnchor.constraint(equalToConstant: viewWidth * 5 / 6).isActive = true
        
        let changeSVHeight = recodeStackView.frame.size.height
        
        print("changeSVHeightの値は\(changeSVHeight)")
        print("changeSVHeightの値は\(recodeStackView.frame.size.width)")

        
        dateStackView.translatesAutoresizingMaskIntoConstraints = false
        dateStackView.heightAnchor.constraint(equalToConstant: changeSVHeight / 5).isActive = true
        
        startTimeStackView.translatesAutoresizingMaskIntoConstraints = false
        startTimeStackView.heightAnchor.constraint(equalToConstant: changeSVHeight / 5).isActive = true
        
        getMoneyPersonStackView.translatesAutoresizingMaskIntoConstraints = false
        getMoneyPersonStackView.heightAnchor.constraint(equalToConstant: changeSVHeight / 5).isActive = true
        
        locationStackView.translatesAutoresizingMaskIntoConstraints = false
        locationStackView.heightAnchor.constraint(equalToConstant: changeSVHeight / 5).isActive = true
        
        recodeButtonStackView.translatesAutoresizingMaskIntoConstraints = false
        recodeButtonStackView.heightAnchor.constraint(equalToConstant: changeSVHeight / 5).isActive = true
        
        recodeButton.frame.size.height = recodeButtonStackView.frame.size.height / 3
        recodeButton.layer.cornerRadius = recodeButton.frame.size.width / 6
        
        print("dateStackViewのheightの値は\(dateStackView.frame.size.height)")
        print("startTimeStackViewのheightの値は\(startTimeStackView.frame.size.height)")
        print("getMoneyPersonStackViewのheightの値は\(getMoneyPersonStackView.frame.size.height)")
        print("locationStackViewのheightの値は\(locationStackView.frame.size.height)")
        print("changeButtonのheightの値は\(recodeButton.frame.size.height)")
        
        
    }
    
    @IBAction func recode(_ sender: Any) {
        
        
        
        
        
        //nextのデータを値が更新されているもののみアップデートする
        var newDate:Timestamp = self.nextMoai!.date
        var newStartTime:String = self.nextMoai!.startTime
        var newGetMoneyPerson:String = self.nextMoai!.getMoneyPerson
        var newGetMoneyPersonID:String = self.nextMoai!.getMoneyPersonID
        var newLocation:String = self.nextMoai!.locationName

        if self.dateTextField.text != "" {
            //Date型のselectedDateの値をTimestamp型に変換
            let selectedDateTypeOfTimestamp = Timestamp(date: self.selectedDate?[0] as! Date )
            newDate = selectedDateTypeOfTimestamp
        }
        if self.startTimeTextField.text != "" {
            newStartTime = self.startTimeTextField.text!
        }
        if self.getMoneyPersonTextField.text != "" {
            newGetMoneyPerson = self.getMoneyPersonTextField.text!
            let menbersIndex = self.moaiMenbersNameList?.firstIndex(of: self.getMoneyPersonTextField.text!)
            newGetMoneyPersonID = (self.moai?.menbers[menbersIndex!])!
        }
        if self.locationTextField.text != "" {
            newLocation = self.locationTextField.text!
        }
        
        //未定の状態なら記録できないようにする
        if newStartTime == "未定" || newGetMoneyPerson == "未定" || newGetMoneyPersonID == "未定" || newLocation == "未定" {
            print("記録しませーん")
            let alert: UIAlertController = UIAlertController(title: "'未定'の箇所があります。", message: nil, preferredStyle: UIAlertController.Style.alert)
            let OKAction: UIAlertAction = UIAlertAction(title: "OK", style: UIAlertAction.Style.cancel, handler:{
                // ボタンが押された時の処理を書く（クロージャ実装）
                (action: UIAlertAction!) -> Void in
                print("OK")
            })
            alert.addAction(OKAction)
            present(alert, animated: true, completion: nil)
        }
        
        let changedInfo = "日付：\(DateUtils.stringFromDate(date: newDate.dateValue()))" + "\n" + "開始時刻：\(newStartTime)" + "\n" + "模合代受け取り：\(newGetMoneyPerson)" + "\n" + "場所：\(newLocation)"
        
        let alert: UIAlertController = UIAlertController(title: "以下の内容はでよろしいですか？", message: changedInfo, preferredStyle:  UIAlertController.Style.alert)
        let joinAction: UIAlertAction = UIAlertAction(title: "はい", style: UIAlertAction.Style.default, handler:{
            // ボタンが押された時の処理を書く（クロージャ実装）
            (action: UIAlertAction!) -> Void in
            
            //nextに入っていたデータをpastRecodeに入れる
            self.addRecodeToPastRecode(newDate: newDate, newstartTime: newStartTime, newGetMoneyPerson: newGetMoneyPerson, newGetMoneyPersonID: newGetMoneyPersonID, newLocation: newLocation)
            
            //nextにあったデータの削除
            self.removeNextMoaiInfo()
            
            //nextに新しいデータを入れる
            self.addNewRecodeToNext()
            
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
        view.endEditing(true)
    }
    
    @objc private func cancelPressed() {
        //編集中のものを消去
        if dateTextField.isEditing == true {
            dateTextField.text = ""
        }
        if startTimeTextField.isEditing == true {
            startTimeTextField.text = ""
        }
        if getMoneyPersonTextField.isEditing == true {
            getMoneyPersonTextField.text = ""
        }
        if locationTextField.isEditing == true {
            locationTextField.text = ""
        }
        
        view.endEditing(true)
    }
    
    private func addRecodeToPastRecode(newDate:Timestamp, newstartTime:String,newGetMoneyPerson:String, newGetMoneyPersonID:String ,newLocation:String) {
        guard let moaiID = self.moaiID else {
            print("なんや知らんけど、moaiID取れて無いっすわ")
            return
        }
        
        let dic = [
            "date":newDate,
            "getMoneyPerson":newGetMoneyPerson,
            "getMoneyPersonID":newGetMoneyPersonID,
            "location":newLocation,
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
    
    private func addNewRecodeToNext() {
        guard let moaiID = self.moaiID else {
            print("なんや知らんけど、moaiID取れて無いっすわ")
            return
        }
        
        guard let moai = self.moai else {return}
        print("weekの値は\(moai.week) | dayの値は\(moai.day)")
        let weekAndDayArray:[Int] = moai.switchMoaiDate(weekNum: moai.week, weekDay: moai.day)
        
        self.newNextMoaiDate = DateUtils.returnNextMoaiDate(weekNum: weekAndDayArray[0], weekDay: weekAndDayArray[1])
        self.newNextMoaiDateID = DateUtils.stringFromDateoForSettingNextID(date: self.newNextMoaiDate!)
        
        let dic = [
            "date":newNextMoaiDate,
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
    }
}






extension RecodeMoaiInfoViewController: FSCalendarDelegate,FSCalendarDataSource {
    
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
        self.selectedDate = [date , DateUtils.stringFromDate(date: date)]
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


extension RecodeMoaiInfoViewController: UIPickerViewDelegate,UIPickerViewDataSource {
    
    //列数
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    //行数
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        switch pickerView.tag {
        case 1:
            return moaiMenbersNameList!.count
        case 2:
            return sampleArray.count
        default:
            return 1
        }
    }
    
    //表示内容
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        switch pickerView.tag {
        case 1:
            return moaiMenbersNameList![row]
        case 2:
            return sampleArray[row]
        default:
            return "エラーでっせ"
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        switch pickerView.tag {
        case 1:
            return self.getMoneyPersonTextField.text = moaiMenbersNameList![row]
        case 2:
            return self.startTimeTextField.text = sampleArray[row]
        default:
            return self.getMoneyPersonTextField.text = ""
        }
    }
    
    
}
