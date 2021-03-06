//
//  ViewController.swift
//  WWDC Scholars 2015
//
//  Created by Gelei Chen on 15/5/20.
//  Copyright (c) 2015 WWDC-Scholars. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation


class LocationViewController: UIViewController,CLLocationManagerDelegate,MKMapViewDelegate,UITableViewDataSource,UITableViewDelegate,UIViewControllerTransitioningDelegate  {
    
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    @IBAction func changeMapTypeTaped(sender: UISegmentedControl) {
        if sender.selectedSegmentIndex == 0 {
            self.mapView.mapType = MKMapType.Standard
        } else if sender.selectedSegmentIndex == 1 {
            self.mapView.mapType = MKMapType.Hybrid
        } else {
            self.mapView.mapType = MKMapType.Satellite
        }
    }
    @IBOutlet weak var bottomImageView: UIImageView!
    @IBOutlet weak var mapView: MKMapView!
    let locationManager = CLLocationManager()
    
    //init the model
    var scholarArray:[Scholar] = ((DataManager.sharedInstance.scholarArray) as NSArray) as! [Scholar]
    
    var cacheArray : [Scholar] = []
    var viewChanged = false
    var currentScholar:Scholar?
    
    let transition = BubbleTransition()
    
    var index = 0
    var qTree = QTree()
    var myLocation : CLLocationCoordinate2D?
    
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if CLLocationManager.locationServicesEnabled() {
            self.locationManager.requestWhenInUseAuthorization()
        }
        
        myLocation = mapView.userLocation.coordinate as CLLocationCoordinate2D
        
        
        let zoomRegion = MKCoordinateRegionMakeWithDistance(CLLocationCoordinate2D(latitude: 38.8833, longitude: -77.0167), 10000000, 10000000)
        self.mapView.setRegion(zoomRegion, animated: true)
        mapView.showsUserLocation = true
        mapView.delegate = self
        mapView.mapType = MKMapType.Standard
        
        //The "Find me" button
        let button = UIButton.buttonWithType(UIButtonType.Custom) as! UIButton
        button.frame = CGRectMake(UIScreen.mainScreen().bounds.width - 55,UIScreen.mainScreen().bounds.height - self.bottomImageView.frame.size.height - 25, 50, 50)
        button.setImage(UIImage(named: "MyLocation"), forState: .Normal)
        button.addTarget(self, action: "buttonAction:", forControlEvents: UIControlEvents.TouchUpInside)
        button.layer.shadowOpacity = 0.5
        button.layer.shadowOffset = CGSizeMake(0, 0)
        button.layer.shadowRadius = 2
        button.layer.cornerRadius = button.frame.width/2
        button.layer.masksToBounds = true
        button.backgroundColor = UIColor.whiteColor()
        self.view.addSubview(button)
        
        self.segmentedControl.layer.cornerRadius = 5.0
        
        
        for scholar in scholarArray {
            
            //if scholar latitude and longtitude is not nil
            
            let annotation = scholarAnnotation(coordinate: CLLocationCoordinate2DMake(scholar.latitude, scholar.longitude), title: scholar.name!,subtitle:scholar.location!,profilePictureUrl:(scholar.smallPicture)!)
                self.qTree.insertObject(annotation)
            
            //self.mapView.addAnnotation(annotation)
        }
        //self.reloadAnnotations()
        
        var leftSwipe = UISwipeGestureRecognizer(target: self, action: Selector("handleSwipes:"))
        var rightSwipe = UISwipeGestureRecognizer(target: self, action: Selector("handleSwipes:"))
        
        leftSwipe.direction = .Left
        rightSwipe.direction = .Right
        
        view.addGestureRecognizer(leftSwipe)
        view.addGestureRecognizer(rightSwipe)
        
