//
//  ViewController.swift
//  kmlTestDemo
//
//  Created by Peggy Tsai on 2019/4/10.
//  Copyright © 2019 Peggy Tsai. All rights reserved.
//

import UIKit
import MapKit

struct KMLData: Codable {
    var kml: String
}

class ViewController: UIViewController {
    
    @IBOutlet weak var mapView: MKMapView!
    
    let kmlURL = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.delegate = self
        showKML()
    }
    
    func showKML(){
        //getKMLData from json
        kGetKML { (error, kmlDataGet) in
            if error == nil {
                let kmlData = Data(kmlDataGet.kml.utf8)
                
                KMLDocument.parse(data: kmlData) { [unowned self] (kml) in
                    // Add overlays
                    self.mapView.addOverlays(kml.overlays)
                    // Add annotations
                    self.mapView.showAnnotations(kml.annotations, animated: true)
                }
            }else{
                print("error",error ?? "")
            }
        }
    }

    func kGetKML(handler: @escaping (_ error:Error?,_ result:KMLData) ->Void){
        //get KML resource
        if let url = URL(string: kmlURL){
            var kmlDataGet: KMLData?
            let task = URLSession.shared.dataTask(with: url) { (data, response , error) in
                let decoder = JSONDecoder()
                decoder.dateDecodingStrategy = .iso8601
                if let data = data, let kmlData = try?
                    decoder.decode(KMLData.self, from: data)
                {
                    kmlDataGet = KMLData(kml: kmlData.kml)
                }
                DispatchQueue.main.async {
                    guard let kmlDataGet = kmlDataGet else{
                        return
                    }
                    handler(error,kmlDataGet)
                }
            }
            task.resume()
        }
    }
}
extension ViewController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        if let overlayPolyline = overlay as? KMLOverlayPolyline {
            // return MKPolylineRenderer
            return overlayPolyline.renderer()
        }
        if let overlayPolygon = overlay as? KMLOverlayPolygon {
            // return MKPolygonRenderer
            return overlayPolygon.renderer()
        }
        return MKOverlayRenderer(overlay: overlay)
    }
}
