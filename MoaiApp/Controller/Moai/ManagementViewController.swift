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
    var nextMoai: MoaiRecord? //次回の模合の情報
    var nextMoaiID: String?
    var pastRecodeArray: [MoaiRecord]?  //古いデータが「0番目」、新しいのが「n番目」になってる
    var pastRecodeIDStringArray: [String]?  // 20210417みたいな形で取り出してる
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
        ["C","2/13"]
    ]

    let today = Date()
    var nextMoaiDate: String?
    
    var vi: UIView?  //過去の模合のスクロールビューで使用
    
    //viewが初めて呼ばれた１回目だけ呼ばれるメソッド
    override func viewDidLoad() {
        super.viewDidLoad()
        print("viewDidLoad")
    }
    
    //viewが更新された度に呼ばれる
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        print("viewWillAppear")
        
        //ユーザー情報の取得（模合に参加してるならmanagementVCに、してないならMoaiに画面遷移）
        self.fetchLoginUserInfo()
        
        self.blurView.alpha = 1
        
        self.navigationItem.rightBarButtonItem?.isEnabled = false
        
        HUD.flash(.progress, onView: view, delay: 1) { _ in
            //HUDを非表示にした後の処理
            self.setupView()
            self.makeGetMoneyPersonList()
            self.getMoneyPersonTableView.dataSource = self
            self.getMoneyPersonTableView.delegate = self
            self.navigationItem.rightBarButtonItem?.isEnabled = true
            self.blurView.alpha = 0
        }
        
        //1秒後に処理
