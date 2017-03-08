//
//  FirstWalkThroughController.swift
//  CrystalBallApp
//
//  Created by Kalyani on 22/02/17.
//  Copyright © 2017 Apple Inc. All rights reserved.
//

import UIKit

class FirstWalkThroughController: UIViewController {
   
    @IBOutlet weak var userName: UITextField!
    
    @IBOutlet weak var password: UITextField!
    
    @IBOutlet weak var userNameLabel: UILabel!    
    
    @IBOutlet weak var passwordLabel: UILabel!
    
    
    let VERIFY_CREDENTIALS_URL = "http://10.0.1.210:8080/MaasOauthServer/rest/oauth/verifyCredentials"
    
    let LINKED_ALL_APPLICATIONS_STORYBOARD_ID = "LinkedAppID"
    
    let JOIN_NOW_STORYBOARD_ID = "JoinNowID"
    
    let SECOND_WALKTHROUGH_SCREEN_STORYBOARD_ID = "SecondWalkThroughID"
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

  
    @IBAction func arrowBtnPressed(_ sender: Any) {
        OperationQueue.main.addOperation
            {
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                let viewController = storyboard.instantiateViewController(withIdentifier : self.SECOND_WALKTHROUGH_SCREEN_STORYBOARD_ID) as! SecondWalkThroughController
                self.present(viewController, animated: true)
                
        }
        
    }

    @IBAction func joinNowBtnPressed(_ sender: Any) {
        
        OperationQueue.main.addOperation
            {
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                let viewController = storyboard.instantiateViewController(withIdentifier : self.JOIN_NOW_STORYBOARD_ID) as! JoinNowController
                self.present(viewController, animated: true)
                
        }
    }
 
    @IBAction func signInBtnPressed(_ sender: Any) {
        
        // ----------------POST REQUEST---------------------
        
        print("\(userName.text!)")
        print("\(password.text!)")
        if userName.text! == ""  {
            userNameLabel.text = "User Name can not be blank!"
            userNameLabel.textColor = UIColor.red
        }
        else  if  password.text! == "" {
            passwordLabel.text = "Password can not be blank!"
            passwordLabel.textColor = UIColor.red
        }
        else
        {
            userNameLabel.text = ""
            passwordLabel.text = ""
            let jsonLoginParams = ["username":"\(userName.text!)" , "password":"\(password.text!)"]
            let jsonData = try! JSONSerialization.data(withJSONObject: jsonLoginParams, options: .prettyPrinted)
            var request = URLRequest(url: URL(string: VERIFY_CREDENTIALS_URL)!)
            request.httpMethod = "POST"
            request.httpBody = jsonData
            request.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
            let task = URLSession.shared.dataTask(with: request) { data, response, error in
                guard let data = data, error == nil else {                                                 // check for fundamental networking error
                    print("error=\(error)")
                    return
                }
                
                if let httpStatus = response as? HTTPURLResponse, httpStatus.statusCode != 200 {           // check for http errors
                    print("statusCode should be 200, but is \(httpStatus.statusCode)")
                    print("response = \(response)")
                }
                
                let responseString = String(data: data, encoding: .utf8)
                print("responseString = ----------\(responseString)")
                
                if let httpResponse = response as? HTTPURLResponse {
                    print("status code@@@@@@@@@@@@@-------------\(httpResponse.statusCode)")
                    let statusCode = httpResponse.statusCode
                    if(statusCode == 201)
                    {
                        
                        OperationQueue.main.addOperation
                            {
                                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                                let viewController = storyboard.instantiateViewController(withIdentifier : self.LINKED_ALL_APPLICATIONS_STORYBOARD_ID) as! LinkedApplicationsController
                                //set login user name in menu bar welcome label
                                viewController.loginUserName = self.userName.text!
                                self.present(viewController, animated: true)
                                
                        }
                        
                    }
                    else if statusCode == 401
                    {
                        OperationQueue.main.addOperation
                            {
                                let alert = UIAlertController(title: "", message: "Incorrect username or password", preferredStyle: UIAlertControllerStyle.alert)
                                alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
                                self.present(alert, animated: true, completion: nil)
                        }
                    }
                }
            }
            task.resume()
        }
    }
}
