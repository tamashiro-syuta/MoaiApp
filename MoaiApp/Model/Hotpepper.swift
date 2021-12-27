//
//  Hotpepper.swift
//  MoaiApp
//
//  Created by 玉城秀大 on 2021/12/27.
//

import Foundation
import UIKit

struct HotpepperAPI {
    static let scheme = "https"
    static let host = "webservice.recruit.co.jp"
    static let gourmetPath = "/hotpepper/gourmet/v1/"
    static let shopPath = "/hotpepper/shop/v1/"
}

struct Hotpepper: Codable {
    let shop: Shop
    
    struct Shop: Codable {
        let id: Int
        let name: String
        let logo_image: String
        let address: String
        let lat: String
        let lng: String
    }
}
