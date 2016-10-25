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

    var mapView: MKMapView!

    var locationManager = CLLocationManager()

    // MARK: - View Life Cycle

    override func loadView() {
        mapView = MKMapView()
        view = mapView

        // Adding segmented control subview.
        let segmentedControl = UISegmentedControl(items: ["Standard", "Hybrid", "Satellite"])
        segmentedControl.backgroundColor = UIColor.white.withAlphaComponent(0.5)
        segmentedControl.selectedSegmentIndex = 0

        segmentedControl.addTarget(self, action: #selector(mapTypeChanged(_:)), for: .valueChanged)

        segmentedControl.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(segmentedControl)

        let topConstraint = segmentedControl.topAnchor.constraint(equalTo: topLayoutGuide.bottomAnchor, constant: 8)

        let margins = view.layoutMarginsGuide
        let leadingConstraint = segmentedControl.leadingAnchor.constraint(equalTo: margins.leadingAnchor)
        let trailingConstraint = segmentedControl.trailingAnchor.constraint(equalTo: margins.trailingAnchor)

        topConstraint.isActive = true
        leadingConstraint.isActive = true
        trailingConstraint.isActive = true

        // Adding button.
        let button = UIButton()
        button.backgroundColor = .white
        button.setTitle("🏠", for: .normal)
        
        button.addTarget(self, action: #selector(zoomOnUserLocation(_:)), for: .touchUpInside)

        button.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(button)

        let buttonBottomConstraint = button.bottomAnchor.constraint(equalTo: bottomLayoutGuide.topAnchor, constant: -8)
        let buttonTrailingConstraint = button.trailingAnchor.constraint(equalTo: margins.trailingAnchor)

        buttonBottomConstraint.isActive = true
        buttonTrailingConstraint.isActive = true
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
    }

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
}

// MARK: - MKMapView Delegate

extension MapViewController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, didAdd views: [MKAnnotationView]) {
        let userAnnotationView = mapView.view(for: mapView.userLocation)
        userAnnotationView?.isHidden = true
    }
}

// MARK: - CLLocationManager Delegate

extension MapViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        status != .notDetermined ? mapView.showsUserLocation = true : print("Authorization for location services denied.")
    }
}
