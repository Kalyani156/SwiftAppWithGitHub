//
//  JoinNowController.swift
//  CrystalBallApp
//
//  Created by Kalyani on 20/02/17.
//  Copyright © 2017 Apple Inc. All rights reserved.
//

import UIKit
import CoreData
class JoinNowController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource, UITextFieldDelegate  {
    
    
    @IBOutlet weak var email: UITextField!
     
    @IBOutlet weak var mobileNo: UITextField!
    
    @IBOutlet weak var password: UITextField!
    
    @IBOutlet weak var emailLabel: UILabel!
    
    @IBOutlet weak var mobileNoLabel: UILabel!
    
    @IBOutlet weak var passwordLabel: UILabel!
    
    let REGISTER_USER_URL = "http://10.0.1.210:8080/MaasOauthServer/rest/oauth/registerUser"
    
    let JOIN_NOW_SUCCESS_STORYBOARD_ID = "JoinNowSuccessID"
    
    var userEntryNumber : Int32 = 0
    
    @IBOutlet weak var selectApplication: UITextField!
    @IBOutlet weak var signInBtn: UIButton!
    @IBOutlet weak var dropDown: UIPickerView!
    let LINKED_APPLICATIONS_URL = "http://10.0.1.210:8080/MaasOauthServer/rest/oauth/getAllApplications"
    let SIGN_IN_STORYBOARD_ID = "SignInID"
    var firstApplication: String?
    var secondApplication: String?
    var thirdApplication: String?
    var fourthApplication: String?
    var allAplications:[String] = []
    var dropDownValues = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.selectApplication.delegate = self
        self.dropDown.delegate = self
        self.dropDown.dataSource = self
        getAllCrystalBallLinkedApplications()
        self.dropDown.showsSelectionIndicator = false
        highlightButton(button: signInBtn)
        dropDown.isHidden = true
    }
    
    
    
    @IBAction func signInBtnPressed(_ sender: Any) {
        OperationQueue.main.addOperation
            {
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                let viewController = storyboard.instantiateViewController(withIdentifier : self.SIGN_IN_STORYBOARD_ID) as! LoginController
                self.present(viewController, animated: true)
                
        }
        
        
    }
    
    // Web Services to get all applications
    func getAllCrystalBallLinkedApplications(){
        var request = URLRequest(url: URL(string: LINKED_APPLICATIONS_URL)!)
        request.httpMethod = "POST"
        let postString = " "
        request.httpBody = postString.data(using: .utf8)
        
        let  task = URLSession.shared.dataTask(with: request) { data, response, error in
            // do stuff with response, data & error here
            
            ///Convert data into JSON format
            let jsonObject = try? JSONSerialization.jsonObject(with: data!, options: .allowFragments)
            
            
            if let jsonDict = jsonObject as? NSDictionary {
                if let firstApplicationNumbers = jsonDict["1"] as? NSDictionary {
                    if let firstApp = firstApplicationNumbers["_id"] as? String {
                        self.firstApplication = firstApp
                        self.allAplications.append(firstApp)
                    }
                }
                if let secondApplicationNumbers = jsonDict["2"] as? NSDictionary {
                    if let secondApp = secondApplicationNumbers["_id"] as? String {
                        self.secondApplication = secondApp
                        self.allAplications.append(secondApp)
                    }
                }
                if let thirdApplicationNumbers = jsonDict["3"] as? NSDictionary {
                    if let thirdApp = thirdApplicationNumbers["_id"] as? String {
                        self.thirdApplication = thirdApp
                        self.allAplications.append(thirdApp)
                    }
                }
                if let fourthApplicationNumbers = jsonDict["4"] as? NSDictionary {
                    if let fourthApp = fourthApplicationNumbers["_id"] as? String {
                        self.fourthApplication = fourthApp
                        self.allAplications.append(fourthApp)
                        
                    }
                }
                DispatchQueue.main.async {
                    self.dropDownValues = self.allAplications
                    
                    DispatchQueue.main.async{
                        self.dropDown.reloadAllComponents()
                    }
                }
            }
        }
        task.resume()
    }
    
    func highlightButton(button: UIButton) {
        button.setTitleColor(UIColor.blue, for: UIControlState.highlighted)
    }
    public func numberOfComponents(in pickerView: UIPickerView) -> Int{
        return 1
        
    }
    
    public func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int{
        
        return dropDownValues.count
        
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        
        self.view.endEditing(true)
        return dropDownValues[row]
        
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        
        self.selectApplication.text = self.dropDownValues[row]
        self.dropDown.isHidden = true
        
        
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        
        if textField == self.selectApplication {
            self.dropDown.isHidden = false
            //if you dont want the users to se the keyboard type:
            
            textField.endEditing(true)
        }
    }
    
    
    @IBAction func joinNowBtnPressed(_ sender: Any) {
        
         userEntryNumber = userEntryNumber + 1
        // save received post data into database
         let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        
        let userDetails = CBUser (context: context)
         userDetails.entryNumber = self.userEntryNumber
        userDetails.cbUsername = email.text!
        userDetails.applicationName = self.selectApplication.text!
        
        // save the data to coredata
        (UIApplication.shared.delegate as! AppDelegate).saveContext()
        
        // ----------------POST REQUEST---------------------
        
       // let loginController = LoginController()
        print("\(email.text!)")
        print("\(mobileNo.text!)")
        if email.text! == ""  {
            emailLabel.text = "Email can not be blank!"
            emailLabel.textColor = UIColor.red
        }
        else  if  mobileNo.text! == "" {
            mobileNoLabel.text = "Mobile number can not be blank!"
            mobileNoLabel.textColor = UIColor.red
        }
        else  if  password.text! == "" {
            passwordLabel.text = "password can not be blank!"
            passwordLabel.textColor = UIColor.red
        }
        else
        {
            emailLabel.text = ""
            mobileNoLabel.text = ""
            passwordLabel.text = ""
            let jsonLoginParams = ["email":"\(email.text!)" , "mobileNo":"\(mobileNo.text!)" ,  "password":"\(password.text!)"]
            let jsonData = try! JSONSerialization.data(withJSONObject: jsonLoginParams, options: .prettyPrinted)
            var request = URLRequest(url: URL(string: REGISTER_USER_URL)!)
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
                    // Check IP Status
                   // if loginController.checkIPStatus()
                   // {
                    
                    if(statusCode == 201)
                    {
                       //  let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
                        OperationQueue.main.addOperation
                            {
                                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                                let viewController = storyboard.instantiateViewController(withIdentifier : self.JOIN_NOW_SUCCESS_STORYBOARD_ID) as! JoinNowSuccessController
                                //set login user name , selected application and password in join now success controller
                                viewController.username = self.email.text!
                                viewController.selectedApplication =  self.selectApplication.text!
                                viewController.password = self.password.text!
                                self.present(viewController, animated: true)
                                
                        }
                        
                    }
                    else if statusCode == 401
                    {
                        OperationQueue.main.addOperation
                            {
                                let ipAddressAlert = UIAlertController(title: "", message: "User already exist", preferredStyle: UIAlertControllerStyle.alert)
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
                                let myString  = "User already exist"
                                var myMutableString = NSMutableAttributedString()
                                myMutableString = NSMutableAttributedString(string: myString as String, attributes: [NSFontAttributeName:UIFont(name: "Georgia", size: 12.0)!])
                                myMutableString.addAttribute(NSForegroundColorAttributeName, value: UIColor.white, range: NSRange(location:0,length:myString.characters.count))
                                ipAddressAlert.setValue(myMutableString, forKey: "attributedMessage")
                                self.present(ipAddressAlert, animated: true, completion: nil)
                        }
                    }
                    }
//                    else
//                    {
//                        OperationQueue.main.addOperation
//                            {
//                                let ipAddressAlert = UIAlertController(title: "", message: "Could not connect to the server. Please try again.", preferredStyle: UIAlertControllerStyle.alert)
//                                ipAddressAlert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
//                                // change background color.
//                                let FirstSubview = ipAddressAlert.view.subviews.first
//                                let AlertContentView = FirstSubview?.subviews.first
//                                for subview in (AlertContentView?.subviews)! {
//                                    subview.backgroundColor = UIColor(red: 0.1098, green: 0.2863, blue: 0.4431, alpha: 1.0)
//                                    subview.layer.cornerRadius = 10
//                                    subview.alpha = 1
//                                    subview.layer.borderWidth = 1
//                                    subview.layer.borderColor = UIColor(red: 0.1098, green: 0.2863, blue: 0.4431, alpha: 1.0).cgColor
//                                }
//                                //change message color
//                                let myString  = "Could not connect to the server. Please try again."
//                                var myMutableString = NSMutableAttributedString()
//                                myMutableString = NSMutableAttributedString(string: myString as String, attributes: [NSFontAttributeName:UIFont(name: "Georgia", size: 12.0)!])
//                                myMutableString.addAttribute(NSForegroundColorAttributeName, value: UIColor.white, range: NSRange(location:0,length:myString.characters.count))
//                                ipAddressAlert.setValue(myMutableString, forKey: "attributedMessage")
//                                self.present(ipAddressAlert, animated: true, completion: nil)
//                        }
//                      }
               // }
            }
            task.resume()
        }
        
        
    }
    
    
    
}


