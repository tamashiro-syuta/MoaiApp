//
//  ChatInputAccessoryView.swift
//  ChatAppWithFirebase
//
//  Created by 玉城秀大 on 2021/05/10.
//

import UIKit

protocol ChatInputAccessoryViewDelegate: class {
    //引数を用いてtextを別のコントローラーに渡すためのメソッド
    func tappedSendButton(text: String)
}

class ChatInputAccessoryView: UIView {
    
    
    @IBOutlet weak var sendButton: UIButton!
    @IBOutlet weak var chatTextView: UITextView!
    
    
    @IBAction func tappedSendButton(_ sender: Any) {
        //これでtextViewの情報を渡せる
        guard let text = chatTextView.text else { return }
        delegate?.tappedSendButton(text: text)
    }
    
    weak var delegate:ChatInputAccessoryViewDelegate?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        nibInit()
        setupView()
        autoresizingMask = .flexibleHeight
    }
    
    
    private func setupView() {
        chatTextView.layer.cornerRadius = 15
        chatTextView.layer.borderColor = UIColor.rgb(red: 230, green: 230, blue: 230).cgColor
        chatTextView.layer.borderWidth = 1
        
        sendButton.layer.cornerRadius = 15
        sendButton.imageView?.contentMode = .scaleAspectFill //sendButtonの中に入ってるimageViewのコンテントモードを変更
        sendButton.contentHorizontalAlignment = .fill
        sendButton.contentVerticalAlignment = .fill
        sendButton.isEnabled = false
        
        chatTextView.text = ""
        chatTextView.delegate = self
    }
    
    func removeText() {
        chatTextView.text = ""
        //送信ボタンを使えるようにする
        sendButton.isEnabled = false
    }
    
    override var intrinsicContentSize: CGSize {
        return .zero
    }
    
    
    //ChatInputAccessoryViewをviewに貼り付ける処理
    //nibファイルとは、ボタンなどのUI要素の描画情報が記述されたファイルのこと
    private func nibInit() {
        let nib = UINib(nibName: "ChatInputAccessoryView", bundle: nil)
        //guard letはオプショナル型を安全に取り出したい時に使います。
        //オプショナル型から値を取り出す時に、nilじゃなければ取り出すというとをやりたい時にguard letは使えます。
        //もし変数viewがnilならelseに入ってreturnで処理を終える。nilでなければ、下に続く処理を実行する。
        guard let view = nib.instantiate(withOwner: self, options: nil).first as? UIView else {
            return
        }
        
        view.frame = self.bounds
        //親のView(ここではChatRoom)のサイズが変わった時に、子のView(ここでは親の上に貼り付けるChatInputAccessoryViewのこと)のサイズや位置を自動的に調整
        view.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        //ここで指定しているviewは、上で宣言したChatInputAccessoryViewを反映したviewのこと
        self.addSubview(view)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(corder) has not been implemented")
    }
}



extension ChatInputAccessoryView: UITextViewDelegate {
    //textViewに何か変更があった場合の処理
    func textViewDidChange(_ textView: UITextView) {
        if textView.text.isEmpty {
            sendButton.isEnabled = false
        }else {
            sendButton.isEnabled = true
        }
    }
}
