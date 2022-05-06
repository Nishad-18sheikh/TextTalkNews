//
//  NewsFeedDeatilsViewController.swift
//  TextalkNews
//
//  Created by gwl on 06/05/22.
//

import UIKit
import Foundation

class NewsFeedDeatilsViewController: UIViewController {
    // MARK: All Outlets
    @IBOutlet weak var contentLabel: UILabel!
    @IBOutlet weak var newsImage: UIImageView!
    @IBOutlet weak var publishDateLabel: UILabel!
    @IBOutlet weak var headLineLabel: UILabel!
    @IBOutlet weak var authorNameLabel: UILabel!
    @IBOutlet weak var newsSourceButton: UIButton!
    // MARK: All Properties
    var feedDetail: Response.Newsfeed? = nil
    // MARK: Viewcontroller LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        initialSetUp()
        setUpDataInView()
        // Do any additional setup after loading the view.
    }
    // MARK: Custome Button Actions
    @IBAction func newsSourceButtonAction(_ sender: Any) {
        if let source = self.feedDetail?.url {
            self.navigateToNewsSource(sourceUrl: source)
        }
    }
}
// MARK: Custom function
extension NewsFeedDeatilsViewController {
    func initialSetUp() {
        addBackButton(title: "Feed Details")
        self.newsImage.setImageCornerRadius(radius: 8, boarderWidth: 0.0, boarderColor: .clear)
    }
    func setUpDataInView() {
        if let authorName = self.feedDetail?.author {
            self.authorNameLabel.text = "Auther Name: " + authorName.htmlToString
        }
        if let articaleSummary = self.feedDetail?.content {
            self.contentLabel.text = articaleSummary.htmlToString
        }
        if let headLine = self.feedDetail?.title {
            self.headLineLabel.text = headLine.htmlToString
        }
        if let publishDate = self.feedDetail?.publishedAt {
            self.publishDateLabel.text = publishDate.getDateWithMonthNameFormat(dateString: publishDate)
        }
        if let source = self.feedDetail?.url {
            newsSourceButton.setTitle(source, for: .normal)
        }
        if let newsThumbnail: String = feedDetail?.urlToImage {
            DispatchQueue.main.async {
                if let encoded = newsThumbnail.addingPercentEncoding(withAllowedCharacters: .urlFragmentAllowed), let url = URL(string: encoded) {
                    self.newsImage.sd_setImage(with: url, placeholderImage: UIImage(named: "newsPlaceHolder"))
                } else {
                    self.newsImage.sd_setImage(with: URL(string: newsThumbnail), placeholderImage: nil)
                }
            }
        }
    }
    func navigateToNewsSource(sourceUrl: String) {
        let newsSourceController: NewsSourceViewController = (UIStoryboard.init(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "NewsSourceViewController") as? NewsSourceViewController)!
        newsSourceController.url = sourceUrl
        self.navigationController?.pushViewController(newsSourceController, animated: true)
    }
}
