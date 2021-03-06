//
//  AddsViewController.swift
//  sumolog
//
//  Created by 岩見建汰 on 2018/08/13.
//  Copyright © 2018年 Kenta. All rights reserved.
//

import UIKit
import Eureka
import PopupDialog

protocol AddsViewInterface: class {
    var formValues:[String:Any?] { get }
    
    func successAdds()
    func showAlert(title: String, msg: String)
}

class AddsViewController: FormViewController, AddsViewInterface {
    var formValues: [String : Any?] {
        return self.form.values()
    }
    
    private var presenter: AddsViewPresenter!
    
    fileprivate let utility = Utility()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.navigationItem.title = "一括追加"
        tableView.isScrollEnabled = false
        initializePresenter()
        CreateForm()
        setUpNavigationButton()
    }
    
    private func setUpNavigationButton() {
        let close = UIBarButtonItem(image: UIImage(named: "icon_close"), style: .plain, target: self, action: #selector(tapCloseButton))
        self.navigationItem.setLeftBarButton(close, animated: true)
    }
    
    @objc private func tapCloseButton() {
        dismiss(animated: true, completion: nil)
    }
    
    private func initializePresenter() {
        presenter = AddsViewPresenter(view: self)
    }
    
    private func CreateForm() {
        let dateFormatterMin = utility.getDateFormatter(format: "yyyy-MM-dd HH:mm")
        let now = Date()
        
        form +++ Section(header: "時刻の範囲", footer: "")
            <<< DateTimeRow(){
                $0.title = "開始地点"
                $0.value = now
                $0.tag = "start"
                $0.dateFormatter = dateFormatterMin
            }
            .cellSetup({ (cell, row) in
                cell.detailTextLabel?.textColor = UIColor.black
            })
            
            <<< DateTimeRow(){
                $0.title = "終了地点"
                $0.value = now
                $0.tag = "end"
                $0.dateFormatter = dateFormatterMin
            }
            .cellSetup({ (cell, row) in
                cell.detailTextLabel?.textColor = UIColor.black
            })
            
        form +++ Section(header: "喫煙情報", footer: "")
            <<< PickerInputRow<Int>(""){
                $0.title = "1本あたりの喫煙時間（分）"
                $0.value = 1
                $0.options = [Int](1...60)
                $0.tag = "time"
            }
            .cellSetup({ (cell, row) in
                cell.detailTextLabel?.textColor = UIColor.black
            })

            <<< IntRow(){
                $0.title = "本数"
                $0.value = 0
                $0.add(rule: RuleRequired(msg: "必須項目です"))
                $0.add(rule: RuleGreaterThan(min: 0, msg: "0以上の値にしてください"))
                $0.validationOptions = .validatesOnChange
                $0.tag = "number"
            }
            .onRowValidationChanged {cell, row in
                self.utility.showRowError(row: row)
            }
        

        form +++ Section()
            <<< ButtonRow(){
                $0.title = "追加"
                $0.baseCell.backgroundColor = UIColor.hex(Color.main.rawValue, alpha: 1.0)
                $0.baseCell.tintColor = UIColor.white
            }
            .onCellSelection {  cell, row in
                if self.utility.isCheckFormValue(form: self.form) {
                    let start = self.formValues["start"] as! Date
                    let end = self.formValues["end"] as! Date
                    
                    if start > end {
                        self.utility.showStandardAlert(title: "エラー", msg: "終了地点は開始地点よりも後の時刻を設定してください。", vc: self, completion: nil)
                    }else {
                        if self.presenter.isVaildValue() {
                            self.presenter.adds()
                        }else {
                            self.utility.showStandardAlert(title: "エラー", msg: "指定した範囲内に喫煙情報が収まりません。下記の項目を調整してください。\n\n・範囲の拡大\n・喫煙本数を増やす\n・喫煙時間を減らす", vc: self, completion: nil)
                        }
                    }
                }else {
                    self.utility.showStandardAlert(title: "エラー", msg: "入力項目を再確認してください", vc: self, completion: nil)
                }
            }
    }
}

// MARK: - Presenterから呼び出される関数一覧
extension AddsViewController {
    func successAdds() {
        let ok = DefaultButton(title: "OK", dismissOnTap: true) {}
        let popup = PopupDialog(title: "成功", message: "複数の喫煙情報の追加が完了しました") {
            self.dismiss(animated: true, completion: nil)
        }
        popup.transitionStyle = .zoomIn
        popup.addButtons([ok])
        present(popup, animated: true, completion: nil)
    }
    
    func showAlert(title: String, msg: String) {
        utility.showStandardAlert(title: title, msg: msg, vc: self, completion: nil)
    }
}
