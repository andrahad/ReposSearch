//
//  Copyright © 2017 test. All rights reserved.
//

import UIKit

class SearchInputView: UIView, UITextFieldDelegate {

    weak var delegate: SearchInputViewDelegate?

    var inputText: String? {
        get {
            return self.textField.text
        }
        set {
            self.textField.text = newValue
        }
    }

    @IBOutlet private var contentView: UIView!
    @IBOutlet private weak var textField: UITextField!

    override init(frame: CGRect) {
        super.init(frame: frame)

        self.commonInit()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)

        self.commonInit()
    }

    func beginSearchingAnimation() {
        let rightView = UIView(frame: CGRect(x: 0, y: 0, width: 100, height: 30))

        let activityIndicatorView = UIActivityIndicatorView(activityIndicatorStyle: .gray)
        activityIndicatorView.frame = CGRect(x: 0, y: 0, width: 30, height: 30)
        activityIndicatorView.startAnimating()
        rightView.addSubview(activityIndicatorView)

        let cancelButton = UIButton(type: .roundedRect)
        cancelButton.frame = CGRect(x: 30, y: 0, width: 70, height: 30)
        cancelButton.setTitle("Cancel", for: .normal)
        cancelButton.setTitleColor(UIColor.blue, for: .normal)
        cancelButton.backgroundColor = UIColor.clear
        cancelButton.addTarget(self, action: #selector(didTouchCancelButton), for: .touchUpInside)
        rightView.addSubview(cancelButton)

        self.textField.rightView = rightView
    }

    func endSearchingAnimation() {
        self.textField.rightView = nil
    }

    private func commonInit() {
        Bundle.main.loadNibNamed("SearchInputView", owner: self, options: nil)
        self.addSubview(self.contentView)
        self.contentView.frame = self.bounds
        self.contentView.autoresizingMask = [.flexibleWidth, .flexibleHeight]

        self.backgroundColor = UIColor.clear
        self.textField.leftViewMode = .always
        self.textField.rightViewMode = .always

        self.displaySearchIcon()
    }

    private func displaySearchIcon() {
        let label = UILabel(frame: CGRect(x: 0, y: 0, width: 30, height: 30))
        label.text = "🔍"
        label.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        label.backgroundColor = UIColor.clear
        label.textAlignment = .center
        self.textField.leftView = label
    }

    @objc private func didTouchCancelButton() {
        self.delegate?.searchInputViewDidTouchCancelButton(self)
    }

    // MARK: - UITextFieldDelegate

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.textField.resignFirstResponder()
        self.delegate?.searchInputViewDidResignFirstResponder(self)

        return true
    }
}
