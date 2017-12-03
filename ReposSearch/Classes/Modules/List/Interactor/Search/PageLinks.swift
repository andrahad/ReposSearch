//
//  Copyright © 2017 test. All rights reserved.
//

import Foundation

// Ported class from Java example
class PageLinks: CustomDebugStringConvertible {

    private class Const {

        static let linksDelimeter: Character = ","
        static let linkParametersDelimeter: Character = ";"
        static let rel = "rel"
        static let first = "first"
        static let last = "last"
        static let next = "next"
        static let prev = "prev"
    }

    private(set) var first: String?
    private(set) var last: String?
    private(set) var next: String?
    private(set) var prev: String?

    init?(fromString headerContents: String) {
        let links = headerContents.split(separator: Const.linksDelimeter)
        for link in links {
            let linkParameters = link.split(separator: Const.linkParametersDelimeter)
            if linkParameters.count < 2 {
                continue
            }

            let linkPart = linkParameters[0].trimmingCharacters(in: .whitespaces)
            if !linkPart.hasPrefix("<") || !linkPart.hasSuffix(">") {
                continue
            }

            let linkValueStartIndex = linkPart.index(linkPart.startIndex, offsetBy: 1)
            let linkValueEndIndex = linkPart.index(linkPart.endIndex, offsetBy: -1)
            let linkValue = String(linkPart[linkValueStartIndex..<linkValueEndIndex])

            for index in 1..<linkParameters.count {
                let relParts = linkParameters[index].trimmingCharacters(in: .whitespaces).split(separator: "=")
                if relParts.count < 2 || relParts[0] != Const.rel {
                    continue
                }

                var relValue = relParts[1]
                if relValue.hasPrefix("\"") && relValue.hasSuffix("\"") {
                    let relValueStartIndex = relValue.index(relValue.startIndex, offsetBy: 1)
                    let relValueEndIndex = relValue.index(relValue.endIndex, offsetBy: -1)
                    relValue = relValue[relValueStartIndex..<relValueEndIndex]
                }

                switch String(relValue) {
                case Const.first:
                    self.first = linkValue
                case Const.last:
                    self.last = linkValue
                case Const.next:
                    self.next = linkValue
                case Const.prev:
                    self.prev = linkValue
                default:
                    break
                }
            }
        }

        if self.first == nil && self.last == nil && self.prev == nil && self.next == nil {
            return nil
        }
    }

    var debugDescription: String {
        var components = [String]()
        if let first = self.first {
            components.append("FIRST: \(first)")
        }
        if let prev = self.prev {
            components.append("PREV: \(prev)")
        }
        if let next = self.next {
            components.append("NEXT: \(next)")
        }
        if let last = self.last {
            components.append("LAST: \(last)")
        }

        return "PageLinks(\(components.joined(separator: ", ")))"
    }
}
