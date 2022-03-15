//
//  ApiManager.swift
//   
//
//     on 19/03/19.
//  Copyright © 2018 Smit Patel. All rights reserved.
//


import Foundation
import Alamofire

var CheckUrl = ""

class ApiCallManager {
    
    public static let apiSessionManager: Session = {
        let configuration = URLSessionConfiguration.default
        //configuration.httpAdditionalHeaders = Session.defaultHTTPHeaders
        configuration.requestCachePolicy = .reloadIgnoringLocalCacheData
        configuration.urlCache = nil
        configuration.timeoutIntervalForRequest = 200
        configuration.timeoutIntervalForResource = 200
        
        
        return Session(configuration: configuration)
    }()
    
    class func requestApiStripe(method: Alamofire.HTTPMethod, urlString: String, parameters: [String: Any]? = nil, headers: [String: String]? = nil, success successBlock:@escaping (([String: Any], Int) -> Void), failure failureBlock:((NSError) -> Bool)?) -> DataRequest {
        
        var finalParameters = [String: Any]()
        if(parameters != nil) {
            finalParameters = parameters!
        }
        
        DLog("parameters = \(finalParameters)")
        DLog("URL = \(urlString)")
        DLog("URL = \( AppPrefsManager.sharedInstance.getUserAccessToken())")
        
        var request = URLRequest(url: URL(string: urlString)!)
        request.httpMethod = method.rawValue
        
        if AppPrefsManager.sharedInstance.isUserLogin() {
            request.addValue("Bearer " + StripeConstant.Secret_key.rawValue, forHTTPHeaderField: "Authorization")
        }
        
        if !finalParameters.isEmpty {
            let jsonString = finalParameters.reduce("") { "\($0)\($1.0)=\($1.1)&" }.dropLast()
            let jsonData = jsonString.data(using: .utf8, allowLossyConversion: false)!
            request.addValue("application/x-www-form-urlencoded", forHTTPHeaderField:"Content-Type")
            request.httpBody  = jsonData
        }
                
        return apiSessionManager.request(request)
            .responseString { response in
                DLog( "Response String: \(String(describing: response.value))")
            }
            .responseJSON { response in
                DLog("urlString = \(urlString)")
                //DLog( "response.request: \(String(describing: response.request?.allHTTPHeaderFields))")
                DLog( "Response Error: \(String(describing: response.error)) URL: \(urlString)")
                DLog(response.value , " URL: \(urlString)")
                
                if(response.error == nil) {
                    let responseObject = response.value as? [NSObject: Any] ?? [NSObject: Any]()
                    let responseObj = responseObject as! [String : Any]
                    //                    let resp = ResponseDataModel(responseObj: response)
                    //                    if resp.message_code == ResponseCode.logOut {
                    //                        AppDelegate.shared().logOut()
                    //                    }
                    successBlock(responseObj, response.response?.statusCode ?? 0)
                } else {
                    if(failureBlock != nil && failureBlock!(response.error! as NSError))
                    {
                        if let statusCode = response.response?.statusCode
                        {
                            handleAlamofireHttpFailureError(statusCode: statusCode)
                            successBlock([String: Any](), response.response?.statusCode ?? 0)
                        }
                    }
                }
            }
    }
    
    class func requestApi(method: Alamofire.HTTPMethod, urlString: String, parameters: [String: Any]? = nil, headers: [String: String]? = nil, success successBlock:@escaping (([String: Any]) -> Void), failure failureBlock:((NSError) -> Bool)?) -> DataRequest
    {
        
        var finalParameters = [String: Any]()
        if(parameters != nil)
        {
            finalParameters = parameters!
        }
        
        
        DLog("parameters = \(finalParameters)")
        DLog("URL = \(urlString)")
        DLog("URL = \( AppPrefsManager.sharedInstance.getUserAccessToken())")
        
        var request = URLRequest(url: URL(string: urlString)!)
        request.httpMethod = method.rawValue
        
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        if AppPrefsManager.sharedInstance.isUserLogin() {
            request.setValue("Bearer " + AppPrefsManager.sharedInstance.getUserAccessToken() , forHTTPHeaderField: "Authorization")
        }
        
        
        
