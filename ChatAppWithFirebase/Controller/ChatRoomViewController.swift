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
    
    var chatroom:ChatRoom?
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

        chatRoomTableView.delegate = self
        chatRoomTableView.dataSource = self
        chatRoomTableView.register(UINib(nibName: "ChatRoomTableViewCell", bundle: nil), forCellReuseIdentifier: cellId)
        //トークの背景色を水色に
        chatRoomTableView.backgroundColor = .rgb(red: 118, green: 140, blue: 180)
        
        fetchMessages()
        
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
                    self.messages.append(message)
                    self.chatRoomTableView.reloadData()
                    
                    
                case .modified, .removed:
                    print("nothiing to do")
                }
            })
        }
    }
    

}



extension ChatRoomViewController: ChatInputAccessoryViewDelegate {
    
    func tappedSendButton(text: String) {
//        messages.append(text)
//        chatInputAccessoryView.removeText()
//        chatRoomTableView.reloadData()
//        print("chatInputAccessoryViewDelegate text:", text)
        
        guard let chatroomDocId = chatroom?.documentId else {return}
        
        guard let name = user?.username else {return}
        guard let uid = Auth.auth().currentUser?.uid else {return}
        //送信後、打ったメッセージを消去
        chatInputAccessoryView.removeText()
        
        let docData = [
        
            "name": name,
            "createdAt": Timestamp(),
            "uid": uid,
            "message": text
            
        ] as [String : Any]
        
        Firestore.firestore().collection("chatRooms").document(chatroomDocId).collection("messages").document()
            .setData(docData) { (err) in
                if let err = err {
                    print("メッセージ情報の保存に失敗しました。\(err)")
                }
                
                print("メッセージの保存に成功しました。")
                
//            .document().addSnapshotListener { (snapshots, err) in
//
//                if let err = err {
//                    print("メッセージ情報の保存に失敗しました。\(err)")
//                    return
//                }
                
        }
        
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
        return cell
    }
    
    
}
