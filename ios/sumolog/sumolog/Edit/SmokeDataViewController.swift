//
//  EditViewController.swift
//  sumolog
//
//  Created by 岩見建汰 on 2018/01/05.
//  Copyright © 2018年 Kenta. All rights reserved.
//

import UIKit
import Eureka
import SwiftyJSON
import Alamofire
import KeychainAccess
import StatusProvider
import PromiseKit

class SmokeDataViewController: FormViewController, UITabBarControllerDelegate, StatusController {

    var preViewName = StoryBoardID.edit.rawValue
    let indicator = Indicator()
    let refresh_controll = UIRefreshControl()
    
    var id = ""
    var uuid = ""
    var results:[JSON] = []
    let keychain = Keychain()
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.tabBarController?.navigationItem.title = "Edit"
        
        SetUpButton()
        
        CallGet24HourSmokeAPI(show_indicator: true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        id = (try! keychain.getString("id"))!
        uuid = (try! keychain.getString("uuid"))!
        
        self.tabBarController?.delegate = self
        
        self.tableView.refreshControl = self.refresh_controll
        self.refresh_controll.addTarget(self, action: #selector(self.refresh(sender:)), for: .valueChanged)
    }
    
    func SetUpButton() {
        if NSString(string: (try! keychain.getString("is_smoking"))!).boolValue {
            let check = UIBarButtonItem(image: UIImage(named: "icon_check"), style: .plain, target: self, action: #selector(TapSmokeEndButton))
            self.tabBarController?.navigationItem.setRightBarButton(check, animated: true)
        }else {
            let add = UIBarButtonItem(image: UIImage(named: "icon_add"), style: .plain, target: self, action: #selector(TapSmokeStartButton))
            self.tabBarController?.navigationItem.setRightBarButton(add, animated: true)
        }
    }
    
    func CallGet24HourSmokeAPI(show_indicator: Bool) {
        if show_indicator {
            indicator.showIndicator(view: self.view)
        }
        
        let urlString = API.base.rawValue + API.v1.rawValue + API.smoke.rawValue + API.hour24.rawValue + API.user.rawValue + id + "/" + uuid
        
        Alamofire.request(urlString, method: .get).responseJSON { (response) in
            // pullされてAPIを叩かれた場合
            if !show_indicator {
                self.refresh_controll.endRefreshing()
            }
            
            self.indicator.stopIndicator()
            
            guard let object = response.result.value else{return}
            let json = JSON(object)
            print("Smoke 24hour results: ", json.count)
            print(json["results"])
            
            self.results = json["results"].arrayValue
            self.DrawView()
        }
    }
    
    func CallCreateSmokeAPI() -> Promise<Int> {
        let urlString = API.base.rawValue + API.v1.rawValue + API.smoke.rawValue
        
        let promise = Promise<Int> { (resolve, reject) in
            Alamofire.request(urlString, method: .post, parameters: ["uuid":uuid], encoding: JSONEncoding(options: [])).responseJSON { (response) in
                guard let object = response.result.value else{return}
                let json = JSON(object)
                print("Smoke 24hour results: ", json.count)
                print(json)
                
                resolve(json["smoke_id"].intValue)
            }
        }
        
        return promise
    }
    
    func refresh(sender: UIRefreshControl) {
        refresh_controll.beginRefreshing()
        CallGet24HourSmokeAPI(show_indicator: false)
    }
    
    func DrawView() {
        UIView.setAnimationsEnabled(false)
        ResetViews()
        
        if results.count == 0 {
            let status = Status(title: "No Data", description: "喫煙記録がないため、データを表示できません", actionTitle: "Reload", image: nil) {
                self.hideStatus()
                self.CallGet24HourSmokeAPI(show_indicator: true)
            }
            show(status: status)
        }else {
            CreateForm()
        }
        UIView.setAnimationsEnabled(true)
    }
    
    func ResetViews() {
        self.hideStatus()
        form.removeAll()
    }
    
    func CreateForm() {
        let section = Section("24hour Smoked")
        
        for smoke in results {
            let title = "Start： " + smoke["started_at"].stringValue + "\n" + "End：   " + smoke["ended_at"].stringValue
            let vc = SmokeDataEditViewController()
            vc.SetSmokeID(id: smoke["id"].intValue)
            vc.SetStartedAt(started_at: smoke["started_at"].stringValue)
            vc.SetEndedAt(ended_at: smoke["ended_at"].stringValue)
            
            let row = ButtonRow() {
                $0.title = title
                $0.presentationMode = .show(controllerProvider: ControllerProvider.callback {return vc}, onDismiss: {vc in vc.navigationController?.popViewController(animated: true)})
                $0.cell.textLabel?.numberOfLines = 0
            }
            
            section.append(row)
        }
        
        form.append(section)
    }
    
    func TapSmokeStartButton() {
        // 喫煙開始のAPIを叩く
        // データ取得のAPIを叩く
        // アラート表示
        // 右上のボタンをチェックマークにする
    }
    
    func TapSmokeEndButton() {
        // 喫煙終了のAPIを叩く
        // データ取得のAPIを叩く
        // アラート表示
        // 右上のボタンをプラスマークにする
    }
    
    func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
        if viewController.restorationIdentifier! == StoryBoardID.edit.rawValue && preViewName == StoryBoardID.edit.rawValue {
            tableView.scroll(to: .top, animated: true)
        }
        
        preViewName = viewController.restorationIdentifier!
    }

    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
