//
//  SearchListTableViewController.swift
//  MoaiApp
//
//  Created by 玉城秀大 on 2021/12/27.
//

import UIKit
import Alamofire
import PKHUD

class SearchListTableViewController: UIViewController {
    
    
    @IBOutlet weak var hotpepperListTableView: UITableView!
    
    
//    var articles = [[String: AnyObject]]()
//    let baseURL = "https://qiita.com/api/v2/items"

//    var url:String = ""
//    let sampleURL = "https://webservice.recruit.co.jp/hotpepper/gourmet/v1/?key=2de3f74a5a1d3e05&keyword=%E7%B3%B8%E6%BA%80%E3%80%80%E9%82%A3%E8%A6%87%E3%80%80%E3%83%A9%E3%83%BC%E3%83%A1%E3%83%B3&format=json"
//    let sampleURL2 = "https://webservice.recruit.co.jp/hotpepper/gourmet/v1/?key=2de3f74a5a1d3e05&keyword=糸満%E3%80%80ラーメン&format=json"
//
//    let decoder: JSONDecoder = JSONDecoder()
//    var hotpepper:Hotpepper?
    var shops:[Shop] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("shopsのカウント --> \(shops.count)")
        
        self.hotpepperListTableView.delegate = self
        self.hotpepperListTableView.dataSource = self

//        HUD.flash(.progress)
//        getDataAsJSON(url: url)
    }
    
    //Get JSON
//    func getDataAsJSON(url: String) {
//        let request = AF.request(url)
//        request.responseJSON { (response) in
//            switch response.result {
//            case .success:
//                do {
//                    print("デコードに成功しました")
//                    self.hotpepper = try self.decoder.decode(Hotpepper.self, from: response.data!)
//                    print("self.hotpepper --> \(self.hotpepper)")
//                    self.shops = (self.hotpepper?.results.shops)!
//                    self.hotpepperListTableView.reloadData()
//                } catch {
//                    print("デコードに失敗しました")
//                    HUD.hide()
//                }
//            case .failure(let error):
//                print("error", error)
//                HUD.hide()
//            }
//        }
//    }
}

extension SearchListTableViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.shops.count == 0 ? 1 : self.shops.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if self.shops.count == 0 {
            return self.view.frame.size.height
        }else {
            return 80
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        let imageView = cell.contentView.viewWithTag(1) as! UIImageView
        let label = cell.contentView.viewWithTag(2) as! UILabel
        
        if shops.count == 0 {
            //まだAPIから値が取れていない時
            label.text = ""
        }else {
            //APIからの値を利用
            imageView.image = UIImage(url: self.shops[indexPath.row].logoImage)
            label.text = self.shops[indexPath.row].name
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("タップされたお")
    }
    
}
