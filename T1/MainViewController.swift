//
//  ViewController.swift
//  T1
//
//  Created by Ivan Porkolab on 12.07.2022..
//

import UIKit
import SnapKit

class MainViewController: UIViewController {
    let service = ColorDataService()
    var data: PresentableAppData?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .yellow
        let spinner = generateSpinner()
        service.getData { data in
            view.backgroundColor = data.backgroundColors[3]
            print("\(data)")
            spinner.stopAnimating()
            self.data = data
            setupUI()
        }
    }
    
    private func setupUI() {
        let button1 = generateButton(text: "Change text color".localize())
        let button2 = generateButton(text: "Change background color".localize())
        
        button1.addTarget(self, action: #selector(changeTextColor), for: .touchUpInside)
        button2.addTarget(self, action: #selector(changeBackgroundColor), for: .touchUpInside)
        
        let buttonContainer = UIView()
        buttonContainer.backgroundColor = .cyan
        let titleLabel = UILabel()
        titleLabel.text = "TITLE".localize()
        
        view.addSubview(buttonContainer)
        view.addSubview(titleLabel)
        
        buttonContainer.addSubview(button1)
        buttonContainer.addSubview(button2)
        
        buttonContainer.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.top.equalTo(button1.snp.top).offset(-10)
            make.bottom.equalTo(button2.snp.bottom).offset(10)
            //make.width.equalTo(100)
        }
        
        button1.snp.makeConstraints { make in
            make.height.equalTo(50)
            make.centerX.equalToSuperview()
            make.width.lessThanOrEqualToSuperview()
        }
        
        button2.snp.makeConstraints { make in
            make.height.centerX.equalTo(button1)
            make.top.equalTo(button1.snp.bottom).offset(30)
            make.width.lessThanOrEqualToSuperview()
        }
        
        titleLabel.snp.makeConstraints { make in
            make.bottom.equalTo(buttonContainer.snp.top).offset(-30)
            make.centerX.equalToSuperview()
        }
    }
    
    @objc func changeTextColor() {
        
    }
    
    @objc func changeBackgroundColor() {
        guard let data = data else { return }
        
        let colorPickerVC = ColorPickerViewController()
        colorPickerVC.setColors(colors: data.backgroundColors)
        
        present(colorPickerVC, animated: true)
        
        colorPickerVC.colorSelected = {(color) in
            self.view.backgroundColor = color
        }
    }
    
    private func generateButton(text: String) -> UIButton {
        let button = UIButton(type: .roundedRect)
        button.setTitle(text, for: .normal)
        button.backgroundColor = .black
        
        return button
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
    
    func getData() -> PresentableAppData {
        return repository.getData()
    }
    
    func getData(success: (PresentableAppData) -> (), onError: ((Error) -> ())? = nil) {
        repository.getData(success: success, onError: onError)
    }
}

class ColorDataRepository {
    var httpClient: HTTPClient = AssetsProvider.httpClient
    
//    func getData() -> PresentableAppData {
//        let data = httpClient.getData(fromUrl: AppURLS.url(forEndpoint: AppURLS.EndPoints.colorData) )
//
//        do {
//            let decoder = JSONDecoder()
//            decoder.keyDecodingStrategy = .convertFromSnakeCase
//            let parsed = try decoder.decode(AppData.self, from: data)
//
//            return parsed.toPresentable() }
//        catch {
//            //handle parse error
//            return PresentableAppData.identity()
//        }
//    }
    func getData() -> PresentableAppData {
        let data = httpClient.getData(url: AppURLS.url(forEndpoint: AppURLS.EndPoints.colorData), modelType: AppData.self)
        
        guard let data = data else {
            return PresentableAppData.identity()
        }
        
        return PresentableAppData.fromAppData(data: data)
    }
    
    func getData(success: (PresentableAppData) -> (), onError: ((Error) -> ())? = nil) {
        httpClient.getData(url: AppURLS.url(forEndpoint: AppURLS.EndPoints.colorData),
                           modelType: AppData.self,
                           success: { data in success(data.toPresentable())},
                           onError: onError)
    }
}

protocol HTTPClient {
    func getData(fromUrl urlString: String) -> Data
    func getData<T: Decodable>(url: String, modelType: T.Type) -> T?
    func getData<T: Decodable>(url: String,
                               modelType: T.Type,
                               success: (T) -> (),
                               onError: ((Error) -> ())?)
}

class ColorDataMockHTTPClient: HTTPClient {
    func getData<T>(url: String,
                    modelType: T.Type,
                    success: (T) -> (),
                    onError: ((Error) -> ())?) where T : Decodable {
        do {
            let decoder = JSONDecoder()
            decoder.keyDecodingStrategy = .convertFromSnakeCase
            let parsed = try decoder.decode(T.self, from: Data(MockData.colorData.utf8))
            
            success(parsed)
        }
        catch {
            //handle parse error
            onError?(error)
        }
    }
    
    func getData<T>(url: String, modelType: T.Type) -> T? where T : Decodable {
        do {
            let decoder = JSONDecoder()
            decoder.keyDecodingStrategy = .convertFromSnakeCase
            let parsed = try decoder.decode(T.self, from: Data(MockData.colorData.utf8))
            
            return parsed }
        catch {
            //handle parse error
            return nil
        }
    }
    
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
    
    func toPresentable() -> PresentableAppData {
        let backgroundColors = colors.backgroundColors.map { hexString in
            UIColor.fromHexString(hex: hexString)
        }
        
        let textColors = colors.textColors.map { hexString in
            UIColor.fromHexString(hex: hexString)
        }
        
        return PresentableAppData(title: title, backgroundColors: backgroundColors, textColors: textColors)
    }
}

struct PresentableAppData {
    let title: String
    let backgroundColors: [UIColor]
    let textColors: [UIColor]
    
    static func fromAppData(data: AppData) -> PresentableAppData {
        let backgroundColors = data.colors.backgroundColors.map { hexString in
            UIColor.fromHexString(hex: hexString)
        }
        
        let textColors = data.colors.textColors.map { hexString in
            UIColor.fromHexString(hex: hexString)
        }
        
        return PresentableAppData(title: data.title, backgroundColors: backgroundColors, textColors: textColors)
    }
    
    static func identity() -> PresentableAppData {
        return PresentableAppData(title: "", backgroundColors: [], textColors: [])
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

extension String {
    func localize() -> String {
        return self
    }
}
