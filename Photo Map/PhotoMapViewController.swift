//
//  PhotoMapViewController.swift
//  Photo Map
//
//  Created by Nicholas Aiwazian on 10/15/15.
//  Copyright © 2015 Timothy Lee. All rights reserved.
//

import UIKit
import MapKit

class PhotoMapViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, LocationsViewControllerDelegate, MKMapViewDelegate {


  var pickedImage: UIImage?
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    let locationsViewController = segue.destination as! LocationsViewController
    locationsViewController.delegate = self

  }
  func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
    let reuseID = "myAnnotationView"

    var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseID)
    if (annotationView == nil) {
      annotationView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseID)
      annotationView?.canShowCallout = true
      annotationView?.leftCalloutAccessoryView = UIImageView(frame: CGRect(x:0, y:0, width: 50, height:50))
    }

    if let imageView = annotationView?.leftCalloutAccessoryView as? UIImageView {
      imageView.image = pickedImage
    }

    return annotationView
  }
  @IBOutlet weak var mapView: MKMapView!
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.

      // One degree of latitude is approximately 111 kilometers (69 miles) at all times.
      // San Francisco Lat, Long = latitude: 37.783333, longitude: -122.416667
      let mapCenter = CLLocationCoordinate2D(latitude: 37.783333, longitude: -122.416667)
      let mapSpan = MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1)
      let region = MKCoordinateRegion(center: mapCenter, span: mapSpan)
      // Set animated property to true to animate the transition to the region
      mapView.setRegion(region, animated: false)
      let vc = UIImagePickerController()
      vc.delegate = self
      vc.allowsEditing = true

      self.present(vc, animated: true, completion: nil)
      if UIImagePickerController.isSourceTypeAvailable(.camera) {
        print("Camera is available")
        vc.sourceType = .camera
      } else {
        print("Camera not available so we will use photo library instead")
        vc.sourceType = .photoLibrary
      }


    }


  func imagePickerController(_ picker: UIImagePickerController,
                             didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
    let originalImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage
    // Do something with the images (based on your use case)
    pickedImage = originalImage

    dismiss(animated: true) { [weak self] in
      self?.performSegue(withIdentifier: "tagSegue", sender: nil)
    }
  }

  func locationsPickedLocation(controller: LocationsViewController, latitude: NSNumber, longitude: NSNumber) {
    addPin()
  }
  func addPin() {
    let annotation = MKPointAnnotation()
    let locationCoordinate = CLLocationCoordinate2D(latitude: 37.779560, longitude: -122.393027)
    annotation.coordinate = locationCoordinate
    annotation.title = "Founders Den"

    mapView.addAnnotation(annotation)
  }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
