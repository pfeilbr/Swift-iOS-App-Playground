//
//  AppDelegate.swift
//  SwiftiOSApp01
//
//  Created by Pfeil, Brian on 6/2/14.
//  Copyright (c) 2014 Pfeil, Brian. All rights reserved.
//

import UIKit
import AssetsLibrary
import CloudKit
import HealthKit
import CoreData
import Webkit
import CoreMotion
import SpriteKit


class SpriteKitPlay {
    
    enum CollisionType:UInt32 {
        case Ball = 1
        case Rock = 2
    }
    
    class MyScene : SKScene {
        var _lbl = SKLabelNode(text: "Hello")
        
        override func didMoveToView(view: SKView!) {
            backgroundColor = UIColor.blueColor()
            _lbl.fontName = "Futura-CondensedExtraBold"
            _lbl.fontSize = 48
            _lbl.position = CGPoint(x: CGRectGetMidX(frame), y: CGRectGetMidY(frame))
            addChild(_lbl)
        }
        
        override func touchesBegan(touches: NSSet!, withEvent event: UIEvent!) {
            var t = touches.anyObject() as UITouch
            var p = t.locationInNode(self)
            var n = nodeAtPoint(p)
            if n == _lbl {
                println("label touched")
                var startActn = SKAction.scaleBy(2.0, duration: 0.1)
                var endActn = SKAction.scaleBy(0.5, duration: 0.1)
                _lbl.fontColor = UIColor.yellowColor()
                _lbl.runAction(SKAction.sequence([startActn, endActn]), completion: {
                    self._lbl.fontColor = UIColor.whiteColor()
                    var gscn = GameScene(size: self.frame.size)
                    self.view.presentScene(gscn)
                })
                
            }
            
            var snd = SKAction.playSoundFileNamed("beep.wav", waitForCompletion: false)
            runAction(snd)
            

        }
        
    }
    
    class GameScene : SKScene, SKPhysicsContactDelegate {
        var _score = 0
        var _nodes:[SKNode] = []

        var _circle = SKShapeNode(circleOfRadius: 30)
        var _scoreLabel = SKLabelNode()
        
        override func didMoveToView(view: SKView!) {
            
            var radius = 30.0
            backgroundColor = UIColor.blackColor()
            _circle.fillColor = UIColor.orangeColor()
            _circle.strokeColor = UIColor.whiteColor()
            _circle.lineWidth = 10
            _circle.glowWidth = 5
            
            _circle.physicsBody = SKPhysicsBody(circleOfRadius: radius)
            _circle.physicsBody.dynamic = false
            _circle.physicsBody.categoryBitMask = CollisionType.Ball.toRaw()
            _circle.position = CGPoint(x: CGRectGetMidX(frame), y: CGRectGetMidY(frame))
            addChild(_circle)
            
            
//            for idx in 0..<10 {
//                var n = SKShapeNode(circleOfRadius: 20)
//                n.fillColor = UIColor.blueColor()
//                n.position = CGPoint(x: 20, y: self.size.height)
//                _nodes.append(n)
//                addChild(n)
//            }
            
            var addRock = SKAction.runBlock({ self.addRock() })
            var wait = SKAction.waitForDuration(0.25, withRange: 0.3)
            var makeRocks = SKAction.sequence([addRock, wait])
            runAction(SKAction.repeatActionForever(makeRocks))
            
            addBat()
            
            addScoreLabel()
            
            self.physicsWorld.contactDelegate = self
            
        }
        
        func didBeginContact(contact: SKPhysicsContact!) {
            println("didBeginContact called.  contact.bodyA.node.name = \(contact.bodyA.node.name)")
            runAction(SKAction.playSoundFileNamed("beep.wav", waitForCompletion: false))
            contact.bodyB.node.removeFromParent()
            _scoreLabel.text = "Score: \(_score)"
            _score++
            
        }
        
