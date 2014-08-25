//
//  MasterViewController.swift
//  WikiStuff
//
//  Created by Rob Napier on 8/16/14.
//  Copyright (c) 2014 Rob Napier. All rights reserved.
//

import UIKit

class MasterViewController: UITableViewController, UISearchResultsUpdating {

  @IBOutlet var searchController: UISearchController!

  let searcher = Searcher()
  var currentSearch: Search?

  var detailViewController: DetailViewController? = nil
  var pages = [Page]()


  override func awakeFromNib() {
    super.awakeFromNib()
    self.clearsSelectionOnViewWillAppear = false
    self.preferredContentSize = CGSize(width: 320.0, height: 600.0)
  }

  override func viewDidLoad() {
    super.viewDidLoad()
    let controllers = self.splitViewController.viewControllers
    self.detailViewController = controllers[controllers.count-1].topViewController as? DetailViewController

    // Create the search controller, but we'll make sure that this SearchShowResultsInSourceViewController
    // performs the results updating.
    self.searchController = UISearchController(searchResultsController: nil)
    self.searchController.searchResultsUpdater = self

    self.searchController.dimsBackgroundDuringPresentation = false

    // Make sure the that the search bar is visible within the navigation bar.
    self.searchController.searchBar.sizeToFit()

    // Include the search controller's search bar within the table's header view.
    self.tableView.tableHeaderView = searchController.searchBar

    self.definesPresentationContext = true
  }


  // MARK: - Segues

  override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    if segue.identifier == "showDetail" {
      let indexPath = self.tableView.indexPathForSelectedRow()
      let object = self.pages[indexPath.row]
      let controller = (segue.destinationViewController as UINavigationController).topViewController as DetailViewController
      controller.detailItem = object.title
      controller.navigationItem.leftBarButtonItem = self.splitViewController.displayModeButtonItem()
      controller.navigationItem.leftItemsSupplementBackButton = true
    }
  }

  // MARK: - Table View

  override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return pages.count
  }

  override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    let cell = self.tableView.dequeueReusableCellWithIdentifier("Cell") as UITableViewCell

    let object = pages[indexPath.row]
    cell.textLabel.text = object.title
    return cell
  }

  // MARK: - Searchbar

  func updateSearchResultsForSearchController(searchController: UISearchController!) {
    self.currentSearch?.cancel()

    let searchString = searchController.searchBar.text

    self.currentSearch = self.searcher.search(searchString, completionHandler: { result in
      self.pages = result ?? []
      
      self.tableView.reloadData()
      }
    )
  }
}

