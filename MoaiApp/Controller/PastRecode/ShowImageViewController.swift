//
//  ShowImageViewController.swift
//  MoaiApp
//
//  Created by 玉城秀大 on 2021/09/03.
//

import UIKit
import AVFoundation
import PKHUD
import Firebase

class ShowImageViewController: standardViewController, AVCapturePhotoCaptureDelegate {
    
    //PastMoaiViewControllerで定義した構造体(前画面から値をもらってくる)
    var pastMoaiImageArray = [pastImage]()
    var orderNumber:Int? //何番目のセルがタップされたか
    
    let navBarHeight:CGFloat = 100 // ( 60 + 40 )
    
    @IBOutlet weak var ImageView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupNavBar()
        
        let image:UIImage = UIImage(data: self.pastMoaiImageArray[orderNumber ?? 0].image) ?? UIImage(named: "niwatori")!
        self.ImageView.image = image
    }
    
    private func setupNavBar() {
        let screenSize: CGRect = UIScreen.main.bounds
        let navBar = UINavigationBar(frame: CGRect(x: 0, y: 60, width: screenSize.width, height: 40))
        let navItem = UINavigationItem(title: " ")
        
        let closeImage = UIImage(systemName: "xmark.circle")
        let closeButton = UIBarButtonItem(image: closeImage, style: .done, target: self, action: #selector(closeButtonPressed(_:)))
        closeButton.tintColor = .white
        
        let downloadButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(downLoadButtonPressed(_:)) )
        downloadButton.tintColor = .white
        
        navItem.setLeftBarButton(closeButton, animated: true)
        navItem.setRightBarButton(downloadButton, animated: true)
        navBar.setItems([navItem], animated: false)
        
//        self.view.addSubview(navBar)
        
        navBar.barTintColor = UIColor(red: 0, green: 0, blue: 0, alpha: 1)
        navBar.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
        navBar.shadowImage = UIImage()
        
        self.view.addSubview(navBar)
    }
    
    @objc func closeButtonPressed(_ sender: UIBarButtonItem) {
        print("戻るボタンが押されたよ")
        self.dismiss(animated: true, completion: nil)
    }
    @objc func downLoadButtonPressed(_ sender: UIBarButtonItem) {
        print("ダウンロードボタンが押されたよ")
  
        //URLから画像を取得し、端末に保存
        fetchImageAndSaveToDevise()
        
    }

    private func fetchImageAndSaveToDevise() {
        let url = self.pastMoaiImageArray[orderNumber!].url
        
        Storage.storage().reference(withPath: url).getData(maxSize: 1 * 1024 * 1024) { (data, err) in
            if let err = err {
                print("画像データの取得に失敗しました。\(err)")
            }else {
                guard let image = UIImage(data: data!) else {return}
                //端末に保存
                UIImageWriteToSavedPhotosAlbum(image, self, #selector(self.didFinishSavingImage(_:didFinishSavingWithError:contextInfo:)), nil)
            }
        }
    }
    
    @objc func didFinishSavingImage(_ image: UIImage, didFinishSavingWithError error: NSError!, contextInfo: UnsafeMutableRawPointer) {
       // 結果によって出すアラートを変更する
       var title = "保存完了"
       var message = "カメラロールに保存しました"
       let ok = "OK"
        
       if error != nil {
           title = "エラー"
           message = "保存に失敗しました"
       }
       
       let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
       alertController.addAction(UIAlertAction(title: ok, style: .default, handler: { _ in
           
       }))
       self.present(alertController, animated: true, completion: nil)
    }
}
