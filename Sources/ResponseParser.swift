import Kitura
import SwiftyJSON
import Foundation

final class ResponseParser {
    
    class func parse(_ json: JSON) -> [API] {

        guard let pathDictionary = json["paths"].dictionary else {
            fatalError("Invalid Swagger JSON")
        }
        
        var apis = [API]()
        
        for (key, value) in pathDictionary {
            
            guard let methodName = value.dictionary?.first?.key,
                let method = RouterMethod(rawValue: methodName.uppercased()) else {
                continue
            }
            
            guard let examples = value.dictionary?.first?.value["responses"]["200"]["examples"] else {
                continue
            }

            let newAPI = API(path: replacePathParams(from: key), method: method, example: examples)
            apis.append(newAPI)
        }
        
        return apis
    }
    
    private class func replacePathParams(from path: String) -> String {
        
        var replaced = path as NSString
        
        let range = NSRange(location: 0, length: replaced.length)
        let regex = try! NSRegularExpression(pattern: "\\{[^\\}]*\\}", options: .caseInsensitive)
        let matches = regex.matches(in: path, options: [], range: range)
        
        for match in matches.sorted (by: { $0.0.range.location > $0.1.range.location }) {
            let paramRange = NSRange.init(location: match.range.location + 1, length: match.range.length - 2)
            let paramName = replaced.substring(with: paramRange)
            replaced = replaced.replacingCharacters(in: match.range, with: ":\(paramName)") as NSString
        }
        
        return replaced as String
    }

}
