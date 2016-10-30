//
//  MapViewController.swift
//  WorldTrotter
//
//  Created by Andy Wong on 10/23/16.
//  Copyright © 2016 Big Nerd Ranch. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

class MapViewController: UIViewController {
    private let kDistanceMeters: CLLocationDistance = 500
    private let annotationCoordinates = { () -> [CLLocationCoordinate2D] in 
        let coordinates = [(42.3601, -71.0589), (40.7128, -74.0059), (37.7749, -122.4194)]
        let coordinateDegrees = coordinates.map { (CLLocationDegrees($0.0), CLLocationDegrees($0.1)) }

        return coordinateDegrees.map { CLLocationCoordinate2D(latitude: $0.0, longitude: $0.1) }
    }()

    private var currentAnnotationIndex = 0

    var mapView: MKMapView!

    var locationManager = CLLocationManager()

    // MARK: - View Life Cycle

    override func loadView() {
        mapView = MKMapView()
        view = mapView

        // Adding segmented control subview.

        let standardString = NSLocalizedString("Standard", comment: "Standard map view")
        let satelliteString = NSLocalizedString("Satellite", comment: "Satellite map view")
        let hybridString = NSLocalizedString("Hybrid", comment: "Hybrid map view")

        let segmentedControl = UISegmentedControl(items: [standardString, satelliteString, hybridString])
        segmentedControl.backgroundColor = UIColor.white.withAlphaComponent(0.5)
        segmentedControl.selectedSegmentIndex = 0

        segmentedControl.addTarget(self, action: #selector(mapTypeChanged(_:)), for: .valueChanged)

        segmentedControl.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(segmentedControl)

        let margins = view.layoutMarginsGuide

        segmentedControl.topAnchor.constraint(equalTo: topLayoutGuide.bottomAnchor, constant: 8).isActive = true
        segmentedControl.leadingAnchor.constraint(equalTo: margins.leadingAnchor).isActive = true
        segmentedControl.trailingAnchor.constraint(equalTo: margins.trailingAnchor).isActive = true

        // Adding user location zoom button.

        let userZoomButton = UIButton()
        userZoomButton.backgroundColor = .white
        userZoomButton.setTitle("🏠", for: .normal)
        
        userZoomButton.addTarget(self, action: #selector(zoomOnUserLocation(_:)), for: .touchUpInside)

        userZoomButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(userZoomButton)

        userZoomButton.bottomAnchor.constraint(equalTo: bottomLayoutGuide.topAnchor, constant: -8).isActive = true
        userZoomButton.trailingAnchor.constraint(equalTo: margins.trailingAnchor).isActive = true

        // Adding pin cycling button.

        let pinCyclingButton = UIButton()
        pinCyclingButton.backgroundColor = .white
        pinCyclingButton.setTitle("📍", for: .normal)

        pinCyclingButton.addTarget(self, action: #selector(cycleThroughPinViews(_:)), for: .touchUpInside)

        pinCyclingButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(pinCyclingButton)

        pinCyclingButton.bottomAnchor.constraint(equalTo: userZoomButton.topAnchor, constant: -8).isActive = true
        pinCyclingButton.trailingAnchor.constraint(equalTo: margins.trailingAnchor).isActive = true
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        mapView.delegate = self
        locationManager.delegate = self

        if CLLocationManager.authorizationStatus() == .notDetermined {
            locationManager.requestWhenInUseAuthorization()
        } else if CLLocationManager.authorizationStatus() != .denied {
            mapView.showsUserLocation = true
        }

        for coordinate in annotationCoordinates {
            let annotation = PinAnnotation(coordinate: coordinate)
            mapView.addAnnotation(annotation)
        }
    }

    // MARK: - Event Handlers

    func mapTypeChanged(_ segControl: UISegmentedControl) {
        switch segControl.selectedSegmentIndex {
        case 0:
            mapView.mapType = .standard
        case 1:
            mapView.mapType = .hybrid
        case 2:
            mapView.mapType = .satellite
        default:
            break
        }
    }

    func zoomOnUserLocation(_ button: UIButton) {
        let userAnnotationView = mapView.view(for: mapView.userLocation)
        userAnnotationView?.isHidden = false

        let center = mapView.userLocation.coordinate
        let zoomRegion = MKCoordinateRegionMakeWithDistance(center, kDistanceMeters, kDistanceMeters)
        mapView.setRegion(zoomRegion, animated: true)
    }

    func cycleThroughPinViews(_ button: UIButton) {
        let annotationList = mapView.annotations.filter { $0 is PinAnnotation }

        for annotation in annotationList {
            let annotationView = mapView.view(for: annotation)
            annotationView?.isHidden = true
        }

        let currentAnnotation = annotationList[currentAnnotationIndex]
        let annotationView = mapView.view(for: currentAnnotation)
        annotationView?.isHidden = false

        currentAnnotationIndex += 1
        if currentAnnotationIndex == annotationList.count {
            currentAnnotationIndex = 0
        }
    }
}

// MARK: - MKMapView Delegate

extension MapViewController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        let identifier = "Landmark"

        if annotation is PinAnnotation {
            if let annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier) {
                return annotationView
            } else {
                let annotationView = MKPinAnnotationView(annotation: annotation as! PinAnnotation, reuseIdentifier: identifier)
                annotationView.isHidden = true
                return annotationView
            }
        }
        return nil
    }

    func mapView(_ mapView: MKMapView, didAdd views: [MKAnnotationView]) {
        for view in views {
            if view.annotation is MKUserLocation {
                view.isHidden = true
            }
        }
    }
}

// MARK: - CLLocationManager Delegate

extension MapViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        status != .notDetermined ? mapView.showsUserLocation = true : print("Authorization for location services denied.")
    }
}
