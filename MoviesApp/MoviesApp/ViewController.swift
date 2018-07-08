//
//  ViewController.swift
//  MoviesApp
//
//  Created by Ajit Singh on 04/07/18.
//  Copyright © 2018 Assignment. All rights reserved.
//

import UIKit
import MoviesKit

let kApiKeyUserDefaultsKey = "ApiKeyUserDefaultsKey"
let kImageDownloadURLPrefix = "https://image.tmdb.org/t/p/w500";
let kDefaultMoviesFilterString = "Batman"

let posterImageCache = NSCache<AnyObject, AnyObject>()

// todo: add jailbroken check on settings button click and when reading
// apikey from Userdefaults

class ViewController: UIViewController, UITableViewDelegate {

    // MARK: - Properties
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView?
    @IBOutlet weak var tableView: UITableView!
    let searchController = UISearchController(searchResultsController: nil)
    
    var movies = [IMovie]()
    var moviesDownloader: MKMoviesDownloader?
    
    // MARK: - Lifecycle methods
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Setup the Search Controller
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search Movies"
        searchController.searchBar.delegate = self
        navigationItem.searchController = searchController
        definesPresentationContext = true

        // Initialize the MovieDownloader with API Key
        if let apiKey = self.getAPIKey() {
            moviesDownloader = MKMoviesDownloader(apiKey: apiKey)
        } else {
            moviesDownloader = MKMoviesDownloader()
        }
        
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
        // check if its a jailbroken device
        if self.isRunningOnJailBrokenDevice() {
            self.showError(title: "Error", message: "Operation not supported on a Jailbroken iOS device.")
        } else {
            var message = "Please enter the 32 char API Key."
            if let apiKey = self.getAPIKey() {
                message = """
                Existing API Key is \(apiKey)
                
                Please enter a new API key, if you wish to change.
                """
            }
            
            let alert = UIAlertController(title: "Configuration View", message: message, preferredStyle: UIAlertControllerStyle.alert)
            let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel, handler: nil)
            let saveAction = UIAlertAction(title: "Save", style: UIAlertActionStyle.default) { (alertAction) in
                let textField = alert.textFields?.first
                if (textField?.text?.count)! > 0 {
                    self.saveAPIKey((textField?.text)!)
                    self.filterContentForSearchText(kDefaultMoviesFilterString)
                }
            }
            alert.addAction(saveAction)
            alert.addAction(cancelAction)
            alert.addTextField { (textField) in
                textField.placeholder = "Enter API Key here"
            }
            self.present(alert, animated: true)
        }
    }
    
    // MARK: - Private instance methods
    func saveAPIKey(_ apiKey:String) {
        self.moviesDownloader?.setAPIKey(apiKey)
        let encryptedApiKey = Crypto.encrypt(input: apiKey)
        UserDefaults.standard.set(encryptedApiKey, forKey: kApiKeyUserDefaultsKey)
        UserDefaults.standard.synchronize()
    }
    
    func getAPIKey() -> String! {
        // check if its a jailbroken device
        if !self.isRunningOnJailBrokenDevice() {
            if let encryptedApiKey = UserDefaults.standard.object(forKey: kApiKeyUserDefaultsKey) {
                let apiKey = Crypto.decrypt(input: encryptedApiKey as! String)
                return apiKey
            }
        }
        return nil
    }
    
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
        self.showError(title: "Error", message: message)
    }
    
    func showError(title: String, message: String) {
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
    
    func isRunningOnJailBrokenDevice() -> Bool {
        if TARGET_IPHONE_SIMULATOR != 1
        {
            // Check 1 : existence of files that are common for jailbroken devices
            if FileManager.default.fileExists(atPath: "/Applications/Cydia.app")
                || FileManager.default.fileExists(atPath: "/Library/MobileSubstrate/MobileSubstrate.dylib")
                || FileManager.default.fileExists(atPath: "/bin/bash")
                || FileManager.default.fileExists(atPath: "/usr/sbin/sshd")
                || FileManager.default.fileExists(atPath: "/etc/apt")
                || FileManager.default.fileExists(atPath: "/private/var/lib/apt/")
                || UIApplication.shared.canOpenURL(URL(string:"cydia://package/com.example.package")!)
                    {
                    return true
            }
            // Check 2 : Reading and writing in system directories (sandbox violation)
            let stringToWrite = "Jailbreak Test"
            do
            {
                try stringToWrite.write(toFile:"/private/JailbreakTest.txt", atomically:true, encoding:String.Encoding.utf8)
                //Device is jailbroken
                return true
            }catch
            {
                return false
            }
        }else
        {
            return false
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
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let movie = movies[indexPath.row]
        let movieDetailsViewController:MovieDetailsViewController = self.storyboard?.instantiateViewController(withIdentifier: "MovieDetailsViewController") as! MovieDetailsViewController
        movieDetailsViewController.movie = movie
        self.navigationController?.pushViewController(movieDetailsViewController, animated: true)
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

