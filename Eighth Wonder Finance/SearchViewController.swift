//
//  SearchViewController.swift
//  Eighth Wonder Finance
//
//  Created by Joshua Harris on 11/6/21.
//

import UIKit

class SearchViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate {

    

    
    @IBOutlet var searchBarField: UITextField!
    @IBOutlet weak var searchTableView: UITableView!
    
    var symbols:[String] = Array()
    var originalSymbols:[String] = Array()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        symbols.append("MSFT")
        symbols.append("AAPL")
        symbols.append("AMZN")
        symbols.append("TSLA")
        
        for symbol in symbols {
            originalSymbols.append(symbol)
        }
        
        // Do any additional setup after loading the view.
        searchBarField.backgroundColor = .white
        searchTableView.delegate = self
        searchBarField.delegate = self
        searchTableView.dataSource = self
        searchBarField.addTarget(self, action: #selector(searchRecords(_ :)), for: .editingChanged)
        
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        searchBarField.resignFirstResponder()
        return true
    }
    
    @objc func searchRecords(_ textField: UITextField) {
        self.symbols.removeAll()
        if textField.text?.count != 0 {
            for symbol in originalSymbols {
                if let symbolToSearch = textField.text {
                    let range = symbol.uppercased().range(of: symbolToSearch, options: .caseInsensitive, range: nil, locale: nil)
                    if range != nil {
                        self.symbols.append(symbol)
                    }
                }
            }
        } else {
            for symbol in originalSymbols {
                symbols.append(symbol)
            }
        }
        searchTableView.reloadData()
    }
    
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return symbols.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: "symbol")
        if cell == nil {
            cell = UITableViewCell(style: .default, reuseIdentifier: "symbol")
        }
        
        cell?.textLabel?.text = symbols[indexPath.row]
        return cell!
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let tradeViewController = self.storyboard?.instantiateViewController(withIdentifier: "TradeView") as! TradeViewViewController
        tradeViewController.symbol = symbols[indexPath.row]
        self.navigationController?.pushViewController(tradeViewController, animated: true)
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
