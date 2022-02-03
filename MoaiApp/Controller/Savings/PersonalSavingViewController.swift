//
//  PersonalSavingViewController.swift
//  MoaiApp
//
//  Created by 玉城秀大 on 2021/12/10.
//

import UIKit
import Firebase
import FirebaseStorage
import PKHUD

class PersonalSavingViewController: UIViewController {
    
    @IBOutlet weak var userProfileView: UIView!
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var userIcon: UIImageView!
    @IBOutlet weak var userProfilesHeightConstraints: NSLayoutConstraint!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var personalTotalAmountLabel: UILabel!
    @IBOutlet weak var TVLabelSV: UIStackView!
    
    let db = Firestore.firestore()
    let storage = Storage.storage()
    
    var moai:Moai?
    //積み立ての記録
    var savingsArray: [Savings] = []
    var savingIDArray: [String] = []
    //個人の積み立ての記録
    var personalSavingArray: [ [String:Any] ] = []
    //詳細を表示するメンバー
    var savingMember: [String:Any]?
    var personalTotalAmount:Int = 0

    override func viewDidLoad() {
        super.viewDidLoad()
        
        print("savingMember?[id] -->  \(savingMember?["id"])")
        
        for i in 0...savingsArray.count - 1 {
            let saving:Savings = savingsArray[i]
            print("~~~~~~~~~~~~~~~~~~~~~~")
            print(saving)
            print("~~~~~~~~~~~~~~~~~~~~~~")
            var personalSavingData:[String:Any] = ["id" : savingIDArray[i]]
            print(personalSavingArray)
            
            //該当するメンバーのデータのみを取得
            for item in saving.paidAmounts {
                print(item["id"] as? String)
                if item["id"] as? String == savingMember?["id"] as? String {
                    personalSavingData.updateValue(item["amount"], forKey: "amount")
                    personalSavingArray.append(personalSavingData)
                    print("追加するよ")
                    personalTotalAmount += item["amount"] as! Int
                }
            }
        }
        
        print(savingMember)
        setupViews()
        self.tableView.delegate = self
        self.tableView.dataSource = self
    }
    

    func setupViews() {
        userNameLabel.text = savingMember?["name"] as? String
        getIconFromFireStorage(userID: savingMember?["id"] as! String, imageView: userIcon)
        self.userIcon.layer.cornerRadius = userIcon.frame.size.height / 2
        
        self.personalTotalAmountLabel.text = "  個 人 合 計　　 " + String(personalTotalAmount) + "  　円  "
//        self.TVLabelSV.addBorder(width: 1, color: .black, position: .bottom)
        self.TVLabelSV.layer.cornerRadius = 10
        self.TVLabelSV.layer.borderWidth = 4
        self.TVLabelSV.layer.borderColor = UIColor.textColor2().cgColor
    }

    //アイコンをセット
    private func getIconFromFireStorage(userID: String, imageView:UIImageView) {
        var userIcon:UIImage?
        
        HUD.flash(.progress, onView: imageView, delay: 1) { _ in
            //userIDからFireBaseのuser情報を取得
            self.db.collection("users").document(userID).getDocument { (snapshots, err) in
                if let err = err {
                    print("エラーが出てuser情報取れへん取れへん -> \(err)")
                    imageView.image = UIImage(named: "batu")
                }else {
                    guard let dic = snapshots?.data() else {return}
                    let user = User(dic: dic)
                    let imageURL = user.profileImageUrl
                    userIcon = UIImage(url: imageURL)
                    print(userIcon)
                    imageView.image = userIcon
                    HUD.hide()
                }
            }
        }
    }
    
}

extension PersonalSavingViewController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return personalSavingArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        let stackView = cell.contentView.viewWithTag(1) as! UIStackView
        print(stackView)
        let monthLabel = stackView.viewWithTag(11) as! UILabel
        let amountLabel = stackView.viewWithTag(22) as! UILabel
        
        let yyyymmdd = personalSavingArray[indexPath.row]["id"] as! String
        let date = DateUtils.yyyymmddToJPFormat(yyyymmdd: yyyymmdd)
        
        let amount = personalSavingArray[indexPath.row]["amount"] as! Int
        monthLabel.text = date
        amountLabel.text = String(amount)
        if amount != self.moai?.savingAmount {
            amountLabel.textColor = .red
            amountLabel.font = UIFont.boldSystemFont(ofSize: 20)
        }
        return cell
    }
    
    
}

