
import Foundation
import Alamofire
import CoreLocation
import SVProgressHUD

class ApiManager {
    
    // MARK: API CALL
    
    class func callAPI<T: Codable>(type: T.Type, apiURL: String, method: Alamofire.HTTPMethod, parameters: [String: Any]? = nil, success successBlock:@escaping ((Codable?, Int?) -> Void), failure failureBlock: ((Error, Int?) -> Bool)?) {
        
        var finalParameters = [String: Any]()
        if parameters != nil {
            finalParameters = parameters!
        }
        
        //DLog("parameters = ", finalParameters)
        DLog("apiURL = ", apiURL)
        
        var headers = HTTPHeaders()
        if let authKey = DEFAULTS.value(forKey: DEFAULTS_KEY.AUTH_TOKEN) as? String, !authKey.isEmpty {
            headers.add(name: "Authorization", value: authKey)
            //headers.add(name: "Content-Type", value: "application/json")
        }
        
        AF.request(apiURL, method: method, parameters: finalParameters, encoding: URLEncoding(), headers: headers)
            .responseString { response in
            DLog("Response String: \(String(describing: response.value))")
        }.responseJSON { response in
            
            DLog("Response Error: ", response.error)
            DLog("Response JSON: ", response.value)
            DLog("response.request: ", response.request?.allHTTPHeaderFields)
            DLog("Response Status Code: ", response.response?.statusCode)
            DLog(response.response?.allHeaderFields)
            
            DispatchQueue.main.async {
                if response.response?.statusCode == 401 {
                    Utility.shared.showToast(CONSTANTS.UN_AUTHORIZE_ACCESS.localized())
                    //APPDELEGATE.logoutFromApplication()
                } else if response.response?.statusCode == 200 {
                    if let responseObject = response.value {
                        do {
                            let jsonData = try JSONSerialization.data(withJSONObject: responseObject, options: .prettyPrinted)
                            let model = mappingFromJsonToObject(type: T.self, data: jsonData)
                            successBlock(model, response.response?.statusCode)
                        } catch {
                        }
                    }
                } else if (response.error == nil) {
                    if let responseObject = response.value {
                        do {
                            let jsonData = try JSONSerialization.data(withJSONObject: responseObject, options: .prettyPrinted)
                            let model = mappingFromJsonToObject(type: CommonErrorBaseModel.self, data: jsonData)
                            successBlock(model, response.response?.statusCode)
                        } catch {
                        }
                    }
                } else {
                    if failureBlock != nil && failureBlock!(response.error! as NSError, response.response?.statusCode) {
                        if let statusCode = response.response?.statusCode {
                            ApiManager.handleAlamofireHttpFailureError(statusCode: statusCode)
                        }
                        if let responseObject = response.value {
                            do {
                                let jsonData = try JSONSerialization.data(withJSONObject: responseObject, options: .prettyPrinted)
                                let model = mappingFromJsonToObject(type: T.self, data: jsonData)
                                successBlock(model, response.response?.statusCode)
                            } catch {
                                
                            }
                        }
                    }
                }
            }
        }
    }
        
    // MARK: - Multiple Images
    
    func callMultiPartDataWebServiceNew<T: Codable>(type: T.Type, image: Data?, to url: String, params: [String: Any], success successBlock:@escaping ((T?, Int?) -> Void), failure failureBlock: ((Error, Int?) -> Void)) {
        guard let url = URL(string: url) else {return}
        SVProgressHUD.show()
        SVProgressHUD.setDefaultMaskType(.black)
        var request = URLRequest(url: url)
        request.httpMethod = HTTPMethod.post.rawValue
        request.addValue("multipart/form-data", forHTTPHeaderField: "Content-Type")
        if let authKey = DEFAULTS.value(forKey: DEFAULTS_KEY.AUTH_TOKEN) as? String, !authKey.isEmpty {
            request.addValue(authKey, forHTTPHeaderField: "Authorization")
            //headers.add(name: "Content-Type", value: "application/json")
        }
        
        AF.upload(multipartFormData: {
            multipartFormData in
            do {
                for (key, value) in params {
                    if let temp = value as? String {
                        multipartFormData.append(temp.data(using: .utf8)!, withName: key)
                    }
                    if let temp = value as? Int {
                        multipartFormData.append("\(temp)".data(using: .utf8)!, withName: key)
                    }
                    if let temp = value as? NSArray {
                        temp.forEach({ element in
                            let keyObj = key + "[]"
                            if let string = element as? String {
                                multipartFormData.append(string.data(using: .utf8)!, withName: keyObj)
                            } else
                            if let num = element as? Int {
                                let value = "\(num)"
                                multipartFormData.append(value.data(using: .utf8)!, withName: keyObj)
                            }
                        })
                    }
                }
                
                if let data = image {
                multipartFormData.append(data, withName: "image", fileName: "\(Date.init().timeIntervalSince1970).jpg", mimeType: "image/jpg")
                }
                
                
            }
        },  with: request)
            .uploadProgress(queue: .main, closure: { progress in
                //Current upload progress of file
                print("Upload Progress: \(progress.fractionCompleted)")
            })
            .responseJSON(completionHandler: { response in
                print(response)
                SVProgressHUD.dismiss()
                if let err = response.error {
                    print(err)
                    successBlock(nil, response.response?.statusCode)
                    return
                }
                if let json = response.data {
                    let model = mappingFromJsonToObject(type: T.self, data: json)
                    successBlock(model, response.response?.statusCode)
                } else {
                    successBlock(nil, response.response?.statusCode)
                }
                
            })
    }
    
