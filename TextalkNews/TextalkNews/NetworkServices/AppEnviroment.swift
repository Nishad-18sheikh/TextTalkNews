//
//  AppEnviroment.swift
//  TextalkNews
//
//  Created by gwl on 05/05/22.
//

import Foundation
import UIKit

enum AppEnvironmentType: String {
    case DEV
    case QA
    case STAGING
    case PRODUCTION
}
final class AppEnvironment {
    static let current: AppEnvironment = AppEnvironment()
    static let apiKey = "2851d74c3c1542679ae1fd834128ba6e"
    var type: AppEnvironmentType = .PRODUCTION
    private init() {
        #if DEV
        self.type = .DEV
        #elseif QA
        self.type = .QA
        #elseif STG
        self.type = .STAGING
        #else
        self.type = .PRODUCTION
        #endif
    }
    func baseURL() -> String {
        switch type {
        case .DEV:
            return "https://newsapi.org/v2/"
        case .QA:
            return "https://newsapi.org/v2/"
        case .STAGING:
            return "https://newsapi.org/v2/"
        case .PRODUCTION:
            return "https://newsapi.org/v2/"
        }
    }
}
