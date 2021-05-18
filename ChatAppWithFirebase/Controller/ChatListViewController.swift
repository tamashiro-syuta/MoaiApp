//
//  ChatListViewController.swift
//  ChatAppWithFirebase
//
//  Created by 玉城秀大 on 2021/05/09.
//

import UIKit
import Firebase
import Nuke

class ChatListViewController: UIViewController {
    
    private let cellId = "cellId"
    private var chatrooms = [ChatRoom]()
    private var user: User? {
        didSet {
            //ユーザーの情報がセットされた時点でナビゲーションバーのタイトルに名前を設定
            navigationItem.title = user?.username
        }
    }
    
    @IBOutlet weak var chatListTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        setUpViews()
        confirmLoginUser()
        fetchLoginUserInfo()
        fetchChatroomsInfoFromFireStore()
    }
    
    //FireStoreからチャットルーム情報を取得
    private func fetchChatroomsInfoFromFireStore() {
        //  addSnapshotListener　がリアルタイム処理をしてくれる
        Firestore.firestore().collection("chatRooms").addSnapshotListener { [self] (snapshots, err) in

            if let err = err {
                print("chatRoom情報の取得に失敗しました。\(err)")
            }
            
            snapshots?.documentChanges.forEach({ (documentChange) in
                
                //新しく来た情報だけを受け取りたい
                switch documentChange.type {
                //addedは、「新しく情報が追加されたケース」
                case .added:
                    handleAddedDocumentChange(documentChange: documentChange)
                case .modified,.removed:
                    print("nothiing to do")
                }
            })
        }
    }
    
    
    private func handleAddedDocumentChange(documentChange: DocumentChange) {
        let dic = documentChange.document.data()
        let chatroom = ChatRoom(dic: dic)
        
        //相手側のユーザー情報を持ってくる
        guard let uid = Auth.auth().currentUser?.uid else {return}
        //メンバーの確認
        chatroom.menbers.forEach { (menberUid) in
            if menberUid != uid {
                Firestore.firestore().collection("users").document(menberUid!).getDocument { (snapshot, err) in
                    if let err = err {
                        print("ユーザー情報の取得に失敗しました。\(err)")
                        return
                    }
                    
                    guard let dic = snapshot?.data() else {return}
                    let user = User(dic: dic)
                    user.uid = documentChange.document.documentID
                    
                    chatroom.partnerUser = user
                    self.chatrooms.append(chatroom)
                    print("self.chatrooms :",self.chatrooms)
                    self.chatListTableView.reloadData()
                }
            }
        }
    }
    
    
    private func setUpViews() {
        chatListTableView.delegate = self
        chatListTableView.dataSource = self
        chatListTableView.tableFooterView = UIView()
        navigationController?.navigationBar.barTintColor = .rgb(red: 39, green: 49, blue: 69)
        navigationItem.title = "トーク"
        navigationController?.navigationBar.titleTextAttributes = [.foregroundColor: UIColor.white]
        
        let rightBarButton = UIBarButtonItem(title: "新規チャット", style: .plain, target: self, action: #selector(tappedNavRightBarButton))
        //navigationBarの右側にボタンをコードで追加
        navigationItem.rightBarButtonItem = rightBarButton
        navigationItem.rightBarButtonItem?.tintColor = .white
    }
    
    
    private func confirmLoginUser() {
        if Auth.auth().currentUser?.uid == nil {
            //立ち上がった時にSignUpViewControllerを表示する処理
            let storyboard = UIStoryboard(name: "SignUp", bundle: nil)
            let signUpViewController = storyboard.instantiateViewController(withIdentifier: "SignUpViewController") as! SignUpViewController
            signUpViewController.modalPresentationStyle = .fullScreen
            self.present(signUpViewController, animated: true, completion: nil)
        }
    }
    
    //controlから引っ張ってくる以外のアクションの作り方(上のlet rightBarButtoの部分のセレクターとセット)
    @objc private func tappedNavRightBarButton() {
        //新規チャット画面への画面遷移
        let storyborad = UIStoryboard.init(name: "UserList", bundle: nil)
        let userListViewController = storyborad.instantiateViewController(withIdentifier: "UserListViewController")
        //画面遷移先のuserListViewControllerにナビゲーションバーを追加
        let nav = UINavigationController(rootViewController: userListViewController)
        self.present(nav, animated: true, completion: nil)
    }
    
    
    private func fetchLoginUserInfo() {
        guard let uid = Auth.auth().currentUser?.uid else {return}
        //ログインしているユーザーの情報だけを取得
        Firestore.firestore().collection("users").document(uid).getDocument { (snapshot, err) in
            if let err = err {
                print("ユーザー情報の取得に失敗しました。\(err)")
                return
            }
            
            //snapshotのnilチェック
            guard let snapshot = snapshot,let dic = snapshot.data() else {return}
            
            let user = User(dic: dic)
            //上で宣言した16行目で宣言したuserにuser(ログインしているユーザー)を入れる
            self.user = user
        }
    }
}

extension ChatListViewController:  UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        //userの分だけトークを作成
        return chatrooms.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = chatListTableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath) as! ChatListTableViewCell
//        cell.user = users[indexPath.row]
//        cell.userImageView.layer.masksToBounds = true
        cell.userImageView.layer.cornerRadius = 30
        cell.chatroom = chatrooms[indexPath.row]

        return cell
    }
    
    //クリックした時に反応するメソッド
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //"ChatRoom"という名前のストーリボードを初期化
        let storyboard = UIStoryboard.init(name: "ChatRoom", bundle: nil)
        let chatRoomViewController = storyboard.instantiateViewController(withIdentifier: "ChatRoomViewController")
        
        //画面遷移
        navigationController?.pushViewController(chatRoomViewController, animated: true)
    }
    
}





class ChatListTableViewCell: UITableViewCell {
    
    //user6@mail.com
//    var user: User? {
//        didSet {
//            partnerLabel.text = user?.username
//            guard let urlData = user?.profileImageUrl else {
//                print("失敗したお1")
//                return
//            }
//            print("urlData:",urlData)
//            guard let url = URL(string: urlData) else {
//                print("失敗したお2",user!.email)
//                print("失敗したお3",user?.profileImageUrl)
//                return
//            }
//            Nuke.loadImage(with: url, into: userImageView)
//        }
//    }
    
    var chatroom: ChatRoom? {
        didSet {
            if let chatroom = chatroom{
                partnerLabel.text = chatroom.partnerUser?.username
                
                guard let url = URL(string: chatroom.partnerUser?.profileImageUrl ?? "") else {return}
                Nuke.loadImage(with: url, into: userImageView)
                
                dateLabel.text = dateFormatterForDateLabel(date: chatroom.createdAt.dateValue())
            }
        }
    }
    
    
    @IBOutlet weak var userImageView: UIImageView!
    @IBOutlet weak var latestMessageLabel: UILabel!
    @IBOutlet weak var partnerLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    
    //tableViewのviewDidroad的なやつ
    override class func awakeFromNib() {
        super.awakeFromNib()
        
        //userImageView.layer.cornerRadius = 35
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    
    private func dateFormatterForDateLabel(date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .full
        formatter.timeStyle = .none
        formatter.locale = Locale(identifier:  "ja_JP")
        return formatter.string(from: date)
    }
    
}
