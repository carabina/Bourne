import Foundation

public struct JSON {
    public var object: Any?

    public init() {
        self.object = nil
    }
    
    public init(_ object: Any?) {
        self.object = object
    }
    
    public init(json: JSON) {
        self.object = json.object
    }
    
    public init?(data: Data?) {
        guard let data = data else {
            return nil
        }
        
        do {
            let object: Any = try JSONSerialization.jsonObject(with: data, options: .allowFragments)
            self.object = object
        } catch let error as NSError {
            debugPrint(error)
        }
    }
    
    public init?(path: String) {
        guard FileManager.default.fileExists(atPath: path) else {
            return nil
        }

        let data = try? Data(contentsOf: Foundation.URL(fileURLWithPath: path))
        
        self.init(data: data)
    }
    
    /**
     Initialize an instance given a JSON file contained within the bundle.
     
     - parameter bundle: The bundle to attempt to load from.
     - parameter string: A string containing the name of the file to load from resources.
     */
    public init?(bundleClass: AnyClass, filename: String) {
        let bundle = Bundle(for: bundleClass)
        
        self.init(bundle: bundle, filename: filename)
    }
    
    public init?(bundle: Bundle, filename: String) {
        guard let filePath = bundle.path(forResource: filename, ofType: nil) else {
            return nil
        }
        
        self.init(path: filePath)
    }
    
    public subscript(key: String) -> JSON? {
        set {
            if var tempObject = object as? [String : Any] {
                tempObject[key] = newValue?.object
                self.object = tempObject
            } else {
                var tempObject: [String : Any] = [:]
                tempObject[key] = newValue?.object
                self.object = tempObject
            }
        }

        get {
            /**
             NSDictionary is used because it currently performs better than a native Swift dictionary.
             The reason for this is that [String : AnyObject] is bridged to NSDictionary deep down the
             call stack, and this bridging operation is relatively expensive. Until Swift is ABI stable
             and/or doesn't require a bridge to Objective-C, NSDictionary will be used here
             */
            guard let dictionary = object as? NSDictionary, let value = dictionary[key] else {
                return nil
            }
            
            return JSON(value)
        }
    }
}

extension JSON {
    public var string: String? {
        guard let object = object else {
            return nil
        }

        var value: String? = nil
        switch object {
        case is String:
            value = object as? String
        case is NSDecimalNumber:
            value = (object as? NSDecimalNumber)?.stringValue
        case is NSNumber:
            value = (object as? NSNumber)?.stringValue
        default:
            break
        }
        
        return value
    }
}