    class func callPushNotificationAPI<T: Codable>(type: T.Type, apiURL: String, method: Alamofire.HTTPMethod, parameters: [String: Any]? = nil, success successBlock:@escaping ((Codable?, Int?) -> Void), failure failureBlock: ((Error, Int?) -> Bool)?) {
        
        var finalParameters = [String: Any]()
        if parameters != nil {
            finalParameters = parameters!
        }
        
        DLog("parameters = ", finalParameters)
        DLog("apiURL = ", apiURL)
        
        let url = URL(string: apiURL)!
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: finalParameters, options: .prettyPrinted)
            
            var request = URLRequest(url: url)
            request.httpMethod = method.rawValue
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            //request.setValue(kFirebaseServerUrl, forHTTPHeaderField: "Authorization")
            request.httpBody = jsonData
            
            AF.request(request).responseJSON { response in
                
                DLog("Response Error: ", response.error)
                DLog("Response JSON: ", response.value)
                DLog("response.request: ", response.request?.allHTTPHeaderFields)
                DLog("Response Status Code: ", response.response?.statusCode)
                DLog(response.response?.allHeaderFields)
                
                DispatchQueue.main.async {
                    if response.response?.statusCode == 401 {
                        Utility.shared.showToast(CONSTANTS.UN_AUTHORIZE_ACCESS.localized())
                        //APPDELEGATE.logoutFromApplication()
                    } else if (response.error == nil) || response.response?.statusCode == 200 {
                        if let responseObject = response.value {
                            do {
                                let jsonData = try JSONSerialization.data(withJSONObject: responseObject, options: .prettyPrinted)
                                let model = mappingFromJsonToObject(type: T.self, data: jsonData)
                                successBlock(model, response.response?.statusCode)
                            } catch {
                            }
                        }
                    } else {
                        if failureBlock != nil && failureBlock!(response.error! as NSError, response.response?.statusCode) {
                            if let statusCode = response.response?.statusCode {
                                ApiManager.handleAlamofireHttpFailureError(statusCode: statusCode)
                            }
                            if let responseObject = response.value {
                                do {
                                    let jsonData = try JSONSerialization.data(withJSONObject: responseObject, options: .prettyPrinted)
                                    let model = mappingFromJsonToObject(type: T.self, data: jsonData)
                                    successBlock(model, response.response?.statusCode)
                                } catch {
                                    
                                }
                            }
                        }
                    }
                }
            }
        } catch {
            print(error.localizedDescription)
        }
    }
    
    // MARK: SHOW FAILURE ERRORS
    
    class func handleAlamofireHttpFailureError(statusCode: Int) {
        switch statusCode {
        case NSURLErrorUnknown:
            Utility.shared.showToast(CONSTANTS.SOMETHING_WENT_WRONG.localized())
        case NSURLErrorCancelled:
            break
        case NSURLErrorTimedOut:
            Utility.shared.showToast(CONSTANTS.CHECK_INTERNET_CONNECTION.localized())
        case NSURLErrorNetworkConnectionLost:
            Utility.shared.showToast(CONSTANTS.NET_CONNECTION_LOST.localized())
        case NSURLErrorNotConnectedToInternet:
            Utility.shared.showToast(CONSTANTS.CHECK_INTERNET_CONNECTION.localized())
        default:
            Utility.shared.showToast(CONSTANTS.SOMETHING_WENT_WRONG.localized())
        }
    }
}
// MARK: PARSE JSON DATA TO MODEL
private func mappingFromJsonToObject<T: Codable>(type: T.Type, data: Data) -> T? {
    do {
        return try JSONDecoder().decode(T.self, from: data)
    } catch {
        print("JSON decode error:", error)
        return nil
    }
}

extension NSMutableData {
    func appendString(_ string: String) {
        let data = string.data(using: String.Encoding.utf8, allowLossyConversion: false)
        append(data!)
    }
}

extension URLEncoding {
    public func queryParameters(_ parameters: [String: Any]) -> [(String, String)] {
        var components: [(String, String)] = []
        
        for key in parameters.keys.sorted(by: <) {
            let value = parameters[key]!
            components += queryComponents(fromKey: key, value: value)
        }
        return components
    }
}

struct CommonErrorBaseModel: Codable {
    
    var error    : String?
    let message  : String?
    
    enum CodingKeys : String, CodingKey {
        case error       = "error"
        case message    = "message"
    }
    
    init(from decoder: Decoder) throws {
        
        let values = try decoder.container(keyedBy: CodingKeys.self)
        
        self.error       = try values.decodeIfPresent(String.self, forKey: .error)
        self.message    = try values.decodeIfPresent(String.self, forKey: .message)
    }
}
