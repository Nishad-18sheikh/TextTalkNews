//
//  NewsFeedTableViewCell.swift
//  TextalkNews
//
//  Created by gwl on 05/05/22.
//

import UIKit
import SDWebImage

class NewsFeedTableViewCell: UITableViewCell {
    // MARK: All Outlets
    @IBOutlet weak var baseView: UIView!
    @IBOutlet weak var articleSummary: UILabel!
    @IBOutlet weak var articleHeadLines: UILabel!
    @IBOutlet weak var articleImage: UIImageView!
    @IBOutlet weak var nameAndDateLabel: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        self.baseView.setViewCornerRadius(radius: 4, boarderWidth: 1, boarderColor: .clear)
        self.articleImage.setImageCornerRadius(radius: 8, boarderWidth: 0.0, boarderColor: .clear)
    }
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    // MARK: Configure Cell
    func configureCellForNewsFeed(feedDetails: Response.Newsfeed) {
        if let headline = feedDetails.title {
            self.articleHeadLines.text = headline.htmlToString
        }
        if let summary = feedDetails.content {
            self.articleSummary.text = summary.htmlToString
        }
        if let newsThumbnail: String = feedDetails.urlToImage {
            DispatchQueue.main.async {
                if let encoded = newsThumbnail.addingPercentEncoding(withAllowedCharacters: .urlFragmentAllowed), let url = URL(string: encoded) {
                    self.articleImage.sd_setImage(with: url, placeholderImage: UIImage(named: "newsPlaceHolder"))
                } else {
                    self.articleImage.sd_setImage(with: URL(string: newsThumbnail), placeholderImage: nil)
                }
            }
        }
        if let publishDate = feedDetails.publishedAt {
            let date = publishDate.getDateWithMonthNameFormat(dateString: publishDate)
            self.nameAndDateLabel.text = date
        }
    }
}
extension String {
    var htmlToAttributedString: NSAttributedString? {
        return Data(utf8).htmlToAttributedString
    }
    var htmlToString: String {
        return htmlToAttributedString?.string ?? ""
    }
    func getDateWithMonthNameFormat(dateString: String) -> String { //Convert source formate to dMMMyyyy formate
        let formatter = DateFormatter()
        formatter.dateFormat = AppDateFormats.yyyyMMddTHHmmssZ.rawValue
        let startDate = formatter.date(from: dateString)
        formatter.dateFormat = AppDateFormats.dMMMyyyy.rawValue
        let startStringDate = formatter.string(from: startDate ?? Date())
        return startStringDate
    }
}
extension Data {
    var htmlToAttributedString: NSAttributedString? {
        do {
            return try NSAttributedString(data: self, options: [.documentType: NSAttributedString.DocumentType.html, .characterEncoding: String.Encoding.utf8.rawValue], documentAttributes: nil)
        } catch {
            print("error:", error)
            return nil
        }
    }
    var htmlToString: String {
        return htmlToAttributedString?.string ?? ""
    }
}
