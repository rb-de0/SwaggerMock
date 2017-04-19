import Kitura
import SwiftyJSON
import Foundation

final class ResposeParser {
    
    class func parse(_ data: Any) -> [API] {
        
        guard let root = data as? [String: Any],
            let pathData = root["paths"] as? [String: Any] else {
                
            fatalError("Invalid Swagger JSON")
        }
        
        var apis = [API]()
        
        for (key, value) in pathData {
            
            guard let methods = value as? [String: Any],
                let methodKey = methods.keys.first,
                let method = RouterMethod(rawValue: methodKey.uppercased()) else {
                    
                continue
            }
            
            guard let examples = methods
                .dicFor(key: methodKey)?
                .dicFor(key: "responses")?
                .dicFor(key: "200")?
                .valueFor(key: "examples") else {
                    continue
            }

            let newAPI = API(path: replacePathParams(from: key), method: method, example: JSON(examples))
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
            var paramName = replaced.substring(with: match.range)
            paramName.characters.removeLast()
            paramName.characters.removeFirst()
            replaced = replaced.replacingCharacters(in: match.range, with: ":\(paramName)") as NSString
        }
        
        return replaced as String
    }

}
