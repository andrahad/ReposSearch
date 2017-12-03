//
//  Copyright © 2017 test. All rights reserved.
//

import Foundation

class RepositoryListInteractor: RepositoryListInteractorInput {

    private var queue: OperationQueue
    private var nextPage = 1
    private var lastSearchText: String?

    var output: RepositoryListInteractorOutput!

    init() {
        self.queue = OperationQueue()
        self.queue.maxConcurrentOperationCount = 1
    }

    private func performSearch(text: String, page: Int, completion: @escaping ([RepositoryEntity]) -> ()) {
        let operation = SearchRepositoryOperation(searchText: text, page: page)
        operation.completionBlock = { [weak operation] in
            if let operation = operation, !operation.isCancelled {
                completion(operation.repositories)
            }
        }
        self.queue.addOperation(operation)
    }

    // MARK: - RepositoryListInteractorInput

    func findRepositories(text: String) {
        self.nextPage = 1
        self.lastSearchText = text.trimmingCharacters(in: .whitespaces)

        self.findFollowingRepositories()
    }

    func findFollowingRepositories() {
        if let searchText = self.lastSearchText {
            self.performSearch(text: searchText, page: self.nextPage) { repositories in
                DispatchQueue.main.async {
                    self.nextPage = self.nextPage + 1
                    self.output.foundRepositories(repositories: repositories)
                }
            }
        }
    }

    func cancel() {
        self.queue.operations.forEach { $0.cancel() }
    }
}