        override func touchesBegan(touches: NSSet!, withEvent event: UIEvent!)  {
            var t = touches.anyObject() as UITouch
            var actn = SKAction.moveTo(t.locationInNode(self), duration: 0.1)
            actn.timingMode = SKActionTimingMode.EaseOut
            _circle.runAction(actn)
        }
        
        override func touchesMoved(touches: NSSet!, withEvent event: UIEvent!) {
            var t = touches.anyObject() as UITouch
            _circle.position = t.locationInNode(self)
        }
        
        func addScoreLabel() {
            _scoreLabel.text = "Score: \(_score)"
            _scoreLabel.position = CGPoint(x: 250, y: self.size.height - _scoreLabel.frame.height - 15)
            _scoreLabel.fontColor = UIColor.whiteColor()
            addChild(_scoreLabel)
        }
        
        func addRock() {
            var rock = SKShapeNode(circleOfRadius: 15)
            rock.fillColor = UIColor.yellowColor()
            rock.position = CGPoint(x: CGFloat(arc4random_uniform(UInt32(self.size.width))), y: self.size.height + 50)
            rock.name = "rock"
            rock.physicsBody = SKPhysicsBody(circleOfRadius: 15)
            rock.physicsBody.usesPreciseCollisionDetection = true
            rock.physicsBody.categoryBitMask = CollisionType.Rock.toRaw()
            rock.physicsBody.collisionBitMask = CollisionType.Ball.toRaw()
            rock.physicsBody.contactTestBitMask = CollisionType.Ball.toRaw()
            self.addChild(rock)
        }
        
        func addBat() {
            var spriteSheetTexture = SKTexture(imageNamed: "bat-sprite-sheet")
            
            var txtrs:[SKTexture] = []
            for idx in 0..<4 {
                var x = (CGFloat(idx)*0.25)
                var txtr = SKTexture(rect: CGRect(x: x, y: 0, width: 0.25, height: 0.25), inTexture: spriteSheetTexture)
                txtrs.append(txtr)
            }
            var batAnimations = SKAction.animateWithTextures(txtrs, timePerFrame: 0.1)
            
            var batSprite = SKSpriteNode(texture: txtrs[0])
            batSprite.position = CGPoint(x: 300, y: 300)
            batSprite.runAction(SKAction.repeatActionForever(batAnimations))
            addChild(batSprite)
        }
        
        override func update(currentTime: NSTimeInterval) {
            var nodesToRemove:[SKNode] = []
            enumerateChildNodesWithName("rock", usingBlock: {
                node, stop in
                
                // turn physicsBody and colision logic off for _circle to have this work
                if self._circle.containsPoint(node.position) {
                    println("rock collided with cirlce")
                    self.runAction(SKAction.playSoundFileNamed("beep.wav", waitForCompletion: false))
                    nodesToRemove.append(node)
                    self._score++
                    
                }
            })
            
            self.removeChildrenInArray(nodesToRemove)
            _scoreLabel.text = "Score: \(_score)"
        }
    }
    
    
    var _rootView:UIView
    var _skView:SKView
    
    init(view:UIView) {
        _rootView = view
        _skView = SKView(frame: view.frame)
        _skView.showsFPS = true
        _rootView.addSubview(_skView)
    }
    
    func run() {
        var scn = MyScene(size: _skView.bounds.size)
        _skView.presentScene(scn)
    }
}

// only can use LocalAuthentication when target is a device.  doesn't workign sim as of xcode6 beta2
//import LocalAuthentication
// *** NOTE ***: need to add LocalAuthentication.framework back to the project via project settings

// --- Begin - Local Authentication Play Area
/*
class LocalAuthenticationPlay {
    
    func run() {
        
        var lactx = LAContext()
        lactx.evaluatePolicy(LAPolicy.DeviceOwnerAuthenticationWithBiometrics, localizedReason: "My custom local authentication reason", reply: {
            result, err in
                println(result)
            })
        
    }
}
*/
// --- End - Local Authentication Play Area

