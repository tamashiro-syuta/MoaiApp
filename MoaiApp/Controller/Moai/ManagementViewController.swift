//
//  ManagementViewController.swift
//  MoaiApp
//
//  Created by 玉城秀大 on 2021/06/27.
//

import UIKit
import Firebase
import PKHUD

class ManagementViewController: UIViewController {
    
    
    let db = Firestore.firestore()
    let userID = Auth.auth().currentUser?.uid
    
    //pastMoaisButtonの横のアイコンで使用
    let downImage = UIImage(systemName: "arrowtriangle.down.fill")
    let upImage = UIImage(systemName: "arrowtriangle.up.fill")
    
    // 前ページから持ってきた値
    var user: User?
    var moai: Moai?
    var pastRecodeArray: [PastMoaiRecord]?  //古いデータが「0番目」、新しいのが「n番目」になってる
    var pastRecodeIDDateArray: [String]?  //◯月◯日みたいな形で取り出してる
    var nextMoaiEntryArray: [Bool]? // ブーリアン型の配列
    var moaiMenbersNameList: [String] = [] //模合メンバーの名前の配列
    
    @IBOutlet weak var nextMoaiDateLabel: UILabel!
    @IBOutlet weak var entryButton: UIButton!
    @IBOutlet weak var notEntryButton: UIButton!
    @IBOutlet weak var pastMoaisButton: UIButton!
    @IBOutlet weak var pastMoaiLabel: UILabel!
    @IBOutlet weak var getMoneyPersonTableView: UITableView!
    @IBOutlet weak var blurView: UIVisualEffectView!
    
    //模合代を誰が徴収したかの確認(誰が何日にもらって的なやつ)のための辞書型の変数
    //FireBaseからデータを取得して入れる
    var GetMoneyPersonList: Array = [
        ["A","7/1"],
        ["B","×"],
        ["C","なんでテーブルビューが表示されないんだよ"]
    ]

    let today = Date()
    var nextMoaiDate: String?
    
    var vi: UIView?  //過去の模合のスクロールビューで使用
    
    //viewが初めて呼ばれた１回目だけ呼ばれるメソッド
    override func viewDidLoad() {
        super.viewDidLoad()
        print("viewDidLoad")
        
        print(self.pastRecodeArray) //nil
        print(self.pastRecodeArray?.count) //nil
        print(self.nextMoaiEntryArray) //nil
        print(self.moaiMenbersNameList) //[]
        
        self.setupView()
        self.makeGetMoneyPersonList()
        self.getMoneyPersonTableView.dataSource = self
        self.getMoneyPersonTableView.delegate = self
    }
    
