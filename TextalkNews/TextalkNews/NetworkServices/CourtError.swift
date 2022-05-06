//
//  CourtError.swift
//  TextalkNews
//
//  Created by gwl on 05/05/22.
//

import Foundation

struct CourtError: Codable, Error {
    var error: ErrorData
    init(nsError: NSError) {
        self.error = ErrorData(errorMessage: nsError.localizedDescription, errorCode: "\(nsError.code)")
    }
    init(error: ErrorData) {
        self.error = error
    }
    struct ErrorData: Codable {
        var errorMessage: String
        let errorCode: String?
    }
}

extension Error {
    var courtError: CourtError {
        return CourtError(nsError: self as NSError)
    }
}

extension CourtError {
    static let noInternet =  CourtError(error: .init(errorMessage: "No Internet connection", errorCode: "404"))
    static let unknownError =  CourtError(error: .init(errorMessage: "Unknown Error occured", errorCode: "400"))
    static let empty =  CourtError(error: .init(errorMessage: "Data is empty", errorCode: "400"))
    static let parameterError =  CourtError(error: .init(errorMessage: "Unable to parse parameters", errorCode: "400"))
}