class CoreMotionPlay {
    
    var _rootView:UIView
    var _textView:UITextView
    var _pedometer = CMPedometer()
    
    
    init(view:UIView) {
        _rootView = view
        _textView = UITextView(frame: _rootView.bounds)
        _textView.editable = false
        _textView.text = ""
    }
    
    func installOutputView() {
        _rootView.addSubview(_textView)

        _pedometer.startPedometerUpdatesFromDate(NSDate(), withHandler: {
            data, err in
//            data.startDate
//            data.endDate
//            data.distance
            if let steps = data?.numberOfSteps? {
                self._textView.text = "steps: \(steps)\n" + self._textView.text
            }
        })
        
    }
    
    func run() {
        installOutputView()
    }
    
}


class VisualEffectPlay {
    
    var _rootView:UIView
    
    init(view:UIView) {
        _rootView = view
    }

    func installVisualEffectView() {
        var imageView = UIImageView(image: UIImage(named: "profile"))
        var visualEffectView = UIVisualEffectView(effect: UIBlurEffect(style: .Light)) as UIVisualEffectView
        visualEffectView.frame = imageView.bounds
        imageView.addSubview(visualEffectView)
        _rootView.addSubview(imageView)
    }

    func run() {
        installVisualEffectView()
    }
    
}

// --- Begin - Webkit Play Area

class WebkitPlay : NSObject, WKScriptMessageHandler {
    
    var _rootView:UIView
    
    init(view:UIView) {
        _rootView = view
    }
    
    func installWKWebView() {

        // create user script to run after the page loads
        var contentController = WKUserContentController()
        var userScript = WKUserScript(source: "document.body.innerHTML = 'Hello from UserScript'; webkit.messageHandlers.callbackHandler.postMessage(\"Hello from JavaScript injected via a UserScript\");", injectionTime: WKUserScriptInjectionTime.AtDocumentEnd, forMainFrameOnly: false)
        contentController.addUserScript(userScript)
        contentController.addScriptMessageHandler(self, name: "callbackHandler")
        var config = WKWebViewConfiguration()
        var prefs = WKPreferences()
        prefs.javaScriptCanOpenWindowsAutomatically = true;
        config.preferences = prefs
        config.userContentController = contentController

        var webView = WKWebView(frame: _rootView.frame, configuration: config)
        _rootView.addSubview(webView)
        webView.loadRequest(NSURLRequest(URL: NSURL(string: "http://brianpfeil.com")))
    }
    
    // the user script contains js code to force this callback to run
    func userContentController(userContentController: WKUserContentController!, didReceiveScriptMessage message: WKScriptMessage!) {
        if(message.name == "callbackHandler") {
            println("JavaScript is sending a message \(message.body)")
        }
    }
    
    func run() {
        installWKWebView()
    }
}
// --- End - Webkit Play Area

// --- Begin - HealthKit Play Area

class HealthKitPlay {
    
    func getDateOfBirth() {
        var err:NSErrorPointer = nil
        let dob = HKHealthStore().dateOfBirthWithError(err)
        println("dob = \(dob)")
        println("")
    }
    
    func run() {
        getDateOfBirth()
    }
    
}

// --- End - HealthKit Play Area

// --- Begin - Networking Play Area

class NetworkingPlay {
    
    func fetchURLContents() {
        
        var url = NSURL(string: "http://www.google.com")
        var request = NSURLRequest(URL: url)
        
        func handler(response: NSURLResponse!, data: NSData!, error: NSError!) -> Void {
            let body = NSString(data: data, encoding: NSUTF8StringEncoding)
            println(body)
            var s:String = "hello"
        }
        
        //NSURLConnection.sendAsynchronousRequest(request, queue:NSOperationQueue.mainQueue(), completionHandler: handler)
        
        //var url = NSURL(string: "http://www.google.com")
        //var request = NSURLRequest(URL: url)
        NSURLConnection.sendAsynchronousRequest(request, queue: NSOperationQueue.mainQueue(), completionHandler: {
            resp, data, err in
            let body = NSString(data: data, encoding: NSUTF8StringEncoding)
            println(body)
            })
    }
    
