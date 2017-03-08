//
//  ViewController.swift
//  CrystalBallApp
//
//  Created by Kalyani on 15/02/17.
//  Copyright © 2017 Apple Inc. All rights reserved.
//

import UIKit
import CoreData

class LoginController: UIViewController {
    
    @IBOutlet weak var userName: UITextField!
    
    
    @IBOutlet weak var password: UITextField!
    
    
    @IBOutlet weak var userNameLabel: UILabel!
    
    
    @IBOutlet weak var passwordLabel: UILabel!
    
    
    let VERIFY_CREDENTIALS_URL = "http://10.0.1.210:8080/MaasOauthServer/rest/oauth/verifyCredentials"
    
    let LINKED_ALL_APPLICATIONS_STORYBOARD_ID = "LinkedAppID"
    
    let JOIN_NOW_STORYBOARD_ID = "JoinNowID"
    
    let IP_SETTINGS_STORYBOARD_ID = "IPAddressID"
    
    let FIRST_WALKTHROUGH_SCREEN_STORYBOARD_ID = "FirstWalkThroughID"
    
    let HOST_SERVER_IP = "121.241.184.234"
    
    let HOST_SERVER_PORT = "8080"
    
    var ipAddress = ""
    
    var portNo = ""
    
    var selectedApplicationInSignIn = ""
    
    var cbUser: [CBUser] = []
    
