//
//  ViewController.swift
//  Currency
//
//  Created by Robert O'Connor on 18/10/2017.
//  Copyright © 2017 WIT. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UITextFieldDelegate, UIPickerViewDelegate, UIPickerViewDataSource {
    
    //MARK Model holders
    var currencyDict:Dictionary = [String:Currency]()
    let currencyArray = ["EUR","USD", "GBP", "PLN", "RUB", "CNY", "JPY"]
    var baseCurrency:Currency = Currency.init(name:"EUR", rate:1, flag:"🇪🇺", symbol:"€")!
    var lastUpdatedDate:Date = Date()
    
    var convertValue:Double = 0
    
    var activeField: UITextField?
    
    var finishedFetching = false;
    
    //MARK Outlets
    //@IBOutlet weak var convertedLabel: UILabel!
    
    @IBOutlet weak var loadingScreen: UIView!
    
    
    @IBOutlet weak var pickerView: UIPickerView!
    
    
    
    @IBOutlet weak var baseTextField: UITextField!
    @IBOutlet weak var lastUpdatedDateLabel: UILabel!
    
    @IBOutlet weak var gbpSymbolLabel: UILabel!
    @IBOutlet weak var gbpValueLabel: UILabel!
    @IBOutlet weak var gbpFlagLabel: UILabel!
    
    @IBOutlet weak var usdSymbolLabel: UILabel!
    @IBOutlet weak var usdValueLabel: UILabel!
    @IBOutlet weak var usdFlagLabel: UILabel!
    
    @IBOutlet weak var plnSymbolLabel: UILabel!
    @IBOutlet weak var plnValueLabel: UILabel!
    @IBOutlet weak var plnFlagLabel: UILabel!
    
    @IBOutlet weak var rubSymbolLabel: UILabel!
    @IBOutlet weak var rubValueLabel: UILabel!
    @IBOutlet weak var rubFlagLabel: UILabel!
    
    @IBOutlet weak var cnySymbolLabel: UILabel!
    @IBOutlet weak var cnyValueLabel: UILabel!
    @IBOutlet weak var cnyFlagLabel: UILabel!
    
    @IBOutlet weak var jpySymbolLabel: UILabel!
    @IBOutlet weak var jpyValueLabel: UILabel!
    @IBOutlet weak var jpyFlagLabel: UILabel!
    
    @IBOutlet weak var eurSymbolLabel: UILabel!
    @IBOutlet weak var eurValueLabel: UILabel!
    @IBOutlet weak var eurFlagLabel: UILabel!
    
    
    @IBOutlet weak var baseTextBottomConstraint: NSLayoutConstraint!
    
    var defaultBottomConstraint:CGFloat?

    
    
    
    

    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1;
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return currencyArray[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return currencyArray.count
    }
    
    
    
    
    
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        let touch: UITouch? = touches.first
        if touch != baseTextField {
            dismissKeyboard();
        }
    }
    
    func dismissKeyboard() {
        view.endEditing(true)
        
        UIView.animate(withDuration: 0.5, animations: {
            self.view.layoutIfNeeded()
            self.baseTextBottomConstraint.constant = self.defaultBottomConstraint!
        })
    }

    
    func textFieldDidBeginEditing(_ textField: UITextField){
        activeField = textField
    }
    
    func textFieldDidEndEditing(_ textField: UITextField){
        activeField = nil
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadingScreen.isHidden = true;

        // Do any additional setup after loading the view, typically from a nib.
        
        // print("currencyDict has \(self.currencyDict.count) entries")
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(notification:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        defaultBottomConstraint = baseTextBottomConstraint.constant
        
        
        // create currency dictionary
        self.createCurrencyDictionary()

        // get latest currency values
        getConversionTable()
        convertValue = 1
        
        // set up last updated date
        let dateformatter = DateFormatter()
        dateformatter.dateFormat = "dd/MM/yyyy hh:mm a"
        lastUpdatedDateLabel.text = dateformatter.string(from: lastUpdatedDate)
        
        // display currency info
        self.displayCurrencyInfo()
        

        
        
        // set up base currency screen items
        //baseTextField.text = String(format: "%.02f", baseCurrency!.rate)

        // setup view mover
        baseTextField.delegate = self
    }
    
    @objc func keyboardWillShow(notification:NSNotification){
        if let info = notification.userInfo{
        let rect:CGRect = info["UIKeyboardFrameEndUserInfoKey"] as! CGRect
            
        self.view.layoutIfNeeded()
            
            UIView.animate(withDuration: 0.25, animations: {
                self.view.layoutIfNeeded()
                self.baseTextBottomConstraint.constant = rect.height - 50
            })
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func createCurrencyDictionary(){
        //let c:Currency = Currency(name: name, rate: rate!, flag: flag, symbol: symbol)!
        //self.currencyDict[name] = c

        currencyDict["GBP"] = Currency(name:"GBP", rate:1, flag:"🇬🇧", symbol: "£")
        currencyDict["USD"] = Currency(name:"USD", rate:1, flag:"🇺🇸", symbol: "$")
        currencyDict["PLN"] = Currency(name:"PLN", rate:1, flag:"🇵🇱", symbol: "zł")
        currencyDict["RUB"] = Currency(name:"RUB", rate:1, flag:"🇷🇺", symbol: "₽")
        currencyDict["CNY"] = Currency(name:"CNY", rate:1, flag:"🇨🇳", symbol: "元")
        currencyDict["JPY"] = Currency(name:"JPY", rate:1, flag:"🇯🇵", symbol: "¥")
        currencyDict["EUR"] = Currency(name:"EUR", rate:1, flag:"🇪🇺", symbol: "€")

    }
    
    func displayCurrencyInfo() {
        // GBP
        if let c = currencyDict["GBP"]{
            gbpSymbolLabel.text = c.symbol
            gbpValueLabel.text = String(format: "%.02f", c.rate)
            gbpFlagLabel.text = c.flag
        }
        //USD
        if let c = currencyDict["USD"]{
            usdSymbolLabel.text = c.symbol
            usdValueLabel.text = String(format: "%.02f", c.rate)
            usdFlagLabel.text = c.flag
        }
        //PLN
        if let c = currencyDict["PLN"]{
            plnSymbolLabel.text = c.symbol
            plnValueLabel.text = String(format: "%.02f", c.rate)
            plnFlagLabel.text = c.flag
        }
        //RUB
        if let c = currencyDict["RUB"]{
            rubSymbolLabel.text = c.symbol
            rubValueLabel.text = String(format: "%.02f", c.rate)
            rubFlagLabel.text = c.flag
        }
        //CNY
        if let c = currencyDict["CNY"]{
            cnySymbolLabel.text = c.symbol
            cnyValueLabel.text = String(format: "%.02f", c.rate)
            cnyFlagLabel.text = c.flag
        }
        //JPY
        if let c = currencyDict["JPY"]{
            jpySymbolLabel.text = c.symbol
            jpyValueLabel.text = String(format: "%.02f", c.rate)
            jpyFlagLabel.text = c.flag
        }
        if let c = currencyDict["EUR"]{
            eurSymbolLabel.text = c.symbol
            eurValueLabel.text = String(format: "%.02f", c.rate)
            eurFlagLabel.text = c.flag
        }
    }
    
    
    func getConversionTable() {
        let urlStr:String = "https://api.fixer.io/latest"
        
        var request = URLRequest(url: URL(string: urlStr)!)
        request.httpMethod = "GET"
        
        /*let indicator = UIActivityIndicatorView(activityIndicatorStyle: .gray)
        indicator.center = view.center
        view.addSubview(indicator)
        indicator.startAnimating()*/
        self.loadingScreen.isHidden = false;


        let session = URLSession.shared.dataTask(with: request) { data, response, error in

            if error == nil{
                //print(response!)
                
                do {
                    let jsonDict = try JSONSerialization.jsonObject(with: data!, options: .mutableContainers) as! [String:Any]
                    //print(jsonDict)
                    
                    if let ratesData = jsonDict["rates"] as? NSDictionary {
                        for rate in ratesData{
                            let name = String(describing: rate.key)
                            let rate = (rate.value as? NSNumber)?.doubleValue

                            
                            switch(name){
                            case "USD":
                                let c:Currency  = self.currencyDict["USD"]!
                                c.rate = rate!
                                self.currencyDict["USD"] = c
                            case "GBP":
                                let c:Currency  = self.currencyDict["GBP"]!
                                c.rate = rate!
                                self.currencyDict["GBP"] = c
                            case "PLN":
                                let c:Currency  = self.currencyDict["PLN"]!
                                c.rate = rate!
                                self.currencyDict["PLN"] = c
                            case "RUB":
                                let c:Currency  = self.currencyDict["RUB"]!
                                c.rate = rate!
                                self.currencyDict["RUB"] = c
                            case "CNY":
                                let c:Currency  = self.currencyDict["CNY"]!
                                c.rate = rate!
                                self.currencyDict["CNY"] = c
                            case "JPY":
                                let c:Currency  = self.currencyDict["JPY"]!
                                c.rate = rate!
                                self.currencyDict["JPY"] = c
                            case "EUR":
                                let c:Currency  = self.currencyDict["EUR"]!
                                c.rate = rate!
                                self.currencyDict["EUR"] = c
                            default:
                                print("Ignoring currency: \(String(describing: rate))")
                            }
                            
                            /*
                             let c:Currency = Currency(name: name, rate: rate!, flag: flag, symbol: symbol)!
                             self.currencyDict[name] = c
                             */
                        }
                        DispatchQueue.main.async {
                            self.lastUpdatedDate = Date()
                            self.convert(self)
                        }

                    }
                }
                catch let error as NSError{
                    print(error)
                }
            }
            else{
                print("Error")
            }
            
        }
        session.resume()
        
    }
    
    @IBAction func convert(_ sender: Any) {
        loadingScreen.isHidden = true;

        var resultGBP = 0.0
        var resultUSD = 0.0
        var resultPLN = 0.0
        var resultRUB = 0.0
        var resultCNY = 0.0
        var resultJPY = 0.0
        var resultEUR = 0.0
        
        baseCurrency.rate = (currencyDict[currencyArray[pickerView.selectedRow(inComponent: 0)]]?.rate)!
        
        if let currencyToConvert = Double(baseTextField.text!) {
            convertValue = currencyToConvert
            if let gbp = self.currencyDict["GBP"] {
                resultGBP = convertValue * (gbp.rate/baseCurrency.rate)
            }
            if let usd = self.currencyDict["USD"] {
                resultUSD = convertValue * (usd.rate/baseCurrency.rate)
            }
            if let pln = self.currencyDict["PLN"] {
                resultPLN = convertValue * (pln.rate/baseCurrency.rate)
            }
            if let rub = self.currencyDict["RUB"] {
                resultRUB = convertValue * (rub.rate/baseCurrency.rate)
            }
            if let cny = self.currencyDict["CNY"] {
                resultCNY = convertValue * (cny.rate/baseCurrency.rate)
            }
            if let jpy = self.currencyDict["JPY"] {
                resultJPY = convertValue * (jpy.rate/baseCurrency.rate)
            }
            if let eur = self.currencyDict["EUR"] {
                resultEUR = convertValue * (eur.rate/baseCurrency.rate)
            }
        }
        //GBP
        
        //convertedLabel.text = String(describing: resultGBP)
        
        gbpValueLabel.text = String(format: "%.02f", resultGBP)
        usdValueLabel.text = String(format: "%.02f", resultUSD)
        plnValueLabel.text = String(format: "%.02f", resultPLN)
        rubValueLabel.text = String(format: "%.02f", resultRUB)
        cnyValueLabel.text = String(format: "%.02f", resultCNY)
        jpyValueLabel.text = String(format: "%.02f", resultJPY)
        eurValueLabel.text = String(format: "%.02f", resultEUR)

    }
    
    
    @IBAction func refresh(_ sender: Any) {
        getConversionTable()
    }
    
    

    /*
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     
     }
     */
    
    
}

