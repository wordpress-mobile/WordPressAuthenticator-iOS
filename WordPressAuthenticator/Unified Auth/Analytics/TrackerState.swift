import Foundation

class TrackerState {
    enum Source {
        case `default`
        case jetpack
        case share
        case deeplink
        case reauthetication
        case selfHosted // Why is this a source at all?????????
    }
    
    let source: Source
    
    init(source: Source) {
        self.source = source
    }
}
