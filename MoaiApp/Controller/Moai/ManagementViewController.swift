//
//  ManagementViewController.swift
//  MoaiApp
//
//  Created by 玉城秀大 on 2021/06/27.
//

import UIKit
import Firebase

class ManagementViewController: UIViewController {
    
    let db = Firestore.firestore()
    let userID = Auth.auth().currentUser?.uid
    
    //============= 非同期通信用にディスパッチグループおよびディスパッチキューの作成 ============= //
    let dispatchGroup = DispatchGroup()
    let queue1 = DispatchQueue(label: "キュー1")
    let queue2 = DispatchQueue(label: "キュー2", attributes: .concurrent)
    
    
    //pastMoaisButtonの横のアイコンで使用
    let downImage = UIImage(systemName: "arrowtriangle.down.fill")
    let upImage = UIImage(systemName: "arrowtriangle.up.fill")
    
    //模合代を誰が徴収したかの確認(誰が何日にもらって的なやつ)のための辞書型の変数
    //FireBaseからデータを取得して入れる
    //ex) let dic = ["Aさん":"12/5","Bさん":"×"]
    var GetMoneyPersonList = [
        ["A","7/1"],
        ["B","×"],
        ["C","なんでテーブルビューが表示されないんだよ"]
    ]
    
    //ログインしているユーザー情報を入れる
    var user: User? {
        didSet {
            navigationItem.title = user?.username
        }
    }
    var moai: Moai?
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
        
        
        //模合の情報を元に画面に表示
        getMoneyPersonTableView.dataSource = self
        getMoneyPersonTableView.delegate = self
        setupView()
        
        
        
        
//        fetchLoginUserInfo { (currentUser) in
//            self.user = currentUser
//            print("あいうえお\(self.user?.moais[0])")
//        }
        //通信前に呼ばれてるからnilになる
        //print(user?.moais[0])

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
    
    
    
    
    
    
    
    
    
    
    
    //　〜〜〜〜〜〜〜〜〜〜〜〜〜〜〜〜〜〜〜〜〜〜〜〜〜〜〜〜〜〜　次 や る こ と　〜〜〜〜〜〜〜〜〜〜〜〜〜〜〜〜〜〜〜〜〜〜〜〜〜〜〜〜〜〜〜
    // ①複雑化した処理を簡潔に直す。（DBからデータを取得する処理は、一つのメソッドで繋げてやる方向にした。）
    //
    // ②既存のコードには、模合の配列を作り、そこに模合のデータを全て入れることで一回で処理を終わらそうとしているが、模合のデータを表示するところは、２箇所のみ（１箇所は日時固定で表示し、もう１箇所は、選択した日時のものを表示する）ので、そこまで負荷はかからないと判断し、毎回メソッドを用いて、データを取得してくることにした。
    //  なので、moaiArrayなどのコードは、削除する。
    //　（もう一つの理由は、非同期処理が理由でUI表示に苦戦しているので、一度に全部の模合のデータを取得することは、さらに非同期処理の時間を増やすことになるので、毎回メソッドを用いて取得することにした。）
    //
    //
    //　【案①】
    //　viewDidLoadで、初めにの数秒間は、インジケーターを回し、その間、ブラーなどで画面を曇らせ、動作できないようにする。（その間にDB処理）
    //
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    func doMultiAsyncProcess() {
        let dispatchGroup = DispatchGroup()
        // 直列キュー / attibutes指定なし
        let dispatchQueue = DispatchQueue(label: "queue")

        // 5つの非同期処理を実行(ここにDB系の処理を入れる)
        for i in 1...5 {
            let dispatchSemaphore = DispatchSemaphore(value: 0)
            
            dispatchQueue.async(group: dispatchGroup) {
                [weak self] in
                dispatchGroup.enter()
                
                self?.asyncProcess(number: i) {
                    (number: Int) -> Void in
                    print("#\(number) End")
                    
                    dispatchGroup.leave()
                    dispatchSemaphore.signal()
                }
                
                dispatchSemaphore.wait()
            }
        }

        // 全ての非同期処理完了後にメインスレッドで処理
        dispatchGroup.notify(queue: .main) {
            print("All Process Done!")
        }
    }

