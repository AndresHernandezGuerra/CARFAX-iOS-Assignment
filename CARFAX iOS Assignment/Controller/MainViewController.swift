//
//  MainViewController.swift
//  CARFAX iOS Assignment
//
//  Created by Andres S. Hernandez G. on 8/18/19.
//  Copyright © 2019 Andres S. Hernandez G. All rights reserved.
//

import UIKit

class MainViewController: UIViewController, UITableViewDataSource, UITabBarDelegate {

    // Outlet to tableview
    @IBOutlet weak var listingsTableView: UITableView!
    
    // API URL, can be changed and app behavior will remain functional as long as .json file keeps the format
    private var APIUrl = "https://carfax-for-consumers.firebaseio.com/assignment.json"
    
    // Initializing variables to populate and use when assigning the response from HTTP Request
    var carListings: [[String: Any]] = []
    var arrayCarListings = [CarDetails?]()
    
    // Activity view to show loading of data while the API call is completed (will be more useful if app is
    // used with slow internet connection
    public var activityView = UIActivityIndicatorView(style: .whiteLarge)

    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Setting up the ActivityView and starting animation right under the "Empty Screen View"
        activityView.frame = CGRect(x: self.view.bounds.midX - 50, y: self.view.bounds.midY + 65, width: 100, height: 100)
        self.view.addSubview(activityView)
        activityView.startAnimating()
        
        // Calling initial functions
        getCarListings()
        setupTableView()
    }
    
    // Basic operations for tableView setup
    private func setupTableView() {
        self.listingsTableView.separatorStyle = UITableViewCell.SeparatorStyle.singleLine
        self.listingsTableView.tableFooterView = UIView(frame: .zero)
        self.listingsTableView.reloadData()
    }
    
    // MARK: - Network Call (HTTP Response)
    func getCarListings() {
        // Checking URL to perform HTTP Request
        if let url = URL(string: APIUrl) {
            // Starting datatask and declaring completion handler (non-escaping)
            URLSession.shared.dataTask(with: url, completionHandler: {(data, response, error) in
                guard let data = data, error == nil else { return }
                
                // Isolating only the listings portion from large .json response and catching errors
                do {
                    let json = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as! [String:Any]
                    self.carListings = json["listings"] as? [[String: Any]] ?? []
                } catch let error as NSError {
                    print(error)
                }
                
                // Accessing each listing retrieved from listings object
                for myListing in self.carListings as [Any] {
                    do {
                        // Using JSON Serialization on recovered data
                        let jsonData = try JSONSerialization.data(withJSONObject: myListing, options: .prettyPrinted)
                        let listingString = String(data: jsonData, encoding: .utf8)
                        let listingData = listingString?.data(using: .utf8)
                        
                        // Decoding the JSON data and assigning it respectively to the model
                        let jsonDecoder = JSONDecoder()
                        let carListing = try jsonDecoder.decode(CarDetails.self, from: listingData!)
                        
                        // Append the carListing object in the array created above
                        self.arrayCarListings.append(carListing)
                        
                    // Standard Error catching and messages
                    } catch let DecodingError.dataCorrupted(context) {
                        print(context)
                    } catch let DecodingError.keyNotFound(key, context) {
                        print("Key '\(key)' not found:", context.debugDescription)
                        print("codingPath:", context.codingPath)
                    } catch let DecodingError.valueNotFound(value, context) {
                        print("Value '\(value)' not found:", context.debugDescription)
                        print("codingPath:", context.codingPath)
                    } catch let DecodingError.typeMismatch(type, context)  {
                        print("Type '\(type)' mismatch:", context.debugDescription)
                        print("codingPath:", context.codingPath)
                    } catch {
                        print("error: ", error)
                    }
                }
                
                // Asynchronously calling to setup TableView and reload data, as well as stopping ActivityView
                DispatchQueue.main.async {
                    self.activityView.stopAnimating()
                    self.setupTableView()
                }
            }).resume()
        }
    }
    
    
    // MARK: - TableView Methods Necessary
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // Assigning custom CarCell as reusable cell
        let carCell = tableView.dequeueReusableCell(withIdentifier: "carCell") as! CarCell
        
        // If there is a car listing corresponding to the row, then the cell is populated inside here
        if let currentCarDetails = self.arrayCarListings[indexPath.row] as CarDetails?{
            
            // First line of details populated
            carCell.detailedOne.text = "\(currentCarDetails.carYear ??? "N/A") \(currentCarDetails.carMake ?? "N/A") \(currentCarDetails.carModel ?? "N/A")"
            
            // Number formater to add commas where needed for thousands and greater values
            let numberFormatter = NumberFormatter()
            numberFormatter.numberStyle = .decimal
            
            var formattedPrice = String()
            var formattedMileage = String()
            
            // Conditionals checking and formatting price and mileage
            if let currentCarPrice = currentCarDetails.carPrice {
                formattedPrice = numberFormatter.string(from: NSNumber(value:currentCarPrice)) ?? "N/A"
            }
            if let currentCarMileage = currentCarDetails.carMileage {
                formattedMileage = numberFormatter.string(from: NSNumber(value:currentCarMileage)) ?? "N/A"
            }
            
            // Second line of details populated
            carCell.detailedTwo.text = "$" + formattedPrice + "   |   " + formattedMileage + " Miles" + "   |   " + "\(currentCarDetails.dealer?.city ?? "N/A"), \(currentCarDetails.dealer?.state ?? "N/A")"

            // Formatting and populating phone number
            if let currentDealerNumber = currentCarDetails.dealer?.phone {
                carCell.phoneNumber.text = formattedNumber(number: currentDealerNumber)
            }
            
            // Asynchronously updating the images to keep UI clean and smooth, also assigning fallback image
            DispatchQueue.main.async {
                carCell.carImage.downloaded(from: (currentCarDetails.carThumbnail?.firstPhoto?.largePhoto) ?? "https://icon-library.net/images/no-image-available-icon/no-image-available-icon-6.jpg")
            }
        }
        return carCell
    }
    
    // Showing "Empty Screen View" while data is being fetched, then restoring normal TableView
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if self.arrayCarListings.count == 0 {
            self.listingsTableView.setEmptyMessage("Used Car Listings Loading\n\nGathering Data From Server\n\nPlease Wait")
        } else {
            self.listingsTableView.restore()
        }
        
        return self.arrayCarListings.count
    }
}


