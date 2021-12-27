//
//  apiViewController.swift
//  MoaiApp
//
//  Created by 玉城秀大 on 2021/12/27.
//

import UIKit
import Alamofire
import SwiftyJSON
import MapKit
import PKHUD

class apiViewController: UIViewController, XMLParserDelegate {
    
    @IBOutlet weak var hotpepperListTableView: UITableView!
    
    let decoder: JSONDecoder = JSONDecoder()
    var hotpepper = [Hotpepper]()
    
    /// API Key
    private var apiKey: String = String()
    /// ホットペッパーAPIのベースURL
    private let baseURL: String = "https://webservice.recruit.co.jp/hotpepper/gourmet/v1/"
    
    
//    let url: URL = URL(string:"https://news.yahoo.co.jp/rss/topics/it.xml")!
//    var check_title = [String]()
//    var news_title = [String]()
//    var link = [String]()
//    var enclosure = [String]()
//    var check_element = String()
//    var news_array: [ [String:Any] ] = []
    
    
    
    
    let smapleURL = URL(string: "https://webservice.recruit.co.jp/hotpepper/gourmet/v1/?key=2de3f74a5a1d3e05&large_area=Z011")
    //XMLの現在要素名を入れる変数
    var currentElementName : String!
    //取得する要素名(とりはじめの要素)
    let shopElementName : String  = "shop"
    //取得する要素名の決定(item要素の下にあるもの)
    let idElementName  : String = "id"
    let nameElementName  : String = "name"
    let logoImageElementName : String = "logo_image"
    let addressElementName : String = "address"
    let latElementName  : String = "lat"
    let lngElementName   : String = "lng"
    //各エレメント用の変数
    var shops:[Dictionary<String,Any>]!
    var elements:Dictionary = [String: String]()
    var element:String!
    var id: String!
    var name:String!
    var logo_image: String!
    var address: String!
    var lat: String!
    var lng: String!
    
//    //例外な要素
//    let exceptional_elements_array = [
//        "large_service_area","service_area","large_area","middle_area","small_area","genre", "sub_genre" , "budget", "urls"
//    ]
    
    // logo_image,lat,lngは、値取得後、URL、CLLocationDegreesに変換する
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setup()
        
        shops = []
    }
    
    override func viewDidAppear(_ animated: Bool) {
        //NSXMLParserクラスのインスタンスを準備
        let parser : XMLParser = XMLParser(contentsOf: smapleURL!)!
        if parser != nil {
            // XMLParserDelegateをセット
            parser.delegate = self;
            parser.parse()
            
        } else {
            // パースに失敗した時
            print("failed to parse XML")
        }
    }
    
    private func setup() {
        hotpepperListTableView.delegate = self
        hotpepperListTableView.dataSource = self
        
        if let path = Bundle.main.path(forResource: "key", ofType: "plist") {
            if let dic = NSDictionary(contentsOfFile: path) as? [String: Any] {
                if let apiKey = dic["hotpepperApiKey"] as? String {
                    self.apiKey = apiKey
                }
            }
        }
        print("hotpepperのapikey →→→ \(self.apiKey)")
    }
    
    
    //XMLを読み込み開始
    func parserDidStartDocument(_ parser: XMLParser) {
        print("parserDidStartDocument")
    }
    
    //XMLの読み込み終了
    func parserDidEndDocument(_ parser: XMLParser!)
    {
        print("reload table")
        self.hotpepperListTableView.reloadData() //TableViewをReload
    }
    //各エレメントの読み込み開始
    func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?,attributes attributeDict: [String : String]) {
        
        self.element = elementName as String
        print("self.element --> \(self.element)")
        
        //要素名が「shop」の要素が見つかった場合には上で設定したメンバ変数を初期化
        if (elementName as NSString).isEqual(to: self.shopElementName){
            self.elements = [:]
            
            self.id = ""
            self.name = ""
            self.logo_image = ""
            self.address = ""
            self.lat = ""
            self.lng = ""
            
        }
    }
    
    //各エレメントの中の要素を見つけた場合のメソッド
    func parser(_ parser: XMLParser, foundCharacters string: String){
        
        if self.element.isEqual(self.idElementName) {
            self.id.append(
                strip(str:string)
            )
        }
        
        if self.element.isEqual(self.nameElementName) {
            self.name.append(
                strip(str:string)
            )
        }
        
        if self.element.isEqual(self.logoImageElementName) {
            self.logo_image.append(
                strip(str:string)
            )
        }
        
        if self.element.isEqual(self.addressElementName) {
            self.address.append(
                strip(str:string)
            )
        }
        
        if self.element.isEqual(self.latElementName) {
            self.lat.append(
                strip(str:string)
            )
        }
        
        if self.element.isEqual(self.lngElementName) {
            self.lng.append(
                strip(str:string)
            )
        }
    }
    
    //改行と半角スペースの除去
    func strip(str: String) -> String {
        var strBr: String
        var strSp: String
        //改行除去
        strBr = str.replacingOccurrences(of:"\n", with: "")
        //半角スペース除去
        strSp = strBr.replacingOccurrences(of:" ", with: "")
        return strSp
    }
    
    //エレメントの読み込みが終了
    func parser(_ parser: XMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
        
        if (elementName as NSString).isEqual(to: self.shopElementName) {
            
            //各メンバ変数がnilでなければメンバ変数elementsへ「キー」と「値」のペアを格納
            if !self.id.isEqual(nil) {
                self.elements[idElementName] = self.id
            }
            
            if !self.name.isEqual(nil) {
                self.elements[nameElementName] = self.name
            }
            
            if !self.logo_image.isEqual(nil) {
                self.elements[logoImageElementName] = self.logo_image
            }
            
            if !self.address.isEqual(nil) {
                self.elements[addressElementName] = self.address
            }
            
            if !self.lat.isEqual(nil) {
                self.elements[latElementName] = self.lat
            }
            
            if !self.lng.isEqual(nil) {
                self.elements[lngElementName] = self.lng
            }
            
            self.shops.append(self.elements)
            
//            for shop in shops {
//                print(shop)
//            }
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
}

extension apiViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        hotpepper.count
        if shops.count > 0 {
            return shops.count
        }
        return 10
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
//        cell.textLabel?.text = hotpepper[indexPath.row].shop.name
        let imageView = cell.contentView.viewWithTag(1) as! UIImageView
        imageView.image = nil //イメージ初期化
                
        let label = cell.contentView.viewWithTag(2) as! UILabel
                
        //イメージ読み込みのインジケータ
        HUD.flash(.progress, onView: imageView)
                
        //要素を読みこんだpostsがあれば
        if(shops.count>0){
            if let name = shops[indexPath.row]["name"] {
                label.text = name as? String
                print("name、長すぎるから、一回出しておくわ --> \(name)")
            } else {
                label.text = ""
            }
                    
            //画像の読み込み（Optionalの型のnil判定がうまく行かず２段確認になってしまった）
            if let imageURL:String = shops[indexPath.row]["logo_image"] as? String {
                print("画像あるから、それにするんごよ♪")
                let shopImage:UIImage = UIImage(url: imageURL)
                imageView.image = shopImage
            }else{
                print("画像ないみたいだから、サンプル画像にしとくね♬")
                imageView.image = UIImage(named: "batu")
            }
        }
        HUD.hide()
        return cell
    }
}
