//
//  Copyright © 2017 test. All rights reserved.
//

import Foundation

protocol RepositoryListViewOutput {

    func performSearch(text: String?)
    func continueSearch()
    func cancelSearch()
}
