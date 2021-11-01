//
//  ResearchDetailViewController.swift
//  Eighth Wonder Finance
//
//  Created by James Lipe on 10/29/21.
//

import UIKit
import AlamofireImage

class ResearchDetailViewController: UIViewController {
    
    struct Logo : Codable {
        var url: String
        
        enum CodingKeys: String, CodingKey {
            case url
        }
    }
    
    struct CompanyInfo : Codable {
        var description: String
        var website: String
        
        enum CodingKeys: String, CodingKey {
            case description
            case website
        }
    }

    var companyNameToDisplay = ""
    var companySymbol = ""
    var companyLogoURL = ""
    
    
    @IBOutlet weak var websiteLink: UITextView!
    @IBOutlet weak var companyNameLabel: UILabel!
    @IBOutlet weak var companyLogoImage: UIImageView!
    @IBOutlet weak var companyDescriptionView: UITextView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        websiteLink.isEditable = false
        websiteLink.dataDetectorTypes = UIDataDetectorTypes.all
        companyNameLabel.text = companyNameToDisplay
        getLogoUrl(symbol: companySymbol)
        getCompanyInfo(symbol: companySymbol)
    }
    
    func getCompanyInfo(symbol: String) {
        let url = URL(string: "https://cloud.iexapis.com/stable/stock/\(symbol)/company?token=pk_246252e7872a41e4bb86d8c546d5e510")!
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
                let infoResponse = try JSONDecoder().decode(CompanyInfo.self, from: data!) as CompanyInfo
                self.companyDescriptionView.text = infoResponse.description
                self.websiteLink.text = infoResponse.website
//                self.companyLogoURL = infoResponse.url
//                let url = URL(string: self.companyLogoURL)
//                if url == nil {
//                    return
//                } else {
//                    self.companyLogoImage.af.setImage(withURL: url!)
//                }
            } catch {
                print("JSON error: \(error.localizedDescription)")
            }

        }
        task.resume()
    }
    
    func getLogoUrl(symbol: String) {
        let url = URL(string: "https://cloud.iexapis.com/stable/stock/\(symbol)/logo?token=pk_246252e7872a41e4bb86d8c546d5e510")!
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
                let stockResponse = try JSONDecoder().decode(Logo.self, from: data!) as Logo
                self.companyLogoURL = stockResponse.url
                let url = URL(string: self.companyLogoURL)
                if url == nil {
                    return
                } else {
                    self.companyLogoImage.af.setImage(withURL: url!)
                }
            } catch {
                print("JSON error: \(error.localizedDescription)")
            }

        }
        task.resume()
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