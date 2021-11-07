//
//  ResearchViewController.swift
//  Eighth Wonder Finance
//
//  Created by James Lipe on 10/27/21.
//

import UIKit
import AlamofireImage

class ResearchViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
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
    
    struct Logo : Codable {
        var url: String
        
        enum CodingKeys: String, CodingKey {
            case url
        }
    }
    
    var stocks: [StockInfo] = []
    
    @IBOutlet weak var tableView: UITableView!
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return stocks.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let stock = stocks[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "ResearchStockCell") as! ResearchStockCell
        cell.stockName.text = stock.companyName
        cell.currentPrice.text = "Current Price: $\(stock.latestPrice)"
        let percentChange = abs(Float(stock.changePercent) * 100)
        let roundedChange = round(percentChange * 100) / 100.0
        cell.percentChange.text = "\(roundedChange)%"
        if Float(stock.changePercent) < 0 {
            cell.percentChange.textColor = UIColor.systemRed
        } else {
            cell.percentChange.textColor = UIColor.systemGreen
        }
        
        // Logo
        let url = URL(string: "https://cloud.iexapis.com/stable/stock/\(stock.symbol)/logo?token=pk_246252e7872a41e4bb86d8c546d5e510")!
        print(url)
        let request = URLRequest(url: url, cachePolicy: .reloadIgnoringLocalCacheData, timeoutInterval: 10)
        let session = URLSession(configuration: .default, delegate: nil, delegateQueue: OperationQueue.main)
        let task = session.dataTask(with: request) { (data, response, error) in
            // This runs when network request returns
            if let error = error {
                print(error.localizedDescription)
            } else if let data = data {
                let dataDictionary = try! JSONSerialization.jsonObject(with: data, options: []) as! [String: Any]
                print(dataDictionary)
                
                let urlPath = dataDictionary["url"] as? String
                if (urlPath != nil) && (urlPath != "") {
                    let logoURL = URL(string: urlPath!)
                    cell.stockLogo.af.setImage(withURL: logoURL!)
                } else {
                    // No logo
                }
            }
        }
        task.resume()
        return cell
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "researchDetailSegue" {
            let destination = segue.destination as! ResearchDetailViewController
            let indexPath = tableView.indexPathForSelectedRow!
            let selectedStock = stocks[indexPath.row] as StockInfo
            destination.companyNameToDisplay = selectedStock.companyName
            destination.companySymbol = selectedStock.symbol
            
//            getLogo(symbol: selectedStock.symbol)
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    
    func getStockInfo(successCallback: @escaping ([StockInfo]) -> ()) {
        // https://learnappmaking.com/urlsession-swift-networking-how-to/
        let url = URL(string: "https://cloud.iexapis.com/stable/stock/market/list/mostactive?token=pk_246252e7872a41e4bb86d8c546d5e510")!
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
                let stockResponse = try JSONDecoder().decode([StockInfo].self, from: data!) as [StockInfo]
//                print(stockResponse)
                successCallback(stockResponse)
            } catch {
                print("JSON error: \(error.localizedDescription)")
            }

        }
        task.resume()
    }
    
    func handleStockInfo(stockArray: [StockInfo]) -> Void {
        stocks = stockArray
        tableView.reloadData()
    }
    
    override func viewDidLoad() {
        // Do any additional setup after loading the view.
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        getStockInfo(successCallback: handleStockInfo)
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
