//
//  NotificationPreferencesController.swift
//  CrystalBallApp
//
//  Created by Kalyani on 03/03/17.
//  Copyright © 2017 Apple Inc. All rights reserved.


//

import UIKit

class NotificationPreferencesController: UIViewController , UINavigationControllerDelegate {
    
    var notificationAndPrefrencesLbl = ""
    
    var data = [CBUser]()
    
    @IBOutlet weak var preferencesLbl: UILabel!
    
    let LINKED_ALL_APPLICATIONS_STORYBOARD_ID = "LinkedAppID"
    
    @IBOutlet weak var contentView: UIView!
    
    var attrs = [
        NSFontAttributeName : UIFont.systemFont(ofSize: 19.0),
        NSForegroundColorAttributeName : UIColor.white,
        NSUnderlineStyleAttributeName : 1] as [String : Any]
    
    var attributedString = NSMutableAttributedString(string:"")
    
    // Array of Buttons to hold your tab bar buttons.
    @IBOutlet var buttons: [UIButton]!
    
    //Define variables to hold each ViewController associated with a tab.
    var notificationController: UIViewController!
    var preferencesController: UIViewController!
    var analyticsController: UIViewController!
    var statementController: UIViewController!
    
    //Define StoryBoard ID
    let NOTIFICATION_STORYBOARD_ID = "NotificationsStoryBoardID"
    let PREFERENCES_STORYBOARD_ID = "PreferencesStoryBoardID"
    let ANALYTICS_STORYBOARD_ID = "AnalyticsStoryBoardID"
    let STATEMENT_STORYBOARD_ID = "StatementStoryBoardID"
    
    //Define a variable for an array to hold the ViewControllers named, viewControllers.
    var viewControllers: [UIViewController]!
    
    //Define a variable to keep track of the tab button that is selected.
    //Set it to an initial value of 0. We will link the button's tag value to this variable. So an initial value of 0 will reference our first button.
    var selectedIndex: Int = 0
    
    var loginUser = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // set selected cell value to notification and Preferences Label
        preferencesLbl.text = notificationAndPrefrencesLbl
        //Link your ViewController Variables to the ViewControllers in the Storyboard.
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        //Next, instantiate each ViewController by referencing storyboard and the particular ViewController's Storyboard ID
        notificationController = storyboard.instantiateViewController(withIdentifier: NOTIFICATION_STORYBOARD_ID)
        preferencesController = storyboard.instantiateViewController(withIdentifier: PREFERENCES_STORYBOARD_ID)
        analyticsController = storyboard.instantiateViewController(withIdentifier: ANALYTICS_STORYBOARD_ID)
        statementController = storyboard.instantiateViewController(withIdentifier: STATEMENT_STORYBOARD_ID)
    
        //Add each ViewController to your viewControllers array
        viewControllers = [notificationController, preferencesController, analyticsController, statementController]
        
        let preferenceController = preferencesController as! PreferencesController
        preferenceController.applicationName = notificationAndPrefrencesLbl
        preferenceController.data = self.data
        preferenceController.loginUserName = loginUser
       
         didPressTab(buttons[selectedIndex])
        
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.delegate = self
        
    }
    
    
    
    @IBAction func backBtnPressed(_ sender: Any) {
        
        // Here you pass the data back to your original view controller
        DispatchQueue.main.async
            {
                
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                let viewController = storyboard.instantiateViewController(withIdentifier : self.LINKED_ALL_APPLICATIONS_STORYBOARD_ID) as! LinkedApplicationsController
                viewController.cbUser = self.data
                viewController.loginUserName = self.loginUser
                self.present(viewController, animated: true)
                
        }
        
    }
    
    //Create a Shared Action for the Buttons.
    
    @IBAction func didPressTab(_ sender: UIButton) {
        
        // Get Access to the Previous and Current Tab Button.
        //we can keep track of the previous button
        let previousIndex = selectedIndex
        
        //Set the selectedIndex to the tag value of which ever button was tapped.
        selectedIndex = sender.tag
        print(" selectedIndex--\(selectedIndex)")
        //use your previousIndex value to access your previous button and set it to the non-selected state
        // buttons[previousIndex].isSelected = false
        
        //Use the previousIndex to access the previous ViewController from the viewControllers array.
        let previousVC = viewControllers[previousIndex]
        
        //Remove the previous ViewController
        previousVC.willMove(toParentViewController: nil)
        previousVC.view.removeFromSuperview()
        previousVC.removeFromParentViewController()
        
        //access your current selected button and set it to the selected state.
        //sender.isSelected = true
        //Use the selectedIndex to access the current ViewController from the viewControllers array.
        let vc = viewControllers[selectedIndex]
         //Add the new ViewController.
        addChildViewController(vc)
        
        //Adjust the size of the ViewController view you are adding to match the contentView of your tabBarViewController and add it as a subView of the contentView.
        vc.view.frame = contentView.bounds
        contentView.addSubview(vc.view)
        
        //Call the viewDidAppear method of the ViewController you are adding using didMove(toParentViewController: self)
        vc.didMove(toParentViewController: self)
   
        
    }

}
