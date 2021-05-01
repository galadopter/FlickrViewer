//
//  HistoryViewController.swift
//  FlickrViewer
//
//  Created by Yan Schneider on 1.05.21.
//

import UIKit
import RxSwift
import RxCocoa

class HistoryViewController: UIViewController {
    
    @IBOutlet private var tableView: UITableView!
    
    private let viewModel = HistoryViewModel()
    private let bag = DisposeBag()
        
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setup()
    }
}

//MARK: - Setup
private extension HistoryViewController {
    
    func setup() {
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: UITableViewCell.reuseIdentifier)
        bind()
    }
}

// MARK: - Binding
private extension HistoryViewController {
    
    func bind() {
        let output = viewModel.transform(input: ())
        
        bag.insert {
            output.records.drive(tableView.rx.items(cellIdentifier: UITableViewCell.reuseIdentifier, cellType: UITableViewCell.self)) { _, record, cell in
                cell.textLabel?.text = record
            }
            output.errors.emit(to: rx.error)
        }
    }
}
