//
//  detailsNextMoaiViewController.swift
//  MoaiApp
//
//  Created by 玉城秀大 on 2022/01/03.
//

import UIKit


protocol SendNewMembers {

    func SendNewMembers(newMembers: [ [String:Any] ])

}

class detailsNextMoaiViewController: UIViewController, UINavigationControllerDelegate {
    
    var moai:Moai?
    var nextMoai:MoaiRecord?
    var judgeEntryArray: [Bool] = []
    var newMembers: [ [String:Any] ] = []
    
    var EntryMenbersArray: [String]?
    var notEntryMenbersArray: [String]?
    
    
    typealias MySectionRow = (mySection: String, myRow: Array<String>)
    var mySectionRows = [MySectionRow]()
    var selectedClass = ""
    var selectedPerson = ""
    
    let sections = ["日時","受け取り","場所","参加","不参加","備考"]
    //tableViewに表示するようの配列を要素に取る配列
    var nextDetailsArray = [cells]()
    
    //遷移元画面に値を渡す
    var delegate:SendNewMembers?
    

    @IBOutlet weak var DetailsTableView: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        makeEntryMenberArrayAndNot(newMembers: newMembers)

        let data = DateUtils.yyyyMMddEEEFromDate(date: (self.nextMoai?.date.dateValue())!)
        //starttimeがまだ入っていない
        let getMoneyPerson = self.nextMoai!.getMoneyPerson["name"] as! String
        let location = self.nextMoai!.location["name"] as! String
        let entry: [String] = EntryMenbersArray ?? ["なし"]
        let unEntry: [String] = notEntryMenbersArray ?? ["なし"]
        let note = self.nextMoai!.note
        
        self.navigationController?.delegate = self
        
        nextDetailsArray.append(cells(isShown: true, sectionName: "日時", rowArray: [data]))
        nextDetailsArray.append(cells(isShown: true, sectionName: "受取", rowArray: [getMoneyPerson] ))
        nextDetailsArray.append(cells(isShown: true, sectionName: "場所", rowArray: [location]))
        nextDetailsArray.append(cells(isShown: true, sectionName: "参加", rowArray: entry))
        nextDetailsArray.append(cells(isShown: true, sectionName: "不参加", rowArray: unEntry))
        nextDetailsArray.append(cells(isShown: true, sectionName: "備考", rowArray: [note]))
        
        self.navigationController?.navigationItem.backBarButtonItem?.tintColor = .white
        
        self.DetailsTableView.delegate = self
        self.DetailsTableView.dataSource = self
    }
    
    //judgeEntryArrayとmenbersArrayから参加予定の人の配列と不参加予定の人の配列を作成
    private func makeEntryMenberArrayAndNot(newMembers: [ [String:Any] ]) {
        self.judgeEntryArray.removeAll()
        for member in newMembers {
            //false -> 0, true -> 1
            print("member --> \(member)")
            if member["next"] as! Bool == false {
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
        print("self.moai?.members.count -> \(self.moai?.members.count)")
        for i in 0...(self.moai?.members.count)! - 1 {
            print("\(i)番目の処理")
            dic[self.moai!.members[i]["name"] as! String] = self.judgeEntryArray[i]
        }
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
    
    // 画面遷移元に戻るときの走る処理
    func navigationController(_ navigationController: UINavigationController, willShow viewController: UIViewController, animated: Bool) {
        if viewController is ManagementViewController {
            //挿入したい処理
            print("前の画面に戻るよ〜〜〜〜〜〜〜〜〜")
            print("newMember --> \(newMembers)")
            delegate?.SendNewMembers(newMembers: self.newMembers)
        }
    }
}


extension detailsNextMoaiViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return self.nextDetailsArray.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        return self.mySectionRows[section].myRow.count
        //courseArray[section].isShownの値によって、表示数を変更
        return nextDetailsArray[section].isShown ? nextDetailsArray[section].rowArray.count : 0
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return nextDetailsArray[section].sectionName
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = nextDetailsArray[indexPath.section].rowArray[indexPath.row]
        return cell
    }
    
    //HeaderのViewに対して、タップを感知できるようにして行きます。
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UITableViewHeaderFooterView()
        //UITapGestureを定義する。Tapされた際に、headertappedを呼ぶようにしています。
        let gesture = UITapGestureRecognizer(target: self,
                                             action: #selector(headertapped(sender:)))
        //ここで、実際に、HeaderViewをセットします。
        headerView.addGestureRecognizer(gesture)

        headerView.tag = section
        return headerView
    }

    //タップされるとこのメソッドが呼ばれます。
    @objc func headertapped(sender: UITapGestureRecognizer) {
        print("タップされたよ")
        //tagを持っていない場合は、guardします。
        guard let section = sender.view?.tag else {
            return
        }
        //courseArray[section].isShownの値を反転させます。
        nextDetailsArray[section].isShown.toggle()

        //これ以降で表示、非表示を切り替えます。
        DetailsTableView.beginUpdates()
        DetailsTableView.reloadSections([section], with: .automatic)
        DetailsTableView.endUpdates()
    }
}
