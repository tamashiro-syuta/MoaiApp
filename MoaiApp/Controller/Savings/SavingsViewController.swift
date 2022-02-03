//
//  SavingsViewController.swift
//  MoaiApp
//
//  Created by 玉城秀大 on 2021/09/02.
//

import UIKit

class SavingsViewController: standardViewController {
    
    var savingMember: [ [String:Any] ] = []
    var savingOrganizer = "幹事の名前"
    
    
    @IBOutlet weak var amountPerPersonLabel: UILabel!
    @IBOutlet weak var allSavingsLabel: UILabel!
    @IBOutlet weak var finalSavingLabel: UILabel!
    @IBOutlet weak var personInChargeLabel: UILabel!
    @IBOutlet weak var savingsTableView: UITableView!
    @IBOutlet weak var memberAndLastSavingSV: UIStackView!
    @IBOutlet weak var memberLabel: UILabel!
    @IBOutlet weak var lastSavingLabel: UILabel!
    

    override func viewDidLoad() {
        super.viewDidLoad()
        // 積み立てをしているメンバーを取得し変数化
        for member in self.moai!.members {
            guard let saving = member["saving"] else {return}
            if saving as! Bool == true {
                savingMember.append(member)
            }
            if (member["savingOrganizer"] != nil) == true {
                savingOrganizer = member["name"] as! String
            }
        }
        print("savingMember  --> \(savingMember)")
        
        setupViews()
        
        savingsTableView.isScrollEnabled = false
        savingsTableView.delegate = self
        savingsTableView.dataSource = self

    }

    private func setupViews() {
        // navigationItemを表示(デフォでは非表示)
        self.navigationController?.setNavigationBarHidden(false, animated: true)
        self.navigationItem.title = "積み立て"
        
        let lastMonth = DateUtils.yyyyMMFromDate(date: self.moai!.finalMonth as Date)
//        let totalSavingAmount = self.moai!.savingAmount * self.savingMember.count
        
        self.amountPerPersonLabel.text = " 1人当たり　\(String(self.moai!.savingAmount))円 / 回  "
        self.allSavingsLabel.text = "積み立て合計 135000 円"
        self.finalSavingLabel.text = "最終月  " + lastMonth
        self.personInChargeLabel.text = "幹事 " +  savingOrganizer
        
        amountPerPersonLabel.layer.borderWidth = 3
        amountPerPersonLabel.layer.borderColor = UIColor.textColor2().cgColor
        amountPerPersonLabel.layer.cornerRadius = 20
        
        allSavingsLabel.addBorder(width: 1.5, color: UIColor.textColor2(), position: .bottom)
        finalSavingLabel.addBorder(width: 1.5, color: UIColor.textColor2(), position: .bottom)
        personInChargeLabel.addBorder(width: 1.5, color: UIColor.textColor2(), position: .bottom)
        
//        memberLabel.layer.borderWidth = 1.5
//        lastSavingLabel.layer.borderWidth = 1.5
        self.memberAndLastSavingSV.layer.cornerRadius = 10
        self.memberAndLastSavingSV.layer.borderWidth = 4
        self.memberAndLastSavingSV.layer.borderColor = UIColor.textColor2().cgColor

        let recordSavingDataButton = UIBarButtonItem(barButtonSystemItem: .compose, target: self, action: #selector(addBarButtonTapped(_:)))
        recordSavingDataButton.tintColor = .white
        self.navigationItem.rightBarButtonItem = recordSavingDataButton
    }
    
    @objc private func addBarButtonTapped(_ sender: UIBarButtonItem) {
        print("押されたよん♪")
        let storyboard = UIStoryboard(name: "RecordSaving", bundle: nil)
        let recordSavingVC = storyboard.instantiateViewController(withIdentifier: "RecordSavingViewController") as! RecordSavingViewController
        recordSavingVC.user = self.user
        recordSavingVC.recordDate = self.nextMoaiID
        recordSavingVC.members = self.moai?.members
        recordSavingVC.savingAmount = self.moai?.savingAmount
        self.navigationController?.pushViewController(recordSavingVC, animated: true)
    }
}

extension SavingsViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        print("savingMember.count -> \(savingMember.count)")
        return savingMember.count
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = savingsTableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as UITableViewCell
        
        let label1 = cell.contentView.viewWithTag(1) as! UILabel
        let label2 = cell.contentView.viewWithTag(2) as! UILabel
        
        let latestSavingData = self.savingsArray.last
        var name:String?
        var amount:Int?
        for paidAmount in latestSavingData!.paidAmounts {
            if savingMember[indexPath.row]["id"] as! String == paidAmount["id"] as! String {
                name = savingMember[indexPath.row]["name"] as? String
                amount = paidAmount["amount"] as? Int
                print("amount -> \(amount)")
            }
        }
        label1.text = name
        switch amount {
        case self.moai?.savingAmount:
            label2.text = "◯"
        case 0:
            label2.text = "×"
        default:
            let difference = self.moai!.savingAmount - amount!
            label2.text = " 残り " + String(difference) + " 円 "
        }
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~")
        pushPersonalSavingVC(indexPath: indexPath.row)
    }
    
    func pushPersonalSavingVC(indexPath:Int) {
        let storyboard = UIStoryboard(name: "PersonalSaving", bundle: nil)
        let personalSavingVC = storyboard.instantiateViewController(withIdentifier: "PersonalSavingViewController") as! PersonalSavingViewController
        
        personalSavingVC.moai = self.moai
        personalSavingVC.savingMember = self.savingMember[indexPath]
        personalSavingVC.savingsArray = self.savingsArray
        personalSavingVC.savingIDArray = self.savingIDArray
        
        self.navigationController?.pushViewController(personalSavingVC, animated: true)
    }
    
}
