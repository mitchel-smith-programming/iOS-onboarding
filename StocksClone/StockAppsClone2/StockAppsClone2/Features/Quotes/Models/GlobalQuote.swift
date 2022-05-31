// GlobalQuote.swift

import Foundation

struct GlobalQuoteResponse: Codable {
    var quote: Quote
    
    private enum CodingKeys: String, CodingKey {
        case quote = "Global Quote"
    }
}
