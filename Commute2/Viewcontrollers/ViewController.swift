//
//  ViewController.swift
//  Commute2
//
//  Created by Derek Doherty on 21/03/2018.
//  Copyright © 2018 Derek Doherty. All rights reserved.
//

import UIKit
import Alamofire

class ViewController: UIViewController {
    
    @IBOutlet weak var startingStationLabel: UILabel!
    @IBOutlet weak var destStation: UILabel!
    @IBOutlet weak var updateTime: UILabel!
    @IBOutlet weak var myTableView: UITableView!
    
    @IBAction func refreshPressed(_ sender: Any)
    {
        refreshStationData()
    }
    
    @IBAction func switchDirection(_ sender: Any)
    {
        if startingStation == K.AppStrings.rathdrumStationString
        {
            startingStation = K.AppStrings.dalkeyStationString
            startingStationLabel.text = startingStation
            destinationStation = K.AppStrings.destinationRathdrumString
            destStation.text = destinationStation
        } else {
            startingStation = K.AppStrings.rathdrumStationString
            startingStationLabel.text = startingStation
            destinationStation = K.AppStrings.destinationDalkeyString
            destStation.text = destinationStation
        }
        myTableView.reloadData()
        refreshStationData()
    }
    
    func getTimeString () -> String
    {
        let dateFormatter : DateFormatter = DateFormatter()
        dateFormatter.dateFormat = "HH:mm:ss"
        let date = Date()
        return dateFormatter.string(from: date)
    }
    
    
    // These shared variable dictionaries  are accessed from multiple threads as such
    // need to be made thread safe for writing
    var stationsOfInterestNorthbound:[String:[StationData]] = [:]
    var stationsOfInterestSouthbound:[String:[StationData]] = [:]
    
    var startingStation:String = ""
    var destinationStation:String = ""


    override func viewDidLoad()
    {
        super.viewDidLoad()

        myTableView.allowsSelection = false
        myTableView.rowHeight = UITableViewAutomaticDimension
        myTableView.estimatedRowHeight = 40
        
        // Initialize UI and Properties
        //
        startingStation = K.AppStrings.dalkeyStationString
        startingStationLabel.text = startingStation
        destinationStation = K.AppStrings.destinationRathdrumString
        destStation.text = destinationStation
        
        updateTime.text = "Not Updated";
        
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        refreshStationData()
    }
    
    
    func refreshStationData() -> Void
    {
        if ( startingStation == K.AppStrings.rathdrumStationString)  // Northbound
        {
            getStationData(atStation: K.AppStrings.greystonesStationCode, forNumMins: 90)
            getStationData(atStation: K.AppStrings.rathdrumStationCode, forNumMins: 90)
            
        } else { // Southbound
            getStationData(atStation: K.AppStrings.dalkeyStationCode, forNumMins: 90)
            getStationData(atStation: K.AppStrings.greystonesStationCode, forNumMins: 90)
        }
    }
    
    func getStationData(atStation station:String , forNumMins mins:Int)
    {
        //
        // Make a Call to IrishRail API
        //
        let utilityQ = DispatchQueue.global(qos:.userInitiated)
        Alamofire.request(Router.GetStationData(station, mins))
            .validate(statusCode: 200...200)
            .responseData(queue:utilityQ)
            { response in
                print("The original Request is \(response.request!)")  // original URL request
                
                switch response.result
                {
                case .success(let data):
                    
                    let xph = XmlParserHandler()
                    if (self.startingStation == K.AppStrings.rathdrumStationString )
                    {
                       let infoArray = xph.parseTrainData(xmlData: data, direction: "Northbound")
                       self.stationsOfInterestNorthbound[station] = infoArray
                        DispatchQueue.main.async {
                            self.updateTime.text = self.getTimeString()
                            self.myTableView.reloadData()
                        }
                        
                    } else if (self.startingStation == K.AppStrings.dalkeyStationString ) {
                        let infoArray = xph.parseTrainData(xmlData: data, direction: "Southbound")
                        self.stationsOfInterestSouthbound[station] = infoArray
                        DispatchQueue.main.async {
                            self.updateTime.text = self.getTimeString()
                            self.myTableView.reloadData()
                        }
                    }
                    
                case .failure(let error):
                    print(error.localizedDescription)
                }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

extension ViewController : UITableViewDelegate
{
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView?
    {
        let myLabel = UILabel(frame: CGRect(x: 0, y: 0, width: view.frame.width, height: 20))
        myLabel.font = UIFont.boldSystemFont(ofSize: 13)
        myLabel.text = "    " + (self.tableView(tableView, titleForHeaderInSection: section) ?? "")
        myLabel.backgroundColor = UIColor(red: 219/255.0, green: 226/255.0, blue: 237/255.0, alpha: 1.0)
        return myLabel
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 42
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String?
    {
        var leg1String, leg2String : String

        if startingStation == K.AppStrings.rathdrumStationString // NorthBound
        {
            leg1String = "Rathdrum to Greystones Departures ..."
            leg2String = "Greystones to Dalkey Departures ..."
        } else {
            leg1String = "Dalkey to Greystones Departures ..."
            leg2String = "Greystones to Rathdrum Departures ..."
        }

        switch section {
        case 0:
            return leg1String
        case 1:
            return leg2String
        default:
            return ""
        }
    }
}



extension ViewController : UITableViewDataSource
{
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        var arr1, arr2 :[StationData]
        if startingStation == K.AppStrings.rathdrumStationString // NorthBound
        {
            arr1 = stationsOfInterestNorthbound[K.AppStrings.rathdrumStationCode] ?? []
            arr2 = stationsOfInterestNorthbound[K.AppStrings.greystonesStationCode] ?? []
        } else {
            arr1 = stationsOfInterestSouthbound[K.AppStrings.dalkeyStationCode] ?? []
            arr2 = stationsOfInterestSouthbound[K.AppStrings.greystonesStationCode] ?? []
        }
        
        switch section {
        case 0:
            return (arr1.count == 0) ? 1 : arr1.count
        case 1:
            return (arr2.count == 0) ? 1 : arr2.count
        default:
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "TrainInfoCell", for: indexPath) as! TrainDataTableViewCell
        
        var arr1, arr2 :[StationData]
        if startingStation == K.AppStrings.rathdrumStationString // NorthBound
        {
            arr1 = stationsOfInterestNorthbound[K.AppStrings.rathdrumStationCode] ?? []
            arr2 = stationsOfInterestNorthbound[K.AppStrings.greystonesStationCode] ?? []
        } else {
            arr1 = stationsOfInterestSouthbound[K.AppStrings.dalkeyStationCode] ?? []
            arr2 = stationsOfInterestSouthbound[K.AppStrings.greystonesStationCode] ?? []
        }
        
        var theStation : StationData
        switch indexPath.section {
        case 0:
            if arr1.count == 0
            {
                cell.info.text = "No trains Listed"
                cell.minutes.text = ""
                return cell
            } else {
                theStation = arr1[indexPath.row]
            }
        case 1:
            if arr2.count == 0
            {
                cell.info.text = "No trains Listed"
                cell.minutes.text = ""
                return cell
            } else {
                theStation = arr2[indexPath.row]
            }
        default:
            cell.info.text = ""
            cell.minutes.text = ""
            return cell
        }
        
        let minuteString = "\(theStation.Duein.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines )) Mins"
        let delayText = (theStation.Late == "0") ? "On Time" : "Delayed \(theStation.Late) Mins"
        cell.minutes.text = minuteString
        cell.info.text = delayText
        
        return cell
    }
}





