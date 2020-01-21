//
//  HomeViewController.swift
//  FinaliOSProject
//
//  Created by Jaspreet Singh on 2020-01-20.
//  Copyright © 2020 Jaspreet Singh. All rights reserved.
//

import UIKit
import CoreData
import MapKit

class HomeViewController: UIViewController,UISearchBarDelegate {
    
    // Variables
    static var managedContext: NSManagedObjectContext!
    
    var userDataArray = [UserData]()
    var filterArray = [UserData]()
    var selectedPinView: MKAnnotation!
    let locationManager = CLLocationManager()
    
    var searchfound = false
    
    //Outlets
    @IBOutlet weak var tableview: UITableView!
    
    @IBOutlet weak var listView: UIView!
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var searchBar: UISearchBar!
    
    @IBOutlet weak var segment: UISegmentedControl!
    
    @IBAction func addDetailBtnTapped(_ sender: UIBarButtonItem) {
        if let viewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "AddDetailViewController") as? AddDetailViewController {
            
            
            if let navigator = navigationController {
                navigator.pushViewController(viewController, animated: true)
            }
        }
        
    }
    
    @IBAction func typeSegment(_ sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex {
        case 0:
            // Show Map
            listView.isHidden = true
            mapView.isHidden = false
            break
            
        case 1:
            // Show List
            listView.isHidden = false
            mapView.isHidden = true
            tableview.reloadData()
            break
            
        default:
            // Show Map
            listView.isHidden = true
            mapView.isHidden = false
            break
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        searchBar.delegate = self
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        initView()
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        filterArray = searchText.isEmpty ? userDataArray : userDataArray.filter({ (userDetailString: UserData) -> Bool in
            
            return userDetailString.name?.range(of: searchText, options:  .caseInsensitive) != nil
        })
        
        if(filterArray.count <= 0){
            searchfound = false
        }else{
            searchfound = true
        }
        
        tableview.reloadData()
    }
    
    func initView(){
        
        tableview.delegate = self
        tableview.dataSource = self
        
        if(segment.selectedSegmentIndex==0){
            
            // Show Map
            listView.isHidden = true
            mapView.isHidden = false
            
        }else {
            // Show List
            listView.isHidden = false
            mapView.isHidden = true
        }
        
        let nib = UINib.init(nibName: "ListDetailCell", bundle: nil)
        self.tableview.register(nib, forCellReuseIdentifier: "ListDetailCell")
        
        let nibb = UINib.init(nibName: "ListEmptyCell", bundle: nil)
        self.tableview.register(nibb, forCellReuseIdentifier: "ListEmptyCell")
        
        fetchAndUpdateTable()
    }
}

extension HomeViewController: UITableViewDataSource,UITableViewDelegate{
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if(filterArray.count <= 0){
            searchfound = false
            return 1
        }else{
            searchfound = true
        }
        
        return filterArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if(searchfound == false){
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "ListEmptyCell") as! ListEmptyCell
            
            return cell
            
        }else{
            
            let dateFormatter = DateFormatter()
            dateFormatter.dateStyle = .long
            dateFormatter.timeStyle = .none
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "ListDetailCell") as! ListDetailCell
            let userdata = filterArray[indexPath.row]
            
            cell.nameTxt?.text = userdata.name
            cell.imgView.image = userdata.photoImage
            cell.birthdayTxt.text = dateFormatter.string(from: userdata.birthday!)
            cell.countryTxt.text = userdata.country
            cell.genderTxt.text = userdata.gender
            cell.latitudeTxt.text = String(userdata.latitude)
            cell.longitudeTxt.text = String(userdata.longitude)
            
            return cell
            
        }
        
        
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        
        if editingStyle == .delete{
            //  let locationData = userDataArray[indexPath.row]
            
            deleteRecord(data: userDataArray[indexPath.row])
            
            fetchAndUpdateTable()
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // edit
        
        if let viewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "UpdateDetailViewController") as? UpdateDetailViewController {
            
            viewController.singleUserObject = userDataArray[indexPath.row]
            
            if let navigator = navigationController {
                navigator.pushViewController(viewController, animated: true)
            }
        }
    }
    
}

extension HomeViewController{
    
