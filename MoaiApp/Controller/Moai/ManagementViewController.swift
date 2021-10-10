//
//  ManagementViewController.swift
//  MoaiApp
//
//  Created by 玉城秀大 on 2021/06/27.
//

import UIKit
import Firebase
import PKHUD

class ManagementViewController: standardViewController {
    
    //pastMoaisButtonの横のアイコンで使用
    let downImage = UIImage(systemName: "arrowtriangle.down.fill")
    let upImage = UIImage(systemName: "arrowtriangle.up.fill")
    
    // 前ページから持ってきた値
//    var user: User?
//    var moai: Moai?
//    var nextMoai: MoaiRecord? //次回の模合の情報
//    var nextMoaiID: String?
//    var pastRecodeArray: [MoaiRecord]?  //古いデータが「0番目」、新しいのが「n番目」になってる
//    var pastRecodeIDStringArray: [String]?  // 20210417みたいな形で取り出してる
//    var pastRecodeIDDateArray: [String]?  //◯月◯日みたいな形で取り出してる
//    var nextMoaiEntryArray: [Bool]? // ブーリアン型の配列
//    var moaiMenbersNameList: [String] = [] //模合メンバーの名前の配列
    
    
    @IBOutlet weak var nextDateStackView: UIStackView!
    @IBOutlet weak var getMoneyPeopleStackView: UIStackView!
    
    @IBOutlet weak var nextMoaiDateLabel: UILabel!
    @IBOutlet weak var entryButton: UIButton!
    @IBOutlet weak var notEntryButton: UIButton!
    @IBOutlet weak var getMoneyPersonTableView: UITableView!
    @IBOutlet weak var getMoneyPersonLabel: UILabel!
    @IBOutlet weak var blurView: UIVisualEffectView!
    
//    @IBOutlet weak var cellHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var getMoneyPeopleSVHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var getMoneyPeopleLabelHeightConstraint: NSLayoutConstraint!
    

    let today = Date()
    var nextMoaiDate: String?
    
    var membersWithDate: [ [String:Any] ] = []
    
//    var vi: UIView?  //過去の模合のスクロールビューで使用
    
    //viewが初めて呼ばれた１回目だけ呼ばれるメソッド
    override func viewDidLoad() {
        super.viewDidLoad()
        print("viewDidLoad")

    }
    
    //viewが更新された度に呼ばれる
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        print("viewWillAppear")
        
        self.navigationItem.rightBarButtonItem?.isEnabled = false
        
        HUD.flash(.progress, onView: view, delay: 2) { _ in
            //HUDを非表示にした後の処理
            self.setupView()
            self.addDateToMembers()
            self.getMoneyPersonTableView.dataSource = self
            self.getMoneyPersonTableView.delegate = self
            self.setupGetMoneyPersonSV()
            self.navigationItem.rightBarButtonItem?.isEnabled = true
            self.blurView.alpha = 0
            print("現在、ログインしているユーザー　\(self.user?.username)")
            print("self.moai.members -> \(self.moai?.members)")
            print("self.pastRecodeArray -> \(self.pastRecodeArray)")
//            print("self.pastRecodeIDStringArray -> \(self.pastRecodeIDStringArray)")
//            print("self.pastRecodeIDDateArray -> \(self.pastRecodeIDDateArray)")
            print("↓　pastRecode  ↓")
            for item in self.pastRecodeArray! {
                print("item.amount -> \(item.amount)")
                print("item.createdAt -> \(item.createdAt.dateValue())")
                print("item.date -> \(item.date.dateValue())")
                print("item.getMoneyPerson['name'] -> \(item.getMoneyPerson["name"])")
                print("item.getMoneyPerson['id'] -> \(item.getMoneyPerson["id"])")
//                print("item.getMoneyPersonID -> \(item.getMoneyPersonID)")
                print("item.location['name'] -> \(item.location["name"])")
                print("item.location['geoPoint'] -> \(item.location["geoPoint"] as! GeoPoint)")
//                print("item.locationName -> \(item.locationName)")
                print("item.note -> \(item.note)")
                print("item.paid -> \(item.paid)")
                print("item.unpaid -> \(item.unpaid)")
            }
            print("self.nextMoai -> \(self.nextMoai)")
            print("self.nextMoaiID -> \(self.nextMoaiID)")
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
        
        
        let nextMoaiDate = DateUtils.MddEEEFromDate(date: (self.nextMoai?.date.dateValue())! )
        self.nextMoaiDateLabel.text = nextMoaiDate
        
        self.navigationItem.title = self.moai?.groupName
        self.navigationController?.navigationBar.titleTextAttributes = [.foregroundColor: UIColor.white]
        
        //配列の順番をDBのmoaiのmenbersの順番と同じにするため
        self.moaiMembersNameList.reverse()
        
        self.getMoneyPersonTableView.reloadData()
        
        //枠線
        self.getMoneyPersonLabel.layer.cornerRadius = 10
        self.getMoneyPersonLabel.layer.borderWidth = 4
        self.getMoneyPersonLabel.layer.borderColor = UIColor.textColor2().cgColor
        
    }
    
