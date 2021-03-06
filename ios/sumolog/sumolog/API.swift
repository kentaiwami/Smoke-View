//
//  API.swift
//  sumolog
//
//  Created by 岩見建汰 on 2018/08/13.
//  Copyright © 2018年 Kenta. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON
import PromiseKit

class API {
    let sumologBase = GetSumologHost() + "api/"
    let portfolioBase = GetPortfolioHost() + "api/"
    let sumologAPIVersion = "v1/"
    let portfolioAPIVersion = "v1/"
    
    fileprivate let utility = Utility()
    
    fileprivate func get(url: String, isShowIndicator: Bool) -> Promise<JSON> {
        let indicator = Indicator()
        
        if isShowIndicator {
            indicator.start()
        }
        
        let promise = Promise<JSON> { seal in
            Alamofire.request(url, method: .get).validate(statusCode: 200..<600).responseJSON { (response) in
                indicator.stop()
                
                switch response.result {
                case .success(let value):
                    let json = JSON(value)
                    print("***** GET API Results *****")
                    print(json)
                    print("***** GET API Results *****")
                    
                    if self.utility.isHTTPStatus(statusCode: response.response?.statusCode) {
                        seal.fulfill(json)
                    }else {
                        let err_msg = json["msg"].stringValue + "[" + String(json["code"].intValue) + "]"
                        seal.reject(NSError(domain: err_msg, code: (response.response?.statusCode)!))
                    }
                case .failure(_):
                    let err_msg = "エラーが発生しました[-1]"
                    seal.reject(NSError(domain: err_msg, code: (response.response?.statusCode)!))
                }
            }
        }
        return promise
    }
    
    fileprivate func postPutPatchDeleteAuth(url: String, params: [String:Any], httpMethod: HTTPMethod) -> Promise<JSON> {
        let indicator = Indicator()
        indicator.start()
        
        let promise = Promise<JSON> { seal in
            Alamofire.request(url, method: httpMethod, parameters: params, encoding: JSONEncoding(options: [])).validate(statusCode: 200..<600).responseJSON { (response) in
                indicator.stop()
                
                switch response.result {
                case .success(let value):
                    let json = JSON(value)
                    print("***** "+httpMethod.rawValue+" Auth API Results *****")
                    
                    print(json)
                    print("***** "+httpMethod.rawValue+" Auth API Results *****")
                    
                    if self.utility.isHTTPStatus(statusCode: response.response?.statusCode) {
                        seal.fulfill(json)
                    }else {
                        let err_msg = json["msg"].stringValue + "[" + String(json["code"].intValue) + "]"
                        seal.reject(NSError(domain: err_msg, code: (response.response?.statusCode)!))
                    }
                case .failure(_):
                    let err_msg = "エラーが発生しました[-1]"
                    seal.reject(NSError(domain: err_msg, code: (response.response?.statusCode)!))
                }
            }
        }
        return promise
    }
}



// MARK: - Raspi
extension API {
    fileprivate func raspiSignUpRequest(address: String, uuid: String) -> Promise<String> {
        let indicator = Indicator()
        indicator.start()
        
        let request = utility.getConnectRaspberryPIRequest(method: "POST", address: address, uuid: uuid)
        let promise = Promise<String> { seal in
            Alamofire.request(request).validate(statusCode: 200..<600).responseJSON { response in
                indicator.stop()
                
                switch response.result {
                case .success(let value):
                    let json = JSON(value)
                    print("***** raspiSignUpRequest API Results *****")
                    print(json)
                    print("***** raspiSignUpRequest API Results *****")
                    
                    if self.utility.isHTTPStatus(statusCode: response.response?.statusCode) {
                        seal.fulfill(json["uuid"].stringValue)
                    }else {
                        seal.reject(NSError(domain: "センサーに接続できませんでした[-1]", code: (response.response?.statusCode)!))
                    }
                case .failure(_):
                    let err_msg = "センサーに接続できませんでした[-1]"
                    seal.reject(NSError(domain: err_msg, code: (response.response?.statusCode)!))
                }
            }
        }
        return promise
    }
    
    fileprivate func raspiUUIDCountRequest(address: String, uuid: String) -> Promise<Int> {
        let indicator = Indicator()
        indicator.start()
        
        let request = utility.getConnectRaspberryPIRequest(method: "GET", address: address, uuid: uuid)
        let promise = Promise<Int> { seal in
            Alamofire.request(request).validate(statusCode: 200..<600).responseJSON { response in
                indicator.stop()
                
                switch response.result {
                case .success(let value):
                    let json = JSON(value)
                    print("***** raspiUUIDCountRequest API Results *****")
                    print(json)
                    print("***** raspiUUIDCountRequest API Results *****")
                    
                    if self.utility.isHTTPStatus(statusCode: response.response?.statusCode) {
                        seal.fulfill(json["count"].intValue)
                    }else {
                        seal.reject(NSError(domain: "センサーに接続できませんでした[-1]", code: (response.response?.statusCode)!))
                    }
                case .failure(_):
                    let err_msg = "センサーに接続できませんでした[-1]"
                    seal.reject(NSError(domain: err_msg, code: -1))
                }
            }
        }
        return promise
    }
    
