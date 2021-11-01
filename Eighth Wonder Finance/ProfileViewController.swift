//
//  ProfileViewController.swift
//  Eighth Wonder Finance
//
//  Created by Joshua Harris on 10/27/21.
//

import UIKit
import Parse
import AlamofireImage

class ProfileViewController: UIViewController {

    
    @IBOutlet weak var darkmodeSegControl: UISegmentedControl!
    
    @IBOutlet weak var usernameLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        usernameLabel.text = PFUser.current()?.username
        // Do any additional setup after loading the view.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

    
  
    @IBAction func onDarkModeSegControl(_ sender: Any) {
        // toggle dark mode segmented control
        // FYI - currently only changes profile tab
        // figured out how to apply it to window similar to logout
        // but, right now it doesn't persist. to be researched I think
        // persistence has to do with @appdata, but I need to look into this.
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let delegate = windowScene.delegate as? SceneDelegate else { return }
        
        switch darkmodeSegControl.selectedSegmentIndex
        {
        case 0:
            print("Light")
            delegate.window?.overrideUserInterfaceStyle = .light
        case 1:
            print("Dark")
            delegate.window?.overrideUserInterfaceStyle = .dark
        default:
            break
        }
        
    }
    
    
    @IBAction func onLogoutButton(_ sender: Any) {
        // logout
        print("Logout pressed")
        
        let refreshAlert = UIAlertController(title: "Log Out?", message: "Are you sure you want to log out?", preferredStyle: UIAlertController.Style.alert)
        
        refreshAlert.addAction(UIAlertAction(title: "Yes", style: .default,
                                             handler: {(action: UIAlertAction!) in
            print("User pressed yes")
            // log out
            PFUser.logOut()
            
            let main = UIStoryboard(name: "Main", bundle: nil)
            let loginViewController = main.instantiateViewController(withIdentifier: "LoginViewController")
            guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                  let delegate = windowScene.delegate as? SceneDelegate else { return }
            
            delegate.window?.rootViewController = loginViewController
            
        }))
        refreshAlert.addAction(UIAlertAction(title: "No", style: .cancel,
                                             handler: {(action: UIAlertAction!) in
            print("User pressed no")
        }))
        
        present(refreshAlert, animated: true, completion: nil)
    }
    
    @IBAction func onResetButton(_ sender: Any) {
        // reset cash to deafault value, and remove all transcations/holdings
        print("Reset button clicked")
        let refreshAlert = UIAlertController(title: "Restart Game?",
                                             message: "Are you sure you want to restart the game?",preferredStyle: UIAlertController.Style.alert)
        
        refreshAlert.addAction(UIAlertAction(title: "Yes", style: .default,
                                             handler: {(action: UIAlertAction!) in
            print("User pressed yes")
            // add code to reset
        }))
        refreshAlert.addAction(UIAlertAction(title: "No", style: .cancel,
                                             handler: {(action: UIAlertAction!) in
            print("User pressed no")
        }))
        
        present(refreshAlert, animated: true, completion: nil)
        
    }
    
    
}