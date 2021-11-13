//
//  SavingsViewController.swift
//  MoaiApp
//
//  Created by 玉城秀大 on 2021/09/02.
//

import UIKit

class SavingsViewController: standardViewController {
    
    var savingMember: [ [String:Any] ] = []
    
    
    @IBOutlet weak var amountPerPersonLabel: UILabel!
    @IBOutlet weak var allSavingsLabel: UILabel!
    @IBOutlet weak var PersonaSavingsLabel: UILabel!
    @IBOutlet weak var personInChargeLabel: UILabel!
    @IBOutlet weak var savingsTableView: UITableView!
    @IBOutlet weak var memberLabel: UILabel!
    @IBOutlet weak var lastSavingLabel: UILabel!
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        print("~~~~~~~~~~~~~~~~~~~~~~~")
        for saving in self.savingsArray {
            print(saving.ID)
            print(saving.paidAmounts)
            print("ちゃんと値取れているかな？  --->  \(saving.paidAmounts[0]["ID"])")
        }
        print("~~~~~~~~~~~~~~~~~~~~~~~")

        setupViews()
        
        // 積み立てをしているメンバーを取得し変数化
        for member in self.moai!.members {
            guard let saving = member["saving"] else {return}
            if saving as! Bool == true {
                savingMember.append(member)
            }
        }
        
        savingsTableView.isScrollEnabled = true
        savingsTableView.delegate = self
        savingsTableView.dataSource = self

    }

    private func setupViews() {
        
        amountPerPersonLabel.layer.borderWidth = 3
        amountPerPersonLabel.layer.borderColor = UIColor.black.cgColor
        amountPerPersonLabel.layer.cornerRadius = 20
        
        allSavingsLabel.addBorder(width: 1.5, color: .black, position: .bottom)
        PersonaSavingsLabel.addBorder(width: 1.5, color: .black, position: .bottom)
        personInChargeLabel.addBorder(width: 1.5, color: .black, position: .bottom)
        
        memberLabel.layer.borderWidth = 1.5
        lastSavingLabel.layer.borderWidth = 1.5

        let recodeSavingDataButton = UIBarButtonItem(barButtonSystemItem: .compose, target: self, action: #selector(addBarButtonTapped(_:)))
        recodeSavingDataButton.tintColor = .textColor()
        self.navigationItem.rightBarButtonItem = recodeSavingDataButton
    }
    
    @objc private func addBarButtonTapped(_ sender: UIBarButtonItem) {
        print("押されたよん♪")
        let storyboard = UIStoryboard(name: "RecodeSaving", bundle: nil)
        let recodeSavingVC = storyboard.instantiateViewController(withIdentifier: "RecodeSavingViewController") as! RecodeSavingViewController
        self.navigationController?.pushViewController(recodeSavingVC, animated: true)
    }
}

extension SavingsViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return savingMember.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = savingsTableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as UITableViewCell
        
        let label1 = cell.contentView.viewWithTag(1) as! UILabel
        let label2 = cell.contentView.viewWithTag(2) as! UILabel
        
        let latestSavingData = savingsArray.last
        var name:String?
        var amount:Int?
        for paidAmount in latestSavingData!.paidAmounts {
            if savingMember[indexPath.row]["id"] as! String == paidAmount["ID"] as! String {
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
            label2.text = " ー " + String(difference) + " 円 "
        }
        return cell
    }
    
    
}
