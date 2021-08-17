//
//  MapViewController.swift
//  MoaiApp
//
//  Created by 玉城秀大 on 2021/07/09.
//

import UIKit
import MapKit
import CoreLocation

class MapViewController: UIViewController, CLLocationManagerDelegate, UITextFieldDelegate, UISearchBarDelegate {
    
    var user:User?
    var moai:Moai?
    
    @IBOutlet weak var map: MKMapView!
    @IBOutlet weak var searchBar: UISearchBar!
    
    
    var locationManager: CLLocationManager!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        searchBar.delegate = self
        
        locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager!.requestWhenInUseAuthorization()
        
        //位置情報が利用可能か
        if CLLocationManager.locationServicesEnabled() {
            //位置情報の取得開始
            locationManager.startUpdatingLocation()
            print(locationManager.location)
            print(type(of: locationManager.location))
            if let currentLocation = locationManager.location {
                setPin(location: currentLocation, pinTitle: "現在地")
            }
        }else {
            //県庁の位置情報をデフォルトで設定
            //中心座標
            let defaultLocate = CLLocation(latitude: 26.2125, longitude: 127.68111) //たぶん県庁
            setPin(location: defaultLocate, pinTitle: "沖縄県庁")
        }
        
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        //入力された文字を取り出す
        if let searchKey = searchBar.text {
            print("検索開始でっせ！！！")
            print(searchKey)
            
            //キーボードを閉じる。
            searchBar.resignFirstResponder()
            print("1")
                    
            //検索条件を作成する。
            let request = MKLocalSearch.Request()
            request.naturalLanguageQuery = searchKey
            print("2")
                    
            //検索範囲はマップビューと同じにする。
            request.region = map.region
            print("3")
                    
            //ローカル検索を実行する。
            let localSearch:MKLocalSearch = MKLocalSearch(request: request)
            print("4")
            localSearch.start(completionHandler: {(result, error) in
                
                print("5")
             
                for placemark in (result?.mapItems)! {
                    if(error == nil) {
                        print("6")
                        //検索された場所にピンを刺す。
//                        let annotation = MKPointAnnotation()
//                        annotation.coordinate = CLLocationCoordinate2DMake(placemark.placemark.coordinate.latitude, placemark.placemark.coordinate.longitude)
//                        annotation.title = placemark.placemark.name
//                        annotation.subtitle = placemark.placemark.title
//                        self.map.addAnnotation(annotation)
                        guard let location = placemark.placemark.location else {return}
                        let name = placemark.placemark.name
                        self.setPin(location: location, pinTitle: name ?? "")
                                
                    } else {
                        print("7")
                        //エラー
                        print(error)
                    }
                }
                print("8")
            })
        }
    }
    
    private func setPin(location: CLLocation, pinTitle: String) {
        //引数から緯度経度を取得
        let targetCoordinate = location.coordinate
        let pin = MKPointAnnotation()
        //ピンの置く場所の緯度経度を設定
        pin.coordinate = targetCoordinate
        pin.title = pinTitle
        self.map.addAnnotation(pin)
        self.map.region = MKCoordinateRegion(center: targetCoordinate, latitudinalMeters: 5000, longitudinalMeters: 5000)
        
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

}
