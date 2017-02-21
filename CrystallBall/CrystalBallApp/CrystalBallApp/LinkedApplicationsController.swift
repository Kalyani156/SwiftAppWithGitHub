//
//  LinkedApplicationsController.swift
//  CrystalBallApp
//
//  Created by Kalyani on 17/02/17.
//  Copyright © 2017 Apple Inc. All rights reserved.
//

import UIKit


class LinkedApplicationsController: UIViewController, UITableViewDelegate, UITableViewDataSource{
    
    
    @IBOutlet weak var tableView: UITableView!
    
    let linkedApplicationsURL = "http://10.0.1.210:8080/MaasOauthServer/rest/oauth/getAllApplications"
    var firstApplication: String?
    var secondApplication: String?
    var thirdApplication: String?
    var fourthApplication: String?
    
    var allAplications:[String] = []
    
    var items: [String] = []
    
       var linkedApps: [LinkedAllApplicationsVO] = []
    var linkedApplication = LinkedAllApplicationsVO()
       var tableName = [String]()
      override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
        tableView.delegate = self
        getAllCrystalBallLinkedApplications()
               tableView.register(UITableViewCell.self,
                           forCellReuseIdentifier: "linkedApplicationCell")
    
    }

    //
    func getAllCrystalBallLinkedApplications(){
        var request = URLRequest(url: URL(string: linkedApplicationsURL)!)
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
                        print("first app------\(self.firstApplication)")
                        self.allAplications.append(firstApp)
                    }
                }
                if let secondApplicationNumbers = jsonDict["2"] as? NSDictionary {
                    if let secondApp = secondApplicationNumbers["_id"] as? String {
                        self.secondApplication = secondApp
                        print("second app------\(self.secondApplication)")
                        self.allAplications.append(secondApp)
                    }
                }
                if let thirdApplicationNumbers = jsonDict["3"] as? NSDictionary {
                    if let thirdApp = thirdApplicationNumbers["_id"] as? String {
                        self.thirdApplication = thirdApp
                        print("third app------\(self.thirdApplication)")
                        self.allAplications.append(thirdApp)
                    }
                }
                if let fourthApplicationNumbers = jsonDict["4"] as? NSDictionary {
                    if let fourthApp = fourthApplicationNumbers["_id"] as? String {
                        self.fourthApplication = fourthApp
                        print("fourth app------\(self.fourthApplication)")
                        self.allAplications.append(fourthApp)
                        
                    }
                }
                
                print(self.allAplications)
                 DispatchQueue.main.async {
               
                   self.tableName = self.allAplications
                  
                DispatchQueue.main.async{
                    self.tableView.reloadData()
                    }
                }
        }
        }
        task.resume()
    }
    
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
         return tableName.count
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "linkedApplicationCell", for: indexPath as IndexPath)
        cell.textLabel?.text = tableName[indexPath.item]
        return cell
    }

    }




