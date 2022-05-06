//
//  Response.swift
//  TextalkNews
//
//  Created by gwl on 05/05/22.
//

import Foundation
enum Response {
    struct Newsfeed: Codable {
        var author: String?
        var title: String?
        var description: String?
        var url: String?
        var urlToImage: String?
        var publishedAt: String?
        var content: String?
    }
    struct Source: Codable {
        let id: String?
        let name: String?
    }
}
