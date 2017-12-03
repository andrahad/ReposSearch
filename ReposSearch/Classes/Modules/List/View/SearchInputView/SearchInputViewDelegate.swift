//
//  Copyright © 2017 test. All rights reserved.
//

import Foundation

protocol SearchInputViewDelegate: class {

    func searchInputViewDidResignFirstResponder(_ view: SearchInputView)
    func searchInputViewDidTouchCancelButton(_ view: SearchInputView)
}
