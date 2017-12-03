//
//  Copyright © 2017 test. All rights reserved.
//

import Foundation

protocol RepositoryListViewInput {

    func beginSearchAnimation()
    func endSearchAnimation()
    func clearItems()
    func addItems(_ displayItems: [RepositoryListDisplayItem])
}