    var allUsersOfCoreData = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("login ipaddress--\(ipAddress)")
        print("login port--\(portNo)")
        print("selected app \(selectedApplicationInSignIn)")
        
        
        
    }
    
    @IBAction func joinNowBtnPressed(_ sender: Any) {
        
        OperationQueue.main.addOperation
            {
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                let viewController = storyboard.instantiateViewController(withIdentifier : self.JOIN_NOW_STORYBOARD_ID) as! JoinNowController
                self.present(viewController, animated: true)
                
        }
        
        
    }
    func checkIPStatus() -> Bool
    {
        var ipStatus: Bool? = false
        if self.ipAddress == self.HOST_SERVER_IP , self.portNo == self.HOST_SERVER_PORT
        {
            ipStatus = true
        }
        
        return ipStatus!
    }
    
    @IBAction func arrowBtnPressed(_ sender: Any) {
        
        OperationQueue.main.addOperation
            {
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                let viewController = storyboard.instantiateViewController(withIdentifier : self.FIRST_WALKTHROUGH_SCREEN_STORYBOARD_ID) as! FirstWalkThroughController
                self.present(viewController, animated: true)
                
        }
        
    }
    
    
    
    @IBAction func signInBtnPressed(_ sender: Any) {
        
        
        // ----------------POST REQUEST---------------------
        
        let userNameFromCoreData = getUserNameFromCoreData(loginUser: userName.text!)
        print("get username from core data ----\(userNameFromCoreData))")
        
        
        if(userNameFromCoreData.contains(userName.text!))
        {
            print("user found")
            
        }
        else
        {
            print("user not found")
        }
        
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
                    if self.ipAddress == "" , self.portNo == ""
                    {
                        self.ipAddress = self.HOST_SERVER_IP
                        self.portNo = self.HOST_SERVER_PORT
                    }
                    print("ip \( self.ipAddress)")
                    print("port \( self.portNo)")
                    if self.checkIPStatus()
                    {
                        if(statusCode == 201)
                        {
                            ///Convert data into JSON format
                            var jsonObject : [Any]?
                            jsonObject = try! JSONSerialization.jsonObject(with: data) as? [Any]
                            
                            
                            if (userNameFromCoreData.contains(self.userName.text!) == false)
                            {
                                
                                
                                // receive data after web service call
                                if let jsonDict = jsonObject?.first as? [String:Any] {
                                    
                                    if let applicationName = jsonDict["applicationName"] as?  String {
                                        
                                        print("app----\(applicationName)")
                                        // save received post data into database
                                        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
                                        let userDetails = CBUser (context: context)
                                        userDetails.cbUsername = self.userName.text!
                                        userDetails.applicationName = applicationName
                                        
                                        // save the data to coredata
                                        
                                        (UIApplication.shared.delegate as! AppDelegate).saveContext()
                                    }
                                }
                                    
                                else{
                                    print("error in getting application name from  web services")
                                }
                            }
                            
                            
                            
                            
                            
                            OperationQueue.main.addOperation
                                {
                                    let storyboard = UIStoryboard(name: "Main", bundle: nil)
                                    let viewController = storyboard.instantiateViewController(withIdentifier : self.LINKED_ALL_APPLICATIONS_STORYBOARD_ID) as! LinkedApplicationsController
                                    if let jsonDict = jsonObject?.first as? [String:Any] {
                                        
                                        if let activationCode = jsonDict["activationCode"] as?  String {
                                            
                                            viewController.activationcode = activationCode
                                        }
                                        if let linkedAppName = jsonDict["applicationName"] as?  String {
                                            
                                            viewController.appNameFromWebServices = linkedAppName
                                        }
                                    }
                                    else{
                                        print("error in getting activation code from  web services")
                                    }
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
                                    // Background color.
                                    let FirstSubview = alert.view.subviews.first
                                    let AlertContentView = FirstSubview?.subviews.first
                                    for subview in (AlertContentView?.subviews)! {
                                        subview.backgroundColor = UIColor(red: 0.1098, green: 0.2863, blue: 0.4431, alpha: 1.0)
                                        subview.layer.cornerRadius = 10
                                        subview.alpha = 1
                                        subview.layer.borderWidth = 1
                                        subview.layer.borderColor = UIColor(red: 0.1098, green: 0.2863, blue: 0.4431, alpha: 1.0).cgColor
                                    }
                                    //change message color
                                    let myString  = "Incorrect username or password"
                                    var myMutableString = NSMutableAttributedString()
                                    myMutableString = NSMutableAttributedString(string: myString as String, attributes: [NSFontAttributeName:UIFont(name: "Georgia", size: 12.0)!])
                                    myMutableString.addAttribute(NSForegroundColorAttributeName, value: UIColor.white, range: NSRange(location:0,length:myString.characters.count))
                                    alert.setValue(myMutableString, forKey: "attributedMessage")
                                    self.present(alert, animated: true, completion: nil)
                                    
                            }
                        }
                    }
                        
                        //
                    else
                    {
                        OperationQueue.main.addOperation
                            {
                                let ipAddressAlert = UIAlertController(title: "", message: "Could not connect to the server. Please try again.", preferredStyle: UIAlertControllerStyle.alert)
                                ipAddressAlert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
                                // change background color.
                                let FirstSubview = ipAddressAlert.view.subviews.first
                                let AlertContentView = FirstSubview?.subviews.first
                                for subview in (AlertContentView?.subviews)! {
                                    subview.backgroundColor = UIColor(red: 0.1098, green: 0.2863, blue: 0.4431, alpha: 1.0)
                                    subview.layer.cornerRadius = 10
                                    subview.alpha = 1
                                    subview.layer.borderWidth = 1
                                    subview.layer.borderColor = UIColor(red: 0.1098, green: 0.2863, blue: 0.4431, alpha: 1.0).cgColor
                                }
                                //change message color
                                let myString  = "Could not connect to the server. Please try again."
                                var myMutableString = NSMutableAttributedString()
                                myMutableString = NSMutableAttributedString(string: myString as String, attributes: [NSFontAttributeName:UIFont(name: "Georgia", size: 12.0)!])
                                myMutableString.addAttribute(NSForegroundColorAttributeName, value: UIColor.white, range: NSRange(location:0,length:myString.characters.count))
                                ipAddressAlert.setValue(myMutableString, forKey: "attributedMessage")
                                self.present(ipAddressAlert, animated: true, completion: nil)
                        }
                        
                        
                    }
                }
            }
            task.resume()
        }
    }
    func getUserNameFromCoreData(loginUser : String) -> NSArray
    {
        var username : String = ""
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        do
        {
            let request : NSFetchRequest<CBUser> = CBUser.fetchRequest()
            
            let dataPredicate = NSPredicate(format: "cbUsername == %@", loginUser)
            
            
            request.predicate = dataPredicate
            
            cbUser  = try context.fetch(request)
            
            for userDetails in cbUser as [NSManagedObject] {
                //get the Key Value pairs (although there may be a better way to do that...
                username = userDetails.value(forKey: "cbUsername") as! String
                allUsersOfCoreData.append(username)
            }
            
        }
        catch
        {
            print("Fetching user name failed")
        }
        return allUsersOfCoreData as NSArray
    }
    
}



