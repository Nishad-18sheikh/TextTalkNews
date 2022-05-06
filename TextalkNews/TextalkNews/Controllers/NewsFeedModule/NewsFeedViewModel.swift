//
//  NewsFeedViewModel.swift
//  TextalkNews
//
//  Created by gwl on 05/05/22.
//

import Foundation
protocol NewsFeedProtocol: AnyObject {
    func error(errorMessage: String)
    func newsFeedSuccessData(newsFeedResponse: [Response.Newsfeed])
}
class NewsFeedViewModel: NSObject {
    weak var delegate: NewsFeedProtocol?
    func callApiForGetTeslaNews(type: Categories) {
        NetworkService.shared.getNewsFeed(categoryType: type, completionHandler: { result in
            switch result {
            case .success(let response):
               self.delegate?.newsFeedSuccessData(newsFeedResponse: response.articles)
            case .failure(let error): debugPrint(error.error.errorMessage)
                self.delegate?.error(errorMessage: error.error.errorMessage)
            }
        })
    }
}
