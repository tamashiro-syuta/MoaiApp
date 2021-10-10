//
//  detailsNextMoaiViewController.swift
//  MoaiApp
//
//  Created by 玉城秀大 on 2021/07/17.
//

import UIKit

class detailsNextMoaiViewController: UIViewController {
    
    var moai:Moai?
    var nextMoai:MoaiRecord?
    var judgeEntryArray: [Bool] = []  //self.moaiのnextから取得できるので消去
//    var moaiMenbersNameList:[String]?
    
    var EntryMenbersArray: [String]?
    var notEntryMenbersArray: [String]?
    
    @IBOutlet weak var ParentStackView: UIStackView!
    @IBOutlet weak var stackView1: UIStackView!
    @IBOutlet weak var stackView3: UIStackView!
    @IBOutlet weak var stackView4: UIStackView!
    
    
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var entryTableView: UITableView!
    @IBOutlet weak var notEntryTableView: UITableView!
    
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        makeEntryMenberArrayAndNot()
        setupViews()
        entryTableView.delegate = self
        entryTableView.dataSource = self
        notEntryTableView.delegate = self
        notEntryTableView.dataSource = self
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super .viewWillAppear(animated)
        makeEntryMenberArrayAndNot()
    }
    
    private func setupViews() {
        let date = DateUtils.MddEEEFromDate(date: (self.nextMoai?.date.dateValue())!)
        let startTime = DateUtils.fetchStartTimeFromDate(date: (self.nextMoai?.date.dateValue())!)
        dateLabel.text = " " + date + " " + startTime + " 〜 "
        //locationがセットされてるかで表示内容を変換
        if nextMoai?.location["name"] as! String  != nil || nextMoai?.location["name"] as! String == ""{
            locationLabel.text = " " + (nextMoai?.location["name"] as! String)
        }else {
            locationLabel.text = "未設定"
        }
        
    }
    
    //judgeEntryArrayとmenbersArrayから参加予定の人の配列と不参加予定の人の配列を作成
    private func makeEntryMenberArrayAndNot() {
        self.judgeEntryArray.removeAll()
        for member in self.moai!.members {
            //false -> 0, true -> 1
            if member["next"] as! Int == 0 {
                print("\(member["name"])は、falseです。")
                self.judgeEntryArray.append(false)
            }else {
                print("\(member["name"])は、trueです。")
                self.judgeEntryArray.append(true)
            }
        }
        print("self.judgeEntryArray -> \(self.judgeEntryArray)")
        var dic = [String: Bool]()
        var array1:[String] = []
        var array2:[String] = []
//        guard let arrayCount
//        guard let arrayCount = self.moaiMenbersNameList?.count else {return}
        print("self.moai?.members.count -> \(self.moai?.members.count)")
        for i in 0...(self.moai?.members.count)! - 1 {
            print("\(i)番目の処理")
            dic[self.moai!.members[i]["name"] as! String] = self.judgeEntryArray[i]
        }
//        for i in 0...arrayCount - 1 {
//            dic[self.moaiMenbersNameList![i]] = self.judgeEntryArray![i]
//        }
        for item in dic {
            if item.value == true {
                print(item.key)
                array1.append(item.key)
            }else {
                print(item.key)
                array2.append(item.key)
            }
        }
        self.EntryMenbersArray = array1
        self.notEntryMenbersArray = array2
    }

}

extension detailsNextMoaiViewController: UITableViewDelegate,UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView.tag == 1 {
            if self.EntryMenbersArray?.count == 0 {
                return 1
            }else {
                return self.EntryMenbersArray?.count ?? 1
            }
        }else {
            if self.notEntryMenbersArray?.count == 0 {
                return 1
            }else {
                return notEntryMenbersArray?.count ?? 1
            }
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if tableView.tag == 1 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "cell1", for: indexPath)
            if self.EntryMenbersArray?.count != 0 {
                cell.textLabel?.text = self.EntryMenbersArray?[indexPath.row] as! String
            }else {
                cell.textLabel?.text = "現在、参加予定のメンバーはいません。"
            }
            
            return cell
        }else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "cell2", for: indexPath)
            if self.notEntryMenbersArray?.count != 0 {
                cell.textLabel?.text = self.notEntryMenbersArray?[indexPath.row] as! String
            }else {
                cell.textLabel?.text = "現在、不参加予定のメンバーはいません。"
            }
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
}
