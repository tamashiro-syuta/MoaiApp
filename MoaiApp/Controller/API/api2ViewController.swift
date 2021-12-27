//
//  api2ViewController.swift
//  MoaiApp
//
//  Created by 玉城秀大 on 2021/12/27.
//

import UIKit
import Alamofire
import SwiftyJSON

class api2ViewController: UIViewController {
    
    
    @IBOutlet weak var hotpepperListTableView: UITableView!
    
    
    var articles = [[String: AnyObject]]()
    let baseURL = "https://qiita.com/api/v2/items"
    
    var json = JSON()
    
    let sampleURL = "https://webservice.recruit.co.jp/hotpepper/gourmet/v1/?key=2de3f74a5a1d3e05&large_area=Z011&format=json"
    
    let decoder: JSONDecoder = JSONDecoder()
    var hotpeppers:[Hotpepper] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.hotpepperListTableView.delegate = self
        self.hotpepperListTableView.dataSource = self

        getDataAsJSON(url: sampleURL)
    }
    
    //Get JSON
    func getDataAsJSON(url: String) {
//        AF.request(url, method: .get).responseJSON { res in
//           print(res)
//            self.json = JSON(res)
//            let sample = self.json["shop"]["tones"][1]["score"].float
//            print(sample)
//        }
        AF.request(url, method: .get).responseJSON { response in
            switch response.result {
            case .success:
                do {
                    self.hotpeppers = try self.decoder.decode([Hotpepper].self, from: response.data!)
//                    self.articleListTableView.reloadData()
                    print("デコードに成功しました！！！")
                    print("self.hotpeppers -> \(self.hotpeppers)")
                } catch {
                    print("デコードに失敗しました")
                    print("response -> \(response)")
                    print("response.data -> \(response.data)")
                    print("type(of: response -> \(type(of: response))")
                }
            case .failure(let error):
                print("error", error)
            }
        }
    }

}

extension api2ViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        
        return cell
    }
    
    
}
