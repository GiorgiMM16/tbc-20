//
//  ViewController.swift
//  tbc-2020
//
//  Created by Giorgi Michitashvili on 4/21/24.
//

import UIKit

var informaciiia: List?

class ViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.blue
    }
    
    /* ფუნქცია რომელიც ამაგრებს ეიპიაის */
    func internetidanInfoebi() async throws -> List {
        let endpoint = "https://restcountries.com/v3.1/all"
        
        guard let url = URL(string: endpoint) else {
            throw countriesError.URLError
        }
        let (data, response) = try await URLSession.shared.data(from: url)
        
        guard let response = response as? HTTPURLResponse, response.statusCode == 200 else {
            throw countriesError.InvalidResponse
        }
        
        do{
            let decoder = JSONDecoder()
            decoder.keyDecodingStrategy = .convertFromSnakeCase
            return try decoder.decode(List.self, from: data)
        } catch let error as DecodingError {
            print("Error is \(error)")
            throw countriesError.InvalidData
        } catch {
            print("Unexpected \(error)")
            throw countriesError.InvalidData
        }
    }
}


 /* სტრუქტურები */
struct List: Codable {
    var list: [Description]
    
    struct Description: Codable {
        var name: Name
        var spelling: String
        var currency: String
        var captialCity: String
        var region: String
        var neighbors: String
        var countryFlag: String
        
        struct Name: Codable {
            var official: String
            var nativeName: String
        }
        /* ქოუდინგ ქიები გამოიყენება სწორი სახელის მისათითებლად, რომ ეიპიაიდან სწორად წამოვიღოთ ინფო*/
        enum CodingKeys: String, CodingKey {
            case name
            case spelling
            case currency
            case captialCity
            case region
            case neighbors
            case countryFlag
        }
    }
    enum CodingKeys: String, CodingKey {
        case list
    }
    
}
/* ერორების ენამი */
enum countriesError: Error {
    case URLError
    case InvalidResponse
    case InvalidData
}