    // 非同期処理
    func asyncProcess(number: Int, completion: @escaping (_ number: Int) -> Void) {
        print("#\(number) Start")
        let interval  = TimeInterval(arc4random() % 100 + 1) / 100
        DispatchQueue.global().asyncAfter(deadline: .now() + interval) {
            completion(number)
        }
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
        
        //DB処理
        guard let uid = Auth.auth().currentUser?.uid else {return}
        //ログインしているユーザーの情報だけを取得
        Firestore.firestore().collection("users").document(uid).getDocument { (snapshot, err) in
            if let err = err {
                print("ユーザー情報の取得に失敗しました。\(err)")
                return
            }
            
            //ユーザー情報の取得成功時
            //snapshotのnilチェック
            guard let snapshot = snapshot,let dic = snapshot.data() else {return}
  
            let user = User(dic: dic)
            self.user = user
            
            guard let moaiID = user.moais.first else {return}
            Firestore.firestore().collection("moais").document(moaiID).getDocument { (snapshot, err) in
                if let err = err {
                    print("ユーザーの模合情報の取得に失敗しました。\(err)")
                    return
                }
                
                guard let snapshot = snapshot,let dic = snapshot.data() else {return}
                let moai = Moai(dic: dic)
                //self.usersMoaiArray?.append(moai)
                //DBから取得した値を使ってGetNextMoaiDateで正しい次の模合の日付を取得できるようにする（moaisテーブルのdateを二つに分けて（date1,date2など）それぞれをswitch文でInt型で返すようにしたいので、moaisテーブルにデータをセットする時の処理もそれ用に書き換える必要あり。）
                let moaiDateMaterial = self.switchMoaiDate(weekNum: moai.week, weekDay: moai.day)
                let moaiDate = self.GetNextMoaiDate(weekNum: moaiDateMaterial.0, weekDay: moaiDateMaterial.1)
                
                self.nextMoaiDateLabel.text = moaiDate
            }
            let latesPastRecord = self.fetchPastRecord(moaisDocumentID: user.moais[0], backNumber: 0)
        }
        
    }

    //「過去の模合」の部分のview
    private func setupPastMoaisView() {
        
        //このタイトルは、DBから値を持ってくる前のサンプル的な用途で置いてるだけのやつ
        let title = "  ◯/◯ （◯）" + "\n" + "  受け取り：◯◯さん" + "\n" + "  場所：〜〜〜"
        detailsPastMoaiButton.titleLabel?.numberOfLines = 0
        detailsPastMoaiButton.titleLabel?.sizeToFit()
        detailsPastMoaiButton.setTitle(title, for: .normal)
        detailsPastMoaiButton.titleLabel?.font = UIFont.systemFont(ofSize: 25) //フォントサイズ

    }

    
    
    @IBAction func pickOneOfPastMoais(_ sender: Any) {
        //ダウンスクロールメニューを表示し、その中から過去の模合を選択し、し終わると、その詳細を表示する
    }
    
    @IBAction func detailsMoai(_ sender: Any) {
        //選択されている模合の詳細情報を表示（表示形式は、今のところ画面遷移）
    }
    
    
    
    
    //ーーーーーーーーーーーーーーー 明 日 は こ こ か ら ーーーーーーーーーーーーーーーー
    //【やること】
    //DBから取得した値を使ってGetNextMoaiDateで正しい次の模合の日付を取得できるようにする（moaisテーブルのdateを二つに分けて（date1,date2など）それぞれをswitch文でInt型で返すようにしたいので、moaisテーブルにデータをセットする時の処理もそれ用に書き換える必要あり。）
    //サンプル用の模合のデータはFirebase上で直接書き換える
    //終わったら、チャットの時のコード見ながら、もしユーザーが模合に入っていなかったらMoai.storyboardを表示するようにする。
    //お母さんが帰ってきたら、①模合終了時の書き込み（誰がお金とって、誰が払ってないかなど）はどのタイミングで出来る仕様が良いか、②今のviewを見せて使いづらい点はないか（表示されてるものだけで十分か？逆に情報は多すぎてないか？）、③どんな機能が欲しいか？
    
    //ーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーー
    
