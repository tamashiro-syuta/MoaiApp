//
//  MapViewController.swift
//  MoaiApp
//
//  Created by 玉城秀大 on 2021/07/09.
//

import UIKit
import MapKit
import CoreLocation
import FloatingPanel
import Alamofire
import PKHUD

// SearchListTableViewControllerDelegate は、モーダルから値を受け取るためのデリゲート

class MapViewController: standardViewController, CLLocationManagerDelegate, UITextFieldDelegate, MKMapViewDelegate, UISearchBarDelegate, FloatingPanelControllerDelegate {
    
    
    @IBOutlet weak var map: MKMapView!
    @IBOutlet weak var searchBar: UISearchBar!
    
    
    var locationManager: CLLocationManager!
    var route: MKRoute?
    var routeMessage:String?
    
    //ハーフモーダル
    var halfModalVC = FloatingPanelController()
    var placeMarks: [PlaceMark] = []
    
    var url:String?
    let decoder: JSONDecoder = JSONDecoder()
    var hotpepper:Hotpepper?
    var shops:[Shop] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        
        map.delegate = self
        searchBar.delegate = self
        halfModalVC.delegate = self
        
        //mapにCustomAnnotationViewとCustomeClusterAnnotationViewを使うよ的な宣言
        map.register(CustomAnnotationView.self, forAnnotationViewWithReuseIdentifier: CustomAnnotationView.identifier)
        map.register(CustomeClusterAnnotationView.self, forAnnotationViewWithReuseIdentifier: CustomeClusterAnnotationView.identifier)
        
        locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager!.requestWhenInUseAuthorization()
        
        // 自分の位置情報の場所に青丸をつける
        self.map.showsUserLocation = true
        
