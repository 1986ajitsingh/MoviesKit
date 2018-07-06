//
//  ViewController.swift
//  MoviesApp
//
//  Created by Ajit Singh on 04/07/18.
//  Copyright © 2018 Assignment. All rights reserved.
//

import UIKit
import MoviesKit

let kApiKey = "03feb58bd1b21fa9943cf0fda5ea8f71"
let kImageDownloadURLPrefix = "https://image.tmdb.org/t/p/w500";
let kDefaultMoviesFilterString = "Batman"

let posterImageCache = NSCache<AnyObject, AnyObject>()

class ViewController: UIViewController, UITableViewDelegate {

    // MARK: - Properties
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView?
    @IBOutlet weak var tableView: UITableView!
    let searchController = UISearchController(searchResultsController: nil)
    
    var movies = [IMovie]()
    let moviesDownloader = MKMoviesDownloader(apiKey: kApiKey)
    
    // MARK: - Lifecycle methods
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Setup the Search Controller
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search Movies"
        searchController.searchBar.delegate = self
        navigationItem.searchController = searchController
        definesPresentationContext = true

        // Initially load the default filter
        self.filterContentForSearchText(kDefaultMoviesFilterString)
        
        posterImageCache.countLimit = 20
        
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - IBActions
    @IBAction func showInfoScreen(_ sender: UIBarButtonItem) {
        let infoController = self.storyboard?.instantiateViewController(withIdentifier: "InfoScreen")
        self.navigationController?.pushViewController(infoController!, animated: true)
    }
    
    @IBAction func showSettingsScreen(_ sender: UIBarButtonItem) {
        let alert = UIAlertController(title: "Enter API Key", message: "Please enter the 32 char API Key.", preferredStyle: UIAlertControllerStyle.alert)
        let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel, handler: nil)
        let saveAction = UIAlertAction(title: "Save", style: UIAlertActionStyle.default) { (alertAction) in
            
        }
        alert.addAction(saveAction)
        alert.addAction(cancelAction)
        alert.addTextField { (textField) in
            textField.placeholder = "Existing API key"
        }
        self.present(alert, animated: true)
    }
    
    // MARK: - Private instance methods
    func filterContentForSearchText(_ searchText: String, scope: String = "All") {
        self.showLoading()
        self.moviesDownloader?.downloadLatestMovies(forSearchFilter: searchText) { (error, movies) in
            self.hideLoading()
            if (error == nil) {
                self.movies = movies as! [IMovie]
                self.tableView .reloadData()
            } else {
                // handle error
                self.handleError(error: error! as NSError)
            }
        }
    }
    
    func handleError(error:NSError) {
        let message: String = self.mapErrorCodeToErrorMessage(errorCode: DownloadErrorCodes(rawValue: downloadErrorCodes.RawValue(error.code)))
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.cancel, handler: nil))
        self.present(alert, animated: true)
    }
    
    func mapErrorCodeToErrorMessage(errorCode: DownloadErrorCodes) -> String {
        switch errorCode {
        case MINIMUM_TWO_CHARACTER_SEARCH_FILTER_REQUIRED_ERROR:
            return "Minimum two characters search filter is required."
        case ANOTHER_DOWNLOAD_IS_IN_PROGRESS_ERROR:
            return "Another download is in progress. Please try again later."
        case API_KET_IS_NOT_SET_ERROR:
            return "API Key is not set."
        case NETWORK_ERROR:
            return "Network Error. Please try again later."
        case INVALID_RESPONSE_ERROR:
            return "Invalid response. Please try again."
        case INVALID_API_KEY_ERROR:
            return "API Key is not valid. Please enter a valid API Key."
        case RESPONSE_PARSING_ERROR:
            return "Error parsing response. Please try again."
        case NO_MOVIES_FOUND_MATCHING_SEARCH_FILTER:
            return "No movies found matching the given search filter."
        default:
            return "Unknown error"
        }
    }
    
    func showLoading() {
        self.tableView.isUserInteractionEnabled = false
        self.searchController.searchBar.isUserInteractionEnabled = false
        
        self.activityIndicator?.isHidden = false
        self.activityIndicator?.startAnimating()
    }
    
    func hideLoading() {
        self.tableView.isUserInteractionEnabled = true
        self.searchController.searchBar.isUserInteractionEnabled = true
        
        self.activityIndicator?.isHidden = true
        self.activityIndicator?.stopAnimating()
    }
    
    func getAverageVoteString(voteAverage: Int32) -> String {
        return String(format: "Vote Average: %d", voteAverage)
    }
    
    func setPosterImageForCell(_ movieCell: MovieCell, AtIndexPath indexPath: IndexPath, fromPosterPath posterPath: String) {
        let urlString = kImageDownloadURLPrefix + posterPath
        
        if let imageFromCache = posterImageCache.object(forKey: urlString as AnyObject) as? UIImage {
            movieCell.posterImage.image = imageFromCache
            return
        }
        
        let imageUrl = URL(string: urlString);
        movieCell.tag = indexPath.row
        DispatchQueue.global(qos: .background).async {
            let imageData = try? Data(contentsOf: imageUrl!)
            if (imageData != nil) {
                let image = UIImage(data: imageData!)
                posterImageCache.setObject(image!, forKey: urlString as AnyObject)
                
                DispatchQueue.main.async {
                    if (movieCell.tag == indexPath.row) {
                        movieCell.posterImage.image = image
                    }
                }
            } else {
                print("Failed to download the movie poster")
            }
        }
    }
}

// MARK: - Table View
extension ViewController : UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return movies.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell:MovieCell = tableView.dequeueReusableCell(withIdentifier: "MovieCell", for: indexPath) as! MovieCell
        
        let movie = movies[indexPath.row]
        cell.titleLabel.text = movie.getTitle()
        cell.averageVoteLabel.text = self.getAverageVoteString(voteAverage: movie.getVoteAverage())
        cell.releaseDateLabel.text = movie.getReleaseDate()
        
        let posterPath:String! = movie.getPosterPath()
        if posterPath != nil && posterPath.count > 0 {
            self.setPosterImageForCell(cell, AtIndexPath: indexPath, fromPosterPath: posterPath)
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 200
    }
}

// MARK: - UISearchBarDelegate
extension ViewController : UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        filterContentForSearchText(searchBar.text!)
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        // Reset to default content
        filterContentForSearchText(kDefaultMoviesFilterString)
    }
}