        if !finalParameters.isEmpty
        {
            request.httpBody = try! JSONSerialization.data(withJSONObject: finalParameters)
            
        }
        
        
        
        return apiSessionManager.request(request)
            .responseString { response in
                
                DLog( "Response String: \(String(describing: response.value))")
                
            }
            .responseJSON { response in
                
                
                DLog("urlString = \(urlString)")
                //DLog( "response.request: \(String(describing: response.request?.allHTTPHeaderFields))")
                DLog( "Response Error: \(String(describing: response.error)) URL: \(urlString)")
                DLog(response.value , " URL: \(urlString)")
                
                
                if(response.error == nil) {
                    let responseObject = response.value as? [NSObject: Any] ?? [NSObject: Any]()
                    let response = responseObject as! [String : Any]
                    //                    let resp = ResponseDataModel(responseObj: response)
                    //                    if resp.message_code == ResponseCode.logOut {
                    //                        AppDelegate.shared().logOut()
                    //                    }
                    
                    successBlock(response)
                } else {
                    if(failureBlock != nil && failureBlock!(response.error! as NSError))
                    {
                        if let statusCode = response.response?.statusCode
                        {
                            handleAlamofireHttpFailureError(statusCode: statusCode)
                            successBlock([String: Any]())
                        }
                    }
                }
            }
    }
    
    
    
    
    
    class func callApi(apiURL: String, method: Alamofire.HTTPMethod, parameters: [String: Any]? = nil, headers: HTTPHeaders, success successBlock:@escaping ((Any?, Int?) -> Void), failure failureBlock: ((Error, Int?) -> Bool)?) -> DataRequest
    {
        var finalParameters = [String: Any]()
        if parameters != nil {
            finalParameters = parameters!
        }
        
        DLog("parameters = ", finalParameters)
        DLog("apiURL = ", apiURL)
        DLog("headers = ", headers)
        
        
        return AF.request(apiURL, method: method, parameters: finalParameters, encoding: URLEncoding(), headers: headers)
            .responseString { response in
                
                //DLog("Response String: \(String(describing: response.value))")
                
            }
            .responseJSON { response in
                
                DLog("Response Error: ", response.error)
                DLog("Response JSON: ", response.value)
                DLog("response.request: ", response.request?.allHTTPHeaderFields)
                DLog("Response Status Code: ", response.response?.statusCode)
                // DLog(response.response?.allHeaderFields)
                
                
                
                DispatchQueue.main.async {
                    if (response.error == nil) || response.response?.statusCode == 200 {
                        let responseObject = response.value
                        
                        let response1 = responseObject as? [String : Any] ?? [String : Any]()
                        //                        let resp = ResponseDataModel(responseObj: response1)
                        //                        if resp.message_code == ResponseCode.logOut {
                        //                            AppDelegate.shared().logOut()
                        //                        }
                        
                        successBlock(responseObject, response.response?.statusCode)
                        
                    } else {
                        if failureBlock != nil && failureBlock!(response.error! as NSError, response.response?.statusCode) {
                            if let statusCode = response.response?.statusCode {
                                handleAlamofireHttpFailureError(statusCode: statusCode)
                            }
                            let responseObject = response.value
                            
                            successBlock(responseObject, response.response?.statusCode)
                        }
                    }
                }
            }
    }
    
    
    class func callApiWithUpload(apiURL: String, method: Alamofire.HTTPMethod, parameters: [String: Any]? = nil, fileParameters: [Any]? = nil, headers: [String: String]? = nil, success successBlock:@escaping ((Any?, Int?) -> Void), failure failureBlock: ((Error, Int?) -> Bool)?) {
        
        var finalParameters = [String: Any]()
        if parameters != nil {
            finalParameters = parameters!
        }
        
        DLog("parameters = ", finalParameters)
        DLog("apiURL = ", apiURL)
        
