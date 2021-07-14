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
    
    //============= 非同期通信用にディスパッチグループおよびディスパッチキューの作成 ============= //
    
    
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
    
    var moaiMenbersNameList = [""]
    
    //ログインしているユーザー情報を入れる
    var user: User? {
        didSet {
            navigationItem.title = user?.username
        }
    }
    var moai: Moai?
    var pastRecodeArray: [PastMoaiRecord]?  //古いデータが「0番目」、新しいのが「n番目」になってる
    let today = Date()
    

    @IBOutlet weak var nextMoaiDateLabel: UILabel!
    @IBOutlet weak var pastMoaisButton: UIButton!
    @IBOutlet weak var detailsPastMoaiButton: UIButton!
    @IBOutlet weak var getMoneyPersonTableView: UITableView!
    
    
    //viewが初めて呼ばれた１回目だけ呼ばれるメソッド
    override func viewDidLoad() {
        super.viewDidLoad()

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
        let nextMoaiDate = self.GetNextMoaiDate(weekNum: moaiDate.0, weekDay: moaiDate.1)
        
        self.nextMoaiDateLabel.text = nextMoaiDate
        
        //このタイトルは、DBから値を持ってくる前のサンプル的な用途で置いてるだけのやつ
        guard let pastRecodeArrayCount = self.pastRecodeArray?.count else {return}
        let pastTotalTimes = pastRecodeArrayCount - 1
        self.setupPastMoaisView(backnumber: pastTotalTimes)
        
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
            detailsPastMoaiButton.titleLabel?.numberOfLines = 0
            detailsPastMoaiButton.titleLabel?.sizeToFit()
            detailsPastMoaiButton.setTitle(title, for: .normal)
            detailsPastMoaiButton.titleLabel?.font = UIFont.systemFont(ofSize: 25) //フォントサイズ
        }
    }

    
    
    @IBAction func pickOneOfPastMoais(_ sender: Any) {
        //ダウンスクロールメニューを表示し、その中から過去の模合を選択し、し終わると、その詳細を表示する
    }
    
    @IBAction func detailsMoai(_ sender: Any) {
        //選択されている模合の詳細情報を表示（表示形式は、今のところ画面遷移）
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
                let dic = snpashots?.data()
                self.moai = Moai(dic: dic ?? ["":""] )
            }
            self.makeMoaiMenbersNameList()
        }
    }

    //過去の模合データを取得するメソッド(引数は、模合のDocumentIDと、何回目の模合を取得するかの数(Int型) )
    //viewDidLoadでは直近のデータを取り出し、viewWillApearで選択された時の模合データを取り出す。複数回利用するのでメソッド化
    private func fetchPastRecord() {
        self.db.collection("moais").document("WNIz6YuRUnx7IaP5sLta").collection("pastRecords").getDocuments { (querySnapshots, err) in
            if let err = err {
                print("過去の模合情報の取得でエラーが出ました。\(err)")
                return
            }else {
                var array = [PastMoaiRecord]()
                guard let querySnapshots = querySnapshots else {return}
                for document in querySnapshots.documents {
                    let dic = document.data()
                    let recode = PastMoaiRecord(dic: dic)
                    print("\(document.documentID) => \(document.data())")
                    array.append(recode)
                }
                //古いデータが「0番目」、新しいのが「n番目」になってる
                self.pastRecodeArray = array
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
        self.moaiMenbersNameList.removeFirst()
        for menber in moaiMenbers {
            print("menberに格納されている値はこちら　\(menber)")
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
