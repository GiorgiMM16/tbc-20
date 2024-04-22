


import UIKit

var informacia: List?

class ViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureScrollView()
        configureContentView()
        view.backgroundColor = UIColor.blue
        fetchData()
    }
    
    private let scrollView: UIScrollView = {
        let sv = UIScrollView()
        sv.backgroundColor = UIColor.systemRed
        sv.contentSize = CGSize(width: 20, height: CGFloat(195 * 100))
        return sv
    }()
    
    private let contentView: UIView = {
        let cv = UIView()
        cv.backgroundColor = UIColor.purple
        return cv
    }()
    
    func configureScrollView() {
        view.addSubview(scrollView)
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
    }
    
    func configureContentView() {
        scrollView.addSubview(contentView)
        contentView.translatesAutoresizingMaskIntoConstraints = false
        contentView.topAnchor.constraint(equalTo: scrollView.topAnchor).isActive = true
        contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor).isActive = true
        contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor).isActive = true
        contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor).isActive = true
        contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor).isActive = true
        
        let hConst = contentView.heightAnchor.constraint(equalTo: scrollView.heightAnchor)
        hConst.isActive = true
        hConst.priority = UILayoutPriority(50)
    }
    
    func setupView() {
        guard let countries = informacia?.list else {
            return
        }

        let cellHeight: CGFloat = 50
        var yOffset: CGFloat = 0

        for country in countries {
            let cellView = UIView(frame: CGRect(x: 0, y: yOffset, width: view.frame.width, height: cellHeight))
            cellView.backgroundColor = UIColor.white
            contentView.addSubview(cellView)

            let nameLabel = UILabel(frame: CGRect(x: 10, y: 5, width: view.frame.width - 20, height: 40))
            nameLabel.text = country.name.official
            nameLabel.textColor = UIColor.black
            nameLabel.font = UIFont.systemFont(ofSize: 16)
            cellView.addSubview(nameLabel)

            yOffset += cellHeight + 5
        }

        // Update the content size of the contentView
        contentView.frame.size.height = CGFloat(countries.count * Int(cellHeight))
        scrollView.contentSize = contentView.frame.size
    }


    
    func fetchData() {
        Task {
            do {
                informacia = try await internetidanInfoebi()
                DispatchQueue.main.async {
                    self.setupView()
                    self.updateContentView()
                }
            } catch countriesError.URLError {
                print("URL error")
            } catch countriesError.InvalidResponse {
                print("Invalid response error")
            } catch countriesError.InvalidData {
                print("Invalid data error")
            } catch {
                print("Unexpected error: \(error)")
            }
        }
    }

    
    func updateContentView() {
        guard let informacia = informacia else {
            return
        }
    }
    func internetidanInfoebi() async throws -> List {
        let endpoint = "https://restcountries.com/v3.1/all"
        
        guard let url = URL(string: endpoint) else {
            throw countriesError.URLError
        }
        let (data, response) = try await URLSession.shared.data(from: url)
        
        guard let response = response as? HTTPURLResponse, response.statusCode == 200 else {
            throw countriesError.InvalidResponse
        }
        
        do {
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



