//
//  Copyright © 2017 test. All rights reserved.
//

import UIKit

class RepositoryListViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, SearchInputViewDelegate, RepositoryListViewInput {

    private var items = [RepositoryListDisplayItem]()

    @IBOutlet weak var searchInputView: SearchInputView!
    @IBOutlet weak var tableView: UITableView!

    var output: RepositoryListViewOutput!

    override func viewDidLoad() {
        super.viewDidLoad()

        self.searchInputView.delegate = self
    }

    // MARK: - SearchInputViewDelegate

    func searchInputViewDidResignFirstResponder(_ view: SearchInputView) {
        self.output.performSearch(text: self.searchInputView.inputText)
    }

    func searchInputViewDidTouchCancelButton(_ view: SearchInputView) {
        self.output.cancelSearch()
    }

    // MARK: - UITableViewDataSource

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.items.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: "RepositoryCell") as? RepositoryTableViewCell {
            let repository = self.items[indexPath.row]
            cell.nameLabel.text = repository.name
            cell.languageLabel.text = repository.language
            cell.starsLabel.text = repository.stars
            return cell
        }

        return UITableViewCell()
    }

    // MARK: - UIScrollViewDelegate

    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        if let visibleIndexPaths = self.tableView.indexPathsForVisibleRows {
            if visibleIndexPaths.contains(where: { $0.row == self.items.count - 1 }) {
                self.output.continueSearch()
            }
        }
    }

    // MARK: - RepositoryListViewInput

    func beginSearchAnimation() {
        self.searchInputView.beginSearchingAnimation()
    }

    func endSearchAnimation() {
        self.searchInputView.endSearchingAnimation()
    }

    func clearItems() {
        self.items.removeAll()
        self.tableView.reloadData()
    }

    func addItems(_ items: [RepositoryListDisplayItem]) {
        self.items.append(contentsOf: items)
        self.tableView.reloadData()
    }
}

