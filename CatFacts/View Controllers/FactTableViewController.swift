//
//  FactTableViewController.swift
//  CatFacts
//
//  Created by Jared Warren on 1/7/20.
//  Copyright © 2020 Warren. All rights reserved.
//

import UIKit

class FactTableViewController: UITableViewController {
    
    // MARK: - Properties
    
    private var currentPage = 0
    var facts = [Fact]() {
        didSet {
            tableView.reloadData()
        }
    }
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        fetchFacts()
    }
    
    // MARK: - UITableView Data Source
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        facts.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "factCell", for: indexPath)
        let fact = facts[indexPath.row]
        cell.textLabel?.text = String(fact.id ?? 0)
        cell.detailTextLabel?.text = fact.details
        
        if indexPath.row == facts.count - 1 {
            fetchFacts()
        }
        
        return cell
    }
    
    // MARK: - Private Methods
    
    private func fetchFacts() {
        currentPage += 1
        FactController.fetchFacts(pageNumber: currentPage) { [weak self] (result) in
            DispatchQueue.main.async {
                
                switch result {
                case .success(let facts):
                    self?.facts += facts
                case .failure(let error):
                    self?.presentErrorToUser(localizedError: error)
                }
            }
        }
    }
    
    private func presentPostFactAlert() {
        let postAlert = UIAlertController(title: "New Fact", message: "Let us know!", preferredStyle: .alert)
        postAlert.addTextField { (textField) in
            textField.placeholder = "Cats aren't real."
        }
        let cancelAction = UIAlertAction(title: "Nvm", style: .cancel)
        postAlert.addAction(cancelAction)
        
        let postAction = UIAlertAction(title: "Post", style: .default) { (_) in
            guard let textField = postAlert.textFields?.first,
                let details = textField.text,
                !details.isEmpty else { return }
            
            FactController.postFact(details: details) { [weak self] (result) in
                DispatchQueue.main.async {
                    switch result {
                    case .success(let fact):
                        print(fact)
                        self?.facts.append(fact)
                    case .failure(let error):
                        self?.presentErrorToUser(localizedError: error)
                    }
                }
            }
        }
        postAlert.addAction(postAction)
        present(postAlert, animated: true)
    }
    
    // MARK: - Actions
    
    @IBAction func postFactButtonTapped(_ sender: Any) {
        presentPostFactAlert()
    }
}
