//
//  SCWebBrowserView.swift
//  SwiftExample
//
//  Created by ShannonChen on 2017/6/21.
//  Copyright © 2017年 ShannonChen. All rights reserved.
//

import UIKit
import WebKit

@objc protocol SCWebBrowserViewDelegate {
    @objc optional func webBrowserViewDidStartLoad(_ webBrowserView: SCWebBrowserView)
    @objc optional func webBrowserViewDidFinishLoad(_ webBrowserView: SCWebBrowserView)
    @objc optional func webBrowserView(_ webBrowserView: SCWebBrowserView, didFailLoadWithError error: NSError!)
    @objc optional func webBrowserView(_ webBrowserView: SCWebBrowserView, shouldStartLoadWithRequest request: NSURLRequest!)
    
}



/// A `UIView` subclass designed to wrapper `UIWebView` and `WKWebView`, using `UIWebView` on the version prior to iOS 8 and `WKWebView` on iOS 8 and later.
class SCWebBrowserView: UIView {
    
    // MARK: Properties
    weak var delegate: SCWebBrowserViewDelegate?
    
    var uiWebView: UIWebView?
    var wkWebView: WKWebView?
    
    
    // MARK: Public Methods
    func loadURLWithString(_ URLString: String) {
        let url = URL.init(string: URLString)
        
        if let anUrl = url {
            let request = URLRequest.init(url: anUrl)
            uiWebView?.loadRequest(request)
        }
    
    }
    
    func loadHTMLString(_ HTMLString: String) {
        uiWebView?.loadHTMLString(HTMLString, baseURL: nil)
    }
    

    // MARK: Life cycle
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.setup()
    }
    
    // MARK: Private methods
    func setup() {
        self.backgroundColor = UIColor.red
        
        uiWebView = UIWebView.init(frame: self.bounds)
        uiWebView?.autoresizingMask = [.flexibleWidth, .flexibleHeight];
        addSubview(uiWebView!)
        
    }

}
