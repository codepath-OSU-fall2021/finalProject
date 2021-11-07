//
//  TradeViewViewController.swift
//  Eighth Wonder Finance
//
//  Created by Joshua Harris on 10/27/21.
//

import UIKit
import Parse

class TradeViewViewController: UIViewController, UITextFieldDelegate {
    struct StockInfo : Codable {
        var symbol: String
        var companyName: String
        var latestPrice: Float
        var marketCap: Int
        var changePercent: Float
        
        enum CodingKeys: String, CodingKey {
            case symbol
            case companyName
            case latestPrice
            case marketCap
            case changePercent
        }
    }
    
    var numberOfShares: Int = 0
    var sharePrice: Float = 0
    var symbol: String = "MSFT"
    var user: PFObject? = nil

    @IBOutlet weak var balanceLabel: UILabel!
    @IBOutlet weak var numberOfSharesInput: UITextField!
    @IBOutlet weak var shareDisplayLabel: UILabel!
    @IBOutlet weak var confirmButton: UIButton!
    @IBOutlet weak var totalPriceLabel: UILabel!
    @IBOutlet weak var symbolLabel: UILabel!
    
    @IBAction func onConfirm(_ sender: Any) {
        let totalPrice = Float(numberOfShares) * sharePrice
        let roundedPrice = round(totalPrice * 100) / 100.0
        let query = PFQuery(className: "Stock")
        query.whereKey("user", equalTo: user)
        query.whereKey("symbol", equalTo: symbol)
        query.findObjectsInBackground { (objects: [PFObject]?, error: Error?) in
            if let error = error {
                // Log details of the failure
                print(error.localizedDescription)
            } else if let objects = objects {
                // The find succeeded.
                print("Successfully retrieved \(objects.count) stocks.")
                // Do something with the found objects
                if objects.count == 0 {
                    let stock = PFObject(className: "Stock")
                    stock["symbol"] = self.symbol
                    stock["quantityHeld"] = self.numberOfShares
                    stock["amountSpent"] = roundedPrice
                    stock["user"] = self.user
                    stock.saveInBackground { (success, error) in
                        if (success) {
                            let startBalance = self.user!["balance"] as! Float
                            self.user!["balance"] = startBalance - roundedPrice
                            self.user!.add(stock, forKey: "stocks")
                            self.user?.saveInBackground { (sucess, error) in
                                if (success) {
                                    print("User saved")
                                    self.refreshBalance()
                                } else {
                                    print(error?.localizedDescription)
                                }
                            }
                        } else {
                            print(error?.localizedDescription)
                        }
                    }
                } else if objects.count == 1 {
                    let stockToUpdate = objects[0]
                    stockToUpdate["quantityHeld"] = stockToUpdate["quantityHeld"] as! Int + self.numberOfShares
                    stockToUpdate["amountSpent"] = stockToUpdate["amountSpent"] as! Float + roundedPrice
                    stockToUpdate.saveInBackground { (success, error) in
                        if (success) {
                            let startBalance = self.user!["balance"] as! Float
                            self.user!["balance"] = startBalance - roundedPrice
                            self.user?.saveInBackground { (sucess, error) in
                                if (success) {
                                    print("User saved")
                                    self.refreshBalance()
                                } else {
                                    print(error?.localizedDescription)
                                }
                            }
                        } else {
                            print(error?.localizedDescription)
                        }
                    }
                } else {
                    print("Some error, user has two or more stocks of the same symbol")
                }
            }
        }
    }
    
    func refreshBalance() {
        if self.user == nil {
            return
        }
        
        let balance = self.user?["balance"] as! Float
        let roundedBalance = round(balance * 100) / 100.0
        let formattedBalance = formatAsCurrency(dollarAmount: roundedBalance)
        balanceLabel.text = "Balance: \(formattedBalance)"
        
    }
    
    @IBAction func onShareQuantityChange(_ sender: Any) {
        let nShares: Int? = Int(numberOfSharesInput.text!)
        if nShares != nil {
            self.numberOfShares = nShares!
            handleQuantityChange()
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == numberOfSharesInput{
            textField.resignFirstResponder()
            return false
        }
        return true
    }
    
    func handleQuantityChange() {
        let totalPrice = Float(self.numberOfShares) * self.sharePrice
        let roundedPrice = round(totalPrice * 100) / 100
        let formattedPrice = formatAsCurrency(dollarAmount: roundedPrice)
        totalPriceLabel.text = "Total price: \(formattedPrice)"
        
    }
    
    func handleStockInfo(stockArray: StockInfo) -> Void {
        sharePrice = stockArray.latestPrice
        let roundedPrice = round(sharePrice * 100) / 100
        let formattedPrice = formatAsCurrency(dollarAmount: roundedPrice)
        shareDisplayLabel.text = "Price per share: \(formattedPrice)"
    }
    
    func getStockQuote(successCallback: @escaping (StockInfo) -> ()) {
        // https://learnappmaking.com/urlsession-swift-networking-how-to/
        let url = URL(string: "https://cloud.iexapis.com/stable/stock/\(symbol)/quote?token=pk_246252e7872a41e4bb86d8c546d5e510")!
        let session = URLSession(configuration: .default, delegate: nil, delegateQueue: OperationQueue.main)
        
        let task = session.dataTask(with: url) { data, response, error in
            if error != nil {
                print("Error: \(error)")
                return
            }
            guard let httpResponse = response as? HTTPURLResponse,
                  (200...299).contains(httpResponse.statusCode) else {
                print("Bad http response code")
                return
            }
            guard let mime = response?.mimeType, mime == "application/json" else {
                print("Wrong MIME type!")
                return
            }
            do {
                let stockResponse = try JSONDecoder().decode(StockInfo.self, from: data!) as StockInfo
                successCallback(stockResponse)
            } catch {
                print("JSON error: \(error.localizedDescription)")
            }

        }
        task.resume()
    }

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        numberOfSharesInput.backgroundColor = .white
        self.numberOfSharesInput.delegate = self
        
        self.symbolLabel.text = self.symbol

        let user = PFUser.current()
        
        if user != nil {
            do {
                let query = try PFQuery.getUserObject(withId: user!.objectId!)
                self.user = query
            } catch {
                print(error)
            }
        }
        if symbol != "" {
            getStockQuote(successCallback: handleStockInfo)
        }
        
        refreshBalance()
        // Do any additional setup after loading the view.
    }
    
    func formatAsCurrency(dollarAmount: Float) -> String {
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .currency
        let formatedNumber = numberFormatter.string(from: NSNumber(value: dollarAmount))
        
        return formatedNumber!
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
