//
//  ChangeNextMoaiViewController.swift
//  MoaiApp
//
//  Created by 玉城秀大 on 2021/07/25.
//

import UIKit
import Firebase
import FSCalendar

class ChangeNextMoaiViewController: UIViewController, UITextFieldDelegate {
    
    let db = Firestore.firestore()
    
    var user:User?
    
    var moai:Moai?
    var moaiID:String?
    var moaiMenbersNameList:[String]?
    
    var nextMoai:MoaiRecord?
    var nextMoaiID: String?
    
    
    var viewsWidth:CGFloat?
    var textFieldMargin = 60
    
    var getMoneyPersonPickerView = UIPickerView()
    var menberIDArray:[String]?
    var startTimePickerView = UIDatePicker()
    //配列の初めを""にすることで、変更予定がないのに誤ってタッチしても変更せずにできる
    let sampleArray = ["","1","2","3","4","5","6","7","8","9","10"]
    let startTimePickArrayHour = ["00", "01", "02", "03", "04", "05", "06", "07", "08", "09", "10", "11", "12", "13", "14", "15", "16", "17", "18", "19", "20", "21", "22", "23"]
    
    let calendarView = UIView()
    var choiceDateCalendar: FSCalendar = FSCalendar()
    var selectedDate: [Any]? = nil

    
    
    @IBOutlet weak var changeStackView: UIStackView!
    @IBOutlet weak var dateStackView: UIStackView!
    @IBOutlet weak var startTimeStackView: UIStackView!
    @IBOutlet weak var getMoneyPersonStackView: UIStackView!
    @IBOutlet weak var locationStackView: UIStackView!
    @IBOutlet weak var changeButtonStackView: UIStackView!
    @IBOutlet weak var changeButton: UIButton!
    
    @IBOutlet weak var dateTextField: UITextField!
    @IBOutlet weak var startTimeTextField: UITextField!
    @IBOutlet weak var getMoneyPersonTextField: UITextField!
    @IBOutlet weak var locationTextField: UITextField!

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        viewsWidth = self.view.frame.size.width
        
