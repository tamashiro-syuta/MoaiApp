//
//  UIImageExtension.swift
//  MoaiApp
//
//  Created by 玉城秀大 on 2021/12/16.
//

import UIKit

//URLから画像を取得
extension UIImage {
    public convenience init(url: String) {
        let url = URL(string: url)
        do {
            let data = try Data(contentsOf: url!)
            self.init(data: data)!
            return
        } catch let err {
            print("Error : \(err.localizedDescription)")
        }
        self.init()
    }
}
