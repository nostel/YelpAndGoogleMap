//
//  WebserviceHelper.swift
//  YelpAndGoogleMap
//
//  Created by Son Le on 7/1/17.
//  Copyright © 2017 Son Le. All rights reserved.
//

import Foundation

import Alamofire
import SwiftyJSON

class WebserviceHelper {
    
    static let sharedInstance = WebserviceHelper()
    
    private init() {}
    
    func getYelpAccessToken(forced: Bool = false, successHandler: @escaping () -> Void, errorHandler: @escaping (_ errorMessage: String) -> Void) {
        let userDefaults = UserDefaults.standard
        if !forced, let token = userDefaults.value(forKey: "YELP_ACCESS_TOKEN") as? String {
            Constants.YELP_ACCESS_TOKEN = token
            successHandler()
        } else {
            let parameters: Parameters = [
                "grant_type": "client_credentials",
                "client_id": Constants.YELP_CLIENT_ID,
                "client_secret": Constants.YELP_CLIENT_SECRET
            ]
            
            Alamofire.request(Constants.YelpAPIUrls.GET_ACCESS_TOKEN, method: .post, parameters: parameters).responseJSON(completionHandler: { response in
                switch response.result {
                case .success:
                    if let value = response.result.value {
                        let json = JSON(value)
                        if let token = json["access_token"].string {
                            userDefaults.set(token, forKey: "YELP_ACCESS_TOKEN")
                            userDefaults.synchronize()
                            Constants.YELP_ACCESS_TOKEN = token
                            successHandler()
                        } else {
                            errorHandler("Cannot get access token.")
                        }
                    } else {
                        errorHandler("Cannot get access token.")
                    }
                    break
                case .failure(let error):
                    errorHandler(error.localizedDescription)
                    break
                }
            })
        }
    }
    
    func loadBusinessesForLatLong(latitude: Double, longitude: Double, successHandler: @escaping (_ businessesArray: Array<Business>) -> Void,
                                  errorHandler: @escaping (_ errorMessage: String) -> Void) {
        
        let parameters: Parameters = [
            "latitude": latitude,
            "longitude": longitude,
            "term": Constants.YELP_SEARCH_RESTAUTANT,
            "limit": Constants.YELP_SEARCH_LIMIT
        ]
        
        self.loadData(urlStr: Constants.YelpAPIUrls.SEARCH, parameters: parameters, successHandler: { json in
            let busineseses = json["businesses"].arrayValue.map { businessJ in
                return Business(json: businessJ)
            }
            successHandler(busineseses)
           
        }, errorHandler: errorHandler)
        
    }
    
    func loadReviewsForBusiness(id: String, successHandler: @escaping (_ reviewsArray: Array<Review>) -> Void,  errorHandler: @escaping (_ errorMessage: String) -> Void) {
        
        let urlStr = Constants.YelpAPIUrls.getReviews(id: id)
        
        self.loadData(urlStr: urlStr, successHandler: { json in
            let reviews = json["reviews"].arrayValue.map { reviewJ in
                return Review(json: reviewJ)
            }
            successHandler(reviews)
        }, errorHandler: errorHandler)
    }
    
    private func loadData(forced: Bool = false, retrying: Int = 0, urlStr: String, parameters: Parameters? = nil, successHandler: @escaping (_ json: JSON) -> Void, errorHandler: @escaping (_ errorMessage: String) -> Void) {
        
        if retrying > Constants.LOADING_RETRYING {
            errorHandler("Cannot get access token.")
            return
        }
        
        let loadingGroup = DispatchGroup()
        loadingGroup.enter()
        self.getYelpAccessToken(forced: forced, successHandler: {
            loadingGroup.leave()
        }, errorHandler: errorHandler)
        
        loadingGroup.notify(queue: DispatchQueue.main) {
            
            let headers: HTTPHeaders = [
                "Authorization": Constants.YelpAPIUrls.getAuthorizationHeader()
            ]
            
            Alamofire.request(urlStr, parameters: parameters, headers: headers).responseJSON { response in
                switch response.result {
                case .success:
                    if let value = response.result.value {
                        let json = JSON(value)
                        let error = json["error"]
                        if error.exists() {
                            if let code = error["code"].string {
                                if code.lowercased().contains("token") {
                                    let nextRetrying = retrying + 1
                                    self.loadData(forced: true, retrying: nextRetrying, urlStr: urlStr, parameters: parameters, successHandler: successHandler, errorHandler: errorHandler)
                                    
                                } else if let description = error["description"].string {
                                    errorHandler(description)
                                } else {
                                    errorHandler("An unknown error has occurred when trying to load data.")
                                }
                            } else if let description = error["description"].string {
                                errorHandler(description)
                            } else {
                                errorHandler("An unknown error has occurred when trying to load data.")
                            }
                        } else {
                            successHandler(json)
                        }
                    }
                case .failure(let error):
                    errorHandler(error.localizedDescription)
                }
            }
            
        }
    }
    
}
