//
//  MasterViewController.swift
//  WikiSearch
//
//  Created by Rob Napier on 6/9/15.
//  Copyright © 2015 Rob Napier. All rights reserved.
//

import UIKit

class MasterViewController: UITableViewController, UISearchResultsUpdating {

    var searchController: UISearchController?
    var detailViewController: DetailViewController? = nil
    var pages = [Page]()

    let searcher = Searcher()
    var currentSearch: Search?


    override func viewDidLoad() {
        super.viewDidLoad()

        if let split = self.splitViewController {
            let controllers = split.viewControllers
            self.detailViewController = (controllers[controllers.count-1] as! UINavigationController).topViewController as? DetailViewController
        }

        // Create the search controller, but we'll make sure that this SearchShowResultsInSourceViewController
        // performs the results updating.
        self.searchController = UISearchController(searchResultsController: nil)
        self.searchController?.searchResultsUpdater = self

        self.searchController?.dimsBackgroundDuringPresentation = false

        // Make sure the that the search bar is visible within the navigation bar.
        self.searchController?.searchBar.sizeToFit()

        // Include the search controller's search bar within the table's header view.
        self.tableView.tableHeaderView = self.searchController?.searchBar

        self.definesPresentationContext = true

    }

    override func viewWillAppear(animated: Bool) {
        self.clearsSelectionOnViewWillAppear = self.splitViewController!.collapsed
        super.viewWillAppear(animated)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Segues

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "showDetail" {
            if let indexPath = self.tableView.indexPathForSelectedRow {
                let object = self.pages[indexPath.row]
                let controller = (segue.destinationViewController as! UINavigationController).topViewController as! DetailViewController
                controller.detailItem = object.title
                controller.navigationItem.leftBarButtonItem = self.splitViewController?.displayModeButtonItem()
                controller.navigationItem.leftItemsSupplementBackButton = true
            }
        }
    }

    // MARK: - Table View

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.pages.count
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath)

        let object = pages[indexPath.row]
        cell.textLabel?.text = object.title
        return cell
    }


    // MARK: - UISearchResultsUpdating

    func updateSearchResultsForSearchController(searchController: UISearchController) {
        self.currentSearch?.cancel()

        if let searchString = searchController.searchBar.text {
            self.currentSearch = self.searcher.search(searchString, completionHandler: { result in
                do {
                    try self.pages = result()
                }
                catch {
                    self.pages = []
                }
                self.tableView.reloadData()
                }
            )
        }
    }
}