        setupCalendar()
        setupview()
        makeChoiceDateArray()
        
    }
    
    private func setupview() {
        
        self.setupStackViews()
        
        self.moaiID = self.user?.moais[1]
        
        choiceDateCalendar.delegate = self
        choiceDateCalendar.dataSource = self
        
        dateTextField.delegate = self
        startTimeTextField.delegate = self
        getMoneyPersonTextField.delegate = self
        locationTextField.delegate = self
        
//        startTimePickerView.delegate = self
        startTimePickerView.tag = 1
        //startTimePickerViewの設定
        startTimePickerView.datePickerMode = .countDownTimer
        startTimePickerView.timeZone = NSTimeZone.local
        startTimePickerView.locale = .current
        startTimePickerView.frame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: self.view.frame.height / 3)
        
        getMoneyPersonPickerView.delegate = self
        getMoneyPersonPickerView.tag = 2
        
        locationTextField.frame.size.width = viewsWidth! - 60
        
        let date = DateUtils.MddEEEFromDate(date: (self.nextMoai?.date.dateValue())!)
        let startTime = DateUtils.fetchStartTimeFromDate(date: (self.nextMoai?.date.dateValue())!)
        dateTextField.placeholder = date
        startTimeTextField.placeholder = startTime
        getMoneyPersonTextField.placeholder = self.nextMoai?.getMoneyPerson["name"] as! String
        locationTextField.placeholder = self.nextMoai?.location["name"] as! String
        
        let toolbar = UIToolbar(frame: CGRect(x: 0, y: 0, width: view.frame.size.width, height: 50))
        //toolbarに表示させるアイテム
        let space = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: self, action: nil)
        let done = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(self.donePressed))
        let cancel = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(self.cancelPressed))
        toolbar.setItems([cancel , space, done ], animated: true)
        
        dateTextField.inputView = calendarView
        print("dateTextFieldのinputViewは\(dateTextField.inputView)")
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
        changeStackView.translatesAutoresizingMaskIntoConstraints = false
        
        changeStackView.heightAnchor.constraint(equalToConstant: viewHeight * 2 / 3).isActive = true
        changeStackView.widthAnchor.constraint(equalToConstant: viewWidth * 5 / 6).isActive = true
        
        let changeSVHeight = changeStackView.frame.size.height
        
        print("changeSVHeightの値は\(changeSVHeight)")
        print("changeSVHeightの値は\(changeStackView.frame.size.width)")

        
        dateStackView.translatesAutoresizingMaskIntoConstraints = false
        dateStackView.heightAnchor.constraint(equalToConstant: changeSVHeight / 5).isActive = true
        
        startTimeStackView.translatesAutoresizingMaskIntoConstraints = false
        startTimeStackView.heightAnchor.constraint(equalToConstant: changeSVHeight / 5).isActive = true
        
        getMoneyPersonStackView.translatesAutoresizingMaskIntoConstraints = false
        getMoneyPersonStackView.heightAnchor.constraint(equalToConstant: changeSVHeight / 5).isActive = true
        
        locationStackView.translatesAutoresizingMaskIntoConstraints = false
        locationStackView.heightAnchor.constraint(equalToConstant: changeSVHeight / 5).isActive = true
        
        changeButtonStackView.translatesAutoresizingMaskIntoConstraints = false
        changeButtonStackView.heightAnchor.constraint(equalToConstant: changeSVHeight / 5).isActive = true
        
        changeButton.frame.size.height = changeButtonStackView.frame.size.height / 3
        changeButton.layer.cornerRadius = changeButton.frame.size.width / 6
        changeButton.backgroundColor = .barColor()
        
        print("dateStackViewのheightの値は\(dateStackView.frame.size.height)")
        print("startTimeStackViewのheightの値は\(startTimeStackView.frame.size.height)")
        print("getMoneyPersonStackViewのheightの値は\(getMoneyPersonStackView.frame.size.height)")
        print("locationStackViewのheightの値は\(locationStackView.frame.size.height)")
        print("changeButtonのheightの値は\(changeButton.frame.size.height)")
        
        
    }
    
    @objc func donePressed() {
        view.endEditing(true)
    }
    @objc func cancelPressed() {
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
    
    @IBAction func change(_ sender: Any) {
        guard let nextMoaiID = self.nextMoaiID else {
            print("nextMoaiIDがなんかおかしい笑笑")
            return
        }
        let date:String?
        let startTime:String?
        let getMoneyPerson:String?
        let location:String?
        if self.dateTextField.text != "" {
            date = dateTextField.text
        }else {
            date = dateTextField.placeholder
        }
        if self.startTimeTextField.text != "" {
            startTime = startTimeTextField.text
        }else {
            startTime = startTimeTextField.placeholder
        }
        if self.getMoneyPersonTextField.text != "" {
            getMoneyPerson = getMoneyPersonTextField.text
        }else {
            getMoneyPerson = getMoneyPersonTextField.placeholder
        }
        if self.locationTextField.text != "" {
            location = locationTextField.text
        }else {
            location = locationTextField.placeholder
        }
        
        print(date)
        print(startTime)
        print(getMoneyPerson)
        print(location)
        
        let changedInfo = "日付：\(date!)" + "\n" + "開始時刻：\(startTime!)" + "\n" + "模合代受け取り：\(getMoneyPerson!)" + "\n" + "場所：\(location!)"
        print(changedInfo)
        
        let alert: UIAlertController = UIAlertController(title: "変更後の内容は以下でよろしいですか？", message: changedInfo, preferredStyle:  UIAlertController.Style.alert)
        print("1")
        let joinAction: UIAlertAction = UIAlertAction(title: "はい", style: UIAlertAction.Style.default, handler:{
            // ボタンが押された時の処理を書く（クロージャ実装）
            (action: UIAlertAction!) -> Void in
            
            print("joinActionの実行中だよ")
            
            var newDate:Timestamp = self.nextMoai!.date
            var newStartTime:String =  "aiueo" //self.nextMoai!.startTime
            var newGetMoneyPerson:[String:String] = self.nextMoai!.getMoneyPerson
//            var newGetMoneyPersonID:String = self.nextMoai!.getMoneyPersonID
            var newLocation:[String:Any] = self.nextMoai!.location
            
            //値が更新されているもののみアップデートする
            if self.dateTextField.text != "" {
                //Date型のselectedDateの値をTimestamp型に変換
                let selectedDateTypeOfTimestamp = Timestamp(date: self.selectedDate?[0] as! Date )
                newDate = selectedDateTypeOfTimestamp
            }
            if self.startTimeTextField.text != "" {
                newStartTime = self.startTimeTextField.text!
            }
            if self.getMoneyPersonTextField.text != "" {
                newGetMoneyPerson["name"] = self.getMoneyPersonTextField.text!
                let menbersIndex = self.moaiMenbersNameList?.firstIndex(of: self.getMoneyPersonTextField.text!)
                newGetMoneyPerson["id"] = self.menberIDArray![menbersIndex!]
            }
            if self.locationTextField.text != "" {
                newLocation["name"] = self.locationTextField.text!
            }
            
            //更新用データ
            let dic = [
                "date": newDate ,
                "startTime": newStartTime,
                "getMoneyPerson": newGetMoneyPerson,
//                "getMoneyPersonID": newGetMoneyPersonID,
                "location": newLocation,
            ] as [String : Any]
            
            //更新用データを用いて次回の模合情報をアップデート
            self.updateNextMoai(newNextMoaiDic: dic, nextMoaiID: nextMoaiID)

        })
        print("2")
        let cancelAction: UIAlertAction = UIAlertAction(title: "取り消し", style: UIAlertAction.Style.cancel, handler:{
                // ボタンが押された時の処理を書く（クロージャ実装）
                (action: UIAlertAction!) -> Void in
                print("Cancel")
            })
        print("3")
        alert.addAction(cancelAction)
        print("4")
        alert.addAction(joinAction)
        print("5")
        present(alert, animated: true, completion: nil)
        print("6")
    }
    
    //次回の模合情報の更新
    private func updateNextMoai(newNextMoaiDic: [String:Any], nextMoaiID:String) {
        //元あるデータを削除
        self.db.collection("moais").document((self.user?.moais[1])!).collection("next").document(nextMoaiID).delete() { err in
            if let err = err {
                print("エラーでやんす\(err)")
                return
            }else {
                print("既存のドキュメントを削除しました。")
            }
        }
        //新しく更新したデータを追加
        let nextMoaiDate = DateUtils.stringFromDateoForSettingRecordID(date: self.selectedDate?[0] as! Date)
        self.db.collection("moais").document((self.user?.moais[1])!).collection("next").document(nextMoaiDate).setData(newNextMoaiDic) {err in
            if let err = err {
                print("エラーでっせ \(err)")
                return
            }else {
                print("次回模合データの更新に成功しました。")
                self.FinishedChangingNextInfoAlert()
            }
        }
    }
    
    private func FinishedChangingNextInfoAlert() {
        let alert: UIAlertController = UIAlertController(title: "更新が完了しました。", message: .none, preferredStyle:  UIAlertController.Style.alert)
        let OKAction: UIAlertAction = UIAlertAction(title: "OK", style: UIAlertAction.Style.cancel, handler:{
                // ボタンが押された時の処理を書く（クロージャ実装）
                (action: UIAlertAction!) -> Void in
            print("更新後の通知完了っす")
            //前画面に遷移
            self.navigationController?.popViewController(animated: true)
        })
        alert.addAction(OKAction)
        present(alert, animated: true, completion: nil)
    }
    
    //pickerViewに入れる変更する日付の候補日（1ヶ月分の日付 ＋「今月は無し」）
    private func makeChoiceDateArray() {
        
    }
    
    
    
}

