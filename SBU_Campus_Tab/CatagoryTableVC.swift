//
//  CatagoryTableVC.swift
//  SBU_Campus_Tab
//
//  Created by Rashedul Khan & Pavaris Ketavanan on 3/30/16.
//  Copyright © 2016 Stony Brook University. All rights reserved.
//

import UIKit

class CatagoryTableVC: UITableViewController {

    var catagories = [String]()
    var selectedPath: Set<String> = []
    
    override func viewDidLoad() {
        print ("\nView DID LOAD")
        super.viewDidLoad()
        for cat in catagories{print(cat)}
    }
    
    //  MARK: - Navigation
    
    @IBAction func cancelButton(sender: UIBarButtonItem) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func selectAllButton(sender: UIBarButtonItem) {
        for var i=0; i<catagories.count;i++ {
            let indexPath = NSIndexPath(forRow: i, inSection: 0)
            let cell = tableView.cellForRowAtIndexPath(indexPath)
            cell?.accessoryType = UITableViewCellAccessoryType.Checkmark
            selectedPath.insert((cell?.textLabel?.text)!)
        }   // done adding check marks
    }
    
    @IBAction func selectNoneButton(sender: UIBarButtonItem) {
        for var i=0; i<catagories.count;i++ {
            let indexPath = NSIndexPath(forRow: i, inSection: 0)
            let cell = tableView.cellForRowAtIndexPath(indexPath)
            cell?.accessoryType = UITableViewCellAccessoryType.None
        }   // done removing check marks

        selectedPath.removeAll()
    }
    
    
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        print ("Done")
    }
    
    //  MARK: - TableView
    

    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let cell = tableView.cellForRowAtIndexPath(indexPath)
        //  Flip accessory type
        if cell?.accessoryType == UITableViewCellAccessoryType.Checkmark {      // UnSelected
            cell?.accessoryType = UITableViewCellAccessoryType.None
            selectedPath.remove((cell?.textLabel?.text)!)
        }
        else {  // Selected
            cell?.accessoryType = UITableViewCellAccessoryType.Checkmark
            selectedPath.insert((cell?.textLabel?.text)!)
        }
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return catagories.count ?? 0
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        print ("\nGenerating NEW cell")
        let cellIdentifier = "CatagoeryCell"
        let cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier,
            forIndexPath: indexPath)
        //selectedPath.insert(catagories[indexPath.row])
        //  Display Cell
        cell.textLabel?.text = catagories[indexPath.row]
        if (selectedPath.contains(catagories[indexPath.row])) {
            cell.accessoryType = UITableViewCellAccessoryType.Checkmark
        } else {
            cell.accessoryType = UITableViewCellAccessoryType.None
        }
        cell.layoutIfNeeded() // make sure the cell is properly rendered
        return cell
    }


}
