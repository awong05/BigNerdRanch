//
//  WebViewController.swift
//  WorldTrotter
//
//  Created by Andy Wong on 10/24/16.
//  Copyright © 2016 Big Nerd Ranch. All rights reserved.
//

import UIKit
import WebKit

class WebViewController: UIViewController {
    var webView: WKWebView!

    override func loadView() {
        webView = WKWebView()
        view = webView

        webView.load(URLRequest(url: URL(string: "https://www.bignerdranch.com")!))
    }
}