    //getMoneyPeopleSVの高さを模合のメンバー数に応じて動的に処理
    private func setupGetMoneyPersonSV() {
        print("self.getMoneyPeopleSVHeightConstraintの型は、\(type(of: self.getMoneyPeopleSVHeightConstraint))")
        
        //セル1つ分の高さ
        let cellHeight:Int = 50
        let getMoneyPersonSVHeight:CGFloat = CGFloat( CGFloat(cellHeight * (self.moai?.members.count)!) + self.getMoneyPeopleLabelHeightConstraint.constant )
        //セルの高さ * 人数 + ラベルの高さ
        self.getMoneyPeopleSVHeightConstraint.constant = getMoneyPersonSVHeight
        
        //tableViewをタップできなくする
        self.getMoneyPersonTableView.allowsSelection = false
        //tableViewをスクロールできなくする
        self.getMoneyPersonTableView.isScrollEnabled = false
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
        recodeMoaiInfoVC.memberArray = self.memberArray as! [[String : Any]]
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

        detailsNextMoaiVC.moai = self.moai
        detailsNextMoaiVC.nextMoai = self.nextMoai
//        detailsNextMoaiVC.judgeEntryArray = self.nextMoaiEntryArray
//        detailsNextMoaiVC.moaiMenbersNameList = self.moaiMembersNameList
        navigationController?.pushViewController(detailsNextMoaiVC, animated: true)
    }
    
    //次回の模合を変更（日にちや模合など）
    @IBAction func changeNextMoai(_ sender: Any) {
        let storyboard = UIStoryboard(name: "ChangeNextMoai", bundle: nil)
        let changeNextMoaiVC = storyboard.instantiateViewController(identifier: "ChangeNextMoaiViewController") as! ChangeNextMoaiViewController
        changeNextMoaiVC.user = self.user
        changeNextMoaiVC.moai = self.moai
        changeNextMoaiVC.moaiMenbersNameList = self.moaiMembersNameList
        changeNextMoaiVC.nextMoai = self.nextMoai
        changeNextMoaiVC.nextMoaiID = self.nextMoaiID
        print(self.nextMoaiID)
        navigationController?.pushViewController(changeNextMoaiVC, animated: true)
    }
    
    //ユーザーがtrueかfalseか判別すれば良い
    private func entryOrNot2(Bool:Bool) {
        
    }
    
    private func entryOrNot(Bool: Bool) {
        print("nextMoaiEntryArray -> \(nextMoaiEntryArray)")
        print("memberArray -> \(memberArray)")
        guard let myName = self.user?.username else {return}
        print("myName -> \(myName)")
        //ログインしているユーザーが配列の何番目かを取得
        print("moaiMemberNameList -> \(moaiMembersNameList)")
        guard let myNumber = self.moaiMembersNameList.firstIndex(of: myName) else {return}
        print("myNumber -> \(myNumber)")
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
    
    private func addDateToMembers() {
        
        if self.pastRecodeArray == nil || self.pastRecodeArray?.count == 0 {
            //処理終了
            return
        }else {
            membersWithDate = self.moai!.members
            for i in 0..<(membersWithDate.count) {
                for recode in self.pastRecodeArray! {
                    if membersWithDate[i]["name"] as! String == recode.getMoneyPerson["name"]! && membersWithDate[i]["id"] as! String == recode.getMoneyPerson["id"]! {
                        //日付を文字列に変換
                        let date:String = DateUtils.MddEEEFromDate(date: recode.date.dateValue() )
                        membersWithDate[i].updateValue(date, forKey: "date")
                        break //for文(recodeの)を抜ける
                    }else {
                        //なかったら、"×"を入れる
                        membersWithDate[i].updateValue("×", forKey: "date")
                    }
                }
            }
            print("date型を入れてみたよ〜〜〜〜〜♪♪♪")
            print("membersWithDate -> -> -> ->  \(membersWithDate)")
        }
    }
}

extension ManagementViewController: UITableViewDelegate,UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return membersWithDate.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as UITableViewCell
        
        if membersWithDate.count == 0 {
            //元々２つあったセルのうち、1つを削除
            let label2 = cell.contentView.viewWithTag(2) as! UILabel
            label2.removeFromSuperview()
            //残った1つにテキストをつける
            let label1 = cell.contentView.viewWithTag(1) as! UILabel
            label1.text = "初めての模合が終了した後に利用できます。"
        }else {
            let label1 = cell.contentView.viewWithTag(1) as! UILabel
            let label2 = cell.contentView.viewWithTag(2) as! UILabel
            label1.frame.size.width = cell.frame.size.width / 2
            label2.frame.size.width = cell.frame.size.width / 2
            
            label1.text = membersWithDate[indexPath.row]["name"] as! String
            label2.text = membersWithDate[indexPath.row]["date"] as! String
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
}
