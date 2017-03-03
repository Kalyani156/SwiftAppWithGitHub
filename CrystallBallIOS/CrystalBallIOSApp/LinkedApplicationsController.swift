//
//  LinkedApplicationsController.swift
//  CrystalBallApp
//
//  Created by Kalyani on 17/02/17.
//  Copyright © 2017 Apple Inc. All rights reserved.
//

import UIKit

import CoreData

class LinkedApplicationsController: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate,
    UIPickerViewDataSource , UIPickerViewDelegate
{
    
    var loginUserName = ""
    
     var activationcode = ""
    
    @IBOutlet weak var tableView: UITableView!
    
 
    
    @IBOutlet weak var searchBar: UISearchBar!
    
    
    @IBOutlet var menuBarView: UIView!
    
    
    @IBOutlet weak var leadingConstraint: NSLayoutConstraint!
    
    
    @IBOutlet weak var linkedAppPickerView: UIPickerView!
    
    var menuShowing = false
    
    @IBOutlet weak var menuBarLoginUserNameLabel: UILabel!
    
     var appDropDownValues = [String]()
    
    let ACTIVATION_CODE_TEXT = "Activation code"
    
    
    let LINKED_APPLICATIONS_URL = "http://10.0.1.210:8080/MaasOauthServer/rest/oauth/getAllApplications"
    let LINKED_APPLICATIONS_CELL_IDENTIFIER = "linkedApplicationCell"
    var firstApplication: String?
    var secondApplication: String?
    var thirdApplication: String?
    var fourthApplication: String?
    var allAplications:[String] = []
    var tableName = [String]()
    var searchActive : Bool = false
    var filtered:[String] = []
    var delegate: UIViewController?
    var applicationName = [String]()
     var allLinkedApplication = [String]()
    // Entity , which is added into database
    
    var cbUser: [CBUser] = []
    override func viewDidLoad() {
        super.viewDidLoad()
        //set login user name in a label
        menuBarLoginUserNameLabel.text = loginUserName
        tableView.dataSource = self
        tableView.delegate = self
        searchBar.delegate = self
        tableView.allowsSelection = true
        leadingConstraint.constant = -140
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.tap(_:)))
        menuBarView.addGestureRecognizer(tap)
        tap.cancelsTouchesInView = false
       // getAllCrystalBallLinkedApplications()
        tableView.register(UITableViewCell.self,
                           forCellReuseIdentifier: LINKED_APPLICATIONS_CELL_IDENTIFIER)
        for subView in self.searchBar.subviews
        {
            for subsubView in subView.subviews
            {
                if let textField = subsubView as? UITextField
                {
                    textField.attributedPlaceholder = NSAttributedString(string: NSLocalizedString("Search", comment: ""), attributes: [NSForegroundColorAttributeName: UIColor.white])
                    
                    textField.textColor = UIColor.white
                }
            }
        }
        //picker view
       self.linkedAppPickerView.delegate = self
        self.linkedAppPickerView.dataSource = self
        getAllCrystalBallLinkedApplications()
        self.linkedAppPickerView.showsSelectionIndicator = false
        linkedAppPickerView.isHidden = true
    }
    override func viewWillAppear(_ animated: Bool) {
       
        // get the data from core data
      _ = getApplicationNameFromCoreData(loginUser: loginUserName)
        // reload the table view
        tableView.reloadData()
        
        
        //print("all linked app ---- \(getApplicationNameFromCoreData(loginUser: loginUserName))")
       
    }
    
    //Search Bar functionality
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        searchActive = true;
    }
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        searchActive = false;
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchActive = false;
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchActive = false;
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
      // getApplicationSelectedByUser()
      // self.tableView.reloadData()
        filtered = allLinkedApplication.filter({ (text) -> Bool in
            let tmp: NSString = text as NSString
            let range = tmp.range(of: searchText, options: NSString.CompareOptions.caseInsensitive)
            return range.location != NSNotFound
        })
        if(filtered.count == 0){
            searchActive = false;
        } else {
            searchActive = true;
        }
        
        self.tableView.reloadData()
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
                    self.appDropDownValues = self.allAplications
                    
                    DispatchQueue.main.async{
                        self.linkedAppPickerView.reloadAllComponents()
                    }
                }
            }
        }
        task.resume()
    }
    // Receive data from database
    func getApplicationSelectedByUser()
    {
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        do
        {
        let request : NSFetchRequest<CBUser> = CBUser.fetchRequest()
           
        
            let dataPredicate = NSPredicate(format: "cbUsername == %@", loginUserName)
      
            request.predicate = dataPredicate
         
            cbUser  = try context.fetch(request)
            
             self.tableView.reloadData()
            
        }
        catch
        {
            print("Fetching Failed")
        }
        
    }
    // delete or edit data
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        
        if editingStyle == .delete
        {
            let finalTask = cbUser[indexPath.row]
            context.delete(finalTask)
            
            // now save the context
            (UIApplication.shared.delegate as! AppDelegate).saveContext()
            
            // reload the data
            
            do
            {
                cbUser = try context.fetch(CBUser.fetchRequest())
                
            }
            catch
            {
                print("Error in deletion of data")
            }
            
        }
        // reload the data after deleting
         _ = getApplicationNameFromCoreData(loginUser: loginUserName)
        tableView.reloadData()
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if(searchActive) {
            return filtered.count
        }
        return cbUser.count
    }
    // open an alertView while clicking on cell
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("You selected cell number: \(indexPath.row)!")
        showLinkAccountPopup()
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        
        let cell = tableView.dequeueReusableCell(withIdentifier: LINKED_APPLICATIONS_CELL_IDENTIFIER, for: indexPath as IndexPath)
        self.tableView.separatorColor = UIColor.white
        let crystalBallUsers = cbUser[indexPath.row]

        if(searchActive){
            cell.textLabel?.text = filtered[indexPath.row]
        } else {
            cell.textLabel?.text = crystalBallUsers.value(forKeyPath: "applicationName") as? String
           
        }
        // NOTIFICATION ICON PART 1 BELL
        
        cell.backgroundColor = UIColor(red: 0.7922, green: 0.8392, blue: 0.8902, alpha: 1.0)
        
        if indexPath.row == 0
        {
            cell.imageView?.image = UIImage(named: "LOGO 1.png")
        }
        else if indexPath.row == 1
        {
            cell.imageView?.image = UIImage(named: "LOGO 2.png")
        }
        else if indexPath.row == 2
        {
            cell.imageView?.image = UIImage(named: "LOGO 3.png")
        }
        else if indexPath.row == 3
        {
            cell.imageView?.image = UIImage(named: "LOGO 4.png")
        }
        
        return cell
    }
    
    //Menu Bar functionality
    
    @IBAction func menuBtnPressed(_ sender: Any) {
        
        if(menuShowing)
        {
            leadingConstraint.constant = -140
        }
        else{
            leadingConstraint.constant = 0
        }
    }
    
    func tap(_ gestureRecognizer: UITapGestureRecognizer) {
        leadingConstraint.constant = -140
        
    }
    
    // get application name
    
    func getApplicationNameFromCoreData(loginUser : String) -> NSArray
        
        
    {
        var applicationName : String = ""
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        do
        {
            let request : NSFetchRequest<CBUser> = CBUser.fetchRequest()
         
            let dataPredicate = NSPredicate(format: "cbUsername == %@", loginUser)
             request.predicate = dataPredicate
            
            cbUser  = try context.fetch(request)
//            getApplicationSelectedByUser()
//                self.tableView.reloadData()
            for userDetails in cbUser as [NSManagedObject] {
                //get the Key Value pairs (although there may be a better way to do that...
                applicationName = userDetails.value(forKey: "applicationName") as! String
                if (allLinkedApplication.contains(applicationName) == false)
                {
               allLinkedApplication.append(applicationName)
                
            }
            }
        }
        catch
        {
            print("Fetching application name failed")
        }
      
        print("all apps inside function ---- \(allLinkedApplication)")
        return allLinkedApplication as NSArray
        
        
        
    }
    
    // Picker view stub
    public func numberOfComponents(in pickerView: UIPickerView) -> Int{
        return 1
        
    }
    
    public func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int{
        
        return appDropDownValues.count
        
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        
        self.view.endEditing(true)
        return appDropDownValues[row]
        
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
      
        let existingLinkedApplications = getApplicationNameFromCoreData(loginUser: loginUserName)
        print("existingLinkedApplications  -- \(existingLinkedApplications  )")
        print("self.appDropDownValues[row]---\(appDropDownValues[row])")
        if (existingLinkedApplications  .contains(appDropDownValues[row]) == false)
        {
        // save received post data into database
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        
        let userDetails = CBUser (context: context)
        userDetails.cbUsername = loginUserName
        userDetails.applicationName = self.appDropDownValues[row]
        
        // save the data to coredata
        (UIApplication.shared.delegate as! AppDelegate).saveContext()
       
        }
       _ = getApplicationNameFromCoreData(loginUser: loginUserName)
        //getApplicationNameFromCoreData(loginUser: loginUserName)
        self.linkedAppPickerView.isHidden = true
        self.tableView.reloadData()
    }

    @IBAction func linkedNewAppBtnPressed(_ sender: Any) {
         self.linkedAppPickerView.isHidden = false
         tableView.reloadData()
    }
    // open a pop up window when table cell is pressed
    
    
    func showLinkAccountPopup()  {
        
        let alertController = UIAlertController(title: "", message: "", preferredStyle: UIAlertControllerStyle.alert)
        // Background color.
        let FirstSubview = alertController.view.subviews.first
        let AlertContentView = FirstSubview?.subviews.first
        for subview in (AlertContentView?.subviews)! {
            subview.backgroundColor = UIColor(red: 0.1098, green: 0.2863, blue: 0.4431, alpha: 1.0)
            subview.layer.cornerRadius = 10
            subview.alpha = 1
            subview.layer.borderWidth = 1
            subview.layer.borderColor = UIColor(red: 0.1098, green: 0.2863, blue: 0.4431, alpha: 1.0).cgColor
        }
        
        alertController.addAction(UIAlertAction(title: "Link account",   style: UIAlertActionStyle.default, handler:
            {
                alert -> Void in
                let activationCodeField = alertController.textFields![0] as UITextField
               
              //  self.hostServer = HostServerIPVO(fn: ipAddressField.text!, ln: portField.text!)
                
                if activationCodeField.text != ""  {
                    //TODO: Save user data in persistent storage - a tutorial for another time
                    
                //    self.ipAddressLabel.text = self.hostServer.ipAddress
                  //  self.portLabel.text = self.HOST_SERVER_PORT
                    
                }
                    
                OperationQueue.main.addOperation
                    {
                      //  let storyboard = UIStoryboard(name: "Main", bundle: nil)
//                        let viewController = storyboard.instantiateViewController(withIdentifier : self.LOGIN_STORYBOARD_ID) as! LoginController
//                        viewController.ipAddress = self.ipAddressLabel.text!
//                        viewController.portNo = self.portLabel.text!
//                        self.present(viewController, animated: true)
                        
                }
                
                
        }))
      
        alertController.addTextField(configurationHandler: { (textField) -> Void in
            textField.textColor = UIColor(red: 0.1098, green: 0.2863, blue: 0.4431, alpha: 1.0)
            //textField.insertText(self.activationCodeText)
            //textField.placeholder = self.ACTIVATION_CODE_TEXT
            textField.text  = self.activationcode
            textField.textAlignment = .center
            
        })
        
        // Create Cancel button
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (action:UIAlertAction!) in
            
        }
        alertController.addAction(cancelAction)
          alertController.view.tintColor = UIColor.white
        self.present(alertController, animated: true, completion:{
            alertController.view.superview?.isUserInteractionEnabled = true
            alertController.view.superview?.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.alertControllerBackgroundTapped)))
        })
        
    }
    func alertControllerBackgroundTapped()
    {
        self.dismiss(animated: true, completion: nil)
    }
}



