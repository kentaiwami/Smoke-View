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
        var one_box_number = 0
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
    
    func SetOneBoxNumber(num: Int) {
        data.one_box_number = num
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
    
    func GetOneBoxNumber() -> Int {
        return data.one_box_number
    }
    
    func SetAll(json: JSON) {
        data.payday = json["payday"].intValue
        data.price = json["price"].intValue
        data.target_number = json["target_number"].intValue
        data.address = json["address"].stringValue
        data.one_box_number = json["one_box_number"].intValue
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
        var x = 0
        var next_payday_count = 0
        var one_box_number = 0
    }
    
    private var data = SmokeDetailViewData()
    
    func GetCoefficients() -> Array<Double> {
        return data.coefficients
    }
    
    func GetPrice() -> Int {
        return data.price
    }
    
    func GetAve() -> Double {
        return data.ave
    }
    
    func GetX() -> Int {
        return data.x
    }
    
    func GetNextPaydayCount() -> Int {
        return data.next_payday_count
    }
    
    func GetOneBoxNumber() -> Int {
        return data.one_box_number
    }
    
    func SetAll(json: JSON) {
        data.coefficients = json["coefficients"].arrayValue.map({$0.doubleValue})
        data.price = json["price"].intValue
        data.ave = json["ave"].doubleValue
        data.x = json["x"].intValue
        data.next_payday_count = json["next_payday_count"].intValue
        data.one_box_number = json["one_box_number"].intValue
    }
}