        // Do any additional setup after loading the view.
    }
    
    func handleSwipes(sender:UISwipeGestureRecognizer) {
        if (sender.direction == .Left) {
            println("Swipe Left")
        }
        
        if (sender.direction == .Right) {
            println("Swipe Right")
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func prefersStatusBarHidden() -> Bool {
        return true
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: false)
    }
    
    
    func buttonAction(sender:UIButton!)
    {
        let myLocation = mapView.userLocation.coordinate as CLLocationCoordinate2D
        let zoomRegion = MKCoordinateRegionMakeWithDistance(myLocation,5000000,5000000)
        self.mapView.setRegion(zoomRegion, animated: true)
    }
    
    
    func mapView(mapView: MKMapView!, viewForAnnotation annotation: MKAnnotation!) -> MKAnnotationView! {
        if annotation.isKindOfClass(QCluster.classForCoder()) {
            let PinIdentifier = "PinIdentifier"
            var annotationView = mapView.dequeueReusableAnnotationViewWithIdentifier(ClusterAnnotationView.reuseId()) as? ClusterAnnotationView
            if annotationView == nil {
                annotationView = ClusterAnnotationView(cluster: annotation)
            }
            //annotationView!.canShowCallout = true
            //annotationView!.rightCalloutAccessoryView = UIButton.buttonWithType(UIButtonType.DetailDisclosure) as! UIButton
            annotationView!.cluster = annotation
            return annotationView
        } else if annotation.isKindOfClass(scholarAnnotation.classForCoder()) {
            var pinView = mapView.dequeueReusableAnnotationViewWithIdentifier("ScholarAnnotation")
            if pinView == nil {
                pinView = MKAnnotationView(annotation: annotation, reuseIdentifier: "ScholarAnnotation")
                pinView?.canShowCallout = true
                pinView?.rightCalloutAccessoryView = UIButton.buttonWithType(UIButtonType.DetailDisclosure) as! UIButton
                pinView?.rightCalloutAccessoryView.tintColor = UIColor.blackColor()
                
                let imageView = AsyncImageView(image: UIImage(named: "noProfilePicSmall"))
                let url = (DataManager.sharedInstance.getScholarByName(annotation.title!))?.smallPicture
                
                
                imageView.imageURL = NSURL(string:url!)
                //println((annotation as! scholarAnnotation).profilePictureUrl)
                //println(url)
                
                
                pinView.leftCalloutAccessoryView = imageView
                
                pinView?.image = UIImage(named: "scholarMapAnnotation")
            } else {
                pinView?.annotation = annotation
                
                let imageView = AsyncImageView(image: UIImage(named: "noProfilePicSmall"))
                let url = (DataManager.sharedInstance.getScholarByName(annotation.title!))?.smallPicture
                
                
                imageView.imageURL = NSURL(string:url!)
                //println((annotation as! scholarAnnotation).profilePictureUrl)
                //println(url)
                
                
                pinView.leftCalloutAccessoryView = imageView
                

                
            }
            return pinView
        }
        return nil
    }
    
    func mapView(mapView: MKMapView!, annotationView view: MKAnnotationView!, calloutAccessoryControlTapped control: UIControl!) {
        if view.isKindOfClass(MKAnnotationView.classForCoder()) {
            //mapView.deselectAnnotation(view.annotation, animated: true)
            let title = view.annotation.title
            currentScholar = DataManager.sharedInstance.getScholarByName(title!)
            self.performSegueWithIdentifier("transformToScholarDetail", sender: self)
        }
    }
    
    func reloadAnnotations(){
        if self.isViewLoaded() == false {
            return
        }
        self.cacheArray.removeAll(keepCapacity: false)
        //self.cacheImage?.removeAll(keepCapacity: false)
        let mapRegion = self.mapView.region
        let minNonClusteredSpan = min(mapRegion.span.latitudeDelta, mapRegion.span.longitudeDelta) / 5
        let objects = self.qTree.getObjectsInRegion(mapRegion, minNonClusteredSpan: minNonClusteredSpan) as NSArray
        //println("objects")
        for object in objects {
            if object.isKindOfClass(QCluster){
                let c = object as? QCluster
                let neihgbours = self.qTree.neighboursForLocation((c?.coordinate)!, limitCount: NSInteger((c?.objectsCount)!)) as NSArray
                for nei in neihgbours {
                    //println((nei.title)!!)
                    
                    let tmp = self.scholarArray.filter({
                        return $0.name == (nei.title)!!
                    })
                  
                    if find(self.cacheArray, tmp[0]) == nil {
                        self.cacheArray.insert(tmp[0], atIndex: self.cacheArray.count)
                        //self.cacheImage?[tmp[0].picture!] = false
                    }
                    
                    

                }
            } else {
                //println((object.title)!!)
                let tmp = self.scholarArray.filter({
                    return $0.name == (object.title)!!
                })
                
                if find(self.cacheArray, tmp[0]) == nil {
                    self.cacheArray.insert(tmp[0], atIndex: self.cacheArray.count)
                    //self.cacheImage?[tmp[0].picture!] = false
                    
                }

              
            }
        }
        //self.tableView.clearsContextBeforeDrawing = true
        //self.tableView.reloadData()
        
        let annotationsToRemove = (self.mapView.annotations as NSArray).mutableCopy() as! NSMutableArray
        annotationsToRemove.removeObject(self.mapView.userLocation)
        annotationsToRemove.removeObjectsInArray(objects as [AnyObject])
        self.mapView.removeAnnotations(annotationsToRemove as [AnyObject])
        let annotationsToAdd = objects.mutableCopy() as! NSMutableArray
        annotationsToAdd.removeObjectsInArray(self.mapView.annotations)
        
        self.mapView.addAnnotations(annotationsToAdd as [AnyObject])
        
        
    }
    func mapView(mapView: MKMapView!, regionDidChangeAnimated animated: Bool) {
        viewChanged = true
        self.reloadAnnotations()
    }
    func setColor(row:Int)->UIColor{
        if row == 0 {
            return UIColor(red: 46/255, green: 195/255, blue: 179/255, alpha: 1.0)
        } else if row == 1{
            return UIColor(red: 252/255, green: 63/255, blue: 85/255, alpha: 1.0)
        } else {
            return UIColor(red: 237/255, green: 204/255, blue: 64/255, alpha: 1.0)
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "transformToScholarDetail" {
            
            let dest = segue.destinationViewController as! DetailViewController
            dest.currentScholar = currentScholar
            dest.transitioningDelegate = self
            dest.modalPresentationStyle = .Custom
        }
        
    }
    
    // MARK: UIViewControllerTransitioningDelegate
    
    func animationControllerForPresentedController(presented: UIViewController, presentingController presenting: UIViewController, sourceController source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        transition.transitionMode = .Present
        transition.startingPoint = self.view.center
        transition.bubbleColor =  setColor(index)
        return transition
    }
    
    func animationControllerForDismissedController(dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        transition.transitionMode = .Dismiss
        transition.startingPoint = self.view.center
        transition.bubbleColor = setColor(index)
        return transition
    }

    
    
    //tableview delegate & datasource
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if viewChanged {
            return self.cacheArray.count
        } else {
            return self.scholarArray.count
        }
        
    }
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("cell", forIndexPath: indexPath) as! CustomTableViewCell
   
        let profileImageView = cell.viewWithTag(202) as! UIImageView
        profileImageView.image = UIImage(named: "no-profile")
        profileImageView.contentMode = .ScaleAspectFill
        profileImageView.layer.cornerRadius = 10
        
        if viewChanged {
            cell.name.text = cacheArray[indexPath.row].name
            cell.location.text = cacheArray[indexPath.row].location
        } else {
            cell.name.text = scholarArray[indexPath.row].name
            cell.location.text = scholarArray[indexPath.row].location
        }
        if let scholar = DataManager.sharedInstance.getScholarByName(cell.name.text!){
            profileImageView.imageURL = NSURL(string: scholar.picture!)
            /*
            let qos = Int(QOS_CLASS_USER_INITIATED.value)
            dispatch_async(dispatch_get_global_queue(qos, 0)) { () -> Void in
                var imageData : NSData?
                if self.cacheImage?[scholar.picture!] == false {
                    imageData = NSData(contentsOfURL: NSURL(string: scholar.picture!)!)
                    dispatch_async(dispatch_get_main_queue()) {
                       
                            if imageData != nil {
                                profileImageView.image = UIImage(data: imageData!)
                            } else {
                                profileImageView.image = UIImage(named: "no-picture")
                            }
                        }
                    
                    self.cacheImage?[scholar.picture!] = true
                } else {
                    if imageData != nil {
                        profileImageView.image = UIImage(data: imageData!)
                    } else {
                        profileImageView.image = UIImage(named: "no-picture")
                    }
 
                }
                
                
            }*/

        }
        return cell
        
    }
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: false)
        let cell = tableView.cellForRowAtIndexPath(indexPath) as! CustomTableViewCell
        currentScholar = DataManager.sharedInstance.getScholarByName(cell.name.text!)
        
        if indexPath.row % 3 == 0 {
            index = 0
        } else if indexPath.row % 3 == 1 {
            index = 1
        } else {
            index = 2
        }

        self.performSegueWithIdentifier("transformToScholarDetail", sender: self)
    }
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 80
    }
    /* REQUIRED, do not connect to any Outlet.
    BUG DETECTED? Exit segue doesn't dismiss automatically, so we have to dismiss it manually.
    */
    @IBAction func unwindToMainViewController (sender: UIStoryboardSegue){
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
}
