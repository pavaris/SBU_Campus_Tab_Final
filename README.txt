README: SBU_CAMPUS_APP
Author: Rashedul Khan & Pavaris Ketavanan


PROGRAM DATA:

    // Location data
    var locations = [CustomGMSMarker]() //original
    var categories = [String]() // corresponding categories(not assigned='Default')
    var categorySet: Set<String> = []
    var selectedCategorySet: Set<String> = []
    
    //  Searching Data
    var locationTitles = [String]()
    var filteredTitles = [String]()

Immutable data: “locations”, “locationTitles”, “categories” and “categorySet”
Mutable data: “selectedCategorySet”, “filteredTitles”

	The “locations” is the original array that is used to hold all original markers downloaded from the server. This array should NEVER be mutated. Other data structures should be used if data must be mutated. “categories” array must also NOT be mutated as it is calulated at the original markers downloaded from the server. “categorySet” contains identical data as “categories’ except it is a set and not an array.

	“selectedCategorySet” contains the set of categories that was selected by the user from “CategoryTableVC”. This data set dictates which type of POI will be displayed on the map by default. Thus, at ViewDidLoad() it is empty as no markers should be displayed on the map unless the user explicitely searches for a marker or selects categories to display. This data set is also passed back and forth to the CatagoryTableVC via “unwindToMapView” and “prepareForSegue” for synchronization. 

	“locationTitles” and “filteredTitles” serves as the data source for the search table. However, “locationTitles” is immutable and “filteredTitles” is mutable. “filteredTitles” data is generated from “locations” during ViewDidLoad(). This data should never be altered by the programmer. “filteredTitles” is mutated according to the text typed into the search bar by the user. Everytime user types in a character, it is updated to reflect results that matches the search text. Thus, data in “locationTitles” is never mutated.


PROGRAM FLOW:

	During ViewDidLoad() all POI markers are downloaded from the server asynchnorously. Corresponding data is parsed and loaded into the appropriate data fields. However, this is done in the background while the map is loading. Once this process is complete the program should have all necessary data that user can interact with.

	When the “search” button is pressed, it hides the category and search button. Then the table is unhidden and loaded with data from the corresponding data set. The user can interact with the table and enter search keywords at the same time. When cancel is pressed, the table, and search bar are both hidden from the view. The search button and category button is displayed along with the map view.

	When the “categories” button is pressed, the program segues to “CatagoryTableVC”. This is a table view controller that displayes a list of categories onto a table. The user is allowed to scroll and select items from the table. These selections will be saved when the user returns to this view through a data passing through a segue mechanism. The user can also press “Select All” or “Deselect” button. “Select All” simply copies all content from “catagories” to “selectedPath”. The “Deseclt” does the exact opposite, it clears all content from “selectedPath”. If the “Cancel” button is pressed the view is simply dismissed and the user is returned to the original view controller. The “Done” button causes an exit action to unwind back to the original view controller. When it is pressed “unwindToMapView()” is called in the original view controller. “unwindToMapView()” simply retrieves the “selectedPath” onto “selectedCategorySet”. Then the map is cleared and updated according to this data set. Thus, all POI marker on the map are tied to categories selected by the user.