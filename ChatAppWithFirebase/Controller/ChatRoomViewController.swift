//
//  ChatRoomViewController.swift
//  ChatAppWithFirebase
//
//  Created by 玉城秀大 on 2021/05/09.
//

import UIKit

//チャット画面
class ChatRoomViewController: UIViewController {
    
    private let cellId = "cellId"
    
    private var messages = [String]()
    
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

}



extension ChatRoomViewController: ChatInputAccessoryViewDelegate {
    
    func tappedSendButton(text: String) {
        messages.append(text)
        chatInputAccessoryView.removeText()
        chatRoomTableView.reloadData()
        print("chatInputAccessoryViewDelegate text:", text)
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
        cell.messageText = messages[indexPath.row]
        return cell
    }
    
    
}
