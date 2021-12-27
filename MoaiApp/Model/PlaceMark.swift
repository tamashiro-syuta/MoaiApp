//
//  PlaceMark.swift
//  MoaiApp
//
//  Created by 玉城秀大 on 2021/12/27.
//

import Foundation
import MapKit

class PlaceMark {
    
    var name: String?
    var title: String?
    var coordinate: CLLocationCoordinate2D?
    var locality: String?
    
    init(dic: [String: Any]) {
        self.name = dic["name"] as? String ?? "なし"
        self.title = dic["title"] as? String ?? "なし"
        self.coordinate = dic["coordinate"] as? CLLocationCoordinate2D
        self.locality = dic["locality"] as? String ?? "なし"
    }
}
    

