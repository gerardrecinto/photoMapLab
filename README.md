# Photo Map

![Swift](https://img.shields.io/badge/Swift-3.0-F05138?logo=swift&logoColor=white)
![iOS 9+](https://img.shields.io/badge/iOS-9%2B-000000?logo=apple&logoColor=white)
![MapKit](https://img.shields.io/badge/MapKit-MKAnnotation-blue)
![Foursquare](https://img.shields.io/badge/Foursquare-Venues%20API-red)

![Demo](docs/assets/demo2.gif)

> Photo tagging app that captures an image via `UIImagePickerController`, searches for nearby venues through the Foursquare API, and drops an `MKPointAnnotation` on an `MKMapView` with the selected photo embedded in the callout's `leftCalloutAccessoryView`.

## Features

- **Camera / library fallback:** `viewDidLoad` presents `UIImagePickerController` immediately; it checks `UIImagePickerController.isSourceTypeAvailable(.camera)` and falls back to `.photoLibrary` on Simulator, so the flow works on both physical devices and during development.
- **Photo in map callout:** `mapView(_:viewFor:)` implements `MKMapViewDelegate` to return a custom `MKPinAnnotationView`; the annotation's `leftCalloutAccessoryView` is a 50×50 `UIImageView` pre-loaded with the captured image, so tapping any pin shows the photo inline.
- **Annotation reuse:** `mapView.dequeueReusableAnnotationView(withIdentifier:)` is used before allocating a new view, following the same cell-reuse pattern as `UITableView` to avoid allocating a new annotation view per pin.
- **Live venue search:** `LocationsViewController` implements `UISearchBarDelegate.searchBar(_:shouldChangeTextIn:replacementText:)`, firing `fetchLocations` on every character change. `URLSession.dataTask` queries the Foursquare Venues API with the partial text and calls `tableView.reloadData()` on the main queue when results arrive.
- **Delegate-based coordinate handoff:** `LocationsViewControllerDelegate` defines `locationsPickedLocation(controller:latitude:longitude:)`. When a venue row is tapped, the delegate call passes `CLLocationDegrees` back to `PhotoMapViewController`, which then calls `mapView.addAnnotation` and pops the navigation stack.
- **MKCoordinateRegion setup:** The map initializes centered on San Francisco (`37.783333, -122.416667`) with a `latitudeDelta` / `longitudeDelta` of 0.1°, giving approximately an 11km viewport — wide enough to show a neighborhood's worth of venues.
- **AFNetworking via CocoaPods:** Network image loading uses AFNetworking (CocoaPods), keeping image fetch logic out of view controllers.

## Tech Stack

| Layer | Technology |
|---|---|
| Language | Swift 3.0 |
| Maps | MapKit (`MKMapView`, `MKPointAnnotation`, `MKPinAnnotationView`) |
| Camera | UIImagePickerController (camera + photo library) |
| Networking | URLSession, AFNetworking (CocoaPods) |
| Location search | Foursquare Venues API v2 |
| Navigation | UINavigationController, storyboard segues, custom delegate protocol |

## Architecture

Three view controllers connected by a storyboard navigation stack. `PhotoMapViewController` is the root — it owns the `MKMapView` and holds the captured `UIImage`. It pushes to `LocationsViewController` (via `"tagSegue"`) to let the user search for a venue; the result flows back through `LocationsViewControllerDelegate` rather than an unwind segue, so the coordinate handoff is explicit and testable. `FullImageViewController` provides a full-screen photo detail view. All networking is fire-and-forget via `URLSessionDataTask`; results land on `OperationQueue.main` to avoid explicit `DispatchQueue.main.async` calls.

## Key Implementation

**Photo embedded in annotation callout:** The `MKMapViewDelegate` method casts `annotationView?.leftCalloutAccessoryView` to `UIImageView` and sets `imageView.image = pickedImage` each time a callout is shown. Because the same `pickedImage` reference is held by `PhotoMapViewController`, the image appears instantly without a second network or disk fetch.

**Live-search on every keystroke:** `shouldChangeTextIn` fires before the text field updates, so `fetchLocations` is called with the reconstructed `newText` (using `NSString.replacingCharacters(in:with:)`) — one character ahead of the visible field. This keeps the table results current without a debounce timer, acceptable for a local Foursquare query at this scale.

**Delegate over segue for coordinate return:** Using a custom `LocationsViewControllerDelegate` instead of an unwind segue means `PhotoMapViewController` receives the `latitude`/`longitude` values as typed `NSNumber` parameters in a single method call, with `navigationController?.popViewController` called immediately after, keeping the dismissal and data handoff co-located.

## Setup

```bash
git clone https://github.com/gerardrecinto/photo-map-ios.git
cd photo-map-ios
pod install
open "Photo Map.xcworkspace"
```

Add your Foursquare `CLIENT_ID` and `CLIENT_SECRET` to `LocationsViewController.swift`. Run on a physical device for camera and GPS; the Simulator will fall back to the photo library.
