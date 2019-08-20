//
//  MainViewController.swift
//  CARFAX iOS Assignment
//
//  Created by Andres S. Hernandez G. on 8/18/19.
//  Copyright © 2019 Andres S. Hernandez G. All rights reserved.
//

import UIKit

class MainViewController: UIViewController, UITableViewDataSource, UITabBarDelegate {

    @IBOutlet weak var listingsTableView: UITableView!
    
    private var APIUrl = "https://carfax-for-consumers.firebaseio.com/assignment.json"
    var carListings: [[String: Any]] = []
    
    var arrayCarListings = [CarDetails?]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        getCarListings()
        setupTableView()
        
    }
    
    private func setupTableView() {
        // Assign delegate and datasource to table view
        self.listingsTableView.separatorStyle = UITableViewCell.SeparatorStyle.singleLine
        self.listingsTableView.tableFooterView = UIView(frame: .zero)
        self.listingsTableView.reloadData()
    }
    
    
    func getCarListings() {
        if let url = URL(string: APIUrl) {
            URLSession.shared.dataTask(with: url, completionHandler: {(data, response, error) in
                guard let data = data, error == nil else { return }
                
                do {
                    let json = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as! [String:Any]
                    self.carListings = json["listings"] as? [[String: Any]] ?? []
                    //print(self.carListings.count)
                } catch let error as NSError {
                    print(error)
                }
                
                for myListing in self.carListings as [Any] {
                    do {
                        let jsonData = try JSONSerialization.data(withJSONObject: myListing, options: .prettyPrinted)
                        let listingString = String(data: jsonData, encoding: .utf8)
                        let listingData = listingString?.data(using: .utf8)
                        
                        // Decode the JSON data and feed it to the data model
                        let jsonDecoder = JSONDecoder()
                        let carListing = try jsonDecoder.decode(CarDetails.self, from: listingData!)
                        
                        // Append the carListing object in the array
                        self.arrayCarListings.append(carListing)
                        
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
                
                DispatchQueue.main.async {
                    self.setupTableView()
                }
                
            }).resume()
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let carCell = tableView.dequeueReusableCell(withIdentifier: "carCell") as! CarCell
        if let currentCarDetails = self.arrayCarListings[indexPath.row] as CarDetails?{
            
            carCell.detailedOne.text = "\(currentCarDetails.carYear ??? "N/A") \(currentCarDetails.carMake ?? "N/A") \(currentCarDetails.carModel ?? "N/A")"
            
            
            // Number formater to add commas where needed for thousands and greater values
            let numberFormatter = NumberFormatter()
            numberFormatter.numberStyle = .decimal
            
            var formattedPrice = String()
            var formattedMileage = String()
            
            if let currentCarPrice = currentCarDetails.carPrice {
                formattedPrice = numberFormatter.string(from: NSNumber(value:currentCarPrice)) ?? "N/A"
            }
            
            if let currentCarMileage = currentCarDetails.carMileage {
                formattedMileage = numberFormatter.string(from: NSNumber(value:currentCarMileage)) ?? "N/A"
            }
            
            carCell.detailedTwo.text = "$" + formattedPrice + "   |   " + formattedMileage + " Miles" + "   |   " + "\(currentCarDetails.dealer?.city ?? "N/A"), \(currentCarDetails.dealer?.state ?? "N/A")"

            if let currentDealerNumber = currentCarDetails.dealer?.phone {
                carCell.phoneNumber.text = formattedNumber(number: currentDealerNumber)
            }
            
            
            DispatchQueue.main.async {
                carCell.carImage.downloaded(from: (currentCarDetails.carThumbnail?.firstPhoto?.mediumPhoto) ?? "https://icon-library.net/images/no-image-available-icon/no-image-available-icon-6.jpg")
            }
        }
        return carCell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if self.arrayCarListings.count == 0 {
            self.listingsTableView.setEmptyMessage("Used Car Listings\n\nNo data yet")
        } else {
            self.listingsTableView.restore()
        }
        
        return self.arrayCarListings.count
    }

}



infix operator ???: NilCoalescingPrecedence

public func ??? <T>(optional: T?, defaultValue: @autoclosure () -> String) -> String {
    return optional.map { String(describing: $0) } ?? defaultValue()
}


private func formattedNumber(number: String) -> String {
    let cleanPhoneNumber = number.components(separatedBy: CharacterSet.decimalDigits.inverted).joined()
    let mask = "(XXX) XXX-XXXX"
    
    var result = ""
    var index = cleanPhoneNumber.startIndex
    for ch in mask where index < cleanPhoneNumber.endIndex {
        if ch == "X" {
            result.append(cleanPhoneNumber[index])
            index = cleanPhoneNumber.index(after: index)
        } else {
            result.append(ch)
        }
    }
    return result
}

extension UITableView {
    
    func setEmptyMessage(_ message: String) {
        let messageLabel = UILabel(frame: CGRect(x: 0, y: 0, width: self.bounds.size.width, height: self.bounds.size.height))
        messageLabel.text = message
        messageLabel.textColor = .black
        messageLabel.numberOfLines = 0;
        messageLabel.textAlignment = .center;
        messageLabel.font = UIFont.systemFont(ofSize: 15)
        messageLabel.sizeToFit()
        
        self.backgroundView = messageLabel;
        self.separatorStyle = .none;
    }
    
    func restore() {
        self.backgroundView = nil
        self.separatorStyle = .none
    }
}
