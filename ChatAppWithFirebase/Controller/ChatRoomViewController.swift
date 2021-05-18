//
//  ChatRoomViewController.swift
//  ChatAppWithFirebase
//
//  Created by 玉城秀大 on 2021/05/09.
//

import UIKit
import Firebase

//チャット画面
class ChatRoomViewController: UIViewController {
    
    private let cellId = "cellId"
    private var messages = [Message]()
    private let accesoryHeight: CGFloat = 100
    private let tableViewContentInset: UIEdgeInsets = .init(top: 60, left: 0, bottom: 0, right: 0)
    private let tableViewIndicatorInset: UIEdgeInsets = .init(top: 60, left: 0, bottom: 0, right: 0)
    private var safeAreabottom: CGFloat {
        get {
            self.view.safeAreaInsets.bottom
        }
    }
    
    var chatroom:ChatRoom?
    //ログインしているuser情報
    var user: User?
    
    //ChatInputAccessoryViewのインスタンスを生成
    private lazy var chatInputAccessoryView: ChatInputAccessoryView = {
        let view = ChatInputAccessoryView()
        view.frame = .init(x: 0, y: 0, width: view.frame.width, height: 100)
        view.delegate = self //viewはchatInputAccessoryViewのインスタンスなので、delegateメソッドを使いたいからdelegateを自分に当ててる
        return view
    }()

    @IBOutlet weak var chatRoomTableView: UITableView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNotification()
        setUpChatRoomView()
        fetchMessages()
    }
    
    private func setupNotification() {
        //キーボードが出てきた時に受け取る処理
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        //キーボードを閉じた時に受け取る処理
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    private func setUpChatRoomView() {
        chatRoomTableView.delegate = self
        chatRoomTableView.dataSource = self
        chatRoomTableView.register(UINib(nibName: "ChatRoomTableViewCell", bundle: nil), forCellReuseIdentifier: cellId)
        //トークの背景色を水色に
        chatRoomTableView.backgroundColor = .rgb(red: 118, green: 140, blue: 180)
        //オートレイアウトでの制約後の微調整（オートレイアウトを保ったまま微調整できる）
        chatRoomTableView.contentInset = tableViewContentInset
        chatRoomTableView.scrollIndicatorInsets = tableViewIndicatorInset
        //スクロールするとキーボードが閉じる処理
        chatRoomTableView.keyboardDismissMode = .interactive
        
        //画面を反転
        chatRoomTableView.transform = CGAffineTransform(a: 1, b: 0, c: 0, d: -1, tx: 0, ty: 0)
    }
    
    @objc func keyboardWillShow(notification: NSNotification) {
        print("keyboardWillShow")
        guard let userInfo = notification.userInfo else {return}
        
        if let keyboardFrame = (userInfo[UIResponder.keyboardFrameEndUserInfoKey] as AnyObject).cgRectValue {
            
            if keyboardFrame.height <= accesoryHeight {return}
            print("keyboardFrame :",keyboardFrame)
            
            let top = keyboardFrame.height - safeAreabottom
            var moveY = -(top - chatRoomTableView.contentOffset.y)
            //最下部以外の時は少しずれるので微調整
            if chatRoomTableView.contentOffset.y != -60 {moveY += 60}
            let contentInset = UIEdgeInsets(top: top, left: 0, bottom: 0, right: 0)
            
            //キーボードが出ててもスクロールできる状態にする処理
            chatRoomTableView.contentInset = contentInset
            chatRoomTableView.scrollIndicatorInsets = contentInset
            
            //チャットを移動させる処理
            chatRoomTableView.contentOffset = CGPoint(x: 0, y: moveY)
        }
    }
    
    @objc func keyboardWillHide() {
        print("keyboardWillHide")
        chatRoomTableView.contentInset = tableViewContentInset
        chatRoomTableView.scrollIndicatorInsets = tableViewIndicatorInset
    }
    
    //inputAccessoryViewというviewを貼り付ける用のviewのようなものにchatInputAccessoryViewをセット
    //inputAccessoryViewを使うことで、viewとキーボードを繋げて自動で動いてくれる
    override var inputAccessoryView: UIView? {
        get {
            return chatInputAccessoryView
        }
    }
    
    override var canBecomeFirstResponder: Bool {
        return true
    }
    
    
    private func fetchMessages() {
        guard let chatroomDocId = chatroom?.documentId else {return}
        
        //addSnapshotListenerで、リアルタイム情報処理
        Firestore.firestore().collection("chatRooms").document(chatroomDocId).collection("messages").addSnapshotListener { (snapshots, err) in
            if let err = err {
                print("メッセージ情報の保存に失敗しました。\(err)")
                return
            }
            
            snapshots?.documentChanges.forEach({ (documentChange) in
                switch documentChange.type {
                case .added:
                    //メッセージ情報を取得
                    let dic = documentChange.document.data()
                    let message = Message(dic: dic)
                    message.partnerUser = self.chatroom?.partnerUser
                    
                    self.messages.append(message)
                    //日付順に並び替え
                    self.messages.sort { (m1, m2) -> Bool in
                        let m1Date = m1.createdAt.dateValue()
                        let m2Date = m2.createdAt.dateValue()
                        return m1Date > m2Date
                    }
                    
                    self.chatRoomTableView.reloadData()
                    //最新のものから表示（1番下にスクロール済みにする）
//                    self.chatRoomTableView.scrollToRow(at: IndexPath(row: self.messages.count - 1, section: 0), at: .bottom, animated: true)
                    
                    
                case .modified, .removed:
                    print("nothiing to do")
                }
            })
        }
    }
    

}



