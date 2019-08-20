//
//  ScheduleCell.swift
//  Crowd Atlas
//
//  Created by Andres S. Hernandez G. on 7/22/19.
//  Copyright © 2019 Andres S. Hernandez G. All rights reserved.
//

import UIKit

class CarCell : UITableViewCell {
    
    
    @IBOutlet weak var detailedOne: UILabel!
    @IBOutlet weak var carImage: UIImageView!
    @IBOutlet weak var detailedTwo: UILabel!
    @IBOutlet weak var phoneNumber: UITextView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        detailedTwo.font = UIFont.preferredFont(forTextStyle: .body)
        detailedTwo.adjustsFontForContentSizeCategory = true
        detailedTwo.adjustsFontSizeToFitWidth = true
    }
}


// Extension of UIImageView for asynchronously loading images
extension UIImageView {
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
    func downloaded(from link: String, contentMode mode: UIView.ContentMode = .scaleAspectFill) {
        guard let url = URL(string: link) else { return }
        downloaded(from: url, contentMode: mode)
    }
}