        //位置情報が利用可能か(standardVCで許可とってもいいかも、初期画面で許可系のやつは全部とった方がユーザビリティ的にも良いのでは？？？？？)
        if CLLocationManager.locationServicesEnabled() {
            //位置情報の取得開始
            locationManager.startUpdatingLocation()
            print(locationManager.location)
            print(type(of: locationManager.location))
            //スタート地点を現在地に指定
            self.map.region = MKCoordinateRegion(center: locationManager.location!.coordinate, latitudinalMeters: 3000, longitudinalMeters: 3000)
        }else {
            //県庁の位置情報をデフォルトで設定
            //中心座標
            let defaultLocate = CLLocation(latitude: 26.2125, longitude: 127.68111) //たぶん県庁
            setPin(location: defaultLocate, pinTitle: "沖縄県庁")
        }
    }
    
    //画面をタップするとテキストフィールドの編集を終わらせてくれる処理
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }

    //ユーザーの場所が更新された時に呼ばれるメソッド
    func mapView(_ mapView: MKMapView, didUpdate userLocation: MKUserLocation) {
    }
    
    //検索
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        //キーボードを閉じる。
        searchBar.resignFirstResponder()
        //差しているピンを削除
        self.map.removeAnnotations(self.map.annotations)
        //表示している経路を削除
        self.map.removeOverlays(self.map.overlays)
        
        
        
        
        
        
        
        
        //ここから下の処理をメソッド化し、shopsに値が入ったらタイミングで発火させる
        
        
        
        
        
        
        
        
        //入力された文字を取り出す
        if searchBar.text != "" {
            let searchKey = searchBar.text
            print("検索開始でっせ！！！")
            print(searchKey)
            
            //検索条件を作成する。
            let request = MKLocalSearch.Request()
            request.naturalLanguageQuery = searchKey
            
            //searchKeyを検索できる形に変換
            let url = makeURL(searchKey: searchKey!)
            
            //生成したURLからJSONデータを取得
            self.getDataAsJSON(url: url)
            

            //検索範囲はマップビューと同じにする。
            request.region = map.region
                    
//            //ローカル検索を実行する。
//            let localSearch:MKLocalSearch = MKLocalSearch(request: request)
//            localSearch.start(completionHandler: {(result, err) in
//
//                for placemark in (result?.mapItems)! {
//                    if let err = err {
//                        print("エラー -> \(err)")
//                        return
//                    }
//                    guard let location = placemark.placemark.location else {return}
//                    let dic = [
//                        "name":placemark.placemark.name ?? "なし",
//                        "title":placemark.placemark.title ?? "なし",
//                        "coordinate":placemark.placemark.coordinate,
//                        "locality":placemark.placemark.locality ?? "なし"
//                    ] as [String : Any]
//                    let place = PlaceMark(dic: dic)
//                    self.placeMarks.append(place)
//                    self.setPin(location: location, pinTitle: place.name ?? "")
//                }
//            })
        }
    }
    
    private func setPin(location: CLLocation, pinTitle: String) {
        //引数から緯度経度を取得
        let targetCoordinate = location.coordinate
        let pin = MKPointAnnotation()
        //ピンの置く場所の緯度経度を設定
        pin.coordinate = targetCoordinate
        pin.title = pinTitle
//        if pinTitle == "現在地" {
//
//        }
        //ピンを設置
        self.map.addAnnotation(pin)
        
        //現在地の情報があれば、現在地と　ヒットした位置情報が画面に収まるように調整する
        //そうじゃなければ、ヒットした位置情報の付近を中心に設定する
        guard let currentPoint = locationManager.location else {return}
        if currentPoint != nil {
            let halfWayPoint = self.halfwayPoint(first: location, second: currentPoint)
            let distance = location.distance(from: currentPoint)
            self.map.region = MKCoordinateRegion(center: halfWayPoint.coordinate, latitudinalMeters: distance * 1.5, longitudinalMeters: distance * 1.5)
        }else {
            self.map.region = MKCoordinateRegion(center: targetCoordinate, latitudinalMeters: 5000, longitudinalMeters: 5000)
        }
    }
    
    /// ピンをタップした時に呼ばれる(ピンの詳細情報を出したりする)
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        //経路が表示されてたら削除
        if self.route != nil {
            self.map.removeOverlay(self.route?.polyline as! MKOverlay)
        }
        if let anotation = view.annotation {
            print("今、ピンをタップしてやったで")
            let latitude = anotation.coordinate.latitude
            let longitude = anotation.coordinate.longitude
            print("latitudeは \(latitude)")
            print("longitudeは \(longitude)")
            let location = CLLocation(latitude: latitude, longitude: longitude)
            self.showRoute(dest: location)
            guard let currentPoint = locationManager.location else {return}
            if currentPoint != nil {
                let halfWayPoint = self.halfwayPoint(first: location, second: currentPoint)
                let distance = location.distance(from: currentPoint)
                self.map.region = MKCoordinateRegion(center: halfWayPoint.coordinate, latitudinalMeters: distance * 1.5, longitudinalMeters: distance * 1.5)
            }else {
                self.map.region = MKCoordinateRegion(center: location.coordinate, latitudinalMeters: 5000, longitudinalMeters: 5000)
            }
        }
    }

    //経路判定
    func showRoute(dest: CLLocation) {
        let currentLocation = self.map.userLocation
        //現在地
        let sourcePlaceMark = MKPlacemark(coordinate: currentLocation.coordinate)
        //行先
        let destinationPlaceMark = MKPlacemark(coordinate: dest.coordinate)
             
        let directionRequest = MKDirections.Request()
        directionRequest.source = MKMapItem(placemark: sourcePlaceMark)
        directionRequest.destination = MKMapItem(placemark: destinationPlaceMark)
        directionRequest.transportType = .automobile

        let directions = MKDirections(request: directionRequest)
        directions.calculate { (response, error) in
            if let err = error {
                print("エラーでっせ\(err)")
                return
            }
            guard let directionResonse = response else {
                print("何らかの理由でレスポンスが取得できませんでした。")
                return
            }
            let route = directionResonse.routes[0]
            self.route = route
            //経路表示
            self.map.addOverlay(route.polyline, level: .aboveRoads)
            let time = route.expectedTravelTime / 60
            //多分、下のは、アラート的な何かでメッセージを表示するやつだと思う。
//            self.showToast(message: "所要時間は「" + String(time.rounded()) + "」分です。", font: .systemFont(ofSize: 12.0))
            }
    }
    
    //2点間の中心地を割り出す
    func halfwayPoint(first:CLLocation, second:CLLocation) -> CLLocation {
        let firstLatitude = first.coordinate.latitude
        let firstLongitude = first.coordinate.longitude
        let secondLatitude = second.coordinate.latitude
        let secondLongitude = second.coordinate.longitude
        
        let latitude = (firstLatitude + secondLatitude)/2
        let longitude = (firstLongitude + secondLongitude)/2
        
        let between2Point = CLLocation(latitude: latitude, longitude: longitude)
        return between2Point
    }
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        let renderer = MKPolylineRenderer(overlay: overlay)
        renderer.strokeColor = UIColor.blue
        renderer.lineWidth = 8
        return renderer
    }
    
    //画面に表示するAnnotationViewを設定
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        //mapView(viewFor:)でクラスター化されたAnnotationの場合、先ほど定義したCustomeClusterAnnotationViewを表示
        if annotation is MKClusterAnnotation {
            return mapView.dequeueReusableAnnotationView(withIdentifier: CustomeClusterAnnotationView.identifier)
        }
        // dequeueReusableAnnotationViewを使うことで、AnnotationViewを再利用することが可能
        let annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: CustomAnnotationView.identifier) as? CustomAnnotationView
        annotationView?.setup()
        return annotationView
    }
    
    func localSearch(request: MKLocalSearch.Request) {
        //ローカル検索を実行する。
        let localSearch:MKLocalSearch = MKLocalSearch(request: request)
        localSearch.start(completionHandler: {(result, err) in
         
            for placemark in (result?.mapItems)! {
                if let err = err {
                    print("エラー -> \(err)")
                    return
                }
                guard let location = placemark.placemark.location else {return}
                let dic = [
                    "name":placemark.placemark.name ?? "なし",
                    "title":placemark.placemark.title ?? "なし",
                    "coordinate":placemark.placemark.coordinate,
                    "locality":placemark.placemark.locality ?? "なし"
                ] as [String : Any]
                let place = PlaceMark(dic: dic)
                self.placeMarks.append(place)
                self.setPin(location: location, pinTitle: place.name ?? "")
            }
        })
    }
    
    // 許可を求めるためのdelegateメソッド
    func locationManager(_ manager: CLLocationManager,didChangeAuthorization status: CLAuthorizationStatus) {
        switch status {
        // 許可されてない場合
        case .notDetermined:
            // 許可を求める
            manager.requestWhenInUseAuthorization()
        // 拒否されてる場合
        case .restricted, .denied:
            // 何もしない
            break
        // 許可されている場合
        case .authorizedAlways, .authorizedWhenInUse:
            // 現在地の取得を開始
            manager.startUpdatingLocation()
            break
        default:
            break
        }
    }
    
    //検索をかけた際に、ハーフモーダルで条件にヒットした店舗を表示(SearchListTVは渡したデータを表示するだけの機能しか持たせないようにする)
    private func halfModal(shops: [Shop]) {
        let storyboard = UIStoryboard(name: "SearchList", bundle: nil)
        let searchListVC = storyboard.instantiateViewController(withIdentifier: "SearchListTableViewController") as! SearchListTableViewController
        searchListVC.shops = shops
        
        halfModalVC.isRemovalInteractionEnabled = true
        halfModalVC.surfaceView.layer.cornerRadius = 10
        halfModalVC.surfaceView.backgroundColor = .clear
        halfModalVC.set(contentViewController: searchListVC)
        halfModalVC.addPanel(toParent: self)
        
    }
    
    private func makeURL(searchKey:String) -> String {
        var url = ""
        
        let baseURL = "https://webservice.recruit.co.jp/hotpepper/gourmet/v1/?key="
        let apikey = APIKeys().hotpepper
        var keyword:String = ""
        //スペース(半角、全角)を検索クエリに適した形(%E3%80%80)に変換 (charactersInの中身は' '(半角)+'　'(全角)だから、無駄にいじらないようにする!!)
        let notEncode:[String] = searchKey.components(separatedBy: CharacterSet(charactersIn: " 　"))
        var encoded:[String] = []
        for element in notEncode {
            //URL用にエンコードした値を配列に入れる
            encoded.append(element.urlEncoded)
        }
        keyword = encoded.joined(separator: "%E3%80%80")
        url = baseURL + apikey + "&keyword=" + keyword + "&large_area=Z098" + "&format=json"
        print("url --> \(url)")

        return url
    }
    
    //URLからJSONデータを取得し、成功すればハーフモーダルを呼び出し、ピンをセット
    func getDataAsJSON(url: String) {
        let request = AF.request(url)
        request.responseJSON { (response) in
            switch response.result {
            case .success:
                do {
                    print("デコードに成功しました")
                    self.hotpepper = try self.decoder.decode(Hotpepper.self, from: response.data!)
                    print("self.hotpepper?.results.shops --> \(self.hotpepper?.results.shops)")
                    self.shops = (self.hotpepper?.results.shops)!
                    
                    
                    print("shopの数は\(self.shops.count)件です。")
                    //shopの数だけピンを立てる
                    for shop in self.shops {
                        let location = CLLocation(latitude: shop.lat, longitude: shop.lng)
                        print("\(shop.name)の緯度経度はこちら -> \(location)")
                        self.setPin(location: location, pinTitle: shop.name)
                    }
                    
                    
                    //ハーフモーダルを呼び出してAPIを叩く
                    self.halfModal(shops: self.shops)
                   
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

// カスタムアノテーションビューの定義
// クラスター化されたAnnotationViewをカスタムクラスとして定義
class CustomAnnotationView: MKMarkerAnnotationView {
    
    static let identifier = "CustomAnnotationView"
    
    override func prepareForDisplay() {
        super.prepareForDisplay()
        image = UIImage.pinImage
    }
    
    //クラスタリングされるように設定
    func setup() {
        clusteringIdentifier = "StationCluster"
    }
    
    override var annotation: MKAnnotation? {
        didSet {
            configure(for: annotation)
        }
    }
    
    override init(annotation: MKAnnotation?, reuseIdentifier: String?) {
        super.init(annotation: annotation, reuseIdentifier: reuseIdentifier)
        configure(for: annotation)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configure(for annotation: MKAnnotation?) {
        displayPriority = .required
        markerTintColor = selectTintColor(annotation)
    }
    
    private func selectTintColor(_ annotation: MKAnnotation?) -> UIColor? {
        guard let annotation = annotation as? MKPointAnnotation else { return nil }
        let colors: [UIColor] = [.systemRed, .systemBlue, .systemYellow, .systemGreen]
        let index = Int(annotation.title ?? "") ?? 0
        let remainder = index % colors.count
        return colors[remainder]
    }
}


// クラスター化されたピンのAnnotationView
class CustomeClusterAnnotationView: MKAnnotationView {
    static let identifier = "CustomeClusterAnnotationView"

    override func prepareForDisplay() {
        super.prepareForDisplay()
        if let clusterAnnotation = annotation as? MKClusterAnnotation {
            image = UIImage.clusterImage(count: clusterAnnotation.memberAnnotations.count)
        }
    }
}



extension UIImage {
    //ピンの画像
    static let pinImage: UIImage? = {
        let size: CGFloat = 16.0
        let contextSize = CGSize(width: size, height: size)
        UIGraphicsBeginImageContextWithOptions(contextSize, false, 0)
        defer {
            UIGraphicsEndImageContext()
        }
        let fillColor = UIColor.green
        let borderColor = UIColor.blue
        let circlePath = UIBezierPath(ovalIn: CGRect(x: 0.0, y: 0.0, width: size, height: size))
        fillColor.setFill()
        circlePath.fill()
        borderColor.setStroke()
        circlePath.stroke()
        return UIGraphicsGetImageFromCurrentImageContext()
    }()
    
    /// クラスター化されたピンの画像を生成する
    /// - Parameters:
    ///   - count: 中央に表示する数字
    /// - Returns: クラスター化されたピンの画像
    static func clusterImage(count: Int) -> UIImage? {
        let size: CGFloat = 33.0
        let contextSize = CGSize(width: size, height: size)
        UIGraphicsBeginImageContextWithOptions(contextSize, false, 0)
        defer {
            UIGraphicsEndImageContext()
        }
        let fillColor = UIColor.red
        let circlePath = UIBezierPath(ovalIn: CGRect(x: 0.0, y: 0.0, width: size, height: size))
        fillColor.setFill()
        circlePath.fill()

        let text = count.description
        let attributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 15.0, weight: UIFont.Weight.bold),
            .foregroundColor: UIColor.white,
        ]
        let textRect = CGRect(origin: CGPoint.zero, size: CGSize(width: size, height: size))
        let textBoundingRect = text.boundingRect(
            with: CGSize(width: textRect.width, height: textRect.height),
            options: .usesLineFragmentOrigin,
            attributes: attributes, context: nil)

        let finalRect = CGRect(
            x: textRect.midX - textBoundingRect.width / 2,
            y: textRect.midY - textBoundingRect.height / 2,
            width: textBoundingRect.width,
            height: textBoundingRect.height
        )
        text.draw(in: finalRect, withAttributes: attributes)

        return UIGraphicsGetImageFromCurrentImageContext()
    }
}

extension String {
    
    var urlEncoded: String {
        // 半角英数字 + "/?-._~" のキャラクタセットを定義
        let charset = CharacterSet.alphanumerics.union(.init(charactersIn: "/?-._~"))
        // 一度すべてのパーセントエンコードを除去(URLデコード)
        let removed = removingPercentEncoding ?? self
        // あらためてパーセントエンコードして返す
        return removed.addingPercentEncoding(withAllowedCharacters: charset) ?? removed
    }
}
