
import UIKit
import WebKit

class CommonWebViewVC: BaseViewController, WKNavigationDelegate, WKScriptMessageHandler, WKUIDelegate {
    
    @IBOutlet weak var globalWebView: WKWebView!

    var webURL: URL?
    var didLoadPaymentURLBlock : ((_ transaction_id: String, _ status: Bool) -> Void)!
    var transaction_id = ""

    override func viewDidLoad() {
        super.viewDidLoad()
        
        globalWebView.uiDelegate = self
        globalWebView.navigationDelegate = self
        self.loadWebviewURL()
    }
        
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        print(message.body)
    }
    
    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        print(error.localizedDescription)
        
        hideLoader()
    }
    
    func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
        print(error.localizedDescription)
        
        hideLoader()
    }
    
    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        
        print("Strat to load")
        if let url = webView.url?.absoluteString {
            print("url = \(url)")
            showLoader()
        }
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        
        print("finish to load")
        if let url = webView.url?.absoluteString {
            print("url = \(url)")
        }
        hideLoader()
        if let _ = webView.url?.absoluteString {
            guard let components = NSURLComponents(url: webView.url!, resolvingAgainstBaseURL: true),
                    let _ = components.path
                else { return }
            var tempStatus = false
            if let status = getValueFromQueryParam(key: "status", components: components) {
                if status == PaymentURLResponse.succeeded {
                    tempStatus = true
                }
                if self.didLoadPaymentURLBlock != nil {
                    self.navigateToLiveClass()
                    self.didLoadPaymentURLBlock(self.transaction_id, tempStatus)
                }
            }
        }
    }
    
    private func navigateToLiveClass() {
        for controller in navigationController!.viewControllers {
            if controller.isKind(of: LiveClassDetailsViewController.self) {
                self.navigationController?.popToViewController(controller, animated: true)
                break
            }
        }
    }

    func loadWebviewURL() {
        if let url = webURL {
            self.globalWebView.load(URLRequest(url: url))
            self.globalWebView.allowsBackForwardNavigationGestures = true
        }
    }
}

struct PaymentURLResponse {
    static let succeeded = "succeeded"
}