//        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
//            //ここに処理
//            self.setupView()
//            self.makeGetMoneyPersonList()
//            self.getMoneyPersonTableView.dataSource = self
//            self.getMoneyPersonTableView.delegate = self
//        }
    }
    
    //「次回の模合は」の部分のview
    private func setupView() {
        
        //ナビゲーションアイテムの追加
        let reloadViewButton = UIBarButtonItem(barButtonSystemItem: .compose, target: self, action: #selector(self.recodeMoaiinfo(_:) ) )
        reloadViewButton.tintColor = .white
        self.navigationItem.rightBarButtonItem = reloadViewButton
        
        //ボタンに文字と画像を設置
        pastMoaisButton.setTitle("過去の模合", for: .normal)
        pastMoaisButton.setImage(downImage, for: .normal)
        //画像と文字絵を被らないように配置
        pastMoaisButton.imageEdgeInsets = UIEdgeInsets(top: 0, left: 180, bottom: 0, right: 0)
        pastMoaisButton.titleEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 20)
        
        
        let nextMoaiDate = DateUtils.stringFromDate(date: (self.nextMoai?.date.dateValue())!)
        self.nextMoaiDateLabel.text = nextMoaiDate
        
        
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
    
    //viewの再読み込み
    @objc func recodeMoaiinfo(_ sender: Any) {
        print("模合の記録をしま〜〜〜〜す！！！！")
        let storyboard = UIStoryboard(name: "RecodeMoaiInfo", bundle: nil)
        let recodeMoaiInfoVC = storyboard.instantiateViewController(withIdentifier: "RecodeMoaiInfoViewController") as! RecodeMoaiInfoViewController
        recodeMoaiInfoVC.user = self.user
        recodeMoaiInfoVC.nextMoai = self.nextMoai
        recodeMoaiInfoVC.nextMoaiID = self.nextMoaiID
        recodeMoaiInfoVC.moai = self.moai
        recodeMoaiInfoVC.moaiMenbersNameList = self.moaiMenbersNameList
        self.navigationController?.pushViewController(recodeMoaiInfoVC, animated: true)
        
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

        detailsNextMoaiVC.nextMoai = self.nextMoai
        detailsNextMoaiVC.judgeEntryArray = self.nextMoaiEntryArray
        detailsNextMoaiVC.moaiMenbersNameList = self.moaiMenbersNameList
        navigationController?.pushViewController(detailsNextMoaiVC, animated: true)
    }
    
    //次回の模合を変更（日にちや模合など）
    @IBAction func changeNextMoai(_ sender: Any) {
        let storyboard = UIStoryboard(name: "ChangeNextMoai", bundle: nil)
        let changeNextMoaiVC = storyboard.instantiateViewController(identifier: "ChangeNextMoaiViewController") as! ChangeNextMoaiViewController
        changeNextMoaiVC.user = self.user
        changeNextMoaiVC.moai = self.moai
        changeNextMoaiVC.moaiMenbersNameList = self.moaiMenbersNameList
        changeNextMoaiVC.nextMoai = self.nextMoai
        changeNextMoaiVC.nextMoaiID = self.nextMoaiID
        print(self.nextMoaiID)
        navigationController?.pushViewController(changeNextMoaiVC, animated: true)
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
                let selectedPastRecode: MoaiRecord = (self.pastRecodeArray?[backnumber])!
                let date = DateUtils.stringFromDate(date: selectedPastRecode.date.dateValue()) //TimeStampからDateに直したものを文字列化
                print("dateはちゃんと取れてるかな〜〜？？\(date)")
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
    
    
    
    
    
    
    //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ DB操作 ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    
    //ユーザー情報の取得
    func fetchLoginUserInfo() {
        self.db.collection("users").document(self.userID ?? "").getDocument { (snapshots, err) in
            if let err = err {
                print("エラーでした~~\(err)")
                return
            }else {
                guard let dic = snapshots?.data() else {
                    print("snapshotsの値が取得できませんでした！！")
                    return
                }
                self.user = User(dic: dic)
                
                //ユーザーの模合の参加判定
                if self.user?.moais.count == 1 {
                    print("ユーザーは模合に入ってなんかいねぇよ！！！")
                    return
                }else {
                    print("ユーザーは模合にちゃんと入ってるよ！！！")
                    //模合情報を取得
                    self.fetchUsersMoaiInfo(user: self.user!)
                    self.fetchPastRecord()
                    self.fetchNextMoaiInfo()
                }
            }
        }
    }
    
    //ユーザーの模合情報の取得(後々は、複数入っている場合の模合情報を取れるようにする（配列の番号指定の部分を変数に置き換えして）)
    func fetchUsersMoaiInfo(user: User) {
        guard let moaiID = self.user?.moais[1] else {return}
        self.db.collection("moais").document(moaiID).getDocument { (snapshot, err) in
            if let err = err {
                print("ユーザーの模合情報の取得に失敗しました。\(err)")
                return
            }else {
                guard let dic = snapshot?.data() else {
                    print("ユーザーの模合情報に誤りがありました。")
                    return
                }
                self.moai = Moai(dic: dic)
            }
            self.makeMoaiMenbersNameList()
            guard let next = self.moai?.next else {return}
            self.nextMoaiEntryArray = next
        }
    }

    //過去の模合データを取得するメソッド(引数は、模合のDocumentIDと、何回目の模合を取得するかの数(Int型) )
    //viewDidLoadでは直近のデータを取り出し、viewWillApearで選択された時の模合データを取り出す。複数回利用するのでメソッド化
    func fetchPastRecord() {
        guard let moaiID = self.user?.moais[1] else {return}
        self.db.collection("moais").document(moaiID).collection("pastRecords").getDocuments { (querySnapshots, err) in
            if let err = err {
                print("過去の模合情報の取得でエラーが出ました。\(err)")
                return
            }else {
                var array1 = [MoaiRecord]()
                var array2 = [String]()
                guard let querySnapshots = querySnapshots else {return}
                for document in querySnapshots.documents {
                    let dic = document.data()
                    let recode = MoaiRecord(dic: dic)
                    print("\(document.documentID) => \(document.data())")
                    array1.append(recode)
                    
                    let moaiID = document.documentID
                    array2.append(moaiID)
                    
                }
                //古いデータが「0番目」、新しいのが「n番目」になってる
                self.pastRecodeArray = array1
                self.pastRecodeIDStringArray = array2
                self.makePastRecodeIDtoDateArray(array: self.pastRecodeIDStringArray!)
            }
        }
    }
        
    func fetchNextMoaiInfo() {
        guard let moaiID = self.user?.moais[1] else {return}
        self.db.collection("moais").document(moaiID).collection("next").getDocuments { (querySnapshots, err) in
            if let err = err {
                print("次回の模合情報の取得でエラーが出ました。\(err)")
                return
            }else {
                guard let querySnapshots = querySnapshots else {return}
                //コレクションからfor文で回しているだけでコレクション内のデータは1つしかないので直接self.nextMoaiに代入している
                for document in querySnapshots.documents {
                    let dic = document.data()
                    let documentID = document.documentID
                    self.nextMoai = MoaiRecord(dic: dic)
                    self.nextMoaiID = documentID
                }
            }
        }
    }
    
    //模合のメンバーをIDでなく、名前で配列に入れる
    private func makeMoaiMenbersNameList() {
        //viewの再読み込み時にデータが人数より増えるのを防ぐため、一度初期化
        self.moaiMenbersNameList = []
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
    // ~~~~~~~~~~~~~~~~~~~~~~~~~~  DB操作終了  ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

    
    private func makePastRecodeIDtoDateArray(array: Array<Any>) {
        
        //これ入れないと、配列に値を入れれなくなって、空になるから消さない。
        self.pastRecodeIDDateArray = ["◯年◯月◯日みたいな形で取り出すよ"]
        self.pastRecodeIDDateArray?.removeFirst()
        
        let dateFormatter1 = DateFormatter()
        dateFormatter1.dateFormat = "yyyyMMdd"  //"E, d MMM yyyy HH:mm:ss Z"
        
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
                        let date = DateUtils.stringFromDate(date: pastRecode.date.dateValue())
                        self.GetMoneyPersonList.append([menberName,date])
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
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
}
