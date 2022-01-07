//
//  standardTabBarController.swift
//  MoaiApp
//
//  Created by 玉城秀大 on 2021/08/04.
//

import UIKit
import CoreLocation

class standardTabBarController: UITabBarController, CLLocationManagerDelegate {
    
    var user: User?
    var moai: Moai?
    var nextMoai: MoaiRecord? //次回の模合の情報
    var nextMoaiID: String?
    var pastRecordArray: [MoaiRecord]?  //古いデータが「0番目」、新しいのが「n番目」になってる
    var pastRecordIDStringArray: [String]?  // 20210417みたいな形で取り出してる
    var pastRecordIDDateArray: [String]?  //◯月◯日みたいな形で取り出してる
    var nextMoaiEntryArray: [Bool]? // ブーリアン型の配列
    var moaiMenbersNameList: [String] = [] //模合メンバーの名前の配列
    
    //位置情報の確認用
    var locationManager: CLLocationManager!
    

    override func viewDidLoad() {
        super.viewDidLoad()
        //位置情報の取得
        locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager!.requestWhenInUseAuthorization()

        //位置情報の利用許可を取る
        locationManager = CLLocationManager()
        CLLocationManager.locationServicesEnabled()
        print(CLLocationManager.locationServicesEnabled())
        
        
        // アイコンの色を変更できます！
        UITabBar.appearance().tintColor = .white
        // 背景色を変更できます！
        UITabBar.appearance().barTintColor = .barColor()
        
        //1秒後に処理(viewControllerを生成するのが早い説？？)
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            //ここに処理
//            self.setVC()
        }
        self.setVC()
        
    }
    
    private func setVC() {
        
        var VCArray = [UIViewController] ()
        
        let managementSB = UIStoryboard(name: "Management", bundle: nil)
        let managementVC = managementSB.instantiateViewController(withIdentifier: "Management")
        let managementImage = UIImage(systemName: "house")
        managementVC.tabBarItem = UITabBarItem(title: "模合", image: managementImage, selectedImage: nil)
        
        let chatSB = UIStoryboard(name: "ChatList", bundle: nil)
        let chatVC = chatSB.instantiateViewController(withIdentifier: "Chat")
        let chatImage = UIImage(systemName: "bubble.left.and.bubble.right")
        chatVC.tabBarItem = UITabBarItem(title: "チャット", image: chatImage, selectedImage: nil)
        
        let pastMoaiSB = UIStoryboard(name: "PastMoai", bundle: nil)
        let pastMoaiVC = pastMoaiSB.instantiateViewController(withIdentifier: "PastMoai")
        let pastMoaiImage = UIImage(systemName: "photo.on.rectangle.angled")
        pastMoaiVC.tabBarItem = UITabBarItem(title: "過去の模合", image: pastMoaiImage, selectedImage: nil)
        
        let mapSB = UIStoryboard(name: "Map", bundle: nil)
        let mapVC = mapSB.instantiateViewController(withIdentifier: "Map")
        let mapImage = UIImage(systemName: "map")
        mapVC.tabBarItem = UITabBarItem(title: "店舗検索", image: mapImage, selectedImage: nil)
        
        let savingsSB = UIStoryboard(name: "Savings", bundle: nil)
        let savingsVC = savingsSB.instantiateViewController(withIdentifier: "Savings")
        let savingImage = UIImage(systemName: "yensign.square.fill")
        savingsVC.tabBarItem = UITabBarItem(title: "積み立て", image: savingImage, selectedImage: nil)
        
        VCArray.append(managementVC)
        VCArray.append(chatVC)
        VCArray.append(pastMoaiVC)
        VCArray.append(mapVC)
        VCArray.append(savingsVC)
        
        self.setViewControllers(VCArray, animated: false)
        
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
