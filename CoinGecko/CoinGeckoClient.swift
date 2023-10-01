//
//  CoinGeckoClient.swift
//  CoinGecko
//
//  Created by Keith Staines on 01/10/2023.
//

import Foundation

class CoinGeckoClient {
    
    
    static let baseURL = URL(string: "https://api.coingecko.com/api/v3/")!

    func fetch(coinName: String, currency: String) async throws -> CoinCurrencyPrice {
        typealias SimplePrice = [String: [String: Double]]
        let url = API.simplePrice(coin: coinName, currency: currency).endpoint
        let request = URLRequest(url: url)
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let response = response as? HTTPURLResponse
        else { throw APIError.responseNotHTTPURLResponse }
        
        let code = response.statusCode
        guard (200..<300).contains(code)
        else { throw APIError.badStatusCode(data: data, code: code) }
        let simplePrice = try JSONDecoder().decode(SimplePrice.self, from: data)
        return CoinCurrencyPrice(
            cointName: coinName,
            currency: currency,
            price: simplePrice[coinName]?[currency]
        )
    }
}



extension CoinGeckoClient {
    enum API {
        
        case simplePrice(coin: String, currency: String)
        // https://api.coingecko.com/api/v3/simple/price?ids=bitcoin&vs_currencies=usd
        var endpoint: URL {
            switch self {
            case .simplePrice(let coin, let currency):
                let path = "simple/price"
                var url = CoinGeckoClient.baseURL.appendingPathComponent(path)
                url.append(
                    queryItems: [
                        URLQueryItem(
                            name: "ids",
                            value: coin
                        ),
                        URLQueryItem(
                            name: "vs_currencies",
                            value: currency
                        )
                    ]
                )
                return url
            }
        }
    }
}

enum APIError: Error {
    case responseNotHTTPURLResponse
    case badStatusCode(data: Data, code: Int)
}


struct CoinCurrencyPrice {
    let cointName: String
    let currency: String
    let price: Double?
}
