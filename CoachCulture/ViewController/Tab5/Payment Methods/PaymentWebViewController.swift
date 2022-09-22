//
//  PaymentWebViewController.swift
//  CoachCulture
//
//  Created by mac on 30/06/1944 Saka.
//

import UIKit
import WebKit

class PaymentWebViewController: UIViewController, WKNavigationDelegate, WKScriptMessageHandler, WKUIDelegate {
    
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        print(message.body)
    }
    
    @IBOutlet weak var paymentWebView: WKWebView!
    
    static func viewcontroller() -> PaymentWebViewController {
        let vc = UIStoryboard(name: "Payment", bundle: nil).instantiateViewController(withIdentifier: "PaymentWebViewController") as! PaymentWebViewController
        return vc
    }
    
    var webUrl = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let url = URL(string: webUrl) {
            paymentWebView.load(URLRequest(url: url))
            view.addSubview(paymentWebView)
        }
        paymentWebView.allowsBackForwardNavigationGestures = true
        paymentWebView.uiDelegate = self
        paymentWebView.navigationDelegate = self
    }
    
    @IBAction func btnBack(_ sender: UIButton) {
        navigationController?.popViewController(animated: true)
    }
    
    public func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Swift.Void) {
        if(navigationAction.navigationType == .other) {
            if let redirectedUrl = navigationAction.request.url {
                if(redirectedUrl.absoluteString.contains("succes")) {
                    showToast(message: "Payment success", seconds: 3)
                    self.navigationController?.popViewController(animated: true)
                } else if (redirectedUrl.absoluteString.contains("fail")) {
                    showToast(message: "Payment failed, please try again", seconds: 3)
                    self.navigationController?.popViewController(animated: true)
                }
            }
        }
        decisionHandler(.allow)
    }

    
//    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
//        print("finish to load")
//        if let url = webView.url?.absoluteString {
//            print("url = \(url)")
//        }
//
//        if let _ = webView.url?.absoluteString {
//            guard let components = NSURLComponents(url: webView.url!, resolvingAgainstBaseURL: true),
//                    let _ = components.path
//                else { return }
//            var tempStatus = false
//            if let status = getValueFromQueryParam(key: "status", components: components) {
//                if status == PaymentURLResponse.succeeded {
//                    tempStatus = true
//                }
//                if self.didLoadPaymentURLBlock != nil {
////                    self.navigateToLiveClass()
////                    self.didLoadPaymentURLBlock(self.transaction_id, tempStatus)
//                }
//            }
//        }
//    }
}

struct PaymentResponse {
    static let succeeded = "succeeded"
}
