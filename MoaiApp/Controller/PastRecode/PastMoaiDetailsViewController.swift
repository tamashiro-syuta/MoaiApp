//
//  PastMoaiDetailsViewController.swift
//  MoaiApp
//
//  Created by 玉城秀大 on 2021/09/04.
//

import UIKit
import Firebase

struct cells {
    var isShown: Bool
    var sectionName: String
    var rowArray: [String]
}

class PastMoaiDetailsViewController: UIViewController {
    
    
    
    typealias MySectionRow = (mySection: String, myRow: Array<String>)
    var mySectionRows = [MySectionRow]()
    var selectedClass = ""
    var selectedPerson = ""
    
    let sections = ["日時","受取","場所","支払い済み","未払い","備考"]
    //tableViewに表示するようの配列を要素に取る配列
    var recordDetailsArray = [cells]()
    
    var pastRecord:MoaiRecord?
    
    //模合を払ってない人がいると画面上部にViewを追加したいからこのViewの位置を下げられるようにscrollViewの中にViewを作っている
    @IBOutlet weak var detailsTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let data = DateUtils.yyyyMMddEEEFromDate(date: (self.pastRecord?.date.dateValue())!)
        let getMoneyPerson = self.pastRecord!.getMoneyPerson["name"] as! String
        let location = self.pastRecord!.location["name"] as! String
//        let paid: [String] = self.pastRecord!.paid
        let paid: [String] = ["金城","大城","比嘉","國吉","新垣"]
//        let unpaid: [String] = self.pastRecord!.unpaid
        let unpaid: [String] = ["なし"]
        let note = self.pastRecord!.note
//
//        self.mySectionRows.append(("日時",[data] ) )
//        self.mySectionRows.append(("受取",[getMoneyPerson] ) )
//        self.mySectionRows.append(("場所",[location] ) )
//        self.mySectionRows.append(("支払い済み", paid ) )
//        self.mySectionRows.append(("未払い", unpaid ) )
//        self.mySectionRows.append(("備考",[note] ) )
//
        recordDetailsArray.append(cells(isShown: true, sectionName: "日時", rowArray: [data]))
        recordDetailsArray.append(cells(isShown: true, sectionName: "受取", rowArray: [getMoneyPerson] ))
        recordDetailsArray.append(cells(isShown: true, sectionName: "場所", rowArray: [location]))
        recordDetailsArray.append(cells(isShown: true, sectionName: "支払い済み", rowArray: paid))
        recordDetailsArray.append(cells(isShown: true, sectionName: "未払い", rowArray: unpaid))
        recordDetailsArray.append(cells(isShown: true, sectionName: "備考", rowArray: [note]))
        
        print("self.recordDetailsArray → \(recordDetailsArray)")

        self.navigationController?.navigationItem.backBarButtonItem?.tintColor = .white
        
        self.detailsTableView.delegate = self
        self.detailsTableView.dataSource = self
    }
    
    private func fetchMemberName(members: [String]) -> [String] {
        
        var membersNameArray = [String]()
        
        for member in members {
            Firestore.firestore().collection("users").document(member).getDocument { (snapshot, err) in
                if let err = err {
                    print("メンバーのユーザーネームを受け取れませんでした。 \(err)")
                    return
                }else {
                    guard let dic = snapshot?.data() else {return}
                    let userData = User(dic: dic)
                    let name = userData.username
                    membersNameArray.append(name)
                }
            }
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            //ここに処理
//            return membersNameArray
        }
        return membersNameArray
    }
    
}

extension PastMoaiDetailsViewController:UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return self.recordDetailsArray.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        return self.mySectionRows[section].myRow.count
        //courseArray[section].isShownの値によって、表示数を変更
        return recordDetailsArray[section].isShown ? recordDetailsArray[section].rowArray.count : 0
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return recordDetailsArray[section].sectionName
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = recordDetailsArray[indexPath.section].rowArray[indexPath.row]
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
        recordDetailsArray[section].isShown.toggle()

        //これ以降で表示、非表示を切り替えます。
        detailsTableView.beginUpdates()
        detailsTableView.reloadSections([section], with: .automatic)
        detailsTableView.endUpdates()
    }
    
}
