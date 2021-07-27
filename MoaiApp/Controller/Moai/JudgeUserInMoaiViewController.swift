//
//  JudgeUserInMoaiViewController.swift
//  MoaiApp
//
//  Created by 玉城秀大 on 2021/07/21.
//

import UIKit
import Firebase
import PKHUD

class JudgeUserInMoaiViewController: UIViewController {
    
    let db = Firestore.firestore()
    let userID = Auth.auth().currentUser?.uid
    var user: User?
    var moai: Moai?
    
    var pastRecodeArray: [MoaiRecord]?  //古いデータが「0番目」、新しいのが「n番目」になってる
    var pastRecodeIDStringArray: [String]?  // 20210417みたいな形で取り出してる
    var pastRecodeIDDateArray: [String]?  //◯月◯日みたいな形で取り出してる
    
    var nextRecodeArray: [MoaiRecord]?
    
    var nextMoaiEntryArray: [Bool]?
    var moaiMenbersNameList: [String] = [] //模合メンバーの名前の配列
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationController?.navigationBar.barTintColor = .rgb(red: 39, green: 49, blue: 69)
        navigationController?.navigationBar.titleTextAttributes = [.foregroundColor: UIColor.white]
        
        //ユーザー情報の取得（模合に参加してるならmanagementVCに、してないならMoaiに画面遷移）
        self.fetchLoginUserInfo()
        //インジケーターを回す
        HUD.flash(.progress, onView: view, delay: 1.5) { _ in
            //HUDを非表示にした後の処理
            //ユーザーの模合情報に応じて別画面に画面遷移
            print("模合のカウントはこちら！！！　\(self.user?.moais.count)")
            if self.user?.moais.count == 1 {
                //模合の作成・参加画面へ画面遷移
                self.pushMoaiBaseVC()
            }else {
                //画面遷移
                self.pushManagementVC()
            }
        }

    }
    
    //ManagementVCに画面遷移
    private func pushManagementVC() {
        print("画面遷移しまーーーーーーーーーーーーーーーす")
        let storyboard = UIStoryboard(name: "Management", bundle: nil)
        let ManagementVC = storyboard.instantiateViewController(withIdentifier: "ManagementViewController") as! ManagementViewController
        ManagementVC.navigationItem.hidesBackButton = true
        //値の受け渡し
        ManagementVC.user = self.user
        ManagementVC.moai = self.moai
        ManagementVC.pastRecodeArray = self.pastRecodeArray
        ManagementVC.pastRecodeIDDateArray = self.pastRecodeIDDateArray
        ManagementVC.nextMoaiEntryArray = self.nextMoaiEntryArray
        ManagementVC.moaiMenbersNameList = self.moaiMenbersNameList
        
        self.navigationController?.pushViewController(ManagementVC, animated: true)
    }
    
    //moai.storyboardに画面遷移
    private func pushMoaiBaseVC() {
        print("ManagementViewに画面遷移しまーす")
        let storyboard = UIStoryboard(name: "Moai", bundle: nil)
        let MoaiBaseVC = storyboard.instantiateViewController(withIdentifier: "MoaiBaseViewController") as! MoaiBaseViewController
        MoaiBaseVC.user = self.user
        MoaiBaseVC.navigationItem.hidesBackButton = true  // navigationの戻るボタンを非表示
        self.navigationController?.pushViewController(MoaiBaseVC, animated: true)
    }
    
    //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ DB操作 ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    
    //ユーザー情報の取得
    private func fetchLoginUserInfo() {
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
                }
            }
        }
    }
    
    //ユーザーの模合情報の取得(後々は、複数入っている場合の模合情報を取れるようにする（配列の番号指定の部分を変数に置き換えして）)
    private func fetchUsersMoaiInfo(user: User) {
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
    private func fetchPastRecord() {
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
    // ~~~~~~~~~~~~~~~~~~~~~~~~~~  DB操作終了  ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    
    //文字列型で入ってる配列を、読みやすい形に直すためのメソッド(引数にはself.pastRecodeIDStringArrayを入れる)
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
    
    
}
