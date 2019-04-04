//
//  ViewController.swift
//  CallKitTutorial
//
//  Created by Paul Wilkinson on 19/2/19.
//  Copyright © 2019 Paul Wilkinson. All rights reserved.
//

import UIKit
import CoreData
import CallKit
import CallerData
import os

class ViewController: UIViewController {
    
    @IBOutlet weak var callerType: UISegmentedControl!
    @IBOutlet weak var tableView: UITableView!
    
    private var showBlocked: Bool {
        return self.callerType.selectedSegmentIndex == 1
    }
    
    lazy private var callerData = CallerData()
    
    private var resultsController: NSFetchedResultsController<Caller>!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        self.loadData()
    }
    
    private func loadData() {
        
        self.navigationItem.title = self.showBlocked ? "Blocked":"ID"
        
        let fetchRequest:NSFetchRequest<Caller> = self.callerData.fetchRequest(blocked: self.showBlocked)
        
        self.resultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: self.callerData.context, sectionNameKeyPath: nil, cacheName: nil)
        self.resultsController.delegate = self
        do {
            try self.resultsController.performFetch()
            self.tableView.reloadData()
        } catch {
            print("Failed to fetch data: \(error.localizedDescription)")
        }
    }
    
    
    @IBAction func callerTypeChanged(_ sender: UISegmentedControl) {
        self.loadData()
    }
    
    @IBAction func unwindFromSave(_ sender: UIStoryboardSegue) {
        
    }
    
    @IBAction func reloadTapped(_ sender: UIButton) {
        CXCallDirectoryManager.sharedInstance.reloadExtension(withIdentifier: "me.wilko.CallKitTutorial.CallKitTutorialExtension", completionHandler: { (error) in
            if let error = error {
                print("Error reloading extension: \(error.localizedDescription)")
            }
        })
        
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if let dest = segue.destination as? AddEditViewController {
            dest.isBlocked = self.showBlocked
            dest.callerData = self.callerData
            if let cell = sender as? UITableViewCell,
                let indexPath = tableView.indexPath(for: cell),
                let caller = self.resultsController.fetchedObjects?[indexPath.row] {
                dest.caller = caller
            }
        }
    }
    
}

extension ViewController: UITableViewDataSource, UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        return self.resultsController.sections?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.resultsController.fetchedObjects?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CallerCell", for: indexPath)
        let caller = self.resultsController.fetchedObjects![indexPath.row]
        
        
        cell.textLabel?.text = caller.isBlocked ? String(caller.number) : caller.name ?? ""
        cell.detailTextLabel?.text = caller.isBlocked ? "" : String(caller.number)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        switch editingStyle {
        case .delete:
            if let caller = self.resultsController.fetchedObjects?[indexPath.row] {
                caller.isRemoved = true
                caller.updatedDate = Date()
                self.callerData.saveContext()
            }
        default:
            break
        }
    }
}

extension ViewController: NSFetchedResultsControllerDelegate {
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        self.tableView.beginUpdates()
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        
        let newIndexPath: IndexPath? = newIndexPath != nil ? IndexPath(row: newIndexPath!.row, section: 0) : nil
        let currentIndexPath: IndexPath? = indexPath != nil ? IndexPath(row: indexPath!.row, section: 0) : nil
        
        switch type {
        case .insert:
            self.tableView.insertRows(at: [newIndexPath!], with: .automatic)
            
        case .delete:
            self.tableView.deleteRows(at: [currentIndexPath!], with: .fade)
            
        case .move:
            self.tableView.moveRow(at: currentIndexPath!, to: newIndexPath!)
            
        case .update:
            self.tableView.reloadRows(at: [currentIndexPath!], with: .automatic)
        @unknown default:
            <#fatalError()#>
        }
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        self.tableView.endUpdates()
    }
}

