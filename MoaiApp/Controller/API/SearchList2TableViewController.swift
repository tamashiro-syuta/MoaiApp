//
//  apiViewController.swift
//  MoaiApp
//
//  Created by 玉城秀大 on 2021/12/27.
//

import UIKit
import Alamofire
import PKHUD

class SearchList2TableViewController: UIViewController {
    
    
    @IBOutlet weak var hotpepperListTableView: UITableView!
    
    
    var articles = [[String: AnyObject]]()
    let baseURL = "https://qiita.com/api/v2/items"

    let sampleURL = "https://webservice.recruit.co.jp/hotpepper/gourmet/v1/?key=2de3f74a5a1d3e05&large_area=Z011&format=json"
    
    let decoder: JSONDecoder = JSONDecoder()
    var hotpepper:Hotpepper?
    var shops:[Shop] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("shopsのカウント --> \(shops.count)")
        
        self.hotpepperListTableView.delegate = self
        self.hotpepperListTableView.dataSource = self

        HUD.flash(.progress)
        getDataAsJSON(url: sampleURL)
    }
    
    //Get JSON
    func getDataAsJSON(url: String) {
        let request = AF.request(url)
        request.responseJSON { (response) in
            switch response.result {
            case .success:
                do {
                    print("デコードに成功しました")
                    self.hotpepper = try self.decoder.decode(Hotpepper.self, from: response.data!)
                    print("self.hotpepper --> \(self.hotpepper)")
                    self.shops = (self.hotpepper?.results.shop)!
                    self.hotpepperListTableView.reloadData()
                } catch {
                    print("デコードに失敗しました")
                    HUD.hide()
                }
            case .failure(let error):
                print("error", error)
                HUD.hide()
            }
        }
    }
}

extension SearchList2TableViewController: UITableViewDelegate, UITableViewDataSource {
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
