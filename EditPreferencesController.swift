//
//  EditPreferencesController.swift
//  CrystalBallApp
//
//  Created by Kalyani on 07/03/17.
//  Copyright © 2017 Apple Inc. All rights reserved.
//

import UIKit

class EditPreferencesController: UIViewController , UIPickerViewDelegate, UIPickerViewDataSource,UITextFieldDelegate
{

    @IBOutlet weak var editPreferencesLbl: UILabel!
    
    var editPreferences = ""
    
    var data = [CBUser]()
    
    var loginUser = ""
    
     let NOTIFICATION_PREFERENCES_STORYBOARD_ID = "NotificationPreferencesID"
    
     let PREFERENCES_STORYBOARD_ID = "PreferencesStoryBoardID"
    
    let FETCH_PURPOSES_URL = "http://10.0.1.210:8080/MaasOauthServer/rest/oauth/fetchPurposes"
    
   let RADIO_BUTTON_SELECTED_IMAGE = "RADIO BUTTON SELECTED.png"
    
    let RADIO_BUTTON_NOT_SELECTED_IMAGE = "RADIO BUTTON NOT SELECTED.png"
    
    @IBOutlet weak var editPreferenceBtn1: UIButton!
    
    @IBOutlet weak var editPreferenceBtn2: UIButton!
    
    @IBOutlet weak var editPreferencesText1: UITextField!
 
    @IBOutlet weak var editPreferencesText2: UITextField!
    
    @IBOutlet weak var dropDown: UIPickerView!
    
    @IBOutlet weak var improveInternalProductsAndServices: UIImageView!
    
    
    @IBOutlet weak var shareDataWithThirdParties: UIImageView!
    
    @IBOutlet weak var editPreferencesLbl1: UILabel!
    
    @IBOutlet weak var editPreferencesLbl2: UILabel!
    
    @IBOutlet weak var editPreferencesTxt1: UITextField!
    
    @IBOutlet weak var editPreferencesTxt2: UITextField!
    
    var applicationNames = ""
    
    var dropDownValues = ["Always allow" , "Send notice" , "Ask consent" , "Always deny"]
    var dropDownValues1 = ["Always allow" , "Send notice" , "Ask consent" , "Always deny"]
    var dropDownValues2 = ["Always allow" , "Send notice" , "Ask consent" , "Always deny"]
    
   
 
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
         editPreferencesLbl.text = editPreferences
        fetchAllPurposes()
        self.dropDown.delegate = self
        self.dropDown.dataSource = self
         dropDown.isHidden = true
         self.dropDown.showsSelectionIndicator = false
        self.editPreferencesText1.delegate = self
         self.editPreferencesText2.delegate = self
        
     }
    public func numberOfComponents(in pickerView: UIPickerView) -> Int{
        return 1
        
    }
    
    public func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int{
        
        return dropDownValues.count
        
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        
        return dropDownValues[row]
        
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        
        print("pickerView.tag-----\(pickerView.tag)")
        
        
        if pickerView.tag == 1 {
         self.editPreferencesTxt1.text = dropDownValues1[row]
        }
        
        if pickerView.tag == 2 {
         self.editPreferencesTxt2.text  = dropDownValues2[row]
        }
        self.dropDown.isHidden = true
    }
   
    
    @IBAction func backBtnPressed(_ sender: Any) {
        
        DispatchQueue.main.async
            {
                
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                let viewController = storyboard.instantiateViewController(withIdentifier : self.NOTIFICATION_PREFERENCES_STORYBOARD_ID) as! NotificationPreferencesController
                viewController.notificationAndPrefrencesLbl = self.applicationNames
                viewController.data = self.data
                viewController.loginUser = self.loginUser
                self.present(viewController, animated: true)
                
        }
    }

    // Web Services to fetch all purposes
    func fetchAllPurposes()
    {
        let postString = "applicationName=\(applicationNames)"
        var request = URLRequest(url: URL(string: "\(FETCH_PURPOSES_URL)?\(postString)")!)
        request.httpMethod = "POST"
        request.setValue("application/x-www-form-urlencoded; charset=utf-8", forHTTPHeaderField: "Content-Type")
        request.httpBody = postString.data(using: String.Encoding.utf8)
        
        print("request********\(request)")
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data, error == nil else {                                                 // check for fundamental networking error
                print("error=\(error)")
                return
            }
            
            if let httpStatus = response as? HTTPURLResponse, httpStatus.statusCode != 200 {           // check for http errors
                print("statusCode ******** \(httpStatus.statusCode)")
                print("response = \(response)")
            }
            
            let responseString = String(data: data, encoding: .utf8)
            print("responseString = \(responseString)")
            
            if let httpResponse = response as? HTTPURLResponse {
                print("status code@@@@@@@@@@@@@-------------\(httpResponse.statusCode)")
                let statusCode = httpResponse.statusCode
                if statusCode == 201
                {
                    let jsonObject = try? JSONSerialization.jsonObject(with: data, options: .allowFragments)
                    if let jsonDict = jsonObject as? NSDictionary {
                         print("jsonDictss*****------\(jsonDict.allKeys)")
                        print("jsonDict------\(jsonDict.allKeys[0])")
                        
                        DispatchQueue.main.async {
                            //self.tableData = jsonDict.allKeys as! [String]
                            self.editPreferencesLbl1.text = jsonDict.allKeys[0] as? String
                            self.editPreferencesLbl2.text = jsonDict.allKeys[1] as? String
                            
                           
                        }
                        
                    }
                }
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
    
    
  
    @IBAction func shareDataWithThirdPartiesBtnPressed(_ sender: Any) {
         self.dropDown.isHidden = false
        //self.secondPickerView.isHidden = true
        dropDown.tag = 1
        shareDataWithThirdParties?.image = UIImage(named: RADIO_BUTTON_SELECTED_IMAGE )
         improveInternalProductsAndServices?.image = UIImage(named: RADIO_BUTTON_NOT_SELECTED_IMAGE)
    }
    
    
    @IBAction func improveInternalProductsBtnPressed(_ sender: Any) {
           self.dropDown.isHidden = false
         dropDown.tag = 2
        improveInternalProductsAndServices?.image = UIImage(named: RADIO_BUTTON_SELECTED_IMAGE)
        shareDataWithThirdParties?.image = UIImage(named: RADIO_BUTTON_NOT_SELECTED_IMAGE)
    }
    
    
    
    
    @IBAction func savePreferencesBtn(_ sender: Any) {
        
        
    }
    
    
}
