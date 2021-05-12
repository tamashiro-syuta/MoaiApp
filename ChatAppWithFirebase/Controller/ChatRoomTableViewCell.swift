//
//  ChatRoomTableViewCell.swift
//  ChatAppWithFirebase
//
//  Created by 玉城秀大 on 2021/05/10.
//

import UIKit

class ChatRoomTableViewCell: UITableViewCell {
    
    var messageText: String? {
        didSet {
            guard let text = messageText else { return }
            let width = estimateFrameForTextView(text: text).width + 20
            
            messageTextViewWidthConstraint.constant = width
            messageTextView.text = text
            
        }
    }
    
    @IBOutlet weak var userImageView: UIImageView!
    @IBOutlet weak var messageTextView: UITextView!
    @IBOutlet weak var dateLabel: UILabel!
    
    //メッセージのテキストの幅をインスタンス化
    @IBOutlet weak var messageTextViewWidthConstraint: NSLayoutConstraint!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        userImageView.layer.cornerRadius = 30
        messageTextView.layer.cornerRadius = 15
        //セルの背景色を透明にして、テーブルビューのセルの背景色が反映されるようにしてる
        backgroundColor = .clear
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    
    //テキストフィールドの幅を計算するメソッド
    private func estimateFrameForTextView(text: String) -> CGRect {
        let size = CGSize(width: 200, height: 1000)
        let options = NSStringDrawingOptions.usesFontLeading.union(.usesLineFragmentOrigin)
        
        return NSString(string: text).boundingRect(with: size, options: options, attributes: [NSAttributedString.Key.font : UIFont.systemFont(ofSize: 14)], context: nil)
    }

}