// MARK: - Custom Nil Coalescing Operator
infix operator ???: NilCoalescingPrecedence
// This function allows you to perfom nil coalescing of Ints or any other type with a String as fallback
public func ??? <T>(optional: T?, defaultValue: @autoclosure () -> String) -> String {
    return optional.map { String(describing: $0) } ?? defaultValue()
}


// MARK: - Phone Number Formatting Function
private func formattedNumber(number: String) -> String {
    // (US format only), based on Stack Overflow thread
    let cleanPhoneNumber = number.components(separatedBy: CharacterSet.decimalDigits.inverted).joined()
    let mask = "(XXX) XXX-XXXX"
    
    var result = ""
    var index = cleanPhoneNumber.startIndex
    for char in mask where index < cleanPhoneNumber.endIndex {
        if char == "X" {
            result.append(cleanPhoneNumber[index])
            index = cleanPhoneNumber.index(after: index)
        } else {
            result.append(char)
        }
    }
    return result
}

// MARK: - Empty Screen View
extension UITableView {
    // Extending UITableView to allow for this initial, or loading screen to be displayed
    func setEmptyMessage(_ message: String) {
        let messageLabel = UILabel(frame: CGRect(x: 0, y: 0, width: self.bounds.size.width, height: self.bounds.size.height))
        messageLabel.text = message
        messageLabel.textColor = .black
        messageLabel.numberOfLines = 0
        messageLabel.textAlignment = .center
        messageLabel.font = UIFont.systemFont(ofSize: 15)
        messageLabel.sizeToFit()
        
        self.backgroundView = messageLabel;
        self.separatorStyle = .none
    }
    
    // Restoring the TableView (cleaning up empty message function) and showing car listings after loading
    func restore() {
        self.backgroundView = nil
        self.separatorStyle = .none
    }
}
