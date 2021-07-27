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
    var nextMoai:MoaiRecord?
    var nextMoaiID: String?
    
    
    var viewsWidth:CGFloat?
    var textFieldMargin = 60
    
    var datePickerView = UIPickerView()
    var startTimePickerView = UIPickerView()
    //配列の初めを""にすることで、変更予定がないのに誤ってタッチしても変更せずにできる
    let sampleArray = ["","1","2","3","4","5","6","7","8","9","10"]
    let sampleArray2 = ["","あ","い","う","え","お"]
    
    let calendarView = UIView()
    var choiceDateCalendar: FSCalendar = FSCalendar()
    var selectedDate: [Any]? = nil

    
    @IBOutlet weak var dateTextField: UITextField!
    @IBOutlet weak var startTimeTextField: UITextField!
    @IBOutlet weak var locationTextField: UITextField!

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        viewsWidth = self.view.frame.size.width
        
        setupCalendar()
        setupview()
        makeChoiceDateArray()
        
    }
    
    private func setupview() {
        
        choiceDateCalendar.delegate = self
        choiceDateCalendar.dataSource = self
        
        dateTextField.delegate = self
        startTimeTextField.delegate = self
        locationTextField.delegate = self
        
        datePickerView.delegate = self
        datePickerView.tag = 1
        startTimePickerView.delegate = self
        startTimePickerView.tag = 2
        
        locationTextField.frame.size.width = viewsWidth! - 60
        
        let date = DateUtils.stringFromDate(date: (self.nextMoai?.date.dateValue())!)
        let startTime = DateUtils.fetchStartTimeFromDate(date: (self.nextMoai?.date.dateValue())!)
        dateTextField.placeholder = date
        startTimeTextField.placeholder = startTime
        locationTextField.placeholder = self.nextMoai?.location
        
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
        locationTextField.inputAccessoryView = toolbar
        
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
        if self.locationTextField.text != "" {
            location = locationTextField.text
        }else {
            location = locationTextField.placeholder
        }
        
        let changedInfo = "日付：\(date!)" + "\n" + "開始時刻：\(startTime!)" + "\n" + "場所：\(location!)"
        
        let alert: UIAlertController = UIAlertController(title: "変更後の内容は以下でよろしいですか？", message: changedInfo, preferredStyle:  UIAlertController.Style.alert)
        let joinAction: UIAlertAction = UIAlertAction(title: "はい", style: UIAlertAction.Style.default, handler:{
            // ボタンが押された時の処理を書く（クロージャ実装）
            (action: UIAlertAction!) -> Void in
            
            var newDate:Timestamp = self.nextMoai!.date
            var newStartTime:String = self.nextMoai!.startTime
            var newLocation:String = self.nextMoai!.location
            
            //値が更新されているもののみアップデートする
            if self.dateTextField.text != "" {
                //Date型のselectedDateの値をTimestamp型に変換
                let selectedDateTypeOfTimestamp = Timestamp(date: self.selectedDate?[0] as! Date )
                newDate = selectedDateTypeOfTimestamp
            }
            if self.startTimeTextField.text != "" {
                newStartTime = self.startTimeTextField.text!
            }
            if self.locationTextField.text != "" {
                newLocation = self.locationTextField.text!
            }
            
            //更新用データ
            let dic = [
                "date": newDate ,
                "startTime": newStartTime,
                "getMoneyPerson": "",
                "getMoneyPersonID": "",
                "location": newLocation,
            ] as [String : Any]
            
            //更新用データを用いて次回の模合情報をアップデート
            self.updateNextMoai(newNextMoaiDic: dic, nextMoaiID: self.nextMoaiID!)

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
        let nextMoaiDate = DateUtils.stringFromDateoForSettingNextID(date: self.selectedDate?[0] as! Date)
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
            return sampleArray2.count
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
            return sampleArray2[row]
        default:
            return "なんだろう、勝手にエラーでるのやめてもらっていいっすか？？"
        }
    }
    
    
}