//
//  CurrencyData.swift
//  wirebarley_coding_test_iOS
//
//  Created by 장예지 on 1/25/24.
//

import Foundation

enum CountryCurrency : String, CaseIterable{
    case KRW = "한국(KRW)"
    case JPY = "일본(JPY)"
    case PHP = "필리핀(PHP)"
    
    var currency: String {
        switch self {
        case .KRW:
            return "KRW"
        case .JPY:
            return "JPY"
        case .PHP:
            return "PHP"
        }
    }
}

struct CurrencyData: Codable {
    let timestamp: Int
    let quotes: [String:Double]
    
    enum CodingKeys: CodingKey {
        case timestamp
        case quotes
    }
}
