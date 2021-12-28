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
    let results: ResultsData
}

struct ResultsData: Codable {
    let resultsReturned: String
    let shop: [Shop]
    
    enum CodingKeys: String, CodingKey {
        case resultsReturned = "results_returned"
        case shop = "shop"
    }
}

struct Shop: Codable {
    let ID: String
    let name: String
    let logoImage: String
    let address: String
    let lat: Float
    let lng: Float
    
    //スネークケースから、キャメルケースに変換するため
    enum CodingKeys: String, CodingKey {
        case ID = "id"
        case name = "name"
        case logoImage = "logo_image"
        case address = "address"
        case lat = "lat"
        case lng = "lng"
    }
}
