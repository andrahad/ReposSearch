//
//  Copyright © 2017 test. All rights reserved.
//

import Foundation

extension RepositoryEntity {

    static func parseJsonData(data: Data) -> [RepositoryEntity]? {
        guard let jsonObject = try? JSONSerialization.jsonObject(with: data),
            let rootDictionary = jsonObject as? [String: Any],
            let itemDictionaries = rootDictionary["items"] as? [[String: Any]] else {
                return nil
        }

        var parsedRepositories = [RepositoryEntity]()

        for itemDictionary in itemDictionaries {
            guard let id = itemDictionary["id"] as? Int else {
                continue
            }

            let name = itemDictionary["name"] as? String
            let language = itemDictionary["language"] as? String
            let stars = itemDictionary["stargazers_count"] as? Float
            let repository = RepositoryEntity(id: id, name: name, language: language, stars: stars)
            parsedRepositories.append(repository)
        }

        return parsedRepositories
    }
}
