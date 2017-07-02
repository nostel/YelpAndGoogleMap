//
//  MapViewController.swift
//  YelpAndGoogleMap
//
//  Created by Son Le on 7/1/17.
//  Copyright © 2017 Son Le. All rights reserved.
//

import Foundation
import GoogleMaps

class MapViewController: UIViewController
{
    var currentZoom: Float = 17;
    
    var locationManager = CLLocationManager()
    
    var selectedBusiness: Business!
    
    var scaleChangedBySlider: Bool = false
    
    var isCurrentLocationDefined = false
    
    var markersDict = Dictionary<String, GMSMarker>()
    
    @IBOutlet weak var mapView: GMSMapView!
    
    @IBOutlet weak var segmentedContainer: UIView!
    
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    
    @IBOutlet weak var scaleSlider: UISlider!
    
    // MARK:
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.mapView.addObserver(self, forKeyPath: "myLocation", options: NSKeyValueObservingOptions.new, context: nil)
        
        
        self.locationManager.delegate = self
        self.locationManager.requestWhenInUseAuthorization()
        
        self.mapView.delegate = self
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if !self.isCurrentLocationDefined {
            let currentUserLocation = change![NSKeyValueChangeKey.newKey] as! CLLocation
            self.mapView.camera = GMSCameraPosition.camera(withTarget: currentUserLocation.coordinate, zoom: currentZoom)
            self.mapView.settings.myLocationButton = true
            self.isCurrentLocationDefined = true
            self.loadData()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ShowBusinessDetails" {
            if let dest = segue.destination as? BusinessDetailViewController {
                dest.businessToShow = self.selectedBusiness
            }
        }
    }
    
    // MARK: LOAD MAPDATA AND MAKER
    func loadData() {
        let lat = self.mapView.camera.target.latitude
        
        let lng = self.mapView.camera.target.longitude
        
        WebserviceHelper.sharedInstance.loadBusinessesForLatLong(latitude: Double(lat), longitude: Double(lng), successHandler: { array in
            
            var newBusinessesDict = Dictionary<String, Business>()
            for business in array {
                if let id = business.id {
                    newBusinessesDict[id] = business
                }
            }
            let newIds = Set(newBusinessesDict.map { $0.key })
            let oldIds = Set(self.markersDict.map { $0.key })
            
            if (oldIds.count > 100) {//May find better solution
                let toDelete = oldIds.subtracting(newIds)
                for id in toDelete {
                    self.markersDict[id]?.map = nil
                    self.markersDict[id] = nil
                }
            }
            
            let toAdd = newIds.subtracting(oldIds)
            for id in toAdd {
                self.markersDict[id] = self.setuplocationMarker(business: newBusinessesDict[id]!)
            }
            
        }, errorHandler: { errorMessage in
            self.showAlert(title: "Error", message: errorMessage)
        })
        
    }
    
    func setuplocationMarker(business: Business) -> GMSMarker? {
        
        if let coordinate = business.coordinate {
            let locationMarker = GMSMarker(position: coordinate)
            
            locationMarker.appearAnimation = .pop
            locationMarker.icon = GMSMarker.markerImage(with: UIColor.blue)
            locationMarker.opacity = 0.75
            
            let userData = ["business": business]
            locationMarker.userData = userData
            locationMarker.map = self.mapView
            return locationMarker
        }
        return nil
    }
    
    
    
//    // calculate radius
//    private func getCenterCoordinate() -> CLLocationCoordinate2D {
//        
//        let centerPoint = mapView.center
//        let centerCoordinate = mapView.projection.coordinate(for: centerPoint)
//        
//        return centerCoordinate
//    }
//    
//    private func getTopCenterCoordinate() -> CLLocationCoordinate2D {
//        
//        let p             = CGPoint(x: mapView.frame.size.width / 2, y: 0)
//        let topCenterCoor = mapView.convert(p, from: mapView)
//        let point         = mapView.projection.coordinate(for: topCenterCoor)
//        
//        return point
//    }
//    
//    func getRadius() -> Int {
//        
//        let centerCoordinate = getCenterCoordinate()
//        let centerLocation = CLLocation(latitude: centerCoordinate.latitude, longitude: centerCoordinate.longitude)
//        let topCenterCoordinate = getTopCenterCoordinate()
//        let topCenterLocation = CLLocation(latitude: topCenterCoordinate.latitude, longitude: topCenterCoordinate.longitude)
//        
//        let radius = CLLocationDistance(centerLocation.distance(from: topCenterLocation))
//        
//        return Int(round(radius))
//    }
}

extension MapViewController: GMSMapViewDelegate
{
    func mapView(_ mapView: GMSMapView, markerInfoWindow marker: GMSMarker) -> UIView? {
        let customInfoWindow = CustomMarkerInfoView(frame: CGRect(x: 0, y: 0, width: 260, height: 120))
        if let userData = marker.userData as? Dictionary<String, Any> {
            let business = userData["business"] as! Business
            customInfoWindow.business = business
            self.selectedBusiness = business
        }
        return customInfoWindow
    }
    
    func mapView(_ mapView: GMSMapView, didTapInfoWindowOf marker: GMSMarker) {
        self.performSegue(withIdentifier: "ShowBusinessDetails", sender: self)
    }
    
    func mapView(_ mapView: GMSMapView, idleAt position: GMSCameraPosition) {
        self.loadData()
    }
}

extension MapViewController: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .authorizedWhenInUse {
            self.mapView.isMyLocationEnabled = true
        }
    }
}
