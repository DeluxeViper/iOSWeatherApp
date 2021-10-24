//
//  ViewController.swift
//  RedditCloneApp
//
//  Created by Abdullah Mohamed on 2021-10-23.
//

import UIKit
import CoreLocation

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, CLLocationManagerDelegate {

    @IBOutlet var table: UITableView!
    
    var models = [Daily]()
    
    let locationManager = CLLocationManager()
    
    var currentLocation: CLLocation?
    var currentWeather: CurrentWeather?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Register 2 cells
        table.register(HourlyTableViewCell.nib(), forCellReuseIdentifier: HourlyTableViewCell.identifier)
        table.register(WeatherTableViewCell.nib(), forCellReuseIdentifier: WeatherTableViewCell.identifier)
        
        table.delegate = self
        table.dataSource = self
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        setupLocation()
    }
    
    // Location
    func setupLocation() {
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if !locations.isEmpty, currentLocation == nil{
            currentLocation = locations.first
            locationManager.stopUpdatingLocation()
            requestWeatherForLocation()
        }
    }
    
    func requestWeatherForLocation() {
        guard let currentLocation = currentLocation else {
            return
        }

        let long = currentLocation.coordinate.longitude
        let lat = currentLocation.coordinate.latitude
        
        let apikey = "1ccb64cf8b6a6a7ae8bfc5fed75e34e9"
        let url = "https://api.openweathermap.org/data/2.5/onecall?lat=\(lat)&lon=\(long)&appid=\(apikey)"
        
        
        URLSession.shared.dataTask(with: URL(string: url)!, completionHandler: {data, response, error in
            
            // Validation
            guard let data = data, error == nil else {
                print("something went wrong")
                return
            }
            
            // Convert data to models/some object
            var json: WeatherResponse?
            do {
                json = try JSONDecoder().decode(WeatherResponse.self, from: data)
            } catch {
                print("error: \(error)")
            }
            
            guard let result = json else {
                return
            }
            
            print("Current weather: \(result.current!)")
//            print("Daily weather: \(result.daily)")
            
            let dailyEntries = result.daily
            
            self.models.append(contentsOf: dailyEntries)
//            result.daily.forEach {daily in
//                print(daily)
//            }
//            for hourlyWeather in result.hourly! {
////                print(hourlyWeather.temp)
////                for weather1 in hourlyWeather.weather {
////                    print(weather1.main)
////                }
//            }
//            print("Hourly weather: \(result.hourly!)")
            
            let current = result.current
            self.currentWeather = current
            // Update user interface
            DispatchQueue.main.async {
                self.table.reloadData()
                
                
                self.table.tableHeaderView = self.createTableHeader()
            }
        }).resume()
        print("\(long) | \(lat)")
    }

    // Table functionality
    
    func createTableHeader() -> UIView {
        let headerView = UIView(frame: CGRect(x: 0, y: 0, width: view.frame.size.width, height: view.frame.size.height/2))
        
        headerView.backgroundColor = .red
        
        let locationLabel = UILabel(frame: CGRect(x: 10, y: 10, width: view.frame.size.width-20, height: headerView.frame.size.height/5))
        let summaryLabel = UILabel(frame: CGRect(x: 10, y: 20 + locationLabel.frame.size.height, width: view.frame.size.width-20, height: headerView.frame.size.height/5))
        let tempLabel = UILabel(frame: CGRect(x: 10, y: 20 + locationLabel.frame.size.height + summaryLabel.frame.size.height, width: view.frame.size.width-20, height: headerView.frame.size.height/2))
        
        headerView.addSubview(locationLabel)
        headerView.addSubview(tempLabel)
        headerView.addSubview(summaryLabel)
        
        tempLabel.textAlignment = .center
        locationLabel.textAlignment = .center
        summaryLabel.textAlignment = .center
        
        guard let currentWeather = self.currentWeather else {
            return UIView()
        }
        tempLabel.text = "\(currentWeather.temp-273.15)°C"
        tempLabel.font = UIFont(name: "Helvetica-Bold", size: 32)
        locationLabel.text = "Current Location"
        summaryLabel.text = currentWeather.weather[0].description
        return headerView
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return models.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: WeatherTableViewCell.identifier, for: indexPath) as! WeatherTableViewCell
        cell.configure(with: models[indexPath.row])
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
}

struct WeatherResponse: Codable {
    let lat: Float
    let lon: Float
    let timezone: String
    let timezone_offset: Int64
    let current: CurrentWeather?
    let minutely: [Minutely]
    let hourly: [Hourly]?
    let daily: [Daily]
    
}

struct CurrentWeather: Codable {
    let dt: Int64
    let sunrise: Double
    let sunset: Double
    let temp: Float
    let feels_like: Float
    let pressure: Int
    let humidity: Int
    let dew_point: Float
    let uvi: Float
    let clouds: Int
    let visibility: Int
    let wind_speed: Double
    let wind_deg: Int
    let weather: [Weather]
    let rain: Rain?
}

struct Weather: Codable {
    let id: Int64
    let main: String
    let description: String
    let icon: String
}

struct Rain: Codable {
    let h: Float
}

struct Minutely: Codable {
    let dt: Int64
    let precipitation: Float
}

struct Hourly: Codable {
    let dt: Int64
    let temp: Float
    let feels_like: Float
    let pressure: Int
    let humidity: Int
    let dew_point: Float
    let uvi: Float
    let clouds: Int
    let visibility: Int
    let wind_speed: Float
    let wind_deg: Int
    let wind_gust: Float
    let weather: [Weather]
    let pop: Double?
}

struct Daily: Codable {
    let dt: Double
    let sunrise: Int64
    let sunset: Int64
    let moonrise: Int64
    let moonset: Int64
    let moon_phase: Float
    let temp: Temp
    let feels_like: FeelsLike
    let pressure: Int
    let humidity: Int
    let dew_point: Float
    let wind_speed: Float
    let wind_deg: Int
    let weather: [Weather]
    let clouds: Int
    let pop: Float?
    let rain: Float?
    let uvi: Float
}

struct Temp: Codable {
    let day: Float
    let min: Float
    let max: Float
    let night: Float
    let eve: Float
    let morn: Float
}

struct FeelsLike: Codable {
    let day: Float
    let night: Float
    let eve: Float
    let morn: Float
}

