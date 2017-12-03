//
//  Copyright © 2017 test. All rights reserved.
//

import Foundation

fileprivate struct SearchRepositoriesDataTaskResult {

    let repositories: [RepositoryEntity]?
    let error: Error?
}

class SearchRepositoryOperation: Operation {

    private class Const {

        static let numberOfThreads = 2
        static let itemsPerThread = 15
    }

    let searchText: String
    let page: Int
    private(set) var repositories = [RepositoryEntity]()
    private(set) var hasMoreResults = false

    private var dataTasks = [URLSessionDataTask]()

    init(searchText: String, page: Int = 1) {
        self.searchText = searchText
        self.page = page
    }

    override func cancel() {
        super.cancel()

        self.dataTasks.forEach { $0.cancel() }
        self.repositories.removeAll()
        self.hasMoreResults = false

        self.setExecuting(false)
        self.setFinished(true)
    }

    override func main() {
        guard !self.isCancelled else {
            return
        }

        let urlSession = URLSession(configuration: .default)
        let taskDispatchGroup = DispatchGroup()
        var dataTaskResults = [SearchRepositoriesDataTaskResult]()

        for threadIndex in 0..<Const.numberOfThreads {
            guard let searchURL = formatURL(threadIndex: threadIndex) else {
                continue
            }

            print("Searching URL \(searchURL)")

            let dataTask = urlSession.dataTask(with: searchURL, completionHandler: { [weak self] (data, response, error) in
                guard let strongSelf = self else {
                    return
                }

                if !strongSelf.isCancelled {
                    if let error = error {
                        print("Received error \(error)")
                    }

                    if let response = response {
                        strongSelf.hasMoreResults = !strongSelf.isResponseLast(response)
                    }

                    let taskResult = strongSelf.makeTaskResult(data: data, error: error)
                    dataTaskResults.append(taskResult)
                }

                taskDispatchGroup.leave()
            })

            self.dataTasks.append(dataTask)
            taskDispatchGroup.enter()
        }

        taskDispatchGroup.notify(queue: DispatchQueue.global()) { [weak self] in
            guard let strongSelf = self else {
                return
            }

            if !strongSelf.isCancelled {
                strongSelf.repositories = dataTaskResults.filter { $0.repositories != nil }.flatMap { $0.repositories! }

                strongSelf.setExecuting(false)
                strongSelf.setFinished(true)
            }
        }

        self.setExecuting(true)
        self.dataTasks.forEach { $0.resume() }
    }

    // MARK: - Private

    private func isResponseLast(_ response: URLResponse) -> Bool {
        let maxThreadIndex = Const.numberOfThreads - 1
        let currentOperationMaxQueryPage = self.queryPageFromThreadIndex(maxThreadIndex)

        if let  httpResponse = response as? HTTPURLResponse,
            let links = httpResponse.allHeaderFields["Link"] as? String,
            let pageLinks = PageLinks(fromString: links),
            let lastLink = pageLinks.last,
            let lastPage = self.extractPageNumber(from: lastLink),
            currentOperationMaxQueryPage < lastPage {

            return false
        }

        return true
    }

    private func queryPageFromThreadIndex(_ threadIndex: Int) -> Int {
        return (self.page - 1) * Const.numberOfThreads + threadIndex + 1
    }

    private func formatURL(threadIndex: Int) -> URL? {
        guard let encodedSearchText = self.searchText.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed) else {
            return nil
        }

        let queryPage = self.queryPageFromThreadIndex(threadIndex)
        let URLString = "https://api.github.com/search/repositories?q=\(encodedSearchText)&sort=stars&order=desc&page=\(queryPage)&per_page=\(Const.itemsPerThread)"

        return URL(string: URLString)
    }

    private func extractPageNumber(from queryString: String) -> Int? {
        let pattern = "^.*\\?q.*(\\?|&)page=(\\d+)($|&.*$)"
        guard let regex = try? NSRegularExpression(pattern: pattern, options: NSRegularExpression.Options.caseInsensitive) else {
            return nil
        }

        let matches = regex.matches(in: queryString,
                                    options: NSRegularExpression.MatchingOptions.anchored,
                                    range: NSMakeRange(0, queryString.count))

        guard let match = matches.first, match.numberOfRanges >= 3 else {
            return nil
        }

        let range = match.range(at: 2)
        let start = queryString.index(queryString.startIndex, offsetBy: range.location)
        let end = queryString.index(queryString.startIndex, offsetBy: range.location + range.length)
        let pageString = queryString[start..<end]
        let page = Int(pageString)

        return page
    }

    private func makeTaskResult(data: Data?, error: Error?) -> SearchRepositoriesDataTaskResult {
        var repositories: [RepositoryEntity]? = nil

        if let data = data {
            repositories = RepositoryEntity.parseJsonData(data: data)
        }

        return SearchRepositoriesDataTaskResult(repositories: repositories, error: error)
    }

    // MARK: - Workflow

    private var isExecutingSearch = false
    private var isFinishedSearch = false

    override var isFinished: Bool {
        return isFinishedSearch
    }

    override var isExecuting: Bool {
        return isExecutingSearch
    }

    override var isConcurrent: Bool {
        return true
    }

    private func setExecuting(_ value: Bool) {
        self.willChangeValue(forKey: "executing")
        isExecutingSearch = value
        self.didChangeValue(forKey: "executing")
    }

    private func setFinished(_ value: Bool) {
        self.willChangeValue(forKey: "finished")
        isFinishedSearch = value
        self.didChangeValue(forKey: "finished")
    }
}

