//
//  MovieDetailsViewController.swift
//  MoviesApp
//
//  Created by Ajit Singh on 08/07/18.
//  Copyright © 2018 Assignment. All rights reserved.
//

import UIKit
import MoviesKit

class MovieDetailsViewController: UIViewController {

    var movie: IMovie?

    @IBOutlet weak var posterImage: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var voteLabel: UILabel!
    @IBOutlet weak var releaseDateLabel: UILabel!
    @IBOutlet weak var overviewTextView: UITextView!

    override func viewDidLoad() {
        super.viewDidLoad()

        if let movieObj = self.movie {
            let releaseDateStr = self.getDateInRequiredFormat(dateStr: movieObj.getReleaseDate())
            self.titleLabel.text = movieObj.getTitle()
            self.voteLabel.text = "Vote: Total - \(movieObj.getVoteCount()) Average - \(movieObj.getVoteAverage())"
            self.releaseDateLabel.text = "Release Date: \(releaseDateStr)"
            self.overviewTextView.text = movieObj.getOverview()

            let urlString = kImageDownloadURLPrefix + movieObj.getPosterPath()
            let imageUrl = URL(string: urlString)
            DispatchQueue.global(qos: .background).async {
                let imageData = try? Data(contentsOf: imageUrl!)
                if imageData != nil {
                    let image = UIImage(data: imageData!)
                    DispatchQueue.main.async {
                        self.posterImage.image = image
                    }
                } else {
                    print("Failed to download the movie poster")
                }
            }
        }
    }

    func getDateInRequiredFormat(dateStr: String) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let date = dateFormatter.date(from: dateStr)

        let targetDateFormatter = DateFormatter()
        targetDateFormatter.dateFormat = "MMM dd, YYYY"
        return targetDateFormatter.string(from: date!)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
