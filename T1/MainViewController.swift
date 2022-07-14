//
//  ViewController.swift
//  T1
//
//  Created by Ivan Porkolab on 12.07.2022..
//

import UIKit
import SnapKit

class MainViewController: UIViewController {
    var service = ColorDataService()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .yellow
        let spinner = generateSpinner()
        let data = service.getData()
        view.backgroundColor = data.backgroundColors[3]
        print("\(data)")
    }
    
    private func generateSpinner() -> UIActivityIndicatorView {
        let spinner = UIActivityIndicatorView()
        spinner.color = .blue
        view.addSubview(spinner)
        spinner.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
        
        spinner.startAnimating()
        
        return spinner
    }
}

class ColorDataService {
    var repository = ColorDataRepository()
    
    func getData() -> PresetableAppData {
        return repository.getData()
    }
}

class ColorDataRepository {
    var httpClient: HTTPClient = AssetsProvider.httpClient
    
    func getData() -> PresetableAppData {
        let data = httpClient.getData(fromUrl: AppURLS.url(forEndpoint: AppURLS.EndPoints.colorData) )
        
        do {
            let decoder = JSONDecoder()
            decoder.keyDecodingStrategy = .convertFromSnakeCase
            let parsed = try decoder.decode(AppData.self, from: data)
            
            return parsed.toPresentable() }
        catch {
            //handle parse error
            return PresetableAppData.identity()
        }
    }
}

protocol HTTPClient {
    func getData(fromUrl urlString: String) -> Data
}

class ColorDataMockHTTPClient: HTTPClient {
    func getData(fromUrl urlString: String) -> Data {
        return Data(MockData.colorData.utf8)
    }
}

class DefaultHTTPClient {
    func getData(fromUrl urlString: String) -> Data {
        return Data(MockData.colorData.utf8)
    }
}

struct AssetsProvider {
    static let httpClient = ColorDataMockHTTPClient()
}








//Controller > Service > Repository >> httpClient/localBase/UserDefaults.... -> Model > PresentableModel > Repo > Service > Controller

struct AppData: Decodable {
    struct ColorData: Decodable {
        let backgroundColors: [String]
        let textColors: [String]
    }
    
    let title: String
    let colors: ColorData
    
    func toPresentable() -> PresetableAppData {
        let backgroundColors = colors.backgroundColors.map { hexString in
            UIColor.fromHexString(hex: hexString)
        }
        
        let textColors = colors.textColors.map { hexString in
            UIColor.fromHexString(hex: hexString)
        }
        
        return PresetableAppData(title: title, backgroundColors: backgroundColors, textColors: textColors)
    }
}

struct PresetableAppData {
    let title: String
    let backgroundColors: [UIColor]
    let textColors: [UIColor]
    
    static func fromAppData(data: AppData) -> PresetableAppData {
        let backgroundColors = data.colors.backgroundColors.map { hexString in
            UIColor.fromHexString(hex: hexString)
        }
        
        let textColors = data.colors.textColors.map { hexString in
            UIColor.fromHexString(hex: hexString)
        }
        
        return PresetableAppData(title: data.title, backgroundColors: backgroundColors, textColors: textColors)
    }
    
    static func identity() -> PresetableAppData {
        return PresetableAppData(title: "", backgroundColors: [], textColors: [])
    }
}

struct AppURLS {
    static let baseURL = "https://d2t41j3b4bctaz.cloudfront.net/"
    
    struct EndPoints {
        static let colorData = "interview.json"
    }
    
    static func url(forEndpoint endpoint: String) -> String {
        return baseURL + endpoint
    }
}

struct MockData {
    static var colorData = """
            {
                "title": "Title text",
                "colors": {
                    "background_colors": [
                        "000000",
                        "ffffff",
                        "888888",
                        "ee3333",
                        "33ee33",
                        "11aaff"
                    ],
                    "text_colors": [
                        "000000",
                        "ffffff",
                        "888888",
                        "ee3333",
                        "33ee33",
                        "11aaff"
                    ]
                }
            }
"""
}

extension UIColor {
    static func fromHexString (hex:String) -> UIColor {
        var cString:String = hex.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
        
        if (cString.hasPrefix("#")) {
            cString.remove(at: cString.startIndex)
        }
        
        if ((cString.count) != 6) {
            return UIColor.gray
        }
        
        var rgbValue:UInt64 = 0
        Scanner(string: cString).scanHexInt64(&rgbValue)
        
        return UIColor(
            red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
            green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
            blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
            alpha: CGFloat(1.0)
        )
    }
}
