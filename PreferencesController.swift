//
//  PreferencesController.swift
//  CrystalBallApp
//
//  Created by Kalyani on 06/03/17.
//  Copyright © 2017 Apple Inc. All rights reserved.
//

import UIKit

class PreferencesController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    
    
    @IBOutlet weak var tableView: UITableView!
    
    let PII_DOMAIN_SPECIFIC_FIELD_CELL_IDENTIFIER = "PIIDomainFieldsCell"
    
    var tableData = [String]()
    
     var data = [CBUser]()
    
    var applicationName = ""
    
    var loginUserName = ""
    
    let DATA_FIELDS_URL = "http://10.0.1.210:8080/MaasOauthServer/rest/oauth/getDataFields"
    
    let EDIT_PREFERENCES_STORYBOARD_ID = "EditPreferencesStoryBoardID"
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        print("applicationName----\(applicationName)")
        tableView.dataSource = self
        tableView.delegate = self
        getPIIFields()
        tableView.register(UITableViewCell.self,
                           forCellReuseIdentifier: PII_DOMAIN_SPECIFIC_FIELD_CELL_IDENTIFIER)
    }
    
    @IBAction func segmentedControlAction(_ sender: Any) {
        //        let title1 = segmentedControl.titleForSegment(at: 0)
        //        let title2 = segmentedControl.titleForSegment(at: 1)
        if(segmentedControl.selectedSegmentIndex == 0)
        {
            
            getPIIFields()
        }
        else if(segmentedControl.selectedSegmentIndex == 1)
        {
            
            getDomainSpecificFields()
            
        }
        
    }
    
    // Web Services to get all PII Fields
    func getPIIFields()
    {
        let postString = "applicationName=\(applicationName)&type=0"
        var request = URLRequest(url: URL(string: "\(DATA_FIELDS_URL)?\(postString)")!)
        request.httpMethod = "POST"
        request.setValue("application/x-www-form-urlencoded; charset=utf-8", forHTTPHeaderField: "Content-Type")
        request.httpBody = postString.data(using: String.Encoding.utf8)
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data, error == nil else {                                                 // check for fundamental networking error
                print("error=\(error)")
                return
            }
            
            if let httpStatus = response as? HTTPURLResponse, httpStatus.statusCode != 200 {           // check for http errors
                print("statusCode ******** \(httpStatus.statusCode)")
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
                        print("jsonDict------\(jsonDict.allKeys)")
                        DispatchQueue.main.async {
                            self.tableData = jsonDict.allKeys as! [String]
                            
                            DispatchQueue.main.async{
                                self.tableView.reloadData()
                            }
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
    // Web Services to get all Domain Specific Fields
    func getDomainSpecificFields()
    {
        let postString = "applicationName=\(applicationName)&type=1"
        var request = URLRequest(url: URL(string: "\(DATA_FIELDS_URL)?\(postString)")!)
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
                        print("jsonDict------\(jsonDict.allKeys)")
                        DispatchQueue.main.async {
                            self.tableData = jsonDict.allKeys as! [String]
                            
                            DispatchQueue.main.async{
                                self.tableView.reloadData()
                            }
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
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return tableData.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: PII_DOMAIN_SPECIFIC_FIELD_CELL_IDENTIFIER, for: indexPath as IndexPath)
        cell.textLabel?.text = tableData[indexPath.row];
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let currentCell = tableView.cellForRow(at: indexPath)! as UITableViewCell
        let selectedCell = currentCell.textLabel!.text! as String
        print("selectedCell---\(selectedCell)")
        DispatchQueue.main.async
            {
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                let viewController = storyboard.instantiateViewController(withIdentifier : self.EDIT_PREFERENCES_STORYBOARD_ID) as! EditPreferencesController
                viewController.editPreferences = selectedCell
                viewController.applicationNames = self.applicationName
                viewController.loginUser = self.loginUserName
               
                viewController.data = self.data
                self.present(viewController, animated: true)
         }
    }
    
}
