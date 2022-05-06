//
//  NewsFeedCollectionViewCell.swift
//  TextalkNews
//
//  Created by gwl on 06/05/22.
//

import UIKit

class NewsFeedCollectionViewCell: UICollectionViewCell {
    // MARK: All Outlets
    @IBOutlet weak var categoryNameLabel: UILabel!
    // MARK: Configure Cell Data
    func configureCellForNewsFeedCategory(categoryName: String) {
        categoryNameLabel.text = categoryName
    }
}
