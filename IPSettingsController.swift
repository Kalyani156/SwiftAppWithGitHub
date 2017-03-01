//
//  IPSettingsController.swift
//  CrystalBallApp
//
//  Created by Kalyani on 24/02/17.
//  Copyright © 2017 Apple Inc. All rights reserved.
//

import UIKit

class IPSettingsController: UIViewController {
    
    
    @IBOutlet weak var ipAddressLabel: UILabel!
    
    @IBOutlet weak var portLabel: UILabel!
    
    @IBOutlet weak var hostServerIpRadioButtonView: UIImageView!
    
    @IBOutlet weak var changePwdRadioButtonView: UIImageView!
    
    @IBOutlet weak var checkForUpdatesRadioButtonView: UIImageView!
    
    var hostServer: HostServerIPVO!
    
    let HOST_SERVER_IP = "121.241.184.234"
    
    let HOST_SERVER_PORT = "8080"
    
    let LOGIN_STORYBOARD_ID = "SignInID"
    
    var ip = ""
    var port = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
    }
    

    @IBAction func hostServerIpBtnPressed(_ sender: Any) {
        hostServerIpRadioButtonView?.image = UIImage(named: "RADIO BUTTON SELECTED.png")
        checkForUpdatesRadioButtonView?.image = UIImage(named: "RADIO BUTTON NOT SELECTED.png")
        changePwdRadioButtonView?.image = UIImage(named: "RADIO BUTTON NOT SELECTED.png")
        showIPAddressAndPortSettings()
        
    }
    
    // open a pop up window when Host Server IP Button is pressed
    
    
    func showIPAddressAndPortSettings()  {
        
        let alertController = UIAlertController(title: "Host Server IP Settings", message: "Crystal Ball will restart after pressing save", preferredStyle: UIAlertControllerStyle.alert)
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
        
        
        let myString  = "Host Server IP Settings"
        var myMutableString = NSMutableAttributedString()
        myMutableString = NSMutableAttributedString(string: myString as String, attributes: [NSFontAttributeName:UIFont(name: "Georgia", size: 18.0)!])
        myMutableString.addAttribute(NSForegroundColorAttributeName, value: UIColor.white, range: NSRange(location:0,length:myString.characters.count))
        alertController.setValue(myMutableString, forKey: "attributedTitle")
        
        let myMessageString  = "Crystal Ball will restart after pressing save"
        var myMsgMutableString = NSMutableAttributedString()
        myMsgMutableString = NSMutableAttributedString(string: myMessageString as String, attributes: [NSFontAttributeName:UIFont(name: "Georgia", size: 12.0)!])
        myMsgMutableString.addAttribute(NSForegroundColorAttributeName, value: UIColor.white, range: NSRange(location:0,length:myMessageString.characters.count))
        alertController.setValue(myMsgMutableString, forKey: "attributedMessage")
      
        
        alertController.addAction(UIAlertAction(title: "Save",   style: UIAlertActionStyle.default, handler:
            {
                alert -> Void in
                let ipAddressField = alertController.textFields![0] as UITextField
                let portField = alertController.textFields![1] as UITextField
                self.hostServer = HostServerIPVO(fn: ipAddressField.text!, ln: portField.text!)
                
                if ipAddressField.text != ""  , portField.text == ""{
                    //TODO: Save user data in persistent storage - a tutorial for another time
                    
                    self.ipAddressLabel.text = self.hostServer.ipAddress
                    self.portLabel.text = self.HOST_SERVER_PORT
                    
                }
                    
                else if portField.text != "" , ipAddressField.text == ""
                {
                    self.ipAddressLabel.text = self.HOST_SERVER_IP
                    self.portLabel.text = self.hostServer.port
                    
                }
                else if ipAddressField.text != "" , portField.text != ""
                {
                    self.ipAddressLabel.text = self.hostServer.ipAddress
                    self.portLabel.text = self.hostServer.port
                }
                    
                else if ipAddressField.text == "" , portField.text == ""
                {
                    self.ipAddressLabel.text = self.HOST_SERVER_IP
                    self.portLabel.text = self.HOST_SERVER_PORT
                }
                
                  OperationQueue.main.addOperation
                              {
                                  let storyboard = UIStoryboard(name: "Main", bundle: nil)
                                  let viewController = storyboard.instantiateViewController(withIdentifier : self.LOGIN_STORYBOARD_ID) as! LoginController
                                 viewController.ipAddress = self.ipAddressLabel.text!
                                  viewController.portNo = self.portLabel.text!
                                              self.present(viewController, animated: true)
              
                          }
                
                
        }))
        alertController.view.tintColor = UIColor.white
        alertController.addTextField(configurationHandler: { (textField) -> Void in
            textField.textColor = UIColor(red: 0.1098, green: 0.2863, blue: 0.4431, alpha: 1.0)
            textField.placeholder = self.HOST_SERVER_IP
            textField.textAlignment = .center
            
        })
        
        alertController.addTextField(configurationHandler: { (textField) -> Void in
            textField.textColor = UIColor(red: 0.1098, green: 0.2863, blue: 0.4431, alpha: 1.0)
            textField.placeholder = self.HOST_SERVER_PORT
            textField.textAlignment = .center
        })
        
        self.present(alertController, animated: true, completion:{
            alertController.view.superview?.isUserInteractionEnabled = true
            alertController.view.superview?.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.alertControllerBackgroundTapped)))
        })
      
    }
    
    @IBAction func checkForUpdatesBtnPressed(_ sender: Any) {
        hostServerIpRadioButtonView?.image = UIImage(named: "RADIO BUTTON NOT SELECTED.png")
        checkForUpdatesRadioButtonView?.image = UIImage(named: "RADIO BUTTON SELECTED.png")
        changePwdRadioButtonView?.image = UIImage(named: "RADIO BUTTON NOT SELECTED.png")
        
        
    }
    
    @IBAction func changePwdBtnPressed(_ sender: Any) {
        hostServerIpRadioButtonView?.image = UIImage(named: "RADIO BUTTON NOT SELECTED.png")
        checkForUpdatesRadioButtonView?.image = UIImage(named: "RADIO BUTTON NOT SELECTED.png")
        changePwdRadioButtonView?.image = UIImage(named: "RADIO BUTTON SELECTED.png")
    }
    func alertControllerBackgroundTapped()
    {
        self.dismiss(animated: true, completion: nil)
    }
}
