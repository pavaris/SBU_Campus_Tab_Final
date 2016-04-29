//  Daily Life
//
//  FirstViewController.swift
//  SBU_Campus_Tab
//
//  Created by Rashedul Khan & Pavaris Ketavanan on 11/9/15.
//  Copyright © 2015 Stony Brook University. All rights reserved.
//

import UIKit
import GoogleMaps

class DailyLifeVC: UIViewController, UISearchBarDelegate, UITableViewDelegate, UITableViewDataSource,GMSMapViewDelegate {
    //  MARK:-  Outlets
    
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var viewMap: GMSMapView!
    @IBOutlet weak var table: UITableView!
    @IBOutlet weak var bottomTableHeight: NSLayoutConstraint!
    
    @IBAction func searchButton(sender: UIButton) {
        searchButt = sender
        categoryButton.hidden = true
        searchBar.becomeFirstResponder()
        searchBar.placeholder = "Building Names"
        sender.hidden = true
    }
    
    @IBOutlet weak var categoryButton: UIButton!
    
    var searchButt:UIButton!
    
    //  MARK:-  Variables
    
    // Location data
    var locations = [CustomGMSMarker]() //original
    var categories = [String]() // corresponding categories(not assigned='Default')
    var categorySet: Set<String> = []
    var selectedCategorySet: Set<String> = []
    
    //  Searching Data
    var locationTitles = [String]()
    var filteredTitles = [String]()
    
    //  MARK:-  ViewDidLoad
    
    override func viewDidLoad() {
        serverRequest()
        super.viewDidLoad()
        //UIApplication.sharedApplication().statusBarStyle = UIStatusBarStyle.Default
        searchBar.resignFirstResponder()
        table.hidden = true // hide table
        configMap()
        
        //  Delegates
        searchBar.delegate = self
        table.dataSource = self
        table.delegate = self
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("keyboardWillShow:"), name: UIKeyboardWillShowNotification, object: nil)
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    private func getTitles() {
        for loc in locations {
            locationTitles.append(loc.title)
        }
    }
    
    private func getCategories() {
        for loc in locations {
            categories.append(loc.category)
            categorySet.insert(loc.category)
            // Initially unselect all.
            //selectedCategorySet.insert(loc.category)
        }
    }
    
    private func configMap() {
        let camera = GMSCameraPosition.cameraWithLatitude(40.914468,
            longitude: -73.123646, zoom: 16)
        viewMap.camera = camera
        viewMap.myLocationEnabled = true
        viewMap.settings.myLocationButton = true
        viewMap.padding = UIEdgeInsetsMake(0, 0, bottomLayoutGuide.length + 60, 0)
    }
    
    private func getMarker(title: String!) -> GMSMarker? {
        for (var i=0;i<locations.count;i++) {
            if (title == locations[i].title) {
                return locations[i]
            }
        }
        return nil
    }
    
    //  MARK: - Search
    
    internal func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {
        // called when text changes (including clear)
        filterContentForSearchText(searchText)
    }
    
    func filterContentForSearchText(searchText: String, scope: String = "All") {
        filteredTitles = locationTitles.filter { title in
            return title.lowercaseString.containsString(searchText.lowercaseString)
        }
        table.reloadData()
    }
    
    internal func searchBarTextDidBeginEditing(searchBar: UISearchBar) {
        // called when text starts editing
        searchButt.hidden = true
        categoryButton.hidden = true
        table.reloadData()
        print("Begin editing")
        searchBar.showsCancelButton = true
        
        let time = dispatch_time(dispatch_time_t(DISPATCH_TIME_NOW), 1000)
        dispatch_after(time, dispatch_get_main_queue()) {
            self.table.hidden = false
            self.table.updateConstraints()
            self.table.reloadData()
        }
        
    }
    
    internal func searchBarSearchButtonClicked(searchBar: UISearchBar){
        // called when keyboard search button pressed
        searchBar.showsCancelButton = true
        print("Pressed Enter!!!\n")
        table.reloadData()
        
    }
    