    func run() {
        fetchURLContents()
    }
}

// --- End - Networking Play Area

// --- Begin - CloudKit Play Area

class CloudManager {
    
    struct Shared {
        static var Instance = CloudManager()
    }
    
    var container:CKContainer { return CKContainer.defaultContainer() }
    var publicDb:CKDatabase { return container.publicCloudDatabase }
    
    func requestDiscoverabilityPermission(completion: ( (discoverable:Bool) -> Void )? ) {
        container.requestApplicationPermission(CKApplicationPermissions.PermissionUserDiscoverability, completionHandler: {
            applicationPermissionStatus, err in
            
            if err {
                println("error occured:\n\(err)")
                abort()
            } else {
                dispatch_async(dispatch_get_main_queue(), {
                    completion!(discoverable: applicationPermissionStatus == CKApplicationPermissionStatus.Granted)
                })
            }
            
        })
    }
    
    func discoverUserInfo(completion: ((user:CKDiscoveredUserInfo)->Void)? ) {
        
        container.fetchUserRecordIDWithCompletionHandler({
            recordID, err in
            if err {
                println("error occured:\n\(err)")
                abort()
            } else {
                
                self.container.discoverUserInfoWithUserRecordID(recordID, completionHandler: {
                    user, err in
                    dispatch_async(dispatch_get_main_queue(), {
                        completion!(user: user)
                    })
                })
                
            }
        })
    }
    
    func uploadAssetWithURL(recordType:String, field:String, fileURL:NSURL, completion:((record:CKRecord)->Void)? ) {
        var record = CKRecord(recordType: recordType)
        record.setObject(CKAsset(fileURL: fileURL), forKey: field)
        publicDb.saveRecord(record, completionHandler: {
            record, err in
            if err {
                println("error occured:\n\(err)")
            } else {
                completion!(record: record)
            }
        })
    }
}

class CloudKitPlay {
    var defaultContainer:CKContainer { return CKContainer.defaultContainer() }
    var privateDb:CKDatabase { return defaultContainer.privateCloudDatabase }
    var publicDb:CKDatabase { return defaultContainer.publicCloudDatabase }
    
    let itemRecordType = "Item"
    let personRecordType = "Person"
    
    func createRecordExample() {
        
        var rec = CKRecord(recordType: personRecordType)
        rec.setValue("Brian", forKey: "name")
        publicDb.saveRecord(rec, completionHandler: {
            rec, err in
            if (err) {
                println(err)
            }
            if (rec) {
                println(rec)
            }
            })
        
    }
    
    func queryExample( completionHandler:( (CKRecord[]!, NSError!)->Void)! ) {
        var q = CKQuery(recordType: "Person", predicate: NSPredicate(format: "name = %@", "Brian"))
        privateDb.performQuery(q, inZoneWithID: CKRecordZone.defaultRecordZone().zoneID, completionHandler:{
            results, err in
            for rec:CKRecord in results as CKRecord[] {
                let name = rec.valueForKey("name") as String
                println("rec.valueForKey(\"name\") = \(name)")
            }
            
            completionHandler(results as CKRecord[], err)
            });
    }
    
    func updateRecordExample() {
        
        queryExample({
            recs, err in
            var rec = recs[0]
            rec.setValue(36, forKey: "age")
            
            self.privateDb.saveRecord(rec, completionHandler: {
                rec, err in
                println(rec)
                })
            
            })
        
    }
    
