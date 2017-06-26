//
//  ViewController.swift
//  SwiftExample
//
//  Created by ShannonChen on 2017/6/21.
//  Copyright © 2017年 ShannonChen. All rights reserved.
//

import UIKit

class ViewController: UIViewController, SCWebBrowserViewDelegate {
    
    static let defaultAddress: String = "https://www.apple.com";
    
    // MARK: Properties
    @IBOutlet weak var webBrowserView: SCCustomWebBrowserView!
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        webBrowserView.delegate = self
        
        let path = Bundle.main.path(forResource: "WebViewTest", ofType: "html")
        guard let filePath = path else {
            return
        }
        
        do {
            let HTMLString = try String.init(contentsOfFile: filePath, encoding: String.Encoding.utf8)
            webBrowserView.loadHTMLString(HTMLString)
        } catch {
            print(error)
        }
        
    }

}

