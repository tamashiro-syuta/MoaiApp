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
    var hotpepper:Hotpepper?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.hotpepperListTableView.delegate = self
        self.hotpepperListTableView.dataSource = self

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
//                    print(response)
                    self.hotpepper = try self.decoder.decode(Hotpepper.self, from: response.data!)
                    print("self.hotpepper --> \(self.hotpepper)")
//                    self.hotpepperListTableView.reloadData()
                } catch {
                    print("デコードに失敗しました")
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
