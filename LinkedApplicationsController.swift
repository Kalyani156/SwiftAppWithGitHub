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
    var checked :Bool = false
    
    var loginUserName = ""
    
    var activationcode = ""
    
    var appNameFromWebServices = ""
    
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var searchBar: UISearchBar!
    
    
    @IBOutlet var menuBarView: UIView!
    
    
    @IBOutlet weak var leadingConstraint: NSLayoutConstraint!
    
    
    @IBOutlet weak var linkedAppPickerView: UIPickerView!
    
    var menuShowing = false
    
    @IBOutlet weak var menuBarLoginUserNameLabel: UILabel!
    
    var appDropDownValues = [String]()
    
    let ACTIVATION_CODE_TEXT = "Activation code"
    
    let NOTIFICATION_PREFERENCES_STORYBOARD_ID = "NotificationPreferencesID"
    
    let PREFERENCES_STORYBOARD_ID = "PreferencesStoryBoardID"
    
    let LINKED_APPLICATIONS_URL = "http://10.0.1.210:8080/MaasOauthServer/rest/oauth/getAllApplications"
    
    let VERIFY_CODE_AND_LINK_ACCOUNT_URL = "http://10.0.1.210:8080/MaasOauthServer/rest/oauth/verifyCodeAndLinkAccount"
    
    let LINKED_APPLICATIONS_CELL_IDENTIFIER = "linkedApplicationCell"
    
    let LINKED_ALL_APPLICATIONS_STORYBOARD_ID = "LinkedAppID"
    
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
    var allLinkedApps = [String]()
    // CBUser Entity , which is added into database
    var selectedAppName = ""
    var cbUser: [CBUser] = []
    //Linked application images
    var linkedAppImage = "link icon.png"
    // LinkedApplications Entity , which is added into database
    
    var linkedApps: [LinkedApplications] = []
    
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
        self.tableView.reloadData()
       
        
        
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
    // delete or edit data
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        
        if editingStyle == .delete
        {
            let finalTask = linkedApps[indexPath.row]
            context.delete(finalTask)
            
            // now save the context
            (UIApplication.shared.delegate as! AppDelegate).saveContext()
            
            // reload the data
            
            do
            {
                linkedApps = try context.fetch(LinkedApplications.fetchRequest())
                
            }
            catch
            {
                print("Error in deletion of data")
            }
            
        }
        // reload the data after deleting
        _ = getLinkedApplicationsFromLinkedApplicationEntity(loginUser: loginUserName)
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
        
        let currentCell = tableView.cellForRow(at: indexPath)! as UITableViewCell
        selectedAppName = currentCell.textLabel!.text! as String
        
        //get applications from database
        let existingLinkedApps = self.getLinkedApplicationsFromLinkedApplicationEntity(loginUser: self.loginUserName)
      
        // open a pop up window when table cell is pressed
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
      
        // Add a visual cue to indicate that the cell was selected.
        if existingLinkedApps.contains(self.selectedAppName) == false
        {
        alertController.addAction(UIAlertAction(title: "Link account",   style: UIAlertActionStyle.default, handler:
            {
                alert -> Void in
                let activationCodeField = alertController.textFields![0] as UITextField
                               if activationCodeField.text != ""  {
                    //TODO: Save user data in persistent storage - a tutorial for another time
                    
                }
                // Web Services to verify linked application and code
                var request = URLRequest(url: URL(string: self.VERIFY_CODE_AND_LINK_ACCOUNT_URL)!)
                request.httpMethod = "POST"
                let postString = activationCodeField.text!
                request.httpBody = postString.data(using: .utf8)
                request.setValue("text/plain", forHTTPHeaderField: "Content-Type")
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
                            
                            
                            print("getLinkedApplicationsFromLinkedApplicationEntity---\(existingLinkedApps)")
                            // Add a visual cue to indicate that the cell was selected.
                            if existingLinkedApps.contains(self.selectedAppName) == false
                            {
                                // get data from Entity LinkedApplication
                                let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
                                
                                // save received post data into LinkedApplication Entity database
                                
                                let linkedCBApps = LinkedApplications (context: context)
                                linkedCBApps.cbUsername = self.loginUserName
                                linkedCBApps.applicationName = self.selectedAppName
                                linkedCBApps.linked = true
                                
                                // save the data to coredata
                                (UIApplication.shared.delegate as! AppDelegate).saveContext()
                                
                                // reload table instantly
                                DispatchQueue.main.async{
                                    self.tableView.reloadData()
                                }
                            }
                            
                            
                        }
                            
                        else  if statusCode == 401
                        {
                            OperationQueue.main.addOperation
                                {
                                    let alert = UIAlertController(title: "", message: "Invalid activation code", preferredStyle: UIAlertControllerStyle.alert)
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
                                    let myString  = "Invalid activation code"
                                    var myMutableString = NSMutableAttributedString()
                                    myMutableString = NSMutableAttributedString(string: myString as String, attributes: [NSFontAttributeName:UIFont(name: "Georgia", size: 12.0)!])
                                    myMutableString.addAttribute(NSForegroundColorAttributeName, value: UIColor.white, range: NSRange(location:0,length:myString.characters.count))
                                    alert.setValue(myMutableString, forKey: "attributedMessage")
                                    self.present(alert, animated: true, completion: nil)
                                    
                            }
                        }
                    }
                    
                }
                task.resume()
                
        }))
        
        alertController.addTextField(configurationHandler: { (textField) -> Void in
            textField.textColor = UIColor(red: 0.1098, green: 0.2863, blue: 0.4431, alpha: 1.0)
            if (self.selectedAppName == self.appNameFromWebServices)
            {
                textField.text  = self.activationcode
            }
            else
            {
                textField.text  = self.ACTIVATION_CODE_TEXT
            }
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
        else{
             //Redirect to preferences page if applications are linked
           
           DispatchQueue.main.async
               {
                    let storyboard = UIStoryboard(name: "Main", bundle: nil)
                    let viewController = storyboard.instantiateViewController(withIdentifier : self.NOTIFICATION_PREFERENCES_STORYBOARD_ID) as! NotificationPreferencesController
                    viewController.notificationAndPrefrencesLbl = self.selectedAppName
                    viewController.loginUser = self.loginUserName
                viewController.data = self.cbUser
                   self.present(viewController, animated: true)
                
            }
        }
       
        
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
        print(" _ = getApplicationNameFromCoreData(loginUser: loginUserName)--\(getApplicationNameFromCoreData(loginUser: loginUserName))")
        print("getLinkedApp(loginUser : self.loginUserName)**\(getLinkedApp(loginUser : self.loginUserName))")
        if getApplicationNameFromCoreData(loginUser: loginUserName).contains(cell.textLabel!.text! as String) == true
        {
            //cell.accessoryType = .checkmark
            let checkImage = UIImage(named: self.linkedAppImage)
            let checkmark = UIImageView(image: checkImage)
            cell.accessoryView = checkmark
            
            
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
    
    // get application name from CBUser Entity
    
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
    
    // get application name from LinkedApplication Entity
    func getLinkedApplicationsFromLinkedApplicationEntity(loginUser : String) -> NSArray
    {
        // get data from Entity LinkedApplication
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        do
        {
            let request : NSFetchRequest<LinkedApplications> = LinkedApplications.fetchRequest()
            
            let dataPredicate = NSPredicate(format: "cbUsername == %@", loginUser)
            request.predicate = dataPredicate
            self.linkedApps  = try context.fetch(request)
            
            for linkedAppDetails in self.linkedApps as [NSManagedObject] {
                //get the Key Value pairs (although there may be a better way to do that...
                let  linkedUserName = linkedAppDetails.value(forKey: "cbUsername") as! String
                let  linkAppsName = linkedAppDetails.value(forKey: "applicationName") as! String
                let  linkedValue = linkedAppDetails.value(forKey: "linked") as! Bool
                print("linkedUserName--\(linkedUserName)")
                print("linkAppsName---\(linkAppsName)")
                print("linkedValue---\(linkedValue)")
                if (allLinkedApps.contains(linkAppsName) == false)
                {
                    allLinkedApps.append(linkAppsName)
                    
                }
                
            }
        }
        catch
        {
            print("Fetching application name failed from ")
        }
        return allLinkedApps as NSArray
        
    }
    func getLinkedApp(loginUser : String) -> String
    {
        var appName = ""
        // get data from Entity LinkedApplication
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        do
        {
            let request : NSFetchRequest<LinkedApplications> = LinkedApplications.fetchRequest()
            
            let dataPredicate = NSPredicate(format: "cbUsername == %@", loginUser)
            request.predicate = dataPredicate
            self.linkedApps  = try context.fetch(request)
            
            for linkedAppDetails in self.linkedApps as [NSManagedObject] {
                //get the Key Value pairs (although there may be a better way to do that...
                appName = linkedAppDetails.value(forKey: "applicationName") as! String
                print("isAppLinked---\(appName)")
                
            }
        }
        catch
        {
            print("Fetching application linked value")
        }
        return appName
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
        
        self.linkedAppPickerView.isHidden = true
        self.tableView.reloadData()
    }
    
    @IBAction func linkedNewAppBtnPressed(_ sender: Any) {
        self.linkedAppPickerView.isHidden = false
        tableView.reloadData()
    }
    
    
    func alertControllerBackgroundTapped()
    {
        self.dismiss(animated: true, completion: nil)
    }
    
}