        var request = URLRequest(url: URL(string: apiURL)!)
        request.httpMethod = HTTPMethod.post.rawValue
        request.addValue("multipart/form-data", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        if AppPrefsManager.sharedInstance.isUserLogin() {
            request.setValue("Bearer " + AppPrefsManager.sharedInstance.getUserAccessToken() , forHTTPHeaderField: "Authorization")
        }
        
        
        AF.upload(multipartFormData: { (multipartFormData) in
            
            
            /*let userdddJsonData = try! JSONSerialization.data(withJSONObject: finalParameters, options: JSONSerialization.WritingOptions(rawValue: 0))
             multipartFormData.append(userdddJsonData, withName: "")*/
            
            for (key, hgfhf) in finalParameters {
                
                multipartFormData.append(String(describing: hgfhf).data(using: .utf8)!, withName: key)
                DLog(hgfhf)
                
                //                let userdddJsonData = try! JSONSerialization.data(withJSONObject: hgfhf, options: JSONSerialization.WritingOptions(rawValue: 0))
                //                multipartFormData.append(userdddJsonData, withName: key)
                
            }
            
            if fileParameters != nil && fileParameters!.count > 0 {
                for i in 0...(fileParameters!.count - 1) {
                    let dict = fileParameters![i] as! [String : Any]
                    multipartFormData.append(dict["file_data"] as! Data, withName: dict["param_name"] as? String ?? "", fileName: dict["file_name"] as? String ?? "", mimeType: dict["mime_type"] as? String ?? "")
                }
            }
            
            
        },  with: request)
        .uploadProgress(queue: .main, closure: { progress in
            //Current upload progress of file
            DLog("Upload Progress: \(progress.fractionCompleted)")
        })
        
        .responseJSON(completionHandler: { data in
            
            DLog("Response Error: ", data.error)
            DLog("Response JSON: ", data.value)
            DLog("response.request: ", data.request?.allHTTPHeaderFields)
            DLog("Response Status Code: ", data.response?.statusCode)
            
            if data.response?.statusCode == 200 {
                let dataObj = data.value as? [String:Any] ??   [String:Any]()
                successBlock(dataObj, data.response?.statusCode)
            } else {
                
                if let statusCode = data.response?.statusCode {
                    let dataObj = data.value as? [String:Any] ??   [String:Any]()
                    successBlock(dataObj, data.response?.statusCode)
                    handleAlamofireHttpFailureError(statusCode: statusCode)
                }
                
            }
            
        })
        
    }
    
    
    class func handleAlamofireHttpFailureError(statusCode: Int) {
        switch statusCode {
        case NSURLErrorUnknown:
            
            Utility.showMessageAlert(title: "Error", andMessage: "Ooops!! Something went wrong, please try after some time!", withOkButtonTitle: "OK")
            
        case NSURLErrorCancelled:
            
            break
        case NSURLErrorTimedOut:
            
            Utility.showMessageAlert(title: "Error", andMessage: "The request timed out, please verify your internet connection and try again.", withOkButtonTitle: "OK")
            
        case NSURLErrorNetworkConnectionLost:
            //displayAlert("Error", andMessage: NSLocalizedString("network_lost", comment: ""))
            break
            
        case NSURLErrorNotConnectedToInternet:
            //displayAlert("Error", andMessage: NSLocalizedString("internet_appears_offline", comment: ""))
            break
            
        default:
            
            Utility.showMessageAlert(title: "Error", andMessage: "Ooops!! Something went wrong, please try after some time!", withOkButtonTitle: "OK")
            
        }
    }
    
    
}


public func jsonObjectFromJsonString(_ jsonString: String) -> AnyObject {
    do {
        let jsonData = jsonString.data(using: String.Encoding.utf8)!
        let jsonObj = try JSONSerialization.jsonObject(with: jsonData, options: JSONSerialization.ReadingOptions.mutableContainers)
        
        return jsonObj as AnyObject
    }
    catch let error as NSError {
        DLog("Error!! = \(error)")
    }
    
    return "" as AnyObject
}


public func jsonStringFromDictionaryOrArrayObject(obj: Any) -> String
{
    do {
        let jsonData = try JSONSerialization.data(withJSONObject: obj, options: JSONSerialization.WritingOptions.prettyPrinted)
        let jsonString = NSString(data: jsonData, encoding: String.Encoding.utf8.rawValue)
        
        return jsonString! as String
    }
    catch let error as NSError {
        DLog("Error!! = \(error)")
    }
    
    return ""
}
