//
//  Extensions.swift
//  sumolog
//
//  Created by 岩見建汰 on 2018/01/03.
//  Copyright © 2018年 Kenta. All rights reserved.
//

import UIKit

extension UIColor {
    class func hex ( _ hexStr : String, alpha : CGFloat) -> UIColor {
        var hexString = hexStr as NSString
        
        hexString = hexString.replacingOccurrences(of: "#", with: "") as NSString
        let scanner = Scanner(string: hexString as String)
        var color: UInt32 = 0
        if scanner.scanHexInt32(&color) {
            let r = CGFloat((color & 0xFF0000) >> 16) / 255.0
            let g = CGFloat((color & 0x00FF00) >> 8) / 255.0
            let b = CGFloat(color & 0x0000FF) / 255.0
            return UIColor(red:r,green:g,blue:b,alpha:alpha)
        } else {
            print("invalid hex string")
            return UIColor.white;
        }
    }
}

extension UITableView {
    public enum ScrollDirection {
        case top
    }
    
    public func scroll(to direction: ScrollDirection, animated: Bool) {
        let offset: CGPoint
        switch direction {
        case .top:
            offset = CGPoint(x: contentOffset.x, y: -adjustedContentInset.top)
        }
        setContentOffset(offset, animated: animated)
    }
}

extension Date {
    static func stringFromString(string: String, formatIn: String, formatOut: String) -> String {
        let formatterIn: DateFormatter = DateFormatter()
        formatterIn.dateFormat = formatIn
        let formatterOut: DateFormatter = DateFormatter()
        formatterOut.dateFormat = formatOut
        return formatterOut.string(from: formatterIn.date(from: string)!)
    }
}
