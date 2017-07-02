//
//  Constants.swift
//  YelpAndGoogleMap
//
//  Created by Son Le on 7/1/17.
//  Copyright © 2017 Son Le. All rights reserved.
//

import Foundation

struct Constants {
    
    struct YelpAPIUrls {
        
        static let GET_ACCESS_TOKEN = "https://api.yelp.com/oauth2/token"
        
        static let GET_BUSINESSES = "https://api.yelp.com/v3/businesses/"
        
        static let SEARCH = YelpAPIUrls.GET_BUSINESSES + "search"
        
        static func getReviews(id: String) -> String {
            return YelpAPIUrls.GET_BUSINESSES + id + "/reviews"
        }
        
        static func getAuthorizationHeader() -> String {
            return "Bearer \(Constants.YELP_ACCESS_TOKEN)"
        }
    }
    
    static let GOOGLE_MAPS_API_KEY = "AIzaSyCVEnxS6RPykDW3oLVhH36LLlUP9f6pEaE"
    
    static let YELP_CLIENT_ID = "PwnX-DgoCHaZtHvJJR_Gxg"
    
    static let YELP_CLIENT_SECRET = "ulm27z7FoTAINZjMP5BP6PUTtsR2ePJNlgysczL6713jvIhNsVLHAJRa01s1QKQS"
    
    static var YELP_ACCESS_TOKEN = ""
    
    static let LOADING_RETRYING = 3
    
    static let YELP_SEARCH_RESTAUTANT = "Restaurants"
    static let YELP_SEARCH_LIMIT = 50
    
}
