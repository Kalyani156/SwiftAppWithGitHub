//
//  JoinNowController.swift
//  CrystalBallApp
//
//  Created by Kalyani on 20/02/17.
//  Copyright © 2017 Apple Inc. All rights reserved.
//

import UIKit

class JoinNowController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource, UITextFieldDelegate  {
    
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
}