extension ChatRoomViewController: ChatInputAccessoryViewDelegate {
    
    func tappedSendButton(text: String) {
        addMessageToFirestore(text: text)
    }
    
    private func addMessageToFirestore(text: String) {
        guard let chatroomDocId = chatroom?.documentId else {return}
        
        guard let name = user?.username else {return}
        guard let uid = Auth.auth().currentUser?.uid else {return}
        //送信後、打ったメッセージを消去
        chatInputAccessoryView.removeText()
        
        let messageId = randomString(length: 20)
        
        let docData = [
            
            "name": name,
            "createdAt": Timestamp(),
            "uid": uid,
            "message": text
            
        ] as [String : Any]
        
        //上で宣言したmessageIdを使用して手動でmessageIdをセット
        Firestore.firestore().collection("chatRooms").document(chatroomDocId).collection("messages").document(messageId).setData(docData) { (err) in
                if let err = err {
                    print("メッセージ情報の保存に失敗しました。\(err)")
                }
                
                let latestMessageData = [
                    "latestMessageId": messageId
                ]
                
                //「upData」は、firestoreのフィールドに既に存在するものそ改めて値をセットしたい時に使う。
                Firestore.firestore().collection("chatRooms").document(chatroomDocId).updateData(latestMessageData) { (err) in
                    if let err = err {
                        print("最新メッセージの保存に失敗しました。\(err)")
                        return
                    }
                }
                print("メッセージの保存に成功しました。")
            }
    }
    
    
    func randomString(length: Int) -> String {
            let letters : NSString = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
            let len = UInt32(letters.length)

            var randomString = ""
            for _ in 0 ..< length {
                let rand = arc4random_uniform(len)
                var nextChar = letters.character(at: Int(rand))
                randomString += NSString(characters: &nextChar, length: 1) as String
            }
            return randomString
    }
    
}



//相手側のメッセージについて
extension ChatRoomViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        chatRoomTableView.estimatedRowHeight = 20  //最低基準の高さ
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messages.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        //セルをChatRoomTableViewCellのセルとして生成
        //as! ChatRoomTableViewCellとすることで messageTextView を参照できるようになる
        let cell = chatRoomTableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath) as! ChatRoomTableViewCell
        cell.message = messages[indexPath.row]
        cell.transform = CGAffineTransform(a: 1, b: 0, c: 0, d: -1, tx: 0, ty: 0)
        return cell
    }
    
    
}