    func cloudManagerRequestDiscoverabilityPermission() {
        CloudManager.Shared.Instance.requestDiscoverabilityPermission({
            discoverable in
                println("discoverable=\(discoverable.description)")
            })
    }
    
    func cloudManagerDiscoverUserInfo () {
        CloudManager.Shared.Instance.discoverUserInfo({
            user in
            println("discoverUserInfo:\n\(user)")
        })
    }
    
    func requestPermissionUserDiscoverability() {
        defaultContainer.requestApplicationPermission(CKApplicationPermissions.PermissionUserDiscoverability, completionHandler:{status, err in
            println("status = \(status)")
            })
    }
    
    func currentUserInformation() {
        CKContainer.defaultContainer().fetchUserRecordIDWithCompletionHandler({
            recordId, err in
            
            /*
            self.publicDb.fetchRecordWithID(recordId, completionHandler: {
            userRecord, err in
            println("userRecord = \(userRecord)")
            })
            */
            
            
            self.defaultContainer.discoverUserInfoWithUserRecordID(recordId, completionHandler: {
                discoverableUserInfo, err in
                println("discoverableUserInfo = \(discoverableUserInfo)")
                var fullName = (discoverableUserInfo.valueForKey("firstName") as String) + " " + (discoverableUserInfo.valueForKey("lastName") as String)
                println("fullName = \(fullName)")
                
                })
            
            })
    }
    
    func createSubscription() {
        var recordType = personRecordType
        var subscription = CKSubscription(recordType: recordType, predicate: NSPredicate(value: true), options: CKSubscriptionOptions.FiresOnRecordCreation)
        var notification = CKNotificationInfo()
        notification.alertBody = "\(recordType) record created"
        subscription.notificationInfo = notification
        publicDb.saveSubscription(subscription, completionHandler: {
            subscription, err in
            
            if err {
                println(err)
            } else {
                println(subscription)
            }
            
        })
    }
    
    func run() {
        //cloudManagerRequestDiscoverabilityPermission()
        cloudManagerDiscoverUserInfo()
        
        //createRecordExample()
        
        // NOTE: uncomment / run create before update
        //updateRecordExample()
        
        //requestPermissionUserDiscoverability()
        //currentUserInformation()
        
        //createSubscription()
    }
    
}

// --- End - CloudKit Play Area


// --- Begin - UI Play Area
class UICellFactory {
    
    struct Shared {
        static var cellConfigurations:Dictionary<String, Dictionary<String, AnyObject>> = Dictionary<String, Dictionary<String, AnyObject>>()
    }
    
    func addCellConfiguration(name:String, cfg:Dictionary<String, AnyObject>) {
        Shared.cellConfigurations[name] = cfg
    }
    
    func createCell(cfg:Dictionary<String, AnyObject>) -> UITableViewCell {
        var cell = UITableViewCell(style: UITableViewCellStyle.Default, reuseIdentifier: "")
        return cell
    }
    
}

class MyCell : UITableViewCell {
    
    init(style: UITableViewCellStyle, reuseIdentifier: String!) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.backgroundColor = UIColor.greenColor()
    }
    
    
}

// --- End - UI Play Area

class MyTVC : UITableViewController {
    var items:String[] = ["Brian", "Tricia", "Wyatt", "Max"]
    
