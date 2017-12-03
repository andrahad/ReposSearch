//
//  Copyright © 2017 test. All rights reserved.
//

import Foundation

class RepositoryListPresenter: RepositoryListInteractorOutput, RepositoryListViewOutput {

    var interactor: RepositoryListInteractorInput!
    var view: RepositoryListViewInput!

    private func makeDisplayItem(_ repository: RepositoryEntity) -> RepositoryListDisplayItem {
        let name = self.normalizeString(repository.name ?? "[unnamed]")
        let language = self.normalizeString(repository.language ?? "[unspecified]")
        let stars = self.formatStars(repository: repository)

        return RepositoryListDisplayItem(name: name, language: language, stars: stars)
    }

    private func normalizeString(_ string: String) -> String {
        let maxLength = 30

        if string.count > maxLength {
            let endIndex = string.index(string.startIndex, offsetBy: maxLength)
            return "\(string[..<endIndex])..."
        }

        return string
    }

    private func formatStars(repository: RepositoryEntity) -> String {
        return (repository.stars != nil) ? "★ \(repository.stars!)" : ""
    }

    // MARK: - RepositoryListInteractorOutput

    func foundRepositories(repositories: [RepositoryEntity]) {
        print("Found repositories: \(repositories.count)")

        let displayItems = repositories.map { self.makeDisplayItem($0) }
        self.view.addItems(displayItems)
        self.view.endSearchAnimation()
    }

    // MARK: - RepositoryListViewOutput

    func performSearch(text: String?) {
        if let text = text {
            self.view.clearItems()
            self.view.beginSearchAnimation()
            self.interactor.findRepositories(text: text)
        }
    }

    func continueSearch() {
        self.view.beginSearchAnimation()
        self.interactor.findFollowingRepositories()
    }

    func cancelSearch() {
        self.view.endSearchAnimation()
        self.interactor.cancel()
    }
}
