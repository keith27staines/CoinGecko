//
//  ContentView.swift
//  CoinGecko
//
//  Created by Keith Staines on 01/10/2023.
//

import SwiftUI

struct ContentView: View {
        
    @StateObject var vm = ViewModel()
    
    var body: some View {
        VStack {
            if let viewData = vm.viewData {
                Text("Coint: \(viewData.coinName)")
                Text("Currency: \(viewData.currency)")
                Text("Price: \(viewData.price)")
            }
            
            if let error = vm.error {
                Text("Error: \(error)")
            }

        }
        .padding()
        .task {
            await vm.fetchPrice(coinName: "bitcoin", currency: "usd")
        }
    }
}

#Preview {
    ContentView()
}

extension ContentView {
    @MainActor
    final class ViewModel: ObservableObject {
        @Published var viewData: ViewData?
        @Published var error: String?
        
        let service = CoinGeckoClient()
        
        func fetchPrice(
            coinName: String,
            currency: String
        ) async {
            self.error = nil
            do {
                let result = try await service.fetch(
                    coinName: coinName,
                    currency: currency
                )
                viewData = ViewData(result)
            } catch {
                self.error = error.localizedDescription
            }
        }
        
        struct ViewData {
            let coinName: String
            let currency: String
            let price: String
            
            init(coinName: String, currency: String, price: String) {
                self.coinName = coinName
                self.currency = currency
                self.price = price
            }
            
            init(_ ccp: CoinCurrencyPrice) {
                let price: String
                switch ccp.price {
                case .some(let p):
                    price = String(p)
                case .none:
                    price = ""
                }
                
                self.init(
                    coinName: ccp.cointName,
                    currency: ccp.currency,
                    price: price
                )
            }
        }
    }
}
