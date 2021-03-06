//
//  ChatListViewController.swift
//  ChatAppWithFirebase
//
//  Created by 玉城秀大 on 2021/05/09.
//

import UIKit
import Firebase
import FirebaseAuth
import Nuke

class ChatListViewController: standardViewController {
    
    private let cellId = "cellId"
    private var chatrooms = [ChatRoom]()
    private var chatRoomLinstener: ListenerRegistration?
    
    @IBOutlet weak var chatListTableView: UITableView!
    
    //最初のviewWillAppearでメソッドが呼ばれないように
    var first = 1
    
    
    override func viewDidLoad() {
        print("self.userIDは\(self.userID)")
        super.viewDidLoad()
//        fetchLoginUserInfo()
        
        //1秒後に処理
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            //ここに処理
            self.setUpViews()
            //chatListViewが呼ばれる度にchatroomの情報を更新していると無駄に通信して良くないので、viewWillAppearではなく、viewDidLoadに記載
            self.fetchChatroomsInfoFromFireStore()
            self.first += 1
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        if first != 1 {
            self.fetchChatroomsInfoFromFireStore()
        }
    }
    
    //FireStoreからチャットルーム情報を取得
    func fetchChatroomsInfoFromFireStore() {
        //  addSnapshotListener　がリアルタイム処理をしてくれる
        //　chatRoomLinstener　というプロパティの中に処理の情報を入れて、呼ばれる度にremoveするのでデータが重複することがない。
        chatRoomLinstener?.remove()
        chatrooms.removeAll()
        chatListTableView.reloadData()
        
        chatRoomLinstener = Firestore.firestore().collection("chatRooms").addSnapshotListener { [self] (snapshots, err) in

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
        chatroom.documentId = documentChange.document.documentID
        
        //相手側のユーザー情報を持ってくる
        guard let uid = Auth.auth().currentUser?.uid else {return}
        
        let isContain = chatroom.menbers.contains(uid)
        if !isContain { return }
        
        //メンバーの確認
        chatroom.menbers.forEach { (menberUid) in
            if menberUid != uid {
                Firestore.firestore().collection("users").document(menberUid!).getDocument { (userSnapshot, err) in
                    if let err = err {
                        print("ユーザー情報の取得に失敗しました。\(err)")
                        return
                    }
                    
                    guard let dic = userSnapshot?.data() else {return}
                    let user = User(dic: dic)
                    user.uid = documentChange.document.documentID
                    chatroom.partnerUser = user
                    
                    guard let chatroomId = chatroom.documentId else {return}
                    let latestMessageId = chatroom.latestMessageId
                    
                    if latestMessageId == "" {
                        
                        self.chatrooms.append(chatroom)
                        print("self.chatrooms :",self.chatrooms)
                        self.chatListTableView.reloadData()
                        return
                        
                    }
                    
                    //FirestoreからlatestMessageを取得
                    Firestore.firestore().collection("chatRooms").document(chatroomId).collection("messages").document(latestMessageId ?? "").getDocument { (messageSnapshot, err) in
                        if let err = err {
                            print("最新情報の取得に失敗しました。\(err)")
                            return
                        }
                        
                        //取得した値を変数messageにMessage型で生成し、chatroomに値を保存
                        guard let dic = messageSnapshot?.data() else {return}
                        let message = Message(dic: dic)
                        chatroom.latestMessage = message

                        self.chatrooms.append(chatroom)
                        print("self.chatrooms :",self.chatrooms)
                        self.chatListTableView.reloadData()
                        
                    }
                    
                }
            }
        }
    }
    
    
    private func setUpViews() {
        print("self.navigationController?.navigationBar.barTintColorは\(self.navigationController?.navigationBar.barTintColor)")
        
        self.navigationItem.title = self.user?.username
        //viewの背景を白に設定
        self.view.backgroundColor = .white
        
        chatListTableView.delegate = self
        chatListTableView.dataSource = self
        chatListTableView.tableFooterView = UIView()
//        navigationController?.navigationBar.barTintColor = .barColor()
        navigationItem.title = "トーク"
        navigationController?.navigationBar.titleTextAttributes = [.foregroundColor: UIColor.white]
        
//        let rightBarButton = UIBarButtonItem(title: "新規チャット", style: .plain, target: self, action: #selector(tappedNavRightBarButton))
//        let logoutBarButton = UIBarButtonItem(title: "ログアウト", style: .plain, target: self, action: #selector(tappedLogoutButton))
        
        //navigationBarの右側にボタンをコードで追加
//        navigationItem.rightBarButtonItem = rightBarButton
//        navigationItem.rightBarButtonItem?.tintColor = .white
//        navigationItem.leftBarButtonItem = logoutBarButton
//        navigationItem.leftBarButtonItem?.tintColor = .white

    }
    
//    @IBAction func tappedLogoutButton(_ sender: Any) {
//        //ログアウトは、必ずdo catch構文で書かないといけない
//        do {
//            try Auth.auth().signOut()
//            pushLoginViewController()
//        } catch {
//            print("ログアウトに失敗しました。\(error)")
//        }
//    }
//
//    @IBAction func tappedNavRightBarButton(_ sender: Any) {
//        //新規チャット画面への画面遷移
//        let storyborad = UIStoryboard.init(name: "UserList", bundle: nil)
//        let userListViewController = storyborad.instantiateViewController(withIdentifier: "UserListViewController")
//        //画面遷移先のuserListViewControllerにナビゲーションバーを追加
//        let nav = UINavigationController(rootViewController: userListViewController)
//        self.present(nav, animated: true, completion: nil)
//    }

    
//    private func pushLoginViewController() {
//        let storyboard = UIStoryboard(name: "SignUp", bundle: nil)
//        let signUpViewController = storyboard.instantiateViewController(withIdentifier: "SignUpViewController")
//        //signUpViewControllerをナビゲーションの最初の画面にし、それを定数navに格納
//        let nav = UINavigationController(rootViewController: signUpViewController)
//        nav.modalPresentationStyle = .fullScreen
//        self.present(nav, animated: true, completion: nil)
//    }

//    private func fetchLoginUserInfo() {
//        guard let uid = Auth.auth().currentUser?.uid else {return}
//        //ログインしているユーザーの情報だけを取得
//        db.collection("users").document(uid).getDocument { (snapshot, err) in
//            if let err = err {
//                print("ユーザー情報の取得に失敗しました。\(err)")
//                return
//            }
//            //snapshotのnilチェック
//            guard let snapshot = snapshot,let dic = snapshot.data() else {return}
//            let user = User(dic: dic)
//            self.user = user
//            //模合の情報を取得
//            self.fetchUsersMoaiInfo(user: self.user!)
//
//        }
//    }

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
        cell.userImageView.layer.cornerRadius = 30
        cell.chatroom = chatrooms[indexPath.row]

        return cell
    }
    
