//
//  Copyright © 2017 test. All rights reserved.
//

import Foundation

protocol RepositoryListInteractorInput {

    func findRepositories(text: String)
    func findFollowingRepositories()
    func cancel()
}
