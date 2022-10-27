import Foundation
import UIKit

class ViewController: UIViewController,  UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate  {
    
    var books: [ProductBook] = []
    var booksFilter: [ProductBook] = []
    let networking = Network()
    
    private lazy var searchBar: UISearchBar = {
        let search = UISearchBar()
        search.translatesAutoresizingMaskIntoConstraints = false
        search.delegate = self
        return search
    }()
    
    private lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        tableView.backgroundColor = .white
        return tableView
    }()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        setupNetworking()
    }
    
    private func setupNetworking() {
        networking.getBooks { result in
            switch result {
            case .success(let response):
                self.books = response.books
                self.booksFilter = self.books
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
            case .failure(let failure):
                print("error \(failure)")
            }
        }
    }
    
    private func setupFilterNetwork(query: String) {
        networking.filterBooksForTitle(with: query) { response in
            switch response {
            case .success(let result):
                print(result.books)
                self.booksFilter.removeAll()
                self.booksFilter = result.books
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
            case .failure(let failure):
                print("error \(failure)")
            }
        }
    }
    
    private func setupView() {
        view.addSubview(searchBar)
        view.addSubview(tableView)
        
        NSLayoutConstraint.activate([
            
            searchBar.topAnchor.constraint(equalTo:  view.safeAreaLayoutGuide.topAnchor),
            searchBar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            searchBar.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            searchBar.bottomAnchor.constraint(equalTo: tableView.topAnchor),
            
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ])
    }
    
    private func isSearchBarEmpty() -> Bool {
        return searchBar.text?.isEmpty ?? true
    }
    
    private func filterBooks(_ query: String) {
        // Filtrando da api buscanco por titulo
        // setupFilterNetwork(query: query)
        
        
         // Ou usando filtro para o que ja foi salvo no carregamento por código do status do livro
                booksFilter = books.filter({ book in
                    return book.titulo.lowercased().contains(query.lowercased())
                })
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
        
    }
    
    //MARK: UITableViewDelegate, UITableViewDataSource
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if !booksFilter.isEmpty {
            return booksFilter.count
        }
        return books.count
    }
    
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        if !booksFilter.isEmpty {
            cell.textLabel?.text = booksFilter[indexPath.row].titulo
        } else {
            cell.textLabel?.text = books[indexPath.row].titulo
        }
        
        return cell
    }
    
    //MARK: UISearchBarDelegate
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        filterBooks(searchText)
    }
}