    //これを元にDB系のメソッドをやってみる
    //引数completionにクロージャを指定
    func getDocuments(completion: @escaping (Int) -> () ){
        db.collection("aaa").document("bbb").collection("ccc").getDocuments() { (querySnapshot, err) in
            if let err = err {
                print("Error getting documents: \(err)")
            } else {
                for document in querySnapshot!.documents {
                    // countに取得したデータの数を入れる
                    if let count = querySnapshot?.documents.count {
                        //
                        DispatchQueue.main.async {
                            //以降のgetDocuments()のクロージャの処理でcountが使用できるようになる
                            completion(count)
                        }
                    }
                }
            }
        }
    }

//    getDocuments() { count in
//        //ここでDBからの情報を変数に格納したりする
//        self.aNumber = Double(count)
//        self.amountNumber.text = "\(count)" // 20
//        print(self.aNumber)
//    }
    
//    private func fetchLoginUserInfo(completion: @escaping (User) -> () ) {
//        guard let uid = Auth.auth().currentUser?.uid else {return}
//        //ログインしているユーザーの情報だけを取得
//        Firestore.firestore().collection("users").document(uid).getDocument { (snapshot, err) in
//            if let err = err {
//                print("ユーザー情報の取得に失敗しました。\(err)")
//                return
//            }
//            DispatchQueue.main.async {
//                //以降の関数呼び出し時のクロージャの処理でcountが使用できるようになる
//                guard let snapshot = snapshot,let dic = snapshot.data() else {return}
//                let currentUser = User(dic: dic)
//                completion(currentUser)
//            }
//            //上で宣言したuserにuser(ログインしているユーザー)を入れる
//        }
//    }
    
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
        }
    }
    

//    private func fetchUsersMoaiInfo() {
//        guard let moaiID = self.user?.moais.first else {return}
//        Firestore.firestore().collection("moais").document(moaiID).getDocument { (snapshot, err) in
//            if let err = err {
//                print("ユーザーの模合情報の取得に失敗しました。\(err)")
//                return
//            }
//
//            guard let snapshot = snapshot,let dic = snapshot.data() else {return}
//            let moai = Moai(dic: dic)
//            self.usersMoaiArray?.append(moai)
//
//            //DBから取得した値を使ってGetNextMoaiDateで正しい次の模合の日付を取得できるようにする（moaisテーブルのdateを二つに分けて（date1,date2など）それぞれをswitch文でInt型で返すようにしたいので、moaisテーブルにデータをセットする時の処理もそれ用に書き換える必要あり。）
//            let moaiDateMaterial = self.switchMoaiDate(weekNum: moai.week, weekDay: moai.day)
//            let moaiDate = self.GetNextMoaiDate(weekNum: moaiDateMaterial.0, weekDay: moaiDateMaterial.1)
//        }
//    }
    
    
    //過去の模合データを取得するメソッド(引数は、模合のDocumentIDと、何回目の模合を取得するかの数(Int型) )
    //viewDidLoadでは直近のデータを取り出し、viewWillApearで選択された時の模合データを取り出す。複数回利用するのでメソッド化
    private func fetchPastRecord(moaisDocumentID: String, backNumber:Int) -> Array<Any> {
        var pastRecordsArray:Array<Any> = []
        Firestore.firestore().collection("moais").document(moaisDocumentID).collection("pastRecords").getDocuments { (querySnapshot, err) in
            if let err = err {
                print("サブコレクション(pastRecords)の取得に失敗しました。\(err)")
                return
            }
            guard let querySnapshot = querySnapshot else {return}
            for document in querySnapshot.documents {
                //document.data()は辞書型
                print(document.data())
                pastRecordsArray.append(document.data())
            }
            print(pastRecordsArray[0])
        }
        return pastRecordsArray
    }
    
    
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
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    

}

extension ManagementViewController: UITableViewDelegate,UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return GetMoneyPersonList.count
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = getMoneyPersonTableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        let label1 = cell.contentView.viewWithTag(1) as! UILabel
        let label2 = cell.contentView.viewWithTag(2) as! UILabel
        
        print("なんでテーブルビューが表示されねぇんだよ3")
        
        // Labelにテキストを設定する
        label1.text = GetMoneyPersonList[indexPath.row][0]
        label2.text = GetMoneyPersonList[indexPath.row][1]
        
        return cell
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        print("なんでテーブルビューが表示されねぇんだよ1")
        return 1
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return view.frame.size.height / 6
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "タイトル"
    }
    
    
}
