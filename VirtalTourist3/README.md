#  VirtualTourist3
This app is a graduation project for Udacity IOS Nanodegree.

## Overview
The app uses Mapview with CoreData and Flickr API to desplay collection of images based on their location.


## This project focused on working with data persistence (CoreData)
- working with userDefault
- Making network request
- Parsing JSON file 
- CoreData stack
- NSFetchedResultsController
- Mapkit


## The idea
The idea of this project is that the user can add one or more pins on the map. When clicking on a pin, the user will be sent to another ViewController that shows a map where the pin is placed, a collecion of photos from Flickr in the location where the pin is placed and a button that allows the user to update the photos collection. When the user taps on one or more photos, the update button will change into "Delete photos" to allow the user to delete the photos that has been selected. If there were not photos at the location the pin is placed, an error will be displayed to the user. When the user closes the app and reopen it again, the pins will still be there since it is saved in CoreData 


## How to build
The app was built with XCode 10.1 and Swift 4.2
1. The least visrsion you need is XCode 9.0 and Swift 4.
2. Open 'VirtualTourist3.xcodeproj' file on XCode.
3. Run the app by Build button, Command + R or Product -> Run.