    override func viewDidLoad() {
        var tv:UITableView = self.tableView
        //tv.registerClass(cellClass: MyCell.Type, forCellReuseIdentifier: "MyCell")
        
        var cls:AnyClass = MyCell.classForCoder()
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView!) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView!, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }
    
    override func tableView(tableView: UITableView!, cellForRowAtIndexPath indexPath: NSIndexPath!) -> UITableViewCell! {
        var cellId = "MyCell"
        var cell = UITableViewCell(style: UITableViewCellStyle.Default, reuseIdentifier: cellId)
        //var cell:UITableViewCell = tableView.dequeueReusableCellWithIdentifier(cellId) as UITableViewCell
        cell.textLabel.text = items[indexPath.row]
        return cell
    }
    
    override func tableView(tableView: UITableView!, didSelectRowAtIndexPath indexPath: NSIndexPath!) {
        var name:String = items[indexPath.row]
        var msg = "You selected " + name
        var alertCtrl = UIAlertController(title: "A Message for You", message: msg, preferredStyle: UIAlertControllerStyle.Alert)
        var dismissAction = UIAlertAction(title: "Close", style: UIAlertActionStyle.Cancel, handler: {
            action in
                alertCtrl.dismissViewControllerAnimated(true, completion: nil)
        })
        alertCtrl.addAction(dismissAction)
        self.presentViewController(alertCtrl, animated: true, completion: {

        })
    }
}

class MyStoryboardBasedVC : UIViewController {

    @IBAction func btnHandler(sender : AnyObject) {
        println("btnHandler called")
    }
}

class MyVC : UIViewController {
    var views: UIView[] = UIView[]()
    var textView: UITextView!
    
    override func viewDidLoad()  {
        self.view.backgroundColor = UIColor.blueColor()
        self.textView = UITextView(frame: CGRect(x: 0, y: 0, width: 320, height: 200))
        self.view.addSubview(self.textView)
    }
    
    override func touchesBegan(touches: NSSet!, withEvent event: UIEvent!) {
        let t:UITouch = touches.anyObject() as UITouch
        let p = t.locationInView(self.view)
        println(p)
        
        let v = UIView(frame: CGRect(origin: p, size: CGSize(width: 10, height: 10)))
        v.backgroundColor = UIColor.greenColor()
        self.views += v
        self.view.addSubview(v)
    }
}

class UIManager {
    var window:UIWindow!
    
    init(window:UIWindow) {
        self.window = window
    }
    
    func installView() {
        var v = UIView(frame: CGRect(x: 0,y: 0, width: 200,height: 200))
        v.backgroundColor = UIColor.redColor()
        window.addSubview(v)
    }
    
    func installMyVC() {
        var vc = MyVC()
        window.addSubview(vc.view)
        window.rootViewController = vc
    }
    
    func installMyTVC() {
        var tvc = MyTVC()
        window.addSubview(tvc.view)
        window.rootViewController = tvc
    }
    
    func installMyStoryboardBasedVC() {
        var sb = UIStoryboard(name: "Storyboard", bundle: nil)
        var mySbVC = sb.instantiateViewControllerWithIdentifier("MyStoryboardBasedVC") as MyStoryboardBasedVC
        window.addSubview(mySbVC.view)
        window.rootViewController = mySbVC
    }
    
}

// --- Begin - ALAssetLibrary Play Area

class AssetLibraryPlay {
    
    var window:UIWindow?
    
    init(window:UIWindow) {
        self.window = window
    }
    
    var al = ALAssetsLibrary()
    
    func enumerateAssets() {
        
        al.enumerateGroupsWithTypes(Int(ALAssetsGroupSavedPhotos), usingBlock: {
            assetsGroup, stop in
            
            if assetsGroup {
                println("assetsGroup:\n\(assetsGroup)")
                var counter:Int64 = 0
                assetsGroup.enumerateAssetsUsingBlock({
                    asset, idx, err in
                    println("asset:\n\(asset)")
                    
                    counter = counter+1
                    var delay = counter*1000000000
                    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, delay), dispatch_get_main_queue(), {
                        var cgImg = asset?.thumbnail().takeRetainedValue()
                        var img = UIImage(CGImage: cgImg)
                        var iv = UIImageView(image: img)
                        iv.frame = CGRect(x: 0, y: 0, width: 100, height: 100)
                        self.window!.addSubview(iv)
                        });
                    
                    
                    })
            }
            
            }, failureBlock: {
                err in
                println("err:\n\(err)")
            })
        
    }
    
    func run() {
        enumerateAssets()
    }
}
// --- End - ALAssetLibrary Play Area

