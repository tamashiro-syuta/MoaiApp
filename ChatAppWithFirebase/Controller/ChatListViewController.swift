//
//  ChatListViewController.swift
//  ChatAppWithFirebase
//
//  Created by 玉城秀大 on 2021/05/09.
//

import UIKit
import Firebase

class ChatListViewController: UIViewController {
    
    private let cellId = "cellId"
    private var users = [User]()
    
    @IBOutlet weak var chatListTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        chatListTableView.delegate = self
        chatListTableView.dataSource = self
        navigationController?.navigationBar.barTintColor = .rgb(red: 39, green: 49, blue: 69)
        navigationItem.title = "トーク"
        navigationController?.navigationBar.titleTextAttributes = [.foregroundColor: UIColor.white]
        
        if Auth.auth().currentUser?.uid == nil {
            //立ち上がった時にSignUpViewControllerを表示する処理
            let storyboard = UIStoryboard(name: "SignUp", bundle: nil)
            let signUpViewController = storyboard.instantiateViewController(withIdentifier: "SignUpViewController") as! SignUpViewController
            signUpViewController.modalPresentationStyle = .fullScreen
            self.present(signUpViewController, animated: true, completion: nil)
        }
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        fetchUserInfoFromFirestore()
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
                //usersという配列に追加
                self.users.append(user)
                self.chatListTableView.reloadData()
                
                users.forEach { (user) in
                    print("user.username:", user.username)
                }
                
                //print("date :",data)
            })
        }
    }
    
}

extension ChatListViewController:  UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        //userの分だけトークを作成
        return users.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = chatListTableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath) as! ChatListTableViewCell
        cell.user = users[indexPath.row]
        
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
    
    var user: User? {
        didSet {
            if let user = user {
                partnerLabel.text = user.username
                //userImageView.image = user?.ProfileImageUrl
                dateLabel.text = dateFormatterForDateLabel(date: user.createdAt.dateValue())
                latestMessageLabel.text = user.email
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
