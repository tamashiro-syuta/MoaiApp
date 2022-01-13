//
//  WebViewController.swift
//  MoaiApp
//
//  Created by 玉城秀大 on 2022/01/13.
//

import UIKit
import WebKit

class WebViewController: UIViewController, WKUIDelegate, WKNavigationDelegate {

    @IBOutlet weak var webView: WKWebView!
    let webConfiguration = WKWebViewConfiguration()
    
    var url:String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        webView?.frame = self.view.frame
        webView?.uiDelegate = nil
        webView?.navigationDelegate = nil
        
        let request = URLRequest(url: URL(string: self.url!)!)
        
        webView?.load(request)
    }
    
}
