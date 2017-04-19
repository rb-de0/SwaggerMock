import Kitura
import KituraNet
import Foundation

let arguments = ProcessInfo().arguments

guard arguments.count > 1 else {
    fatalError("Input json URL")
}

let jsonURL = arguments[1]

let request = HTTP.request(jsonURL) { response in
    
    guard let response = response,
        let responseValue = try? response.readString() else {
            
        fatalError("Invalid Response")
    }
    
    guard let data = responseValue?.data(using: .utf8) else {
        
        fatalError("Invalid Response Data")
    }
    
    guard let json = try? JSONSerialization.jsonObject(with: data, options: .mutableContainers) else {
        
        fatalError("Invalid JSON Structure")
    }
    
    let apis = ResponseParser.parse(json)
    
    let router = Router()
    
    for api in apis {
        
        let registerMethod: (String, @escaping RouterHandler...) -> Router
        
        switch api.method {
        case .get:
            registerMethod = router.get
        case .post:
            registerMethod = router.post
        default:
            registerMethod = router.get
        }
        
        _ = registerMethod(api.path) { request, response, next in
            response.send(json: api.example)
            next()
        }
    }
    
    Kitura.addHTTPServer(onPort: 8081, with: router)
    Kitura.run()
}

request.end()
