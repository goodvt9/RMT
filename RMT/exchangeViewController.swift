//
//  exchangeViewController.swift
//  RMT
//
//  Created by vt9 on 2023/8/5.
//

import UIKit

class exchangeViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {
    
    var selectedCountry: country = countryInfo[0]
    var pickData: Array<String> = []
    var pickDict: [String:Double] = [:]
    
    @IBOutlet weak var fromCountryPickerView: UIPickerView!
    
    @IBOutlet weak var fromCurrencyUILabel: UILabel!
    
    @IBOutlet weak var exAmtUITextField: UITextField!
    
    @IBOutlet weak var f_tw: UIButton!
    @IBOutlet weak var f_jp: UIButton!
    @IBOutlet weak var f_kr: UIButton!
    @IBOutlet weak var f_ta: UIButton!
    @IBOutlet weak var f_us: UIButton!
    @IBOutlet weak var f_cn: UIButton!
    
    
    @IBOutlet weak var toCountryPickerView: UIPickerView!
    @IBOutlet weak var toCountryUILabel: UILabel!
    @IBOutlet weak var resultAmt: UILabel!
    
    
    @IBOutlet weak var t_tw: UIButton!
    @IBOutlet weak var t_jp: UIButton!
    @IBOutlet weak var t_kr: UIButton!
    @IBOutlet weak var t_ta: UIButton!
    @IBOutlet weak var t_us: UIButton!
    @IBOutlet weak var t_cn: UIButton!
    
    
    //指定有幾排pickerView選單，這邊設定為1代表只有一排
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    //指定每一個component有幾個選項(row)，這邊回傳10，所以會有十個選項可以選
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return countryInfo.count    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return countryInfo[row].CountryTwName
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        print("row:\(row), component:\(component)")
        if (pickerView == fromCountryPickerView) {
            selectedCountry = countryInfo[row]
            fromCurrencyUILabel.text = selectedCountry.CurrencyCode
            
            reSet(selectedCountry.CurrencyCode)
        } else if (pickerView == toCountryPickerView) {
            selectedCountry = countryInfo[row]
            toCountryUILabel.text = selectedCountry.CurrencyCode
            
            if exAmtUITextField.text != "" {
                var i = 0
                for (key, value) in pickDict {
                    let currency = key
                    if (currency == toCountryUILabel.text ?? "TWD") {
                        let rate = value as? Double ?? 0
                        resultAmt.text = String(format: "%.2f", (Double(exAmtUITextField.text ?? "0") ?? 0) * rate)
                        break
                    }
                    i += 1
                }
            }
        }
        
    }
    
    func GetRate(_ code: String) {
        URLSession.shared.dataTask(with: URL(string: "https://open.er-api.com/v6/latest/\(code )")!) { (data, response, error) -> Void in
            // Check if data was received successfully
            if error == nil && data != nil {
                do {
                    // Convert NSData to Dictionary where keys are of type String, and values are of any type
                    let json = try JSONSerialization.jsonObject(with: data!, options: []) as! [String:Any]
                    // Access specific key with value of type String
                    let dict = json["rates"] as! NSDictionary
                    for (key, value) in dict {
                        let myKey = key as! String
                        //let index = myKey
                        self.pickData.append(String(myKey))
                        self.pickDict[String(myKey)] = value as? Double
                    }
                    
                } catch {
                    // Something went wrong
                }
            }
        }.resume()
    }
    
    @objc func closeKeyboard(){
        self.view.endEditing(true)
    }
    
    func reSet(_ currency: String) {
        pickData = []
        pickDict = [:]
        print(currency)
        
        URLSession.shared.dataTask(with: URL(string: "https://open.er-api.com/v6/latest/\(currency)")!) { (data, response, error) -> Void in
            // Check if data was received successfully
            if error == nil && data != nil {
                do {
                    // Convert NSData to Dictionary where keys are of type String, and values are of any type
                    let json = try JSONSerialization.jsonObject(with: data!, options: []) as! [String:Any]
                    // Access specific key with value of type String
                    let dict = json["rates"] as! NSDictionary
                    for (key, value) in dict {
                        let myKey = key as! String
                        //let index = myKey
                        self.pickData.append(String(myKey))
                        self.pickDict[String(myKey)] = value as? Double
                    }
                    
                    DispatchQueue.main.async {
                        
                        if self.exAmtUITextField.text != "" {
                            var i = 0
                            for (key, value) in self.pickDict {
                                let currency = key
                                if (currency == self.toCountryUILabel.text ?? "TWD") {
                                    let rate = value as? Double ?? 0
                                    self.resultAmt.text = String(format: "%.2f", (Double(self.exAmtUITextField.text ?? "0") ?? 0) * rate)
                                    break
                                }
                                i += 1
                            }
                        }
                    }
                } catch {
                    // Something went wrong
                }
            }
        }.resume()
    }
    
    func reCale() {
        if self.exAmtUITextField.text != "" {
            var i = 0
            for (key, value) in self.pickDict {
                let currency = key
                if (currency == self.toCountryUILabel.text ?? "TWD") {
                    let rate = value as? Double ?? 0
                    self.resultAmt.text = String(format: "%.2f", (Double(self.exAmtUITextField.text ?? "0") ?? 0) * rate)
                    break
                }
                i += 1
            }
        }
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        fromCountryPickerView.delegate = self
        fromCountryPickerView.dataSource = self
        
        toCountryPickerView.delegate = self
        toCountryPickerView.dataSource = self
        
        //init
        fromCountryPickerView.selectRow(141, inComponent: 0, animated: false)
        fromCurrencyUILabel.text = "TWD"
        toCountryPickerView.selectRow(141, inComponent: 0, animated: false)
        toCountryUILabel.text = "TWD"
        
        exAmtUITextField.text = "1"
        resultAmt.text = "1.00"
        
        GetRate("TWD")
        
        self.view.endEditing(true)
    }
    
    @IBAction func SetCountry(_ sender: UIButton) {
        print(sender.tag)
        switch (sender.tag) {
        case btnType.f_tw.rawValue:
            fromCountryPickerView.selectRow(141, inComponent: 0, animated: false)
            fromCurrencyUILabel.text = "TWD"
            reSet(fromCurrencyUILabel.text ?? "TWD")
        case btnType.f_jp.rawValue:
            fromCountryPickerView.selectRow(70, inComponent: 0, animated: false)
            fromCurrencyUILabel.text = "JPY"
            reSet(fromCurrencyUILabel.text ?? "TWD")
        case btnType.f_kr.rawValue:
            fromCountryPickerView.selectRow(76, inComponent: 0, animated: false)
            fromCurrencyUILabel.text = "KRW"
            reSet(fromCurrencyUILabel.text ?? "TWD")
        case btnType.f_ta.rawValue:
            fromCountryPickerView.selectRow(133, inComponent: 0, animated: false)
            fromCurrencyUILabel.text = "THB"
            reSet(fromCurrencyUILabel.text ?? "TWD")
        case btnType.f_us.rawValue:
            fromCountryPickerView.selectRow(145, inComponent: 0, animated: false)
            fromCurrencyUILabel.text = "USD"
            reSet(fromCurrencyUILabel.text ?? "TWD")
        case btnType.f_cn.rawValue:
            fromCountryPickerView.selectRow(29, inComponent: 0, animated: false)
            fromCurrencyUILabel.text = "CNY"
            reSet(fromCurrencyUILabel.text ?? "TWD")
        case btnType.t_tw.rawValue:
            toCountryPickerView.selectRow(141, inComponent: 0, animated: false)
            toCountryUILabel.text = "TWD"
            reCale()
        case btnType.t_jp.rawValue:
            toCountryPickerView.selectRow(70, inComponent: 0, animated: false)
            toCountryUILabel.text = "JPY"
            reCale()
        case btnType.t_kr.rawValue:
            toCountryPickerView.selectRow(76, inComponent: 0, animated: false)
            toCountryUILabel.text = "KRW"
            reCale()
        case btnType.t_ta.rawValue:
            toCountryPickerView.selectRow(133, inComponent: 0, animated: false)
            toCountryUILabel.text = "THB"
            reCale()
        case btnType.t_us.rawValue:
            toCountryPickerView.selectRow(145, inComponent: 0, animated: false)
            toCountryUILabel.text = "USD"
            reCale()
        case btnType.t_cn.rawValue:
            toCountryPickerView.selectRow(29, inComponent: 0, animated: false)
            toCountryUILabel.text = "CNY"
            reCale()
        default:
            print(sender)
            break
        }
    }
    
    @IBAction func exAmtChange(_ sender: Any) {
        reCale()
    }
    
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destination.
     // Pass the selected object to the new view controller.
     }
     */
    
}
