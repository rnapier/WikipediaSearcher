//
//  RandomCollectionViewController.swift
//  WikipediaSearcher
//
//  Created by Rob Napier on 8/25/14.
//  Copyright (c) 2014 Rob Napier. All rights reserved.
//

import UIKit

let reuseIdentifier = "Cell"

extension Array {
  func flatMap<U>(f: T ->[U]) -> [U] {
    return self.reduce([U]()) { (acc, t) in
      return acc + f(t)
    }
  }
}

class RandomCollectionViewController: UICollectionViewController {

  let randomPageGenerator = RandomPageGenerator()
  var pageImages = [(UIImage, Page)]()

  override func viewDidLoad() {
    super.viewDidLoad()

    // Register cell classes
    self.collectionView?.registerClass(UICollectionViewCell.self, forCellWithReuseIdentifier: reuseIdentifier)

    // TODO: working here
//    switch self.randomPageGenerator.requestPages(10, {_ in return}) {
//    case .Success(let pages):
//      self.pageImages = pages.unbox.flatMap(pageImagesForPage)
//    case .Failure(let error):
//      println(error)
//    }

    // Do any additional setup after loading the view.
  }

  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }

  /*
  // MARK: - Navigation

  // In a storyboard-based application, you will often want to do a little preparation before navigation
  override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject!) {
  // Get the new view controller using [segue destinationViewController].
  // Pass the selected object to the new view controller.
  }
  */

  // MARK: UICollectionViewDataSource

  //    override func numberOfSectionsInCollectionView(collectionView: UICollectionView!) -> Int {
  //        //#warning Incomplete method implementation -- Return the number of sections
  //        return 0
  //    }


  override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    //#warning Incomplete method implementation -- Return the number of items in the section
    return 0
  }

  override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
    let cell = collectionView.dequeueReusableCellWithReuseIdentifier(reuseIdentifier, forIndexPath: indexPath) as UICollectionViewCell

    // Configure the cell

    return cell
  }

  // MARK: UICollectionViewDelegate

  /*
  // Uncomment this method to specify if the specified item should be highlighted during tracking
  func collectionView(collectionView: UICollectionView!, shouldHighlightItemAtIndexPath indexPath: NSIndexPath!) -> Bool {
  return true
  }
  */

  /*
  // Uncomment this method to specify if the specified item should be selected
  func collectionView(collectionView: UICollectionView!, shouldSelectItemAtIndexPath indexPath: NSIndexPath!) -> Bool {
  return true
  }
  */

  /*
  // Uncomment these methods to specify if an action menu should be displayed for the specified item, and react to actions performed on the item
  func collectionView(collectionView: UICollectionView!, shouldShowMenuForItemAtIndexPath indexPath: NSIndexPath!) -> Bool {
  return false
  }

  func collectionView(collectionView: UICollectionView!, canPerformAction action: String!, forItemAtIndexPath indexPath: NSIndexPath!, withSender sender: AnyObject!) -> Bool {
  return false
  }

  func collectionView(collectionView: UICollectionView!, performAction action: String!, forItemAtIndexPath indexPath: NSIndexPath!, withSender sender: AnyObject!) {

  }
  */

}
