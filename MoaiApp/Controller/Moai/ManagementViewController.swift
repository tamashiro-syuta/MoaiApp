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
    
    //模合代を誰が徴収したかの確認(誰が何日にもらって的なやつ)のための辞書型の変数
    //FireBaseからデータを取得して入れる
    //ex) let dic = ["Aさん":"12/5","Bさん":"×"]
    var GetMoneyPersonList: Array = [
        ["A","7/1"],
        ["B","×"],
        ["C","なんでテーブルビューが表示されないんだよ"]
    ]
    
    var moaiMenbersNameList: [String] = [] //模合メンバーの名前の配列
    
    //ログインしているユーザー情報を入れる
    var user: User?
    var moai: Moai?
    var pastRecodeArray: [PastMoaiRecord]?  //古いデータが「0番目」、新しいのが「n番目」になってる
    var pastRecodeIDStringArray: [String]?  // 20210417みたいな形で取り出してる
    var pastRecodeIDDateArray: [String]?  //◯月◯日みたいな形で取り出してる
    var nextMoaiEntryArray: [Bool]? // ブーリアン型の配列
    let today = Date()
    var nextMoaiDate: String?
    
    
    var vi: UIView?

    @IBOutlet weak var nextMoaiDateLabel: UILabel!
    @IBOutlet weak var entryButton: UIButton!
    @IBOutlet weak var notEntryButton: UIButton!
    @IBOutlet weak var pastMoaisButton: UIButton!
    @IBOutlet weak var pastMoaiLabel: UILabel!
    @IBOutlet weak var getMoneyPersonTableView: UITableView!
    @IBOutlet weak var blurView: UIVisualEffectView!
    
    
    
    //viewが初めて呼ばれた１回目だけ呼ばれるメソッド
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.blurView.alpha = 1
        
        //ユーザーが模合に入っているか確認
        confirmUserInMoai()
        
        //ユーザーの模合情報から模合情報を取得
        fetchLoginUserInfo()
        
        //インジケーターを回す
        HUD.flash(.progress, onView: view, delay: 1.5) {_ in
            //非表示にした後の処理
            //模合の情報を元に画面に表示
            self.setupView()
            self.makeGetMoneyPersonList()
            self.getMoneyPersonTableView.dataSource = self
            self.getMoneyPersonTableView.delegate = self
            self.blurView.alpha = 0
        }
    }
    
    //ログインしてないとログイン画面に飛ばすやつ(これをユーザーが模合に入っていないと模合の作成、参加画面に飛ばすように変更する)
    private func confirmUserInMoai() {
        db.collection("users").document(userID ?? "").getDocument { (snapshots, err) in
            if let err = err {
                print("なんか知らんけど、ユーザー情報取れないんですけど~~(\(err))")
                return
            }else {
                let moaiArray = snapshots?.data()?["moais"] as! Array<Any>
                print(moaiArray.count)
                //ユーザー登録の時点では、moaisには、空の文字型""が入っているので、カウントが１＝模合に所属していないことになる
                if moaiArray.count == 1 {
                    //Moai.storyboardに画面遷移
                    //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
                    //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
                    //    画面遷移できない（直しが必要）
                    //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
                    //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
                    self.pushMoaiViewController()
                }
            }
        }
    }
    
    //Moai.storyboardに画面遷移
    private func pushMoaiViewController() {
        print("画面遷移しまーーーーーーーーーーーーーーーす")
        let storyboard = UIStoryboard(name: "Moai", bundle: nil)
        let MoaiVC = storyboard.instantiateViewController(withIdentifier: "Moai")
        //signUpViewControllerをナビゲーションの最初の画面にし、それを定数navに格納
//        let nav = UINavigationController(rootViewController: MoaiVC)
//        nav.modalPresentationStyle = .fullScreen
//        self.present(MoaiVC, animated: true, completion: nil)
        navigationController?.pushViewController(MoaiVC, animated: true)
    }
    
    //viewが更新された度に呼ばれる
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
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
        guard let pastRecodeArrayCount = self.pastRecodeArray?.count else {return}
        let pastTotalTimes = pastRecodeArrayCount - 1
        self.setupPastMoaisView(backnumber: pastTotalTimes)
        
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
        
        if backnumber < 0 || backnumber > self.pastRecodeArray!.count {
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


    //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ DB操作 ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        
    //ユーザー情報の取得
    private func fetchLoginUserInfo() {
        self.db.collection("users").document(self.userID ?? "").getDocument { (snapshots, err) in
            if let err = err {
                print("エラーでした~~\(err)")
                return
            }else {
                let dic = snapshots?.data()
                self.user = User(dic: dic ?? ["":""])

                //user情報から模合情報を取得
                self.fetchUsersMoaiInfo(user: self.user!)
                self.fetchPastRecord()
            }
        }
    }
    
    //ユーザーの模合情報の取得(後々は、複数入っている場合の模合情報を取れるようにする（配列の番号指定の部分を変数に置き換えして）)
    private func fetchUsersMoaiInfo(user: User) {
        self.db.collection("moais").document(user.moais[1]).getDocument { (snpashots, err) in
            if let err = err {
                print("エラーでした~~\(err)")
                return
            }else {
                guard let dic = snpashots?.data() else { return }
                self.moai = Moai(dic: dic)
            }
            self.makeMoaiMenbersNameList()
            guard let next = self.moai?.next else {return}
            self.nextMoaiEntryArray = next
        }
    }

    //過去の模合データを取得するメソッド(引数は、模合のDocumentIDと、何回目の模合を取得するかの数(Int型) )
    //viewDidLoadでは直近のデータを取り出し、viewWillApearで選択された時の模合データを取り出す。複数回利用するのでメソッド化
    private func fetchPastRecord() {
        self.db.collection("moais").document((self.user?.moais[1])!).collection("pastRecords").getDocuments { (querySnapshots, err) in
            if let err = err {
                print("過去の模合情報の取得でエラーが出ました。\(err)")
                return
            }else {
                var array1 = [PastMoaiRecord]()
                var array2 = [String]()
                guard let querySnapshots = querySnapshots else {return}
                for document in querySnapshots.documents {
                    let dic = document.data()
                    let recode = PastMoaiRecord(dic: dic)
                    print("\(document.documentID) => \(document.data())")
                    array1.append(recode)
                    
                    let moaiID = document.documentID
                    array2.append(moaiID)
                    
                }
                //古いデータが「0番目」、新しいのが「n番目」になってる
                self.pastRecodeArray = array1
                self.pastRecodeIDStringArray = array2
                self.makePastRecodeIDArray(array: self.pastRecodeIDStringArray!)
            }
        }
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
    
    //模合のメンバーをIDでなく、名前で配列に入れる
    private func makeMoaiMenbersNameList() {
        guard let moaiMenbers = self.moai?.menbers else {return}
        for menber in moaiMenbers {
            //print("menberに格納されている値はこちら　\(menber)")
            self.db.collection("users").document(menber).getDocument { (snapshots, err) in
                if let err = err {
                    print("模合に所属するユーザー情報の取得に失敗しました。\(err)")
                    return
                }
                let dic = snapshots?.data()
                self.moaiMenbersNameList.append(dic?["username"] as! String)
            }
        }
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
    // ~~~~~~~~~~~~~~~~~~~~~~~~~~  DB操作終了  ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    
    private func makeGetMoneyPersonList() {
        //配列の値を一旦、全て削除する
        self.GetMoneyPersonList.removeAll()
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
    
    //文字列型で入ってる配列を、読みやすい形に直すためのメソッド
    private func makePastRecodeIDArray(array: Array<Any>) {
        
        //これ入れないと、配列に値を入れれなくなって、空になるから消さない。
        self.pastRecodeIDDateArray = ["◯年◯月◯日みたいな形で取り出すよ"]
        self.pastRecodeIDDateArray?.removeFirst()
        
        let dateFormatter1 = DateFormatter()
        dateFormatter1.dateFormat = "yyyyMMdd"  //"E, d MMM yyyy HH:mm:ss Z"
//        dateFormatter.dateStyle = .long
//        dateFormatter.timeStyle = .none
//        dateFormatter.locale = Locale(identifier: "ja_JP")
        
        let dateFormatter2 = DateFormatter()
        dateFormatter2.dateStyle = .long
        dateFormatter2.timeStyle = .none
        dateFormatter2.locale = Locale(identifier: "ja_JP")
        
        for item in array {
            //DateFormatterで文字列を◯年◯月◯日に直す。必要なら、DBのIDの形も変えてよし
            //arrayには、20210409の形でデータが入っている
            let pastDate1 = dateFormatter1.date(from: item as! String)
            let pastDate2 = dateFormatter2.string(from: pastDate1!)
            self.pastRecodeIDDateArray?.append(pastDate2)
        }
        print(self.pastRecodeIDDateArray)
        print(self.pastRecodeIDStringArray)
    }
    
}


extension ManagementViewController: UIPickerViewDelegate, UIPickerViewDataSource {
    
    // UIViewPickerの列(横方向)数を指定
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    // UIViewPickerの行(縦方向)数を指定
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        self.pastRecodeArray!.count
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

// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// ~~~~~~~~~~~~~~~~~~~~~~~~~~~ 明日やること ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// ~~~~~~~~~ 参加不参加を押すことで、メンバーが参加予定かそうでないかを判別 ~~~~~~~~
// ~~~~~~~~ 右上の詳細ボタンから、次の模合は誰が参加予定か確認できるようにする ~~~~~
// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

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
