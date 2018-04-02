//
//  Router.swift
//  Commute2
//
//  Created by Derek Doherty on 22/03/2018.
//  Copyright © 2018 Derek Doherty. All rights reserved.
//

import Foundation
import Alamofire

// The Router used is the suggested pattern of AlamoFire
// for a baseUrl API
// URLRequestConvertible protocol demands URLRequest: NSMutableURLRequest computed property
//

enum Router: URLRequestConvertible
{
    static let baseURLString = "http://api.irishrail.ie/realtime/realtime.asmx/"
    
    case GetStationData(String, Int)
    
    // Computed property returns the method for each case
    //
    func asURLRequest() throws -> URLRequest
    {
        var method:Alamofire.HTTPMethod
        {
            switch self {
            case .GetStationData:
                return .get
            }
        }
        
        let params: ([String:String]?) = {
            switch self {
            case .GetStationData(let stationCode, let minutes):
                return ["StationCode" : stationCode, "NumMins" : String(minutes)]
            }
        }()
        
        let url:URL = {
            //Build up and return the URL for each endpoint
            //
            let relativePath:String?
            
            switch self
            {
            case .GetStationData:
                relativePath = "getStationDataByCodeXML_WithNumMins"
            }
            
            var url = URL(string:Router.baseURLString)!
            if let rp = relativePath {
                url = url.appendingPathComponent(rp)
            }
            return url
        }()
        
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = method.rawValue
        
        let encoding:ParameterEncoding = {
            switch self {
            case .GetStationData(_):
                return Alamofire.URLEncoding.default
            }
        }()
        let encodedRequest = try encoding.encode(urlRequest, with: params)
        return encodedRequest
    }

}
