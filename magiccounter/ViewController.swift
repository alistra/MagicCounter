//
//  ViewController.swift
//  magiccounter
//
//  Created by Aleksander Balicki on 10/02/2019.
//  Copyright © 2019 Alistra. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return CounterController.shared.gameHistories[section].states.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: identifier, for: indexPath)
        let game = CounterController.shared.gameHistories[indexPath.section].states[indexPath.row]
        cell.textLabel?.text = "\(game.myLife) / \(game.opponentLife)"
        cell.detailTextLabel?.text = "\(game.date)"
        return cell
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return CounterController.shared.gameHistories.count
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        let gameHistory = CounterController.shared.gameHistories[section]
        let startState = gameHistory.states.first
        let endState = gameHistory.states.last
        return dateFormatter.string(from: startState?.date ?? Date(), to: endState?.date ?? Date())
    }
    
    let dateFormatter: DateIntervalFormatter = {
        let f = DateIntervalFormatter()
        return f
    }()

    lazy var tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .grouped)
        tableView.dataSource = self
        tableView.delegate = self
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: identifier)
        return tableView
    }()
    
    let identifier = "cell"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(tableView)
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
        ])
        
        NotificationCenter.default.addObserver(forName: UserDefaults.didChangeNotification, object: nil, queue: .main) { (_) in
            self.tableView.reloadData()
        }
    }
}

