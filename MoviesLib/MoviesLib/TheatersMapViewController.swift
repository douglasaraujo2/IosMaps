//
//  TheatersMapViewController.swift
//  MoviesLib
//
//  Created by Usuário Convidado on 06/09/17.
//  Copyright © 2017 EricBrito. All rights reserved.
//

import UIKit
import MapKit

class TheatersMapViewController: UIViewController {
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var searchBar: UISearchBar!
    lazy var locationManager = CLLocationManager()
    
    var currentElement: String!
    var theater: Theater!
    var theaters: [Theater] = []
        
    override func viewDidLoad() {
        super.viewDidLoad()
        requestUserLocationAuthorization()
        mapView.delegate = self
        searchBar.delegate = self
        loadXML()
        
    }
    
    func requestUserLocationAuthorization(){
        if CLLocationManager.locationServicesEnabled(){
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            locationManager.allowsBackgroundLocationUpdates = true
            locationManager.pausesLocationUpdatesAutomatically = true
            switch CLLocationManager.authorizationStatus() {
            case .authorizedAlways, .authorizedWhenInUse:
                print("Autorizado")
            case .denied:
                print("Negado")
            case .notDetermined:
                locationManager.requestAlwaysAuthorization()
            case .restricted:
                print("Não habilitado")
            }
        }
    }
    
    func addTheares(){
        for theater in theaters{
            let coordinate = CLLocationCoordinate2D(latitude: theater.latitude, longitude: theater.longitude)
            let annotation = TheaterAnnotation(coordinate: coordinate)
            annotation.coordinate = coordinate
            annotation.title = theater.name
            annotation.subtitle = theater.url
            mapView.addAnnotation(annotation)
        }
        mapView.showAnnotations(mapView.annotations, animated: true)
    }

    func loadXML(){
        if let xmlURL = Bundle.main.url(forResource: "theaters", withExtension: "xml"), let xmlParser = XMLParser(contentsOf: xmlURL){
            xmlParser.delegate = self
            xmlParser.parse()
        }
        
    }
    
}

extension TheatersMapViewController: XMLParserDelegate{
    func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String] = [:]) {
        currentElement = elementName
        if elementName == "Theater"{
            theater = Theater()
        }
        
    }
    
    func parser(_ parser: XMLParser, foundCharacters string: String) {
        let content = string.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        if !content.isEmpty{
            switch currentElement {
            case "name":
                theater.name = content
                break
            case "address":
                theater.address = content
                break
            case "latitude":
                theater.latitude = Double(content)!
            case "longitude":
                theater.longitude = Double(content)!
            case "url":
                theater.url = content
            default:
                break
            }
        }
    }
    
    func parser(_ parser: XMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
        if elementName == "Theater" {theaters.append(theater)}
    }
    
    func parserDidEndDocument(_ parser: XMLParser) {
        addTheares()
    }
    
}


extension TheatersMapViewController: MKMapViewDelegate{
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        var annovationView: MKAnnotationView!
        
        if annotation is TheaterAnnotation{
            annovationView = mapView.dequeueReusableAnnotationView(withIdentifier: "Theater")
            
            if annovationView == nil{
                annovationView = MKAnnotationView(annotation: annotation, reuseIdentifier: "Theater")
                annovationView.canShowCallout = true
                annovationView.image = UIImage(named: "theaterIcon")
            }else{
                annovationView.annotation = annotation
            }
            return annovationView
            
        }
        
        return annovationView
    }
}

extension TheatersMapViewController: CLLocationManagerDelegate{
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        switch status {
        case .authorizedAlways, .authorizedWhenInUse:
            mapView.showsUserLocation = true
        default:
            break
        }
    }
    
    func mapView(_ mapView: MKMapView, didUpdate userLocation: MKUserLocation) {
        print("Velocidade do usuário: ",userLocation.location!.speed)
        let region = MKCoordinateRegionMakeWithDistance(userLocation.coordinate, 100, 100)
        mapView.setRegion(region, animated: true)
        
    }
}
extension TheatersMapViewController: UISearchBarDelegate{
    
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        
    }
    
    
}
