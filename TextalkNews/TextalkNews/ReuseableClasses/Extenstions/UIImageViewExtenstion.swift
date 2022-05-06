//
//  UIImageViewExtenstion.swift
//  TextalkNews
//
//  Created by gwl on 06/05/22.
//

import Foundation
import UIKit
extension UIImageView {
    func setImageCornerRadius(radius: CGFloat, boarderWidth: Double, boarderColor: UIColor) {
        layer.cornerRadius = radius
        layer.borderWidth = CGFloat(boarderWidth)
        layer.borderColor = boarderColor.cgColor
    }
    func convertImagetobase64UrlString() -> String {
        let imagePostPrefix: String = "data:image/png;base64,"
        var strBase64 = ""
        var imageData = self.image?.jpegData(compressionQuality: 0.8) // UIImageJPEGRepresentation(image, 1.0)
        var imageSize: Int = imageData?.count ?? 0
        imageSize = (imageData?.count ?? 0)
        imageSize = (imageSize / 1024)/1024
        debugPrint("Original size of image in MB: %f ", (imageSize / 1024)/1024)
        if imageData != nil {
            if imageSize >= 1 {
                imageData = image?.jpegData(compressionQuality: 0.8)
            }
            strBase64 = imagePostPrefix + (imageData?.base64EncodedString(options:
                                                            .lineLength64Characters) ?? "")
        }
        return strBase64
    }
}
