//
//  Data.swift
//  sumolog
//
//  Created by 岩見建汰 on 2018/01/02.
//  Copyright © 2018年 Kenta. All rights reserved.
//
import SwiftyJSON

class UserData {
    struct UserData {
        var payday = 0
        var price = 0
        var target_number = 0
        var address = ""
        var count = 0
    }
    
    private var data = UserData()
    
    func Setpayday(payday: Int) {
        data.payday = payday
    }
    
    func Setprice(price: Int) {
        data.price = price
    }
    
    func Settarget_number(target_number: Int) {
        data.target_number = target_number
    }
    
    func Setaddress(address: String) {
        data.address = address
    }
    
    func SetCount(count: Int) {
        data.count = count
    }
    
    func Getpayday() -> Int {
        return data.payday
    }
    
    func Getprice() -> Int {
        return data.price
    }
    
    func Gettarget_number() -> Int {
        return data.target_number
    }
    
    func Getaddress() -> String {
        return data.address
    }
    
    func GetCount() -> Int {
        return data.count
    }
    
    func SetAll(json: JSON) {
        data.payday = json["payday"].intValue
        data.price = json["price"].intValue
        data.target_number = json["target_number"].intValue
        data.address = json["address"].stringValue
    }
}

class SmokeOverViewData {
    struct SmokeOverViewData {
        var count = 0
        var min = 0
        var hour:[[String:Int]] = []
        var over = 0
    }
    
    private var data = SmokeOverViewData()
    
    func SetCount(count: Int) {
        data.count = count
    }
    
    func SetMin(min: Int) {
        data.min = min
    }
    
    func SetHour(hour: [[String:Int]]) {
        data.hour = hour
    }
    
    func SetOver(over: Int) {
        data.over = over
    }
    
    func GetCount() -> Int {
        return data.count
    }
    
    func GetMin() -> Int {
        return data.min
    }
    
    func GetHour() -> [[String:Int]] {
        return data.hour
    }
    
    func GetOver() -> Int {
        return data.over
    }
    
    func SetAll(json: JSON) {
        data.count = json["count"].intValue
        data.min = json["min"].intValue
        data.over = json["over"].intValue
        
        for obj in json["hour"].arrayValue {
            let tmp = obj.dictionaryValue
            let key = tmp.keys.first!
            data.hour.append([key:tmp[key]!.intValue])
        }
    }
}

class SmokeDetailViewData {
    struct SmokeDetailViewData {
        var coefficients:[Double] = []
        var price = 0
        var ave = 0.0
    }
    
    private var data = SmokeDetailViewData()
    
    func SetCoefficients(coefficients: Array<Double>) {
        data.coefficients = coefficients
    }
    
    func SetPrice(price: Int) {
        data.price = price
    }
    
    func SetAve(ave: Double) {
        data.ave = ave
    }
    
    func GetCoefficients() -> Array<Double> {
        return data.coefficients
    }
    
    func GetPrice() -> Int {
        return data.price
    }
    
    func GetAve() -> Double {
        return data.ave
    }
    
    func SetAll(json: JSON) {
        data.coefficients = json["coefficients"].arrayValue.map({$0.doubleValue})
        data.price = json["price"].intValue
        data.ave = json["ave"].doubleValue
    }
}