extension ChangeNextMoaiViewController: FSCalendarDelegate,FSCalendarDataSource {
    
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
        
        self.calendarView.frame = CGRect(x: 0, y: 0, width: view.frame.size.width, height: (view.frame.size.height / 2) - 50 )
        self.calendarView.backgroundColor = .white
        self.calendarView.addSubview(choiceDateCalendar)
        self.calendarView.addSubview(calendarToolbar)
        
        guard let nextMoaiDate = self.nextMoai?.date.dateValue() else {return}
        self.selectedDate = [nextMoaiDate, DateUtils.MddEEEFromDate(date: nextMoaiDate)]
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



extension ChangeNextMoaiViewController: UIPickerViewDelegate,UIPickerViewDataSource {
    
    //列数
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    //行数
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        switch pickerView.tag {
        case 1:
            return sampleArray.count
        case 2:
            return self.moaiMenbersNameList!.count
        default:
            return 1
        }
    }
    
    //表示内容
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        switch pickerView.tag {
        case 1:
            return sampleArray[row]
        case 2:
            return self.moaiMenbersNameList![row]
        default:
            return "なんだろう、勝手にエラーでるのやめてもらっていいっすか？？"
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        switch pickerView.tag {
        case 1:
            return self.startTimeTextField.text = sampleArray[row]
        case 2:
            return self.getMoneyPersonTextField.text = self.moaiMenbersNameList![row]
        default:
            return self.getMoneyPersonTextField.text = "なんだろう、勝手にエラー出るのやめてもらっていいですか？？"
        }
    }
    
    
}