    func fetchAndUpdateTable(){
        userDataArray = fetchRecords()
        filterArray = userDataArray
        
        if(filterArray.count <= 0){
            searchfound = false
        }else{
            searchfound = true
        }
        
        tableview.reloadData()
        
        getpins()
    }
    
    func deleteRecord( data : UserData){
        HomeViewController.managedContext.delete(data)
        try! HomeViewController.managedContext.save()
    }
    
    // For Fetching Data in Core Data
    func fetchRecords() -> [UserData]{
        var arrPerson = [UserData]()
        let fetchRequest = NSFetchRequest<UserData>(entityName: "UserData")
        
        do{
            arrPerson  =  try HomeViewController.managedContext.fetch(fetchRequest)//
            
        }catch{
            print(error)
        }
        return arrPerson
    }
}

// Map Delegate functons

extension HomeViewController: CLLocationManagerDelegate,MKMapViewDelegate{
    
    // Map Functions To get the location for the user
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        
        if !(annotation is MKUserLocation) {
            let pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: String(annotation.hash))
            
            let rightButton = UIButton(type: .infoDark)
            rightButton.tag = annotation.hash
            rightButton.addTarget(self, action: #selector(annoBtnPressed), for: .touchDown)
            pinView.animatesDrop = true
            pinView.canShowCallout = true
            pinView.rightCalloutAccessoryView = rightButton
            
            let leftButton = UIButton(type: .close)
            leftButton.tag = annotation.hash
            leftButton.addTarget(self, action: #selector(deleteBtnPressed), for: .touchDown)
            pinView.animatesDrop = true
            pinView.canShowCallout = true
            pinView.leftCalloutAccessoryView = leftButton
            
            return pinView
        }
        else {
            return nil
        }
    }
    
    @objc func annoBtnPressed(){
        self.view.layoutIfNeeded()
        
        if let viewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "UpdateDetailViewController") as? UpdateDetailViewController {
            
            for i in 0..<self.userDataArray.count{
                
                var title = "\(userDataArray[i].name!) - \(userDataArray[i].gender!) - \(userDataArray[i].country!)"
                if(title ==  selectedPinView?.title ){
                    viewController.singleUserObject = self.userDataArray[i]
                    break
                }
            }
            
            
            if let navigator = navigationController {
                navigator.pushViewController(viewController, animated: true)
            }
        }
        
        
        
    }
    
    @objc func deleteBtnPressed(){
        self.view.layoutIfNeeded()
        
        for i in 0..<self.userDataArray.count{
            
            var title = "\(userDataArray[i].name!) - \(userDataArray[i].gender!) - \(userDataArray[i].country!)"
            if(title ==  selectedPinView?.title ){
                
                deleteRecord(data: userDataArray[i])
                break
            }
        }
        
        fetchAndUpdateTable()
        
        
    }
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        let annotation = view.annotation
        selectedPinView = annotation
        
    }
    
    func getpins(){
        
        var locValue:CLLocationCoordinate2D = CLLocationCoordinate2D()
        
        print("latitude" + "\(locValue.latitude)")
        print("latitude" + "\(locValue.longitude)")
        
        var pinPoint = [MKPointAnnotation]()
        
        userDataArray = fetchRecords()
        mapView.removeAnnotations(mapView.annotations)
        
        for i in 0..<userDataArray.count{
            let annotation = MKPointAnnotation()
            
            locValue.latitude = userDataArray[i].latitude
            locValue.longitude = userDataArray[i].longitude
            
            annotation.coordinate = locValue
            //mapView.isZoomEnabled = false
            
            annotation.title =  "\(userDataArray[i].name!) - \(userDataArray[i].gender!) - \(userDataArray[i].country!)"
            
            self.mapView.showAnnotations(self.mapView.annotations, animated: true)
            pinPoint.append(annotation)
            
        }
        
        mapView.addAnnotations(pinPoint)
        
        let loca = CLLocationCoordinate2DMake(locValue.latitude,
                                              locValue.longitude)
        let coordinateRegion = MKCoordinateRegion(center: loca,
                                                  latitudinalMeters: 900000, longitudinalMeters: 900000)
        mapView.setRegion(coordinateRegion, animated: true)
        
    }
    
    
}
