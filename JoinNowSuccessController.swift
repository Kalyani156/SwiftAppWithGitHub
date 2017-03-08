//
//  JoinNowSuccessController.swift
//  CrystalBallApp
//
//  Created by Kalyani on 28/02/17.
//  Copyright © 2017 Apple Inc. All rights reserved.
//

import UIKit

class JoinNowSuccessController: UIViewController {

    
    @IBOutlet weak var usernameLabel: UILabel!
    
    
    @IBOutlet weak var passwordLabel: UILabel!
    
    @IBOutlet weak var selectedApplicationLabel: UILabel!
    
    var username = ""
    
    var password = ""
    
    var selectedApplication = ""
    
     let SIGN_IN_STORYBOARD_ID = "SignInID"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        usernameLabel.text = username
        passwordLabel.text = password
        selectedApplicationLabel.text = selectedApplication
        // Do any additional setup after loading the view.
    }

  
    @IBAction func signInBtnPressed(_ sender: Any) {
        
        OperationQueue.main.addOperation
            {
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                let viewController = storyboard.instantiateViewController(withIdentifier : self.SIGN_IN_STORYBOARD_ID) as! LoginController
//                  viewController.selectedApplicationInSignIn =  self.selectedApplicationLabel.text!
                      self.present(viewController, animated: true)
                
        }
    }

}
