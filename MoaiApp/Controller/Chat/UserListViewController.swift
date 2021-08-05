//
//  UserListViewController.swift
//  ChatAppWithFirebase
//
//  Created by 玉城秀大 on 2021/05/12.
//

import UIKit
import Firebase
import Nuke //画像のURL(文字列)を画像データに変換するためのライブラリ

class UserListViewController: UIViewController {
    
    @IBOutlet weak var userListTableView: UITableView!
    @IBOutlet weak var startChatButton: UIButton!
    
    
    private let cellId = "cellId"
    private var users = [User]()
    private var selectedUser: User?
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        userListTableView.delegate = self
        userListTableView.dataSource = self
        userListTableView.tableFooterView = UIView()
        startChatButton.layer.cornerRadius = 15
        startChatButton.isEnabled = false
        startChatButton.backgroundColor = .white
        startChatButton.setTitleColor(.textColor2(), for: .normal)
        startChatButton.titleLabel?.adjustsFontSizeToFitWidth = true
        startChatButton.titleLabel?.minimumScaleFactor = 0.8
        //startChatButtonを押した時のメソッドの宣言（コードのみでの宣言の仕方）
        startChatButton.addTarget(self, action: #selector(tappedStartCahtButton), for: .touchUpInside)
        
//        navigationController?.navigationBar.barTintColor = .rgb(red: 39, green: 49, blue: 69)
        fetchUserInfoFromFirestore()
        
    }
    
    @objc func tappedStartCahtButton() {
        
        guard let uid = Auth.auth().currentUser?.uid else {return}
        guard let partnerUid = self.selectedUser?.uid else {return}
        let menbers = [uid,partnerUid]
        
        let docData = [
            "menbers": menbers,
            "latestMessageId": "",
            "createdAt": Timestamp()
        ] as [String : Any]
        
        //FireStoreに情報を保存
        Firestore.firestore().collection("chatRooms").addDocument(data: docData) {(err) in
            if let err = err {
                print("chatRoom情報の保存に失敗しました。\(err)")
            }
            //ChatListの画面に戻る
            self.dismiss(animated: true, completion: nil)
            //ChatListの画面に選択したユーザーの情報を載せる
            print("ChatRoom情報の保存に成功しました。")
        }
    }
    
    private func fetchUserInfoFromFirestore() {
        Firestore.firestore().collection("users").getDocuments { [self] (snapshots, err) in
            if let err = err {
                print("ユーザー情報の取得に失敗しました。\(err)")
                return
            }
            snapshots?.documents.forEach({ (snapshot) in
                let dic = snapshot.data()
                //上で定義したデータをUserクラスでインスタンス化
                let user = User.init(dic: dic)
                user.uid = snapshot.documentID
                
                //ログインしているユーザーの情報は反映されないようにするための処理
                guard let uid = Auth.auth().currentUser?.uid else {return}
                if uid == snapshot.documentID {
                    return
                }
                
                //usersという配列に追加
                self.users.append(user)
                self.userListTableView.reloadData()
                //print("date :",data)
            })
        }
    }
    
}


extension UserListViewController: UITableViewDelegate,UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return users.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = userListTableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath)  as! UserListTableViewCell
        cell.user = users[indexPath.row]
        cell.userImageView.layer.cornerRadius = 32.5
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70
    }
    
    //セルが選択された時の処理
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        startChatButton.isEnabled = true
        
        //userの情報を取得し、上で宣言した変数に入れる。
        let user = users[indexPath.row]
        self.selectedUser = user
        
        //受け取った情報をFireStoreに保存し、会話を開始
        
    }
    
    
}





class UserListTableViewCell: UITableViewCell {
    
    
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var userImageView: UIImageView!
    
    
    var user: User? {
        didSet {
            usernameLabel.text = user?.username
            
            if let url = URL(string: user?.profileImageUrl ?? "") {
                //画像のURL(文字列)を画像データに変換
                Nuke.loadImage(with: url, into: userImageView)
            }
        }
    }
    
    override class func awakeFromNib() {
        super.awakeFromNib()
        
        //userImageView.layer.cornerRadius = 25
        
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
}
