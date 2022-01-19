//
//  ManagementViewController.swift
//  MoaiApp
//
//  Created by 玉城秀大 on 2021/06/27.
//

import UIKit
import Firebase
import PKHUD

class ManagementViewController: standardViewController, SendNewMembers {
    
    //pastMoaisButtonの横のアイコンで使用
    let downImage = UIImage(systemName: "arrowtriangle.down.fill")
    let upImage = UIImage(systemName: "arrowtriangle.up.fill")
    
    // 前ページから持ってきた値
//    var user: User?
//    var moai: Moai?
//    var nextMoai: MoaiRecord? //次回の模合の情報
//    var nextMoaiID: String?
//    var pastRecordArray: [MoaiRecord]?  //古いデータが「0番目」、新しいのが「n番目」になってる
//    var pastRecordIDStringArray: [String]?  // 20210417みたいな形で取り出してる
//    var pastRecordIDDateArray: [String]?  //◯月◯日みたいな形で取り出してる
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
    
    var newMembers:[ [String:Any] ] = []
    
    // 画面遷移したかどうかを判定する値
    var changedView:Bool = false
    
    
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
            print("self.pastRecordArray -> \(self.pastRecordArray)")

            //前の画面から値が渡ってきていない場合のみボタンのアルファ値の変更を行う
            if self.changedView == false {
                //ユーザーの参加、不参加によって、ボタンのalpha値を変更
                for i in 0...(self.moai?.members.count)! - 1 {
                    if self.moai?.members[i]["id"] as? String == self.userID {
                        let bool = self.moai?.members[i]["next"] as! Bool
                        print("ログインしているユーザーのnextは、\(bool)です！！！")
                        self.entryButtonsAlpha(Bool: bool)
                    }
                }
            }
        }
    }
    
    //模合詳細から新しいメンバーを受け取る（画面遷移で戻ったら呼ばれる）
    func SendNewMembers(newMembers: [[String : Any]]) {
        print("詳細画面から戻ってきたよ〜")
        // newMwmbersを更新
        self.newMembers = newMembers
        self.changedView = true
    }
    
    //レイアウト処理終了後
    override func viewDidLayoutSubviews() {
        print("レイアウト処理終了後")
        if self.changedView == true {
            print("newMember --> \(newMembers)")
            //参加、不参加ボタンのアルファ値を更新
            for i in 0...(self.newMembers.count) - 1 {
                if self.newMembers[i]["id"] as? String == self.userID {
                    let bool = self.newMembers[i]["next"] as! Bool
                    print("ログインしているユーザーのnextは、\(bool)です！！！")
                    self.entryButtonsAlpha(Bool: bool)
                }
            }
        }
    }
    
    //「次回の模合は」の部分のview
    private func setupView() {
        
        //ナビゲーションアイテムの追加
        let reloadViewButton = UIBarButtonItem(barButtonSystemItem: .compose, target: self, action: #selector(self.recordMoaiinfo(_:) ) )
        reloadViewButton.tintColor = .white
        self.navigationItem.rightBarButtonItem = reloadViewButton
        
        
        let nextMoaiDate = DateUtils.MddEEEFromDate(date: (self.nextMoai?.date.dateValue())! )
        self.nextMoaiDateLabel.text = nextMoaiDate
        
        self.navigationItem.title = self.moai?.groupName
        self.navigationController?.navigationBar.titleTextAttributes = [.foregroundColor: UIColor.white]
        
        //配列の順番をDBのmoaiのmenbersの順番と同じにするため
//        self.moaiMembersNameList.reverse()
        
        self.getMoneyPersonTableView.reloadData()
        
        //枠線
        self.getMoneyPersonLabel.layer.cornerRadius = 10
        self.getMoneyPersonLabel.layer.borderWidth = 4
        self.getMoneyPersonLabel.layer.borderColor = UIColor.textColor2().cgColor
        
        //詳細画面への画面遷移時に、参加不参加ボタンをタップしてないとnewMembersの値が空になってエラーが起きるため
        if self.changedView == false {
            self.newMembers = self.moai!.members
        }
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
    @objc func recordMoaiinfo(_ sender: Any) {
        print("模合の記録をしま〜〜〜〜す！！！！")
        let storyboard = UIStoryboard(name: "RecordMoaiInfo", bundle: nil)
        let recordMoaiInfoVC = storyboard.instantiateViewController(withIdentifier: "RecordMoaiInfoViewController") as! RecordMoaiInfoViewController
        recordMoaiInfoVC.user = self.user
        recordMoaiInfoVC.nextMoai = self.nextMoai
        recordMoaiInfoVC.nextMoaiID = self.nextMoaiID
        recordMoaiInfoVC.moai = self.moai
        self.navigationController?.pushViewController(recordMoaiInfoVC, animated: true)
        
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
        detailsNextMoaiVC.newMembers = self.newMembers
        detailsNextMoaiVC.delegate = self
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
//        changeNextMoaiVC.moaiMenbersNameList = self.moaiMembersNameList
        changeNextMoaiVC.nextMoai = self.nextMoai
        changeNextMoaiVC.nextMoaiID = self.nextMoaiID
        print(self.nextMoaiID)
        navigationController?.pushViewController(changeNextMoaiVC, animated: true)
    }
    
    //ユーザーの"next"が1(true)か2(false)か判別すれば良い
    private func entryOrNot(Bool:Bool) {
        
        self.newMembers = self.moai!.members
        
        for i in 0..<(newMembers.count) {
            if self.newMembers[i]["id"] as? String == userID {
                let next = Bool ? true : false
                print("next --> \(next)")
                newMembers[i]["next"] = next
                print("newMembers[\(i)][next]  -->  \(newMembers[i]["next"])")
            }
        }
        
        self.db.collection("moais").document((self.user?.moais[1])!).updateData(["members" : newMembers]) { (err) in
            if let err = err {
                print("エラーです。\(err)")
                return
            }
            print("entryOrNot完了")
        }
        
        entryButtonsAlpha(Bool: Bool)
    }
    
    private func entryButtonsAlpha(Bool: Bool) {
        print("Bool --> \(Bool)")
        let num = Bool ? 1 : 0
        if num == 1 {
            entryButton.alpha = 1.0
            notEntryButton.alpha = 0.4
        }else {
            entryButton.alpha = 0.4
            notEntryButton.alpha = 1.0
        }
    }
    
    private func addDateToMembers() {
        
        if self.pastRecordArray == nil || self.pastRecordArray?.count == 0 {
            //処理終了
            return
        }else {
            membersWithDate = self.moai!.members
            for i in 0..<(membersWithDate.count) {
                for record in self.pastRecordArray! {
                    if membersWithDate[i]["name"] as! String == record.getMoneyPerson["name"]! && membersWithDate[i]["id"] as! String == record.getMoneyPerson["id"]! {
                        //日付を文字列に変換
                        let date:String = DateUtils.MddEEEFromDate(date: record.date.dateValue() )
                        membersWithDate[i].updateValue(date, forKey: "date")
                        break //for文(recordの)を抜ける
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
