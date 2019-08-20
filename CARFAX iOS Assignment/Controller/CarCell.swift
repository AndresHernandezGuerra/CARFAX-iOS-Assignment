//
//  ScheduleCell.swift
//  Crowd Atlas
//
//  Created by Andres S. Hernandez G. on 7/22/19.
//  Copyright © 2019 Andres S. Hernandez G. All rights reserved.
//

import UIKit

class CarCell : UITableViewCell {
    
    // MARK: - Outlets
    @IBOutlet weak var detailedOne: UILabel!
    @IBOutlet weak var carImage: UIImageView!
    @IBOutlet weak var detailedTwo: UILabel!
    @IBOutlet weak var phoneNumber: UITextView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        // Initialization code for adjustable font inside second line of text (first line always fits)
        detailedTwo.font = UIFont.preferredFont(forTextStyle: .body)
        detailedTwo.adjustsFontForContentSizeCategory = true
        detailedTwo.adjustsFontSizeToFitWidth = true
    }
}


// MARK: - Custom Download Images and Load Asynchronously
extension UIImageView {
    // This function performs the datatask and assigns the returned image asynchronously
    func downloaded(from url: URL, contentMode mode: UIView.ContentMode = .scaleAspectFill) {
        contentMode = mode
        URLSession.shared.dataTask(with: url) { data, response, error in
            guard
                let httpURLResponse = response as? HTTPURLResponse, httpURLResponse.statusCode == 200,
                let mimeType = response?.mimeType, mimeType.hasPrefix("image"),
                let data = data, error == nil,
                let image = UIImage(data: data)
                else { return }
            DispatchQueue.main.async() {
                self.image = image
            }
            }.resume()
    }
    // Helper function to make it easier to call with a String only and not URL
    func downloaded(from link: String, contentMode mode: UIView.ContentMode = .scaleAspectFill) {
        guard let url = URL(string: link) else { return }
        downloaded(from: url, contentMode: mode)
    }
}
