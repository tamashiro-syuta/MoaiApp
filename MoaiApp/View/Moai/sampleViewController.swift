//
//  sampleViewController.swift
//  MoaiApp
//
//  Created by 玉城秀大 on 2021/07/14.
//

import UIKit

class sampleViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    let TODO = ["牛乳を買う", "掃除をする", "アプリ開発の勉強をする"]
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.delegate = self
        tableView.dataSource = self
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return TODO.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as UITableViewCell
        
        cell.textLabel?.text = TODO[indexPath.row]
        
        return cell
    }
    


}