// --- Begin - CoreData Play Area
class CoreDataManager {
    
    var modelName:String
    
    init(modelName:String) {
        self.modelName = modelName
    }
    
    convenience init() {
        self.init(modelName: "App")
    }
    
    struct Shared {
        static var Instance = CoreDataManager()
    }
    
    func saveContext () {
        var error: NSError? = nil
        let managedObjectContext = self.managedObjectContext
        if managedObjectContext != nil {
            if managedObjectContext.hasChanges && !managedObjectContext.save(&error) {
                // Replace this implementation with code to handle the error appropriately.
                // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                //println("Unresolved error \(error), \(error.userInfo)")
                abort()
            }
        }
    }
    
    // #pragma mark - Core Data stack
    
    // Returns the managed object context for the application.
    // If the context doesn't already exist, it is created and bound to the persistent store coordinator for the application.
    var managedObjectContext: NSManagedObjectContext {
    if !_managedObjectContext {
        let coordinator = self.persistentStoreCoordinator
        if coordinator != nil {
            _managedObjectContext = NSManagedObjectContext(concurrencyType: NSManagedObjectContextConcurrencyType.MainQueueConcurrencyType)
            _managedObjectContext!.persistentStoreCoordinator = coordinator
        }
        }
        return _managedObjectContext!
    }
    var _managedObjectContext: NSManagedObjectContext? = nil
    
    // Returns the managed object model for the application.
    // If the model doesn't already exist, it is created from the application's model.
    var managedObjectModel: NSManagedObjectModel {
    if !_managedObjectModel {
        let modelURL = NSBundle.mainBundle().URLForResource(modelName, withExtension: "momd")
        _managedObjectModel = NSManagedObjectModel(contentsOfURL: modelURL)
        }
        return _managedObjectModel!
    }
    var _managedObjectModel: NSManagedObjectModel? = nil
    
    // Returns the persistent store coordinator for the application.
    // If the coordinator doesn't already exist, it is created and the application's store added to it.
    var persistentStoreCoordinator: NSPersistentStoreCoordinator {
    if !_persistentStoreCoordinator {
        let storeURL = self.applicationDocumentsDirectory.URLByAppendingPathComponent("\(modelName).sqlite")
        var error: NSError? = nil
        _persistentStoreCoordinator = NSPersistentStoreCoordinator(managedObjectModel: self.managedObjectModel)
        if _persistentStoreCoordinator!.addPersistentStoreWithType(NSSQLiteStoreType, configuration: nil, URL: storeURL, options: nil, error: &error) == nil {
            /*
            Replace this implementation with code to handle the error appropriately.
            
            abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            
            Typical reasons for an error here include:
            * The persistent store is not accessible;
            * The schema for the persistent store is incompatible with current managed object model.
            Check the error message to determine what the actual problem was.
            
            
            If the persistent store is not accessible, there is typically something wrong with the file path. Often, a file URL is pointing into the application's resources directory instead of a writeable directory.
            
            If you encounter schema incompatibility errors during development, you can reduce their frequency by:
            * Simply deleting the existing store:
            NSFileManager.defaultManager().removeItemAtURL(storeURL, error: nil)
            
            * Performing automatic lightweight migration by passing the following dictionary as the options parameter:
            [NSMigratePersistentStoresAutomaticallyOption: true, NSInferMappingModelAutomaticallyOption: true}
            
            Lightweight migration will only work for a limited set of schema changes; consult "Core Data Model Versioning and Data Migration Programming Guide" for details.
            
            */
            //println("Unresolved error \(error), \(error.userInfo)")
            abort()
        }
        }
        return _persistentStoreCoordinator!
    }
    var _persistentStoreCoordinator: NSPersistentStoreCoordinator? = nil
    
    // #pragma mark - Application's Documents directory
    