    fileprivate func raspiUpdateUUIDRequest(address: String, uuid: String, method: String) -> Promise<String> {
        let indicator = Indicator()
        indicator.start()
        
        let request = utility.getConnectRaspberryPIRequest(method: method, address: address, uuid: uuid)
        let promise = Promise<String> { seal in
            Alamofire.request(request).validate(statusCode: 200..<600).responseJSON { response in
                indicator.stop()
                
                switch response.result {
                case .success(let value):
                    let json = JSON(value)
                    print("***** raspiUpdateUUIDRequest API Results *****")
                    print(json)
                    print("***** raspiUpdateUUIDRequest API Results *****")
                    
                    if self.utility.isHTTPStatus(statusCode: response.response?.statusCode) {
                        seal.fulfill("OK")
                    }else {
                        seal.reject(NSError(domain: "センサーに接続できませんでした[-1]", code: (response.response?.statusCode)!))
                    }
                case .failure(_):
                    let err_msg = "センサーに接続できませんでした[-1]"
                    seal.reject(NSError(domain: err_msg, code: -1))
                }
            }
        }
        return promise
    }
}



// MARK: - SignUp
extension API {
    func saveUUIDInSensor(isSensorSet: Bool, url: String) -> Promise<String> {
        let uuid = NSUUID().uuidString
        
        if !isSensorSet {
            let promise = Promise<String> { seal in
                seal.fulfill(uuid)
            }
            return promise
        }
        
        return raspiSignUpRequest(address: url, uuid: uuid)
    }
    
    func createUser(params: [String:Any]) -> Promise<JSON> {
        let endPoint = "user"
        return postPutPatchDeleteAuth(url: sumologBase + sumologAPIVersion + endPoint, params: params, httpMethod: .post)
    }
}


// MARK: - Token
extension API {
    func sendToken(params: [String:String]) {
        let endPoint = "token"
        let _ = postPutPatchDeleteAuth(url: sumologBase + sumologAPIVersion + endPoint, params: params, httpMethod: .put).done { (_) in}
    }
}



// MARK: - OverView
extension API {
    func getOverView(userID: String) -> Promise<JSON> {
        let endPoint = "smoke/overview/user/" + userID
        return get(url: sumologBase + sumologAPIVersion + endPoint, isShowIndicator: true)
    }
}



// MARK: - ListView
extension API {
    func get24HourSmoke(isShowIndicator: Bool, userID: String) -> Promise<JSON> {
        let endPoint = "smoke/24hour/user/" + userID
        return get(url: sumologBase + sumologAPIVersion + endPoint, isShowIndicator: isShowIndicator)
    }
    
    func startSmoke(params: [String:Any]) -> Promise<JSON> {
        let endPoint = "smoke"
        return postPutPatchDeleteAuth(url: sumologBase + sumologAPIVersion + endPoint, params: params, httpMethod: .post)
    }
    
    func endSmoke(params: [String:Any], smokeID: String) -> Promise<JSON> {
        let endPoint = "smoke/" + smokeID
        return postPutPatchDeleteAuth(url: sumologBase + sumologAPIVersion + endPoint, params: params, httpMethod: .put)
    }
    
    func addSmokes(params: [String:Any]) -> Promise<JSON> {
        let endPoint = "smoke/some"
        return postPutPatchDeleteAuth(url: sumologBase + sumologAPIVersion + endPoint, params: params, httpMethod: .post)
    }
}



// MARK: - ListEdit
extension API {
    func deleteSmoke(smokeID: Int, userID: String) -> Promise<JSON> {
        let endPoint = "smoke/"+String(smokeID)+"/user/"+userID
        return postPutPatchDeleteAuth(url: sumologBase + sumologAPIVersion + endPoint, params: [:], httpMethod: .delete)
    }
    
    func updateSmoke(smokeID: String, params: [String:String]) -> Promise<JSON> {
        let endPoint = "smoke/" + smokeID
        print("+++++++++++++++++++++++++++")
        print(params)
        print("+++++++++++++++++++++++++++")
        return postPutPatchDeleteAuth(url: sumologBase + sumologAPIVersion + endPoint, params: params, httpMethod: .patch)
    }
}



// MARK: - Setting
extension API {
    func getUserData(userID: String) -> Promise<JSON> {
        let endPoint = "user/" + userID
        return get(url: sumologBase + sumologAPIVersion + endPoint, isShowIndicator: true)
    }
    
    func updateUserData(params: [String:Any], userID: String) -> Promise<JSON> {
        let endPoint = "user/info/" + userID
        return postPutPatchDeleteAuth(url: sumologBase + sumologAPIVersion + endPoint, params: params, httpMethod: .put)
    }
    
    func updateSensorData(params: [String:Any], userID: String) -> Promise<JSON> {
        let endPoint = "user/sensor/" + userID
        return postPutPatchDeleteAuth(url: sumologBase + sumologAPIVersion + endPoint, params: params, httpMethod: .put)
    }
    
    func getUUIDCount(address: String) -> Promise<Int> {
        return raspiUUIDCountRequest(address: address, uuid: "")
    }
    
    func updateUUID(address: String, method: String, uuid: String) -> Promise<String> {
        return raspiUpdateUUIDRequest(address: address, uuid: uuid, method: method)
    }
}


// MARK: - Contact
extension API {
    func postContact(params: [String:String]) -> Promise<JSON> {
        let endPoint = "contact/"
        return postPutPatchDeleteAuth(url: portfolioBase + portfolioAPIVersion + endPoint, params: params, httpMethod: .post)
    }
}
