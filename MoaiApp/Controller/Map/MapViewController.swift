//
//  MapViewController.swift
//  MoaiApp
//
//  Created by 玉城秀大 on 2021/07/09.
//

import UIKit
import MapKit
import CoreLocation

class MapViewController: UIViewController, CLLocationManagerDelegate, UITextFieldDelegate {
    
    @IBOutlet weak var map: MKMapView!
    @IBOutlet weak var searchTextField: UITextField!
    
    
    var locationManager: CLLocationManager!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        searchTextField.delegate = self
        
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

        }
        
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        //入力された文字を取り出す
        if let searchKey = textField.text {
            print(searchKey)
            
            let geocorder = CLGeocoder()
            //入力された文字から位置情報を取得
            geocorder.geocodeAddressString(searchKey) { (placemarks, err) in
                //位置情報が存在する場合
                if let unwrapPlacemark = placemarks {
                    print(type(of: unwrapPlacemark))
                    //１件目の情報を取得
                    if let firstPlacemark = unwrapPlacemark.first {
                        print(type(of: firstPlacemark))
                        //位置情報を取得
                        if let location = firstPlacemark.location {
                            //ピンを設置
                            self.setPin(location: location, pinTitle: searchKey)
                        }
                    }
                }
            }
        }
        //キーボードを閉じる
        searchTextField.resignFirstResponder()
        
        return true
    }
    
    private func setPin(location: CLLocation, pinTitle: String) {
        //引数から緯度経度を取得
        let targetCoordinate = location.coordinate
        let pin = MKPointAnnotation()
        //ピンの置く場所の緯度経度を設定
        pin.coordinate = targetCoordinate
        pin.title = pinTitle
        self.map.addAnnotation(pin)
        self.map.region = MKCoordinateRegion(center: targetCoordinate, latitudinalMeters: 3000, longitudinalMeters: 3000)
        
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
