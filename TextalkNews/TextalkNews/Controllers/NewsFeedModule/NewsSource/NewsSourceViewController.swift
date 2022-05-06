//
//  NewsSourceViewController.swift
//  TextalkNews
//
//  Created by gwl on 06/05/22.
//

import UIKit
import WebKit

class NewsSourceViewController: UIViewController, WKUIDelegate {
    // MARK: All Outlets
    @IBOutlet weak var wkwebview: WKWebView!
    // MARK: All Properties
    var url: String = ""
    // MARK: Viewcontroller LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        addBackButton(title: "Feed Details")
        loadDataInWebView()
        // Do any additional setup after loading the view.
    }
    // MARK: Custome functions
    func loadDataInWebView() {
        let sourceUrl = URL(string: url)
        let webViewRequest = URLRequest(url: sourceUrl!)
        wkwebview.load(webViewRequest)
    }
}
