//
//  APICallable.swift
//  TextalkNews
//
//  Created by gwl on 05/05/22.
//

import Foundation

extension NetworkService {
    func getNewsFeed(categoryType: Categories, completionHandler:
                            @escaping (_ result: Result<APIResponse<[Response.Newsfeed]>, CourtError>) -> Void) {
        let parameter: String = getApiPath(categoryType: categoryType).0
        let endPoint = getApiPath(categoryType: categoryType).1
        getperformRequest(endpoint: endPoint, parameter: parameter, method: .GET,
                          completionHandler: completionHandler)

    }
    func getApiPath(categoryType: Categories) -> (String, Endpoint) {
        let currentDate = Date().currentDateString(formate: AppDateFormats.yyyyMMdd.rawValue) ?? ""
        var apiPath: String = ""
        var endPoint: Endpoint = .teslaNews
        if categoryType == Categories.tesla {
            apiPath  = "&from=\(currentDate)" + "&sortBy=publishedAt" + "&apiKey=\(AppEnvironment.apiKey)"
            endPoint = .teslaNews
        }
        if categoryType == Categories.business {
            apiPath  =  "&category=business" + "&apiKey=\(AppEnvironment.apiKey)"
            endPoint = .business
        }
        if categoryType == Categories.techCrunch {
            apiPath  =  "techcrunch" + "&apiKey=\(AppEnvironment.apiKey)"
            endPoint = .techCrunch
        }
        if categoryType == Categories.wallStreet {
            apiPath  =  "wsj.com" + "&apiKey=\(AppEnvironment.apiKey)"
            endPoint = .wallStreet
        }
        if categoryType == Categories.apple {
            apiPath  =  "&from=\(currentDate)" + "&to=\(currentDate)" + "&sortBy=publishedAt" + "&apiKey=\(AppEnvironment.apiKey)"
            endPoint = .appleNews
        }
        return (apiPath, endPoint)
    }
}
