//
//  NewsFeedViewController.swift
//  TextalkNews
//
//  Created by gwl on 05/05/22.
//

import UIKit
enum Categories: String {
    case tesla
    case business
    case techCrunch
    case wallStreet
    case apple
}
class NewsFeedViewController: UIViewController {
    // MARK: All Outlets
    @IBOutlet weak var categoriesCollectionView: UICollectionView!
    @IBOutlet weak var newsFeedTableView: UITableView!
    @IBOutlet weak var noDataFoundView: UIView!
    @IBOutlet weak var errorLabel: UILabel!
    // MARK: All Properties
    var activityIndicatorView: ActivityIndicatorView!
    var newsFeedList: [Response.Newsfeed] = []
    lazy var viewModel: NewsFeedViewModel = {
        return NewsFeedViewModel()
    }()
    var category: [String] = ["Tesla", "Business", "TechCrunch", "Wall Street", "Apple"]
    // MARK: ViewController Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        initialSetup()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        self.navigationController?.navigationBar.isHidden = true
    }
    override func viewDidDisappear(_ animated: Bool) {
        self.navigationController?.navigationBar.isHidden = false
    }
}
// MARK: Collection view Deleaget and Datasource
extension NewsFeedViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return category.count
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath:IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "category", for: indexPath) as! NewsFeedCollectionViewCell
        cell.contentView.layer.cornerRadius = 10
        cell.contentView.layer.borderWidth = 1.0
        cell.contentView.layer.borderColor = UIColor.clear.cgColor
        cell.contentView.layer.masksToBounds = true
        cell.configureCellForNewsFeedCategory(categoryName: category[indexPath.item])
        return cell
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        self.activityIndicatorView = ActivityIndicatorView(title: "Processing...", center: self.view.center)
        self.view.addSubview(self.activityIndicatorView.getViewActivityIndicator())
        self.activityIndicatorView.startAnimating()
        if category[indexPath.item] == "Tesla" {
            viewModel.callApiForGetTeslaNews(type: Categories.tesla)
        } else if category[indexPath.item] == "Business" {
            viewModel.callApiForGetTeslaNews(type: Categories.business)
        } else if category[indexPath.item] == "TechCrunch" {
            viewModel.callApiForGetTeslaNews(type: Categories.techCrunch)
        } else if category[indexPath.item] == "Wall Street" {
            viewModel.callApiForGetTeslaNews(type: Categories.wallStreet)
        } else if category[indexPath.item] == "Apple" {
            viewModel.callApiForGetTeslaNews(type: Categories.apple)
        }

    }
}
// MARK: TableView Delegate and DataSource
extension NewsFeedViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.newsFeedList.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let feedCell = self.newsFeedTableView.dequeueReusableCell(withIdentifier: "feedCell",
                                    for: indexPath) as? NewsFeedTableViewCell else {return UITableViewCell()}
        feedCell.configureCellForNewsFeed(feedDetails: self.newsFeedList[indexPath.row])
        return feedCell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        navigateToNewsFeedDeatils(feedDetails: self.newsFeedList[indexPath.row])
    }
}
// MARK: Custome function
extension NewsFeedViewController {
    func initialSetup() {
        self.activityIndicatorView = ActivityIndicatorView(title: "Processing...", center: self.view.center)
        self.view.addSubview(self.activityIndicatorView.getViewActivityIndicator())
        self.noDataFoundView.isHidden = true
        categoriesCollectionView.reloadData()
        self.viewModel.delegate = self
        self.activityIndicatorView.startAnimating()
        viewModel.callApiForGetTeslaNews(type: Categories.tesla)
    }
    func navigateToNewsFeedDeatils(feedDetails: Response.Newsfeed) {
        let detailController: NewsFeedDeatilsViewController = (UIStoryboard.init(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "NewsFeedDeatilsViewController") as? NewsFeedDeatilsViewController)!
        detailController.feedDetail = feedDetails
        self.navigationController?.pushViewController(detailController, animated: true)
    }
}
extension NewsFeedViewController: NewsFeedProtocol {
    func error(errorMessage: String) {
        self.noDataFoundView.isHidden = false
        self.errorLabel.text = errorMessage
        self.activityIndicatorView.stopAnimating()
    }
    func newsFeedSuccessData(newsFeedResponse: [Response.Newsfeed]) {
        self.newsFeedList.removeAll()
        self.newsFeedList = newsFeedResponse
        if self.newsFeedList.count != 0 {
            self.newsFeedTableView.isHidden = false
            self.noDataFoundView.isHidden = true
            self.newsFeedTableView.reloadData()
        } else {
            self.newsFeedTableView.isHidden = true
            self.noDataFoundView.isHidden = false
            self.errorLabel.text = "News Not Found....."
        }
        self.activityIndicatorView.stopAnimating()
    }
}
extension UIViewController {
    func addBackButton(title: String) {
        let backBtn: UIButton = UIButton(type: .custom)
        backBtn.frame = CGRect(x: 0, y: 0, width: 30, height: 30)
        let backBtnImage = UIImage(named: "back")
        backBtn.setImage(backBtnImage, for: UIControl.State())
        backBtn.addTarget(self, action: #selector(self.goBack(_:)), for: UIControl.Event.touchUpInside)
        let backButton: UIBarButtonItem = UIBarButtonItem(customView: backBtn)
        self.navigationItem.title = title
        self.navigationItem.leftBarButtonItem = backButton
    }
    @objc func goBack(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
}
