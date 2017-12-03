//
//  Copyright © 2017 test. All rights reserved.
//

import Foundation

struct RepositoryEntity: CustomDebugStringConvertible {

    let id: Int
    let name: String?
    let language: String?
    let stars: Float?

    var debugDescription: String {
        var components = [String]()
        components.append("id: \(self.id)")
        if let name = self.name {
            components.append("name: \(name)")
        }
        if let language = self.language {
            components.append("language: \(language)")
        }
        if let stars = self.stars {
            components.append("stars: \(stars)")
        }

        return "PageLinks(\(components.joined(separator: ", ")))"
    }
}
