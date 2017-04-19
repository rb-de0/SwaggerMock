
extension Dictionary {
    
    func valueFor(key: Key) -> Value? {
        return self[key]
    }
}

extension Dictionary where Value == Any {
    
    func dicFor(key: Key) -> [Key: Any]? {
        return self[key] as? [Key: Any]
    }
}