    internal func searchBarCancelButtonClicked(searchBar: UISearchBar) {
        // called when cancel button pressed
        searchBar.placeholder?.removeAll()
        searchBar.text?.removeAll()
        viewMap.clear()
        for loc in locations {
            if selectedCategorySet.contains(loc.category) {
                loc.map = viewMap
            }
        }
        configMap() // reset camera
        table.hidden = true
        searchBar.showsCancelButton = false
        searchBar.resignFirstResponder()
        searchButt.hidden = false
        categoryButton.hidden = false
        table.reloadData()
        
    }
    
    func keyboardWillShow(notification: NSNotification) {
        print("Here")/*
        if let userInfo = notification.userInfo {
            if let keyboardSize = (userInfo[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.CGRectValue() {
                bottomTableHeight.constant = keyboardSize.height
                //view.setNeedsLayout()   // Autolayout update value
            }
        }*/
    }
    
    func keyboardWillHide(notification: NSNotification){
        //bottomTableHeight.constant = 44.0
        //bottomTableHeight.constant = 559
        //view.setNeedsLayout()
    }
    
    //  MARK: - TableView
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    //  Data Source
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if searchBar.text == "" { print("locations \(locationTitles.count)")
            return locationTitles.count
        } else { print("filtered locations \(filteredTitles.count)")
            return filteredTitles.count
        }
    }
    
    //  Labels for cell.
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cellIdentifier = "MyCell"
        let cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier,
            forIndexPath: indexPath)
        if searchBar.text == "" {
            cell.textLabel?.text = locationTitles[indexPath.row]
        } else {
            cell.textLabel?.text = filteredTitles[indexPath.row]
        }
        
        return cell
    }
    
    //  Selected cell.
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        NSLog("You selected cell number: \(indexPath.row)!")
        var loc: GMSMarker!
        if searchBar.text == "" {
            loc = locations[indexPath.row]
        } else {
            loc = getMarker(filteredTitles[indexPath.row])
        }
        viewMap.clear()
        loc.map = viewMap
        let camera = GMSCameraPosition.cameraWithLatitude(loc.position.latitude,
            longitude: loc.position.longitude, zoom: 18)
        viewMap.camera = camera
        
        table.hidden = true
        
    }
    
    //  MARK: - Navigation
    
    //  Pass Unique Categories to CatagoryTableVC
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        print (segue.identifier!)
        if (segue.identifier! == "categorySegue") {
            print(segue.destinationViewController)
            if let nav = segue.destinationViewController as? UINavigationController {
                if let destination = nav.topViewController as? CatagoryTableVC {
                    destination.selectedPath = selectedCategorySet
                    for cat in categorySet.sort(){
                        destination.catagories.append(cat)
                    }
                }
            }
        }
    }
    
    
    @IBAction func unwindToMapView(sender: UIStoryboardSegue) {
        print("unwindToMapView")
        if let sourceViewController = sender.sourceViewController as? CatagoryTableVC {
            selectedCategorySet = sourceViewController.selectedPath
        }
        
        //  Clear map and add new elements
        viewMap.clear()
        for loc in locations {
            if selectedCategorySet.contains(loc.category) {
                loc.map = viewMap
            }
        }
    }
    
    struct MyVariables {
        static var allNames: [String] = []
        static var allShortNames: [String] = []
        static var allCoordX: [Double] = []
        static var allCoordY: [Double] = []
        static var jsonLength = Int()
        static var allCategories: [String] = []
        static var lastModifiedServer = String()
        static var markerList: [poi] = []
        static var allSnippets: [String] = []
        static var hoursWeek: [String] = []
        static var hoursWeekend: [String] = []
    }
    
    func returnName(index: Int){
        print(MyVariables.allNames[index])
    }
    
    func serverRequest(){
        let lastModifiedLocal = NSDate()
        let requestURL: NSURL = NSURL(string: "http://130.245.191.166:8080/maps.php")!
        let urlRequest: NSMutableURLRequest = NSMutableURLRequest(URL: requestURL)
        let session = NSURLSession.sharedSession()
        let task = session.dataTaskWithRequest(urlRequest) {
            (data, response, error) -> Void in
            
            let httpResponse = response as! NSHTTPURLResponse
            let statusCode = httpResponse.statusCode
            
            if (statusCode == 200) {
                print("Everyone is fine, file downloaded successfully.")
                do{
                    
                    let json = try NSJSONSerialization.JSONObjectWithData(data!, options:.AllowFragments)
                    
                    print("length", json.count)
                    print(json)
                    print(lastModifiedLocal)
                    MyVariables.jsonLength = json.count
                    let number = String(0)
                    print("somethingor",json[number])
                    
                    if let item = json[0] as? [String: AnyObject]{
                        MyVariables.lastModifiedServer = String(item["lastModified"])
                        print(MyVariables.lastModifiedServer)
                    }
                    
                    for i in 1...json.count-1{
                        let num = String(i)
                        if let item = json[num] as? [String: AnyObject] {
                            print(item)
                            
                            var name = String(item["name"])
                            name = name.substringWithRange(Range<String.Index>(start: name.startIndex.advancedBy(9), end: name.endIndex.advancedBy(-1)))
                            
                            var shortName = String(item["shortName"])
                            shortName = shortName.substringWithRange(Range<String.Index>(start: shortName.startIndex.advancedBy(9), end: shortName.endIndex.advancedBy(-1)))
                            print(shortName)
                            
                            var coordYs = String(item["coordY"])
                            coordYs = coordYs.substringWithRange(Range<String.Index>(start: coordYs.startIndex.advancedBy(9), end: coordYs.endIndex.advancedBy(-1)))
                            print(coordYs)
                            let coordY = Double(coordYs)
                            
                            var coordXs = String(item["coordX"])
                            coordXs = coordXs.substringWithRange(Range<String.Index>(start: coordXs.startIndex.advancedBy(9), end: coordXs.endIndex.advancedBy(-1)))
                            print(coordXs)
                            
                            let coordX = Double(coordXs)
                            
                            var category = String(item["category"])
                            category = category.substringWithRange(Range<String.Index>(start: category.startIndex.advancedBy(9), end: category.endIndex.advancedBy(-1)))
                            print(category)
                            
                            var id = String(item["_id"])
                            print(id)
                            
                            var snippet = String(item["snippet"])
                            snippet = snippet.substringWithRange(Range<String.Index>(start: snippet.startIndex.advancedBy(9), end: snippet.endIndex.advancedBy(-1)))
                            print(snippet)
                            
                            var hoursWeek = String(item["hoursWeek"])
                            hoursWeek = hoursWeek.substringWithRange(Range<String.Index>(start: hoursWeek.startIndex.advancedBy(9), end: hoursWeek.endIndex.advancedBy(-1)))
                            print(hoursWeek)
                            
                            var hoursWeekend = String(item["hoursWeekend"])
                            hoursWeekend = hoursWeekend.substringWithRange(Range<String.Index>(start: hoursWeekend.startIndex.advancedBy(9), end: hoursWeekend.endIndex.advancedBy(-1)))
                            print(hoursWeekend)
                            
                            MyVariables.allNames.append(name)
                            MyVariables.allCoordX.append(coordX!)
                            MyVariables.allCoordY.append(coordY!)
                            MyVariables.allCategories.append(category)
                            MyVariables.allSnippets.append(snippet)
                            MyVariables.hoursWeek.append(hoursWeek)
                            MyVariables.hoursWeekend.append(hoursWeekend)
                            
                            let tempMarker = poi()
                            tempMarker.name = name
                            tempMarker.xcoord = coordX!
                            tempMarker.ycoord = coordY!
                            tempMarker.category = category
                            tempMarker.snippet = snippet
                            
                            MyVariables.markerList.append(tempMarker)
                        }
                    }
                    
                }
                catch {
                    print("Error with Json: \(error)")
                }
            }
                
            else{
                print("nope");
            }
        }
        
        task.resume()
        let time = dispatch_time(dispatch_time_t(DISPATCH_TIME_NOW),1000050000)
        dispatch_after(time, dispatch_get_main_queue()) {
            self.loadMarkers(self.viewMap)
            self.getTitles()
            self.getCategories()
        }
    }
 
    
    //  Load Markers
    private func loadMarkers(mapView: GMSMapView) {
        
        //Saved locations
        NSUserDefaults.standardUserDefaults().setObject(MyVariables.allNames, forKey: "names")
        let names = NSUserDefaults.standardUserDefaults().objectForKey("names")
        
        NSUserDefaults.standardUserDefaults().setObject(MyVariables.allShortNames, forKey: "shortNames")
        let shortNames = NSUserDefaults.standardUserDefaults().objectForKey("shortNames")
        
        NSUserDefaults.standardUserDefaults().setObject(MyVariables.allCoordX, forKey: "coordX")
        let coordX = NSUserDefaults.standardUserDefaults().objectForKey("coordX")
        
        NSUserDefaults.standardUserDefaults().setObject(MyVariables.allCoordY, forKey: "coordY")
        let coordY = NSUserDefaults.standardUserDefaults().objectForKey("coordY")
        
        NSUserDefaults.standardUserDefaults().setObject(MyVariables.allCategories, forKey: "categories")
        let categories = NSUserDefaults.standardUserDefaults().objectForKey("categories")
        
        
        NSUserDefaults.standardUserDefaults().setObject("", forKey: "serverDate")
        var serverDate = NSUserDefaults.standardUserDefaults().stringForKey("serverDate")
        
        
        NSUserDefaults.standardUserDefaults().setObject(MyVariables.allSnippets, forKey: "snippets")
        var snippets = NSUserDefaults.standardUserDefaults().objectForKey("snippets")
        
        NSUserDefaults.standardUserDefaults().setObject(MyVariables.hoursWeek, forKey: "hoursWeek")
        var hoursWeek = NSUserDefaults.standardUserDefaults().objectForKey("hoursWeek")
        
        NSUserDefaults.standardUserDefaults().setObject(MyVariables.hoursWeekend, forKey: "hoursWeekend")
        var hoursWeekend = NSUserDefaults.standardUserDefaults().objectForKey("hoursWeekend")
        
        
        print("!!", serverDate)
        
        //IF dates don't match, sync
        if serverDate != MyVariables.lastModifiedServer{
            print("DATES DON'T MATCH")
            NSUserDefaults.standardUserDefaults().synchronize()
            NSUserDefaults.standardUserDefaults().setObject(MyVariables.lastModifiedServer, forKey: "serverDate")
            serverDate = NSUserDefaults.standardUserDefaults().stringForKey("serverDate")
        }
        else{
            print("DATES SAME")
        }
        print("AFTER", serverDate)
        
        if(MyVariables.jsonLength != 0){
            for i in 0...MyVariables.jsonLength-2{
                let nameFor = String(names![i])
                print(i, nameFor)
                //                let shortNameFor = String(shortNames![i])
                let categoryFor = String(categories![i])
                let coordXFor = Double(String(coordX![i]))
                let coordYFor = Double(String(coordY![i]))
                let snippetsFor = String(snippets![i])
                
                let tempvar = CustomGMSMarker()
                tempvar.position = CLLocationCoordinate2DMake(coordXFor!,coordYFor!)
                tempvar.title = nameFor
                tempvar.snippet = snippetsFor
                tempvar.category = categoryFor
                //tempvar.map = mapView
                locations.append(tempvar)
            }
        }
        else{
            let alertController = UIAlertController(title: "Error", message:
                "Locations cannot be retrieved. Please check your internet connection.", preferredStyle: UIAlertControllerStyle.Alert)
            alertController.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.Default,handler: nil))
            
            self.presentViewController(alertController, animated: true, completion: nil)
        }
    }
    
    func mapView(mapView: GMSMapView, didTapInfoWindowOfMarker marker: GMSMarker) {
        print("You tapped at \(marker.title), \(marker.snippet)")
        
        for x in 0...MyVariables.allNames.count-1{
            if(MyVariables.allNames[x] == marker.title){
                print(MyVariables.allSnippets[x])
                let moreInfo = MyVariables.allSnippets[x]
                let hoursWeek = MyVariables.hoursWeek[x]
                let hoursWeekend = MyVariables.hoursWeekend[x]
                let messageString = moreInfo + "\nHours \n" + "Monday - Friday: " + hoursWeek + "\n Saturday/Sunday: " + hoursWeekend + ""
                
                
                let alertController = UIAlertController(title: marker.title, message:
                    messageString, preferredStyle: UIAlertControllerStyle.ActionSheet)
                alertController.addAction(UIAlertAction(title: "Done", style: UIAlertActionStyle.Default,handler: nil))
                
                self.presentViewController(alertController, animated: true, completion: nil)
                
            }
        }
    }
}

class poi{
    var name: String?
    var xcoord: Double?
    var ycoord: Double?
    var description: String?
    var hours: String?
    var category: String?
    var snippet: String?
}