    // Returns the URL to the application's Documents directory.
    var applicationDocumentsDirectory: NSURL {
    let urls = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)
        return urls[urls.endIndex-1] as NSURL
    }
    
}

class CoreDataPlay {
    // note: expecting model name to be "App" e.g. "App.momd"
    // you can explicitly specify a model name as constructor param with CoreDataManager(modelName:)
    var mgr = CoreDataManager.Shared.Instance
    
    var managedObjectModel:NSManagedObjectModel {
        return mgr.managedObjectModel
    }
    
    var managedObjectContext:NSManagedObjectContext {
        return mgr.managedObjectContext
    }
    
    func createPerson() {
        var p : NSManagedObject = NSEntityDescription.insertNewObjectForEntityForName("Person", inManagedObjectContext: mgr.managedObjectContext) as NSManagedObject
        p.setValue("Brian", forKey: "name")
        p.setValue(36, forKey: "age")
        var err:NSError?
        mgr.managedObjectContext.save(&err)
        if err {
            println("err:\n\(err)")
        }
    }
    
    func fetchPerson() {
        var entity = NSEntityDescription.entityForName("Person", inManagedObjectContext: mgr.managedObjectContext)
        var request = NSFetchRequest(entityName: "Person")
        mgr.managedObjectContext.performBlock({
            var err:NSError?
            var objs = self.mgr.managedObjectContext.executeFetchRequest(request, error: &err)
            if err {
                println("err:\n\(err)")
            } else {
                println("objs:\n\(objs)")
            }
        })
    }

    func run() {
        println("applicationDocumentsDirectory: \(mgr.applicationDocumentsDirectory)")
        createPerson()
        fetchPerson()
    }

}

// --- Begin - CoreData Play Area

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
                            
    var window: UIWindow?
    var v1: UIView?
    var myvc1: MyVC?
    var mytvc1: MyTVC!
    
    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: NSDictionary?) -> Bool {

        application.registerForRemoteNotifications()
        
        window = UIWindow(frame: UIScreen.mainScreen().bounds)
        // Override point for customization after application launch.
        self.window!.backgroundColor = UIColor.whiteColor()
        
        var uiMgr = UIManager(window: window!)
        //uiMgr.installView()
        //uiMgr.installMyVC()
        //uiMgr.installMyTVC()
        uiMgr.installMyStoryboardBasedVC()
        
        window!.makeKeyAndVisible()
        
        //NetworkingPlay().run()
        //CloudKitPlay().run()
        //HealthKitPlay().run()
        //AssetLibraryPlay(window: window!).run()
        //CoreDataPlay().run()
        //WebkitPlay(view: window!).run()
        //VisualEffectPlay(view: window!).run()
        //LocalAuthenticationPlay().run()
        //CoreMotionPlay(view: window!).run()
        SpriteKitPlay(view: window!).run()
        
        return true
    }
    
    func application(application: UIApplication!, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: NSData!) {
        println("didRegisterForRemoteNotificationsWithDeviceToken: \(deviceToken)")
    }
    
    func application(application: UIApplication!, didFailToRegisterForRemoteNotificationsWithError error: NSError!) {
        println("didFailToRegisterForRemoteNotificationsWithError:\n\(error)")
    }
    
    func application(application: UIApplication!, didReceiveRemoteNotification userInfo: NSDictionary!) {
        println("didReceiveRemoteNotification:\n\(userInfo)")
    }
    
    func application(application: UIApplication!, didReceiveLocalNotification notification: UILocalNotification!) {
        println("didReceiveLocalNotification:\n\(notification)")
    }
    
    func applicationWillResignActive(application: UIApplication) {}
    func applicationDidEnterBackground(application: UIApplication) {}
    func applicationWillEnterForeground(application: UIApplication) {}
    func applicationDidBecomeActive(application: UIApplication) {}
    func applicationWillTerminate(application: UIApplication) {}
}

