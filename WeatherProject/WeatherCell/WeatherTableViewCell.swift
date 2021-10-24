//
//  WeatherTableViewCell.swift
//  RedditCloneApp
//
//  Created by Abdullah Mohamed on 2021-10-23.
//

import UIKit

class WeatherTableViewCell: UITableViewCell {

    @IBOutlet var dayLabel: UILabel!
    @IBOutlet var highTempLabel: UILabel!
    @IBOutlet var lowTempLabel: UILabel!
    @IBOutlet var iconImageView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    static let identifier = "WeatherTableViewCell"

    static func nib() -> UINib {
        return UINib(nibName: "WeatherTableViewCell", bundle: nil)
    }
    
    func configure(with model: Daily) {
        print(model)
        self.highTempLabel.textAlignment = .center
        self.lowTempLabel.textAlignment = .center
        
        self.lowTempLabel.text = "\(Int(model.temp.min-273.15))°C"
        self.highTempLabel.text = "\(Int(model.temp.max-273.15))°C"
        
        self.dayLabel.text = getDayForDate(Date(timeIntervalSince1970: model.dt))
        
        
        if (model.weather[0].main.caseInsensitiveCompare("clear") == .orderedSame) {
            self.iconImageView.image = UIImage(named: "clear")
        } else if (model.weather[0].main.caseInsensitiveCompare("rain") == .orderedSame) {
            self.iconImageView.image = UIImage(named: "rain")
        } else if (model.weather[0].main.caseInsensitiveCompare("clouds") == .orderedSame) {
            self.iconImageView.image = UIImage(named: "cloud")
        }
//        self.iconImageView.image = UIImage(named: "clear")
        self.iconImageView.contentMode = .scaleAspectFit
    }
    
    func getDayForDate(_ date: Date?) -> String {
        guard let inputDate = date else {
            return ""
        }
        
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE" // Month
        return formatter.string(from: inputDate)
    }
}
