//
//  ColorPickerViewController.swift
//  T1
//
//  Created by Ivan Porkolab on 18.07.2022..
//

import UIKit

class ColorPickerViewController: UIViewController {
    
    var colorSelected: ((UIColor) -> ())?
    
    private let stackView = UIStackView()
    private let scrollView = UIScrollView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    private func setupUI() {
        view.backgroundColor = .white
        
        stackView.distribution = .fill
        stackView.axis = .vertical
        stackView.alignment = .fill
        stackView.spacing = 0
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(scrollView)
        scrollView.addSubview(stackView)
        
        scrollView.snp.makeConstraints { make in
            make.edges.equalTo(view.safeAreaLayoutGuide)
        }
        
        stackView.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.left.right.equalTo(view)
            make.bottom.equalTo(scrollView.snp.bottom)
        }
    }
    
    func setColors(colors: [UIColor]) {
        let views = colors.map { color in
            return generateColorView(color: color)
        }
        
        views.forEach { view in
            stackView.addArrangedSubview(StackViewSpacer.spacer(height: 30))
            stackView.addArrangedSubview(view)
        }
    }
    
    private func generateColorView(color: UIColor) -> UIView {
        let colorView = UIView()
        colorView.backgroundColor = color
        
        colorView.snp.makeConstraints { make in
            make.height.equalTo(100)
        }
        
        colorView.isUserInteractionEnabled = true
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(didSelectColor(_:)))
        colorView.addGestureRecognizer(tapGesture)
        
        return colorView
    }
    
    @objc func didSelectColor(_ sender: Any) {
        if let recognizer = sender as? UITapGestureRecognizer,
            let view = recognizer.view,
            let color = view.backgroundColor {
            colorSelected?(color)
            dismiss(animated: true)
        }
    }
}

class StackViewSpacer {
    static func spacer(height: Float) -> UIView {
        let view = UIView()
        view.snp.makeConstraints { make in
            make.height.equalTo(height)
        }
        
        return view
    }
    
}

//UMJESTO NASLJEĐIVANJA
//1. parametriziranje//ekstenzije, factory, statički konstruktori...
//2. protokol (mogućnost default implementacije)
//3. kompozicija
