//
//  HomeViewModel.swift
//  SwiftCoin
//
//  Created by RUMEN GUIN on 14/01/23.
//

import SwiftUI
//
//Using URLSession.shared.dataTask(with: URL and completionHandler) we can make a request to our url and then download all the data from that request from that particular url.
//It creates a task that retrieves the contents of a url based on the specified url request object and calls a handler upon completion
class HomeViewModel: ObservableObject {
    @Published var coins = [Coin]()
    @Published var topMovingCoins = [Coin]()
    init() {
        fetchCoinData()
    }
    
    func fetchCoinData() {
        let urlString = "https://api.coingecko.com/api/v3/coins/markets?vs_currency=usd&order=market_cap_desc&per_page=100&page=1&sparkline=true&price_change_percentage=24h"
        
        guard let url = URL(string: urlString) else {return}
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                print("DEBUG: Error \(error.localizedDescription)")
                return
            }
            
            if let response = response as? HTTPURLResponse {
                print("DEBUG: Response status code \(response.statusCode)") //DEBUG: Response status code 200
                
                //show alert to user if above 200 status code
            }
            
            guard let data = data else {return}
            //print("DEBUG: Data \(data)") //DEBUG: Data 405366 bytes
            
//            let dataAsString = String(data: data, encoding: .utf8)
//            print("DEBUG: Data \(dataAsString)") //show all coins on console
            
            do {
                let coins = try JSONDecoder().decode([Coin].self, from: data)
                //print("DEBUG: Coins \(coins)")
                DispatchQueue.main.async { [weak self] in
                    self?.coins = coins
                    self?.configureTopMovingCoins()
                }
            }catch let error {
                print("DEBUG: Failed to decode with error: \(error)")
            }
            
        }
        .resume() //resume the task if it is suspended
    }
    
    func configureTopMovingCoins() {
        let topMovers = coins.sorted(by: {$0.priceChangePercentage24H > $1.priceChangePercentage24H})
        
        self.topMovingCoins = Array(topMovers.prefix(5))
    }
    
}