    //viewが更新された度に呼ばれる
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        print("viewWillAppear")

    }
    
    //「次回の模合は」の部分のview
    private func setupView() {
        navigationController?.navigationBar.barTintColor = .rgb(red: 39, green: 49, blue: 69)
        //ボタンに文字と画像を設置
        pastMoaisButton.setTitle("過去の模合", for: .normal)
        pastMoaisButton.setImage(downImage, for: .normal)
        //画像と文字絵を被らないように配置
        pastMoaisButton.imageEdgeInsets = UIEdgeInsets(top: 0, left: 180, bottom: 0, right: 0)
        pastMoaisButton.titleEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 20)
        
        
        //DBから取得した値を使ってGetNextMoaiDateで正しい次の模合の日付を取得できるようにする（moaisテーブルのdateを二つに分けて（date1,date2など）それぞれをswitch文でInt型で返すようにしたいので、moaisテーブルにデータをセットする時の処理もそれ用に書き換える必要あり。）
        guard let weekNum = self.moai?.week else {return}
        guard let weekDay = self.moai?.day else {return}
        let moaiDate = self.switchMoaiDate(weekNum: weekNum, weekDay: weekDay)
        self.nextMoaiDate = self.GetNextMoaiDate(weekNum: moaiDate.0, weekDay: moaiDate.1)
        
        self.nextMoaiDateLabel.text = self.nextMoaiDate
        
        //このタイトルは、DBから値を持ってくる前のサンプル的な用途で置いてるだけのやつ
        if self.pastRecodeArray == nil || self.pastRecodeArray?.count == 0 {
            self.setupPastMoaisView(backnumber: 0)
            //ボタンの無効化
            self.pastMoaisButton.isEnabled = false
        }else {
            guard let pastRecodeArrayCount = self.pastRecodeArray?.count else {return}
            let pastTotalTimes = pastRecodeArrayCount - 1
            self.setupPastMoaisView(backnumber: pastTotalTimes)
        }
        
        self.navigationItem.title = self.moai?.groupName
        self.navigationController?.navigationBar.titleTextAttributes = [.foregroundColor: UIColor.white]
        
        //配列の順番をDBのmoaiのmenbersの順番と同じにするため
        self.moaiMenbersNameList.reverse()
    }
    
    //参加ボタン
    @IBAction func entry(_ sender: Any) {
        entryOrNot(Bool: true)
    }
    
    @IBAction func notEntry(_ sender: Any) {
        entryOrNot(Bool: false)
    }
    
    @IBAction func detailsNextMoai(_ sender: Any) {
        let detailsNextMoaiVC = storyboard?.instantiateViewController(identifier: "detailsNextMoaiViewController") as! detailsNextMoaiViewController
        detailsNextMoaiVC.date = self.nextMoaiDate
        detailsNextMoaiVC.location = "あとで設定する〜〜"
        detailsNextMoaiVC.judgeEntryArray = self.nextMoaiEntryArray
        detailsNextMoaiVC.menbersArray = self.moaiMenbersNameList
        navigationController?.pushViewController(detailsNextMoaiVC, animated: true)
    }
    
    

    //過去の模合の情報からn番目の情報をUIに移すメソッド
    private func setupPastMoaisView(backnumber: Int) {
        
        if self.pastRecodeArray == nil || self.pastRecodeArray?.count == 0 {
            if backnumber == 0 {
                //pastRecodeArrayがnilの時の挙動
                let title = " 次が初めての模合です！！"
                pastMoaiLabel.text = title
                pastMoaiLabel.font = UIFont.systemFont(ofSize: 25)
            }
        }else {
            if backnumber < 0 || backnumber > self.pastRecodeArray!.count {
                //引数に正常な値が入ってない時の挙動
                //アラートで出した方が良い？？
                print("ちゃんとした値にしやがれカス")
                return
            }else {
                //引数で指定した番号の模合情報をインスタンス化(上で引数が正常な値かチェックしてるから強制アンラップしても大丈夫)
                let selectedPastRecode: PastMoaiRecord = (self.pastRecodeArray?[backnumber])!
                let date = selectedPastRecode.date
                let getPerson = selectedPastRecode.getMoneyPerson
                let location = selectedPastRecode.location
                let title = "  開催日：\(date)" + "\n" + "  受け取り：\(getPerson)" + "\n" + "  場所：\(location)"
                
                pastMoaiLabel.text = title
                pastMoaiLabel.font = UIFont.systemFont(ofSize: 25)
                return
            }
        }
    }

    
    
    @IBAction func pickOneOfPastMoais(_ sender: Any) {
        //ダウンスクロールメニューを表示し、その中から過去の模合を選択し、し終わると、その詳細を表示する

        //self.pickerView.isHidden = false
        let pickerView = UIPickerView()
        pickerView.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.size.width, height: pickerView.bounds.size.height + 80)
                // Connect data:
        pickerView.delegate   = self
        pickerView.dataSource = self
        pickerView.tag = 1
        
        self.vi = UIView(frame: pickerView.bounds)
        vi?.backgroundColor = UIColor.white
        vi?.addSubview(pickerView)
        
        let toolBar = UIToolbar(frame: CGRect(x: 0, y: 0, width: view.frame.size.width, height: 150))
        toolBar.barStyle = UIBarStyle.default
        toolBar.isTranslucent = true
        toolBar.tintColor = UIColor.black
        let space = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: self, action: nil)
        let done = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(self.donePressed))
        toolBar.setItems([space, done ], animated: true)
        toolBar.isUserInteractionEnabled = true
        toolBar.sizeToFit()
        
        vi?.addSubview(toolBar)
        view.addSubview(vi!)
        let screenSize = UIScreen.main.bounds.size
        vi?.frame.origin.y = screenSize.height
        UIView.animate(withDuration: 0.3) {
            self.vi?.frame.origin.y = screenSize.height - (self.vi?.bounds.size.height)!
        }
        print("push")
    }
    
    @objc func donePressed() {
        self.vi?.isHidden = true
    }

    //DBに文字列で保存外れている値を数字に変換する
    private func switchMoaiDate(weekNum: String, weekDay: String) -> (Int,Int)  {
        let returnWeekNum:Int,returnWeekDay:Int
        switch weekNum {
        case "第１":
            returnWeekNum = 1
        case "第２":
            returnWeekNum = 2
        case "第３":
            returnWeekNum = 3
        case "第４":
            returnWeekNum = 4
        default:
            returnWeekNum = 0
        }
        
        switch weekDay {
        case "日曜日":
            returnWeekDay = 1
        case "月曜日":
            returnWeekDay = 2
        case "火曜日":
            returnWeekDay = 3
        case "水曜日":
            returnWeekDay = 4
        case "木曜日":
            returnWeekDay = 5
        case "金曜日":
            returnWeekDay = 6
        case "土曜日":
            returnWeekDay = 7
        default:
            returnWeekDay = 0
        }

        if returnWeekNum == 0 && returnWeekDay == 0 {
            print("変な値になってるよーーーーー")
        }
        
        return (returnWeekNum,returnWeekDay)
    }
    
    //来月の模合が何日かわかるやつ（今月の模合がまだでも来月の日にちを出力するので、要改善）
    //引数はそれぞれ、使う部分の上でswitch文を使ってDBから得た値をうまく数字に変換してから使う
    private func GetNextMoaiDate(weekNum: Int, weekDay:Int) -> String {
        let cal = Calendar.current
        let year = cal.component(.year, from: Date() )
        let month = cal.component(.month, from: Date() )
        let now = cal.date(from: DateComponents(year: year, month: month))


        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        dateFormatter.calendar = cal
        let yearMonthFomatter = DateFormatter()
        yearMonthFomatter.dateFormat = "yyyy 年 M 月"
        yearMonthFomatter.calendar = cal
        let monthDateFomatter = DateFormatter()
        monthDateFomatter.dateFormat = "M 月 d 日"
        monthDateFomatter.calendar = cal


        var components = cal.dateComponents([.year, .month], from: now ?? Date())
        components.weekdayOrdinal = weekNum // 第◯週目
        print("\n\(yearMonthFomatter.string(from: now ?? Date() )) の第 \(components.weekdayOrdinal!) 日曜日 〜 土曜日")
        //ここから何曜日を取得するかはDBから模合の情報を取り出し、そこで判断する
        components.weekday = weekDay  // の◯曜日
        if let date = cal.date(from: components) {
            print("  \(cal.weekdaySymbols[weekDay - 1]): \(dateFormatter.string(from: date))")
        }
        let nextMoaiDate = monthDateFomatter.string(from: cal.date(from: components) ?? Date())
        
        return nextMoaiDate
    }
    
    private func entryOrNot(Bool: Bool) {
        guard let myName = self.user?.username else {return}
        //ログインしているユーザーが配列の何番目かを取得
        guard let myNumber = self.moaiMenbersNameList.index(of: myName) else {return}
        //配列の中身を更新
        nextMoaiEntryArray?[myNumber] = Bool
        //DBのnextの値を上で更新した配列に切り替える
        self.db.collection("moais").document((self.user?.moais[1])!).updateData(["next": self.nextMoaiEntryArray ]) { (err) in
            if let err = err {
                print("参加ボタン、不参加ボタンで起きたエラー → \(err)")
            }
        }
        if Bool == true {
            entryButton.alpha = 0.5
            notEntryButton.alpha = 1.0
        }else {
            entryButton.alpha = 1.0
            notEntryButton.alpha = 0.5
        }
    }
    
    private func makeGetMoneyPersonList() {
        //配列の値を一旦、全て削除する
        self.GetMoneyPersonList.removeAll()
        
        if self.pastRecodeArray == nil || self.pastRecodeArray?.count == 0 {
            self.GetMoneyPersonList = [ ["初めての模合終了","後に利用できます。"] ]
        }else {
            //GetMoneyPersonListの作成
            guard let pastRecodeArray = self.pastRecodeArray else {return}
            for menberName in self.moaiMenbersNameList {
                var count = 0
                for pastRecode in pastRecodeArray {
                    if menberName == pastRecode.getMoneyPerson {
                        self.GetMoneyPersonList.append([menberName,pastRecode.date])
                        print(self.GetMoneyPersonList.last)
                    }else {
                        count += 1
                        //countが配列の数と同じ＝１回ももらってない
                        if count == pastRecodeArray.count {
                            self.GetMoneyPersonList.append([menberName,"    ×    "])
                        }
                    }
                }
            }
        }
    }
}


extension ManagementViewController: UIPickerViewDelegate, UIPickerViewDataSource {
    
    // UIViewPickerの列(横方向)数を指定
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    // UIViewPickerの行(縦方向)数を指定
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return self.pastRecodeArray!.count
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
    
    //各行のタイトル
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return self.pastRecodeIDDateArray?[row]
    }
    
    // UIViewPickerのrowが選択された時のメソッド
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        //選択されたものに応じて、引数を指定し、ラベルのUI更新のメソッドを呼び出す。
        self.setupPastMoaisView(backnumber: row)
    }
}


extension ManagementViewController: UITableViewDelegate,UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return GetMoneyPersonList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as UITableViewCell
        let label1 = cell.contentView.viewWithTag(1) as! UILabel
        let label2 = cell.contentView.viewWithTag(2) as! UILabel
        label1.frame.size.width = cell.frame.size.width / 2
        label2.frame.size.width = cell.frame.size.width / 2
        
        label1.text = GetMoneyPersonList[indexPath.row][0]
        label2.text = GetMoneyPersonList[indexPath.row][1]
        
        return cell
    }
}
