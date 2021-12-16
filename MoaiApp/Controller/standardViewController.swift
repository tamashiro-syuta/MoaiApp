//
//  UIViewControllerExtension.swift
//  MoaiApp
//
//  Created by 玉城秀大 on 2021/08/19.
//

import UIKit
import Firebase

struct Members:Codable {
    let id:String
    let name:String
    let next:Bool
    let saving:Bool
    
    init(dic: [String: Any]) {
        self.id = dic["id"] as? String ?? ""
        self.name = dic["name"] as? String ?? ""
        self.next = dic["next"] as? Bool ?? false
        self.saving = dic["saving"] as? Bool ?? false
    }
}

class standardViewController :UIViewController {
    
    //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ 参照しているだけだから更新作業したら値が変わるの注意！！！！！ ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

    let db = Firestore.firestore()
    var userID = Auth.auth().currentUser?.uid
    
    var user: User?
    var moai: Moai?
    var nextMoai: MoaiRecord? //次回の模合の情報
    var nextMoaiID: String?
    var pastRecordArray: [MoaiRecord]?  //古いデータが「0番目」、新しいのが「n番目」になってる
//    var pastRecordIDStringArray: [String]?  // 20210417みたいな形で取り出してる
    var pastRecordIDDateArray: [String]?  //◯月◯日みたいな形で取り出してる
    var savingsArray: [Savings] = []
    var savingIDArray: [String] = []
//    var nextMoaiEntryArray: [Bool]? // ブーリアン型の配列
    
//    var memberArray: [ [String:Any] ]? // 模合メンバーの名前の配列（  ex)[["name": "テスト9", "id": "tMfuNFOxckUtupgmxIkgbNcLMap1"], ... ]  ）
//    var moaiMembersNameList: [String] = [] //模合メンバーの名前の配列
    
    override func viewDidLoad() {
        print("viewDidLoadが呼ばれました")
//        fetchUserInfo()
    }
    
    //viewが呼ばれた時に処理を始めているから、初期化(init)した時にDB処理ができるようにする
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
//        setup()
        self.sample(num: 1)
        //初期化された段階でユーザーの情報を取得する
        fetchUserInfo()
    }
//
//    override init(nibName nibNameOrNil: String!, bundle nibBundleOrNil: Bundle!) {
//        super.init(nibName: nil, bundle: nil)
////        setup()
//        self.sample(num: 2)
//      }

//      convenience init() {
//        self.init(nibName: nil, bundle: nil)
//        self.sample(num: 3)
//      }
    
    private func sample(num:Int) {
        print("引数は、\(num)です！！！！！！！")
    }
    
    //ユーザー情報の取得
    func fetchUserInfo() {
        //userIDを更新（生成時には、まだuserIDが入ってないかもしれないから）
        userID = Auth.auth().currentUser?.uid
        
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
                    self.fetchSavings()
                }
            }
        }
    }
    
    //ユーザーの模合情報の取得(後々は、複数入っている場合の模合情報を取れるようにする（配列(moai)の番号指定の部分を変数に置き換えして）)
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
                print("self.moai.members -> \(self.moai?.members)")
            }
        }
    }
    
    //過去の模合データを取得するメソッド(引数は、模合のDocumentIDと、何回目の模合を取得するかの数(Int型) )
    //viewDidLoadでは直近のデータを取り出し、viewWillApearで選択された時の模合データを取り出す。複数回利用するのでメソッド化
    func fetchPastRecord() {
        guard let moaiID = self.user?.moais[1] else {return}
        self.db.collection("moais").document(moaiID).collection("pastRecords").getDocuments { (querySnapshots, err) in
            if let err = err {
                print("過去の模合情報の取得(fetchPastRecord)でエラーが出ました。\(err)")
                return
            }else {
                var array1 = [MoaiRecord]()
                var array2 = [String]()
                guard let querySnapshots = querySnapshots else {return}
                for document in querySnapshots.documents {
                    let dic = document.data()
                    let record = MoaiRecord(dic: dic)
                    print("\(document.documentID) => \(document.data())")
                    array1.append(record)
                    
                    let moaiID = document.documentID
                    array2.append(moaiID)
                    
                }
                //古いデータが「0番目」、新しいのが「n番目」になってる
                self.pastRecordArray = array1
            }
        }
    }
        
    func fetchNextMoaiInfo() {
        guard let moaiID = self.user?.moais[1] else {return}
        self.db.collection("moais").document(moaiID).collection("next").getDocuments { (querySnapshots, err) in
            if let err = err {
                print("次回の模合情報の取得(fetchNextMoaiInfo)でエラーが出ました。\(err)")
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
    
    func fetchSavings() {
        guard let moaiID = self.user?.moais[1] else {return}
        self.db.collection("moais").document(moaiID).collection("savings").getDocuments { (querySnapshots, err) in
            if let err = err {
                print("次回の模合情報の取得(fetchNextMoaiInfo)でエラーが出ました。\(err)")
                return
            }else {
                guard let querySnapshots = querySnapshots else {return}
                for document in querySnapshots.documents {
                    
                    let mapData = document.data() as! [String:Any]
                    let ID = document.documentID
                    let paidAmounts = mapData["paidAmounts"]
                    
                    let dic = ["paidAmounts":paidAmounts] as [String:Any]
                    let saving = Savings(dic: dic)
                    print("saving.paidAmounts --> \(saving.paidAmounts)")
                    self.savingsArray.append(saving)
                    self.savingIDArray.append(ID)
                }
            }
        }
    }
    
    //模合のメンバーをIDでなく、名前で配列に入れる
//    private func makeMoaiMenbersList() {
//        //viewの再読み込み時にデータが人数より増えるのを防ぐため、一度初期化
//        self.memberArray = []
//        for member in self.moai!.menbers {
//            self.db.collection("users").document(member).getDocument { (snapshot, err) in
//                if let err = err {
//                    print("エラーです \(err)")
//                    return
//                }else {
//                    let username = snapshot?.data()?["username"] as! String
//                    let dictionary:Dictionary<String,String> = ["id": member, "name": username] //[member:username]
//                    self.memberArray?.append(dictionary)
//
//                    print("self.memberArray　→→→ \(self.memberArray)")
//
//                }
//            }
//        }
//    }
    
    //既に模合代を受け取った人のリスト
    private func makeAlreadyReceivedList() {
        
    }
    
    private func makePastRecordIDtoDateArray(array: Array<Any>) {
        //これ入れないと、配列に値を入れれなくなって、空になるから消さない。
        self.pastRecordIDDateArray = ["◯年◯月◯日みたいな形で取り出すよ"]
        self.pastRecordIDDateArray?.removeFirst()
        
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
            self.pastRecordIDDateArray?.append(pastDate2)
        }
    }
    
}
