//
//  Requests.swift
//  VirtalTourist3
//
//  Created by Raghad Mah on 26/01/2019.
//  Copyright © 2019 Udacity. All rights reserved.
//

import Foundation


class Requests {
    
    static let sharedInstance = Requests()
    
    func getPhotosforLocation(_ latitude: Double, _ longitude: Double,_ page: Int, _ completion: @escaping (_ success: Bool, _ data: [[String: Any]]? ) -> Void) {
        
        //1.Set the parameters
        let params = [ParameterKeys.APIKey: Constants.APIKey,ParameterKeys.Method: Methods.SearchMethod,ParameterKeys.Extras: ParameterValues.MediumURL,ParameterKeys.Format: ParameterValues.ResponseFormat,ParameterKeys.Lat: String(describing: latitude),ParameterKeys.Lon: String(describing: longitude),ParameterKeys.Page: "\(randomPage.randomPageNumber())",ParameterKeys.PerPage: "20",ParameterKeys.NoJSONCallback: ParameterValues.DisableJSONCallback] as [String: Any]
        
        //2. Build the url
        var components = URLComponents()
        components.scheme = Constants.APIScheme
        components.host = Constants.APIHost
        components.path = Constants.APIPath
        components.queryItems = [URLQueryItem]()
        
        for (key, value) in params {
            let queryItem = URLQueryItem(name: key, value: "\(value)")
            components.queryItems!.append(queryItem)
        }
        
        //3. Make the request
        let request = URLRequest(url: components.url!)
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            
            func showError(_ errorString: String) {
                print(errorString)
                completion(false, nil)
                return
            }
            
            //GUARD was there any errors?
            guard (error == nil) else {
                showError("There was an error with your request.")
                return
            }
            
            //GUARD did we get a statusCode other than 2xx?
            guard let statusCode = (response as? HTTPURLResponse)?.statusCode , statusCode >= 200 && statusCode < 300 else {
                showError("Unsuccessful request response retured.")
                return
            }
            
            let parsedData: [String: AnyObject]!
            do {
                parsedData = try JSONSerialization.jsonObject(with: data!, options: .allowFragments) as? [String: AnyObject]
            } catch {
                showError("Could not parse data")
                return
            }
            
            guard let photos = parsedData[ResponseKeys.Photos] as! [String: Any]?,
                let photo = photos[ResponseKeys.Photo] as! [[String: Any]]? else {
                    showError("Could not extract photos and/or photo dict")
                    return
            }
            
            completion(true, photo)
        }
        //7.start the request
        task.resume()
    }
    
    struct randomPage {
        static func randomPageNumber() -> Int {
            return Int.random(in: 0 ... 10)
        }
    }
}

