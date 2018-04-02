//
//  XmlparserHandler.swift
//  Commute2
//
//  Created by Derek Doherty on 23/03/2018.
//  Copyright © 2018 Derek Doherty. All rights reserved.
//

import Foundation


class XmlParserHandler : NSObject
{

    var xmlText:String = ""
    var StationDataArray:[StationData] = []
    var currentStationData:StationData!
    var direction:String = ""
    
    func parseTrainData(xmlData:Data, direction:String) -> [StationData]
    {
        let xp = XMLParser(data: xmlData)
        self.direction = direction
        xp.delegate = self
        xp.shouldProcessNamespaces = true
        xp.parse()
        
        return StationDataArray
    }
}

extension XmlParserHandler : XMLParserDelegate
{
    func parserDidStartDocument(_ parser: XMLParser) {
        print ("XML Parse Started")
    }
    
    func parserDidEndDocument(_ parser: XMLParser) {
        print ("XML Parse Finished")
    }
    
    func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String] = [:])
    {
        xmlText = ""
        if ( elementName == "objStationData")
        {
            currentStationData = StationData()
        }

    }
    
    func parser(_ parser: XMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?)
    {
        xmlText = xmlText.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines )
        if (qName == "Servertime" )
        {
            currentStationData.Servertime =  xmlText
        }
        else if (qName == "Traincode")
        {
            currentStationData.Traincode = xmlText
        }
        else if (qName == "Stationfullname")
        {
            currentStationData.Stationfullname = xmlText
        }
        else if (qName == "Stationcode")
        {
            currentStationData.Stationcode = xmlText
        }
        else if (qName == "Querytime")
        {
            currentStationData.Querytime = xmlText
        }
        else if (qName == "Traindate")
        {
            currentStationData.Traindate = xmlText
        }
        else if (qName == "Origin")
        {
            currentStationData.Origin = xmlText
        }
        else if (qName == "Destination")
        {
            currentStationData.Destination = xmlText
        }
        else if (qName == "Origintime")
        {
            currentStationData.Origintime = xmlText
        }
        else if (qName == "Destinationtime")
        {
            currentStationData.Destinationtime = xmlText
        }
        else if (qName == "Status")
        {
            currentStationData.Status = xmlText
        }
        else if (qName == "Lastlocation")
        {
            currentStationData.Lastlocation = xmlText
        }
        else if (qName == "Duein")
        {
            currentStationData.Duein = xmlText
        }
        else if (qName == "Late")
        {
            currentStationData.Late = xmlText
        }
        else if (qName == "Exparrival")
        {
            currentStationData.Exparrival = xmlText
        }
        else if (qName == "Expdepart")
        {
            currentStationData.Expdepart = xmlText
        }
        else if (qName == "Scharrival")
        {
            currentStationData.Scharrival = xmlText
        }
        else if (qName == "Schdepart")
        {
            currentStationData.Schdepart = xmlText
        }
        else if (qName == "Direction")
        {
            currentStationData.Direction = xmlText
        }
        else if (qName == "Traintype")
        {
            currentStationData.Traintype = xmlText
        }
        else if (qName == "Locationtype")
        {
            currentStationData.Locationtype = xmlText
        }
        // This is the closing element can add above object to array now
        else if (qName == "objStationData")
        {
            // Need to filter for selected direction
            if ( currentStationData.Direction == direction)
            {
                // If this station Info for Dalkey Southbound then only want Trains
                // Going to GreyStones and not just to Bray!
                if (direction == "Southbound") && ( currentStationData.Stationcode == "DLKEY")
                {
                    if currentStationData.Destination != "Greystones"
                    {
                        return
                    }
                }
                // If this station Info for Greystones Southbound then only want Trains
                // Going to Rathdrum and not just to Bray!
                if (direction == "Southbound") && ( currentStationData.Stationcode == "GSTNS")
                {
                    if currentStationData.Destination != "Rosslare Europort"
                    {
                        return
                    }
                }
                StationDataArray.append(currentStationData)
            }

        }
    }
    func parser(_ parser: XMLParser, foundCharacters string: String)
    {
        xmlText.append(string)
    }
    func parser(_ parser: XMLParser, parseErrorOccurred parseError: Error)
    {
        print("Parse Error: ", parseError.localizedDescription)
    }
}


