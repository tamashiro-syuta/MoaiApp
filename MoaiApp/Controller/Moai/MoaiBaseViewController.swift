//
//  MoaiBaseViewController.swift
//  MoaiApp
//
//  Created by 玉城秀大 on 2021/06/23.
//

import UIKit

class MoaiBaseViewController: UIViewController {
    
    
    @IBOutlet weak var joinButton: UIButton!
    @IBOutlet weak var createButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationController?.navigationBar.barTintColor = .rgb(red: 39, green: 49, blue: 69)
        
        joinButton.layer.cornerRadius = joinButton.frame.size.height / 3
        createButton.layer.cornerRadius = createButton.frame.size.height / 3
        
    }

}