    //クリックした時に反応するメソッド
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //"ChatRoom"という名前のストーリボードを初期化
        let storyboard = UIStoryboard.init(name: "ChatRoom", bundle: nil)
        let chatRoomViewController = storyboard.instantiateViewController(withIdentifier: "ChatRoomViewController") as! ChatRoomViewController
        
        chatRoomViewController.user = user
        //ChatRoomViewcontrollerに選択されたchatroomの情報を渡してる
        chatRoomViewController.chatroom = chatrooms[indexPath.row]
        
        //画面遷移
        navigationController?.pushViewController(chatRoomViewController, animated: true)
    }
    
}


class ChatListTableViewCell: UITableViewCell {
    
    var chatroom: ChatRoom? {
        didSet {
            if let chatroom = chatroom{
                partnerLabel.text = chatroom.partnerUser?.username
                
                guard let url = URL(string: chatroom.partnerUser?.profileImageUrl ?? "") else {return}
                Nuke.loadImage(with: url, into: userImageView)
                
                dateLabel.text = dateFormatterForDateLabel(date: chatroom.latestMessage?.createdAt.dateValue() ?? Date())
                
                latestMessageLabel.text = chatroom.latestMessage?.message
                
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
        formatter.timeStyle = .short
        formatter.locale = Locale(identifier:  "ja_JP")
        return formatter.string(from: date)
    }
    
}
