//
//  SourcesCollectionViewController.swift
//  News App
//
//  Created by Saksham Bhalla on 10/11/17.
//  Copyright © 2017 Pranav Gupta. All rights reserved.
//

import UIKit
import Firebase

// Global Variables
let biaser = BiasingMetaData()
var savethis = -1;
var saveInterventionmonth = -1;
var saveExpiremonth = -1;
var saveExpiredate = -1;

class SourcesCollectionViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    // Variables
    var sourceEntryNum: Int = 0
    var ref: DatabaseReference!// Firebase reference
    var sourcePos: Int = -1                 // Position of source clicked (0-11)
    var sourceTimestamp: String = ""        // Source Timestamp
    var sourceTimespent: Int = 0        // Source Timespent
    var sourceOnlytimerOn: Bool = false
    var numEntries: Int = 0
    var timeSpentonMessage1: Int = 0
    var timeSpentonMessage2: Int = 0
    var timeSpentonMessage3: Int = 0
    var newDay: Bool = false
    var numDays: Int = 0
    weak var timer: Timer?
    var startTime: Double = 0.0
    var time: Double = 0.0
    
    // Outlets
    @IBOutlet weak var collectionView: UICollectionView!
    
    
    // Default functions
    override func viewDidLoad() {

        ref = Database.database().reference()
        biaser.versionType = UserDefaults.standard.integer(forKey: "VersionNum")
        biaser.uniqueID = UserDefaults.standard.string(forKey: "UserID")!
        print(biaser.uniqueID)
        // Initalizing database columns' initial values
        UserDefaults.standard.set(0, forKey: "NumArticleClicked")
      self.ref?.child(biaser.uniqueID).child("Intervention").child("Month").observeSingleEvent(of: .value, with: {(DataSnapshot) in
        
        let originMonth = DataSnapshot.value as? Int
        if(originMonth != nil){
          
          saveInterventionmonth = originMonth!
          
        }
      })
      self.ref?.child(biaser.uniqueID).child("Expire").child("Month").observeSingleEvent(of: .value, with: {(DataSnapshot) in
        
        let originMonth = DataSnapshot.value as? Int
        if(originMonth != nil){
          
          saveExpiremonth = originMonth!
          
        }
      })
      self.ref?.child(biaser.uniqueID).child("Expire").child("Day").observeSingleEvent(of: .value, with: {(DataSnapshot) in
        
        let originMonth = DataSnapshot.value as? Int
        if(originMonth != nil){
          
          saveExpiredate = originMonth!
          
        }
      })
      
      self.ref?.child(biaser.uniqueID).child("Expire").child("Day").observeSingleEvent(of: .value, with: {(DataSnapshot) in
        // Get user value
        let value = DataSnapshot.value as? Int
        //print("Value: \(DataSnapshot.value)")
        
        //Check if intervention date exists
        if(value != nil){
          if (value != 0){
            let date = Date()
            let calendar = Calendar.current
            let day = calendar.component(.day, from: date)
            let month = calendar.component(.month, from: date)
            
            
            if(month == saveExpiremonth){
              if (value! <= day){
                
                let vc = self.storyboard?.instantiateViewController(withIdentifier: "over")
                self.ref?.child(biaser.uniqueID).child("Expire").child("Day").setValue(-1)
                self.navigationController?.present(vc!, animated: true, completion: nil)
              }
              else{
                if(value == -1){
                  
                  let vc = self.storyboard?.instantiateViewController(withIdentifier: "over")
                 
                  self.navigationController?.present(vc!, animated: true, completion: nil)
                }
              }
            }
          }
          else{
            print("Intervention has already happened")
          }
        }
        else{
          let dates = Date()
          let calendar = Calendar.current
          var tday = calendar.component(.day, from: dates) + 20
          var tmonth = calendar.component(.month, from: dates)
          
          
          
          //Check if even or odd month
          let cMonth = tmonth % 2
          print("Checker: \(cMonth)")
          if(cMonth == 0){
            if(tmonth == 2){
              if(tday > 28){
                tday = tday - 28
                tmonth += 1
              }
            }
            else{
            
              if(tday > 30){
                tday = tday - 30
                tmonth += 1
                print("Even")
              }
            }
          }
          else{
         
            if(tday > 31){
              tday = tday - 31
              tmonth += 1
              print("Odd")
            }
          }
          
          self.ref?.child(biaser.uniqueID).child("Expire").child("Day").setValue(tday)
          self.ref?.child(biaser.uniqueID).child("Expire").child("Month").setValue(tmonth)

          print("date: \(dates)")
        }
      }) { (error) in
        print(error.localizedDescription)
      }
        
        var dateToday = UserDefaults.standard.string(forKey: "currentDate")
        let currentDate = getCurrentDate()
        print (currentDate)
        if (dateToday == nil) {
            dateToday = getCurrentDate()
            UserDefaults.standard.set(dateToday, forKey: "currentDate")
            newDay = true
        }
        
        else if (dateToday != currentDate) {
            newDay = true
            UserDefaults.standard.set(dateToday, forKey: "currentDate")
        }
        
        else {
            newDay = false
        }
        
        if (biaser.versionType == 1) { // Biasing without message
            if (newDay){
                biaser.implementBiasing()
                UserDefaults.standard.set(biaser.activeSources, forKey: "ActiveSources")
            }
            else{
                biaser.activeSources = UserDefaults.standard.array(forKey: "ActiveSources") as! [String]
            }
        }
        
        else if (biaser.versionType == 2) { // No bias
            if (newDay){
                biaser.noBiasing()
                UserDefaults.standard.set(biaser.activeSources, forKey: "ActiveSources")
            }
            else {
                biaser.activeSources = UserDefaults.standard.array(forKey: "ActiveSources") as! [String]
            }
            
        }
        
        else if (biaser.versionType == 3) { // Bias with message
          
          self.ref?.child(biaser.uniqueID).child("Intervention").child("Day").observeSingleEvent(of: .value, with: {(DataSnapshot) in
            // Get user value
            let value = DataSnapshot.value as? Int
            //print("Value: \(DataSnapshot.value)")
            
            //Check if intervention date exists
            if(value != nil){
              if (value != 0){
                let date = Date()
                let calendar = Calendar.current
                let day = calendar.component(.day, from: date)
                let month = calendar.component(.month, from: date)
                print("Expire Date: \(saveExpiredate)")
                print("Today: \(day)")
                print("Intervention date: \(value!)")
                
                if(month == saveInterventionmonth)
                {
                  if(day <= saveExpiredate)
                  {
                    if (value! <= day)
                    {
                      self.ref?.child(biaser.uniqueID).child("Intervention").child("Day").setValue(0)
                      self.startTime = Date().timeIntervalSinceReferenceDate
                      
                      self.timer = Timer.scheduledTimer(timeInterval: 0.01, target: self, selector: #selector(self.updateCounterforMessage1), userInfo: nil, repeats: true)
                      self.showMessage1(title: "About this App!", message: "Most news aggregator algorithms, like the kind used in this app, track your behavior. They then use this information to guide you toward news articles that reflect your own ideological preferences. \n Why is this a problem?")
                      print("It is the intervention date")
                    }
                    else
                    {
                      print("Not the intervention date")
                    }
                  }
                  else{
                      print("Past Expire date")
                    }
                }
                else{
                  print("Not the right month")
                }
              }
              else{
                print("Intervention has already happened")
              }
            }
              
              //create date if intervention date does not exist
            else{
              let dates = Date()
              let calendar = Calendar.current
              var day = calendar.component(.day, from: dates) + 10
              var month = calendar.component(.month, from: dates)
             
              
              
              
              //Check if even or odd month
              let cMonth = month % 2
              print("Checker: \(cMonth)")
              if(cMonth == 0){
                if(month == 2){
                  if(day > 28){
                    day = day - 28
                    month += 1
                  }
                  
                }
                else{
                  if(day > 30){
                    day = day - 30
                    month += 1
                    print("Even")
                  }
                  
                }
              }
              else{
                if(day > 31){
                  day = day - 31
                  month += 1
                  print("Odd")
                }
               
              }
              
            
              self.ref?.child(biaser.uniqueID).child("Intervention").child("Day").setValue(day)
              self.ref?.child(biaser.uniqueID).child("Intervention").child("Month").setValue(month)
              let started = self.getDate()
              self.ref?.child(biaser.uniqueID).child("Intervention").child("Started").setValue(started)
              print("Day: \(day)")
              print("Month: \(month)")
              print("date: \(dates)")
            }
            
            
          }) { (error) in
            print(error.localizedDescription)
          }
          
            if (newDay){
                biaser.implementBiasing()
                let daynumber = UserDefaults.standard.integer(forKey: "DayNumber")
                numDays = daynumber + 1
                UserDefaults.standard.set(numDays, forKey: "DayNumber")
                UserDefaults.standard.set(biaser.activeSources, forKey: "ActiveSources")
                if (numDays == 7) {
                    
                    startTime = Date().timeIntervalSinceReferenceDate
                    
                    timer = Timer.scheduledTimer(timeInterval: 0.01, target: self, selector: #selector(updateCounterforMessage1), userInfo: nil, repeats: true)
                    showMessage1(title: "About this App!", message: "Most news aggregator algorithms, like the kind used in this app, track your behavior. They then use this information to guide you toward news articles that reflect your own ideological preferences. \n Why is this a problem?")
                }
            }
            else{
                biaser.activeSources = UserDefaults.standard.array(forKey: "ActiveSources") as! [String]
            }
            
        }
        super.viewDidLoad()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        ref = Database.database().reference()
        biaser.versionType = UserDefaults.standard.integer(forKey: "VersionNum")
        biaser.uniqueID = UserDefaults.standard.string(forKey: "UserID")!
        print(biaser.uniqueID)
        // Initalizing database columns' initial values
        UserDefaults.standard.set(0, forKey: "NumArticleClicked")
        
        var dateToday = UserDefaults.standard.string(forKey: "currentDate")
        let currentDate = getCurrentDate()
        print (currentDate)
        if (dateToday == nil) {
            dateToday = getCurrentDate()
            UserDefaults.standard.set(dateToday, forKey: "currentDate")
            newDay = true
        }
            
        else if (dateToday != currentDate) {
            newDay = true
            UserDefaults.standard.set(dateToday, forKey: "currentDate")
        }
            
        else {
            newDay = false
        }
        
        if (biaser.versionType == 1) { // Biasing without message
            if (newDay){
                biaser.implementBiasing()
                UserDefaults.standard.set(biaser.activeSources, forKey: "ActiveSources")
            }
            else{
                biaser.activeSources = UserDefaults.standard.array(forKey: "ActiveSources") as! [String]
            }
        }
            
        else if (biaser.versionType == 2) { // No bias
            if (newDay){
                biaser.noBiasing()
                UserDefaults.standard.set(biaser.activeSources, forKey: "ActiveSources")
            }
            else {
                biaser.activeSources = UserDefaults.standard.array(forKey: "ActiveSources") as! [String]
            }
            
        }
            
        else if (biaser.versionType == 3) { // Bias with message
            if (newDay){
                biaser.implementBiasing()
                let daynumber = UserDefaults.standard.integer(forKey: "DayNumber")
                numDays = daynumber + 1
                UserDefaults.standard.set(numDays, forKey: "DayNumber")
                UserDefaults.standard.set(biaser.activeSources, forKey: "ActiveSources")
                if (numDays == 7) {
                    
                    startTime = Date().timeIntervalSinceReferenceDate
                    
                    timer = Timer.scheduledTimer(timeInterval: 0.01, target: self, selector: #selector(updateCounterforMessage1), userInfo: nil, repeats: true)
                    showMessage1(title: "About this App!", message: "This app tracks your behavior. It uses this information to guide you toward news articles that reflect your own ideological preferences – liberal or conservative.")
                }
            }
            else{
                biaser.activeSources = UserDefaults.standard.array(forKey: "ActiveSources") as! [String]
            }
            
        }
        
        self.numEntries = 0
        self.ref?.child(biaser.uniqueID).child(String(self.sourceEntryNum)).observeSingleEvent(of: .value, with: { (snapshot) in
            self.numEntries += Int(snapshot.childrenCount)
            if (self.sourceOnlytimerOn && self.numEntries < 7) {
            self.timer?.invalidate()
            self.sourceOnlytimerOn = false
            self.ref?.child(biaser.uniqueID).child(String(self.sourceEntryNum)).child("Source Timespent").setValue(self.sourceTimespent)
            }

        })
    }

    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return biaser.activeSources.count
    }
    
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "SourcesCell", for: indexPath) as! SourcesCell
        cell.myImage.image = UIImage(named: biaser.activeSources[indexPath.row])
        cell.myImage.contentMode = .scaleAspectFit
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        
        self.sourceEntryNum = 0
        self.ref?.child(biaser.uniqueID).observeSingleEvent(of: .value, with: { (snapshot) in
        
            self.sourceEntryNum += Int(snapshot.childrenCount)
            print (self.sourceEntryNum)
            
            self.sourcePos = indexPath.row
            self.sourceTimestamp = self.getCurrentDate()
            
            // Change BiasingScore only for Version1
            if (UserDefaults.standard.integer(forKey: "VersionNum") == 1) {
                
                if (biaser.categorizer[biaser.activeSources[indexPath.row]] == "L") {
                    biaser.lSourceClicked()
                    UserDefaults.standard.set(biaser.biasingScore, forKey: "BiasingScore")
                } else {
                    biaser.cSourceClicked()
                    UserDefaults.standard.set(biaser.biasingScore, forKey: "BiasingScore")
                }
            }
            
            if (UserDefaults.standard.integer(forKey: "VersionNum") == 3) {
                let daynumber = UserDefaults.standard.integer(forKey: "DayNumber")
                self.ref?.child(biaser.uniqueID).child(String(self.sourceEntryNum)).child("Num Days").setValue(daynumber)
                if (biaser.categorizer[biaser.activeSources[indexPath.row]] == "L") {
                    biaser.lSourceClicked()
                    UserDefaults.standard.set(biaser.biasingScore, forKey: "BiasingScore")
                } else {
                    biaser.cSourceClicked()
                    UserDefaults.standard.set(biaser.biasingScore, forKey: "BiasingScore")
                }
            }
            
            // Push source name, position, timestamp and timespent to database
            self.ref?.child(biaser.uniqueID).child(String(self.sourceEntryNum)).child("Source Name").setValue(biaser.activeSources[self.sourcePos])
            self.ref?.child(biaser.uniqueID).child(String(self.sourceEntryNum)).child("Source Position").setValue(self.sourcePos)
            self.ref?.child(biaser.uniqueID).child(String(self.sourceEntryNum)).child("Source Timestamp").setValue(self.sourceTimestamp)
            self.ref?.child(biaser.uniqueID).child(String(self.sourceEntryNum)).child("User Bias").setValue(biaser.biasingScore)
            
            self.startTime = Date().timeIntervalSinceReferenceDate
            self.timer = Timer.scheduledTimer(timeInterval: 0.01, target: self, selector: #selector(self.updateCounterSourcetimespent), userInfo: nil, repeats: true)
            self.sourceOnlytimerOn = true
            
            self.performSegue(withIdentifier: "toArticleTableViewController", sender: nil)
            
        }) { (error) in
            print (error.localizedDescription)
        }
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if (segue.identifier == "toArticleTableViewController") {
            let articleDisplayViewController = segue.destination as! ArticleTableViewController
            
            // Pass variables through segue
            articleDisplayViewController.ref = ref                                      // Firebase reference
            articleDisplayViewController.sourceName = biaser.activeSources[sourcePos]   // Source Name
            articleDisplayViewController.sourcePos = sourcePos                          // Source Position
            articleDisplayViewController.sourceTimestamp = sourceTimestamp              // Source Timestamp
            articleDisplayViewController.sourceEntryNum = sourceEntryNum
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @objc func updateCounterSourcetimespent() {
        time = Date().timeIntervalSinceReferenceDate - startTime
        time = time*1000
        sourceTimespent = Int(time)
        self.sourceOnlytimerOn = true
    }
    
    // Custom functions
    // CHECK: Below function is incorrect.
    func getCurrentDate() -> String {
        let date = NSDate()
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss ZZZ"
        formatter.timeZone = NSTimeZone(abbreviation: "PST")! as TimeZone
        return String(formatter.string(from: date as Date).prefix(10))
    }
    
    func getDate() -> String {
        let date = NSDate()
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss ZZZ"
        formatter.timeZone = NSTimeZone(abbreviation: "PST")! as TimeZone
        return formatter.string(from: date as Date)
    }
    
    // I really don't think you need to worry much about this function. It basically calculates the min, sec, and ms.
    // You'll have to read up on Timer.scheduledTimer(...) documentation to understand it thoroughly.
    // But what I understood is that you need to provide a custom function as argument which gets called every timeInterval (which is 0.01 in this case. Check the line of code where I call timer.scheduleTimer)
    // So every 0.01 seconds the minutes, seconds and milliseconds are calculated and stored in sourceTimespent variable.
    // Also, I'm setting the timerOn variable to true!! (Important because this variable is used in other screens too)
    
    @objc func updateCounterforMessage1() {
        time = Date().timeIntervalSinceReferenceDate - startTime
        time = time*1000
        timeSpentonMessage1 = Int(time)
    }
    @objc func updateCounterforMessage2() {
        time = Date().timeIntervalSinceReferenceDate - startTime
        time = time*1000
        timeSpentonMessage2 = Int(time)
    }
    
    @objc func updateCounterforMessage3() {
        time = Date().timeIntervalSinceReferenceDate - startTime
        time = time*1000
        timeSpentonMessage3 = Int(time)
    }
    
    func createAlert (title:String, message:String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.alert)
        
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: { (action) in alert.dismiss(animated: true, completion: nil)}))
        
        self.present(alert, animated: true, completion: nil)
    }
    
    func showMessage1(title:String, message:String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.alert)
        
        alert.addAction(UIAlertAction(title: "Next", style: UIAlertActionStyle.default, handler: { (action) in alert.dismiss(animated: true, completion: nil)
            self.timer?.invalidate()
            self.ref?.child(biaser.uniqueID).child("Intervention").child("TimeSpent on Message 1").setValue(self.timeSpentonMessage1)
            
            self.startTime = Date().timeIntervalSinceReferenceDate
            
            self.timer = Timer.scheduledTimer(timeInterval: 0.01, target: self, selector: #selector(self.updateCounterforMessage2), userInfo: nil, repeats: true)
            
            self.showMessage2(title: "Why is this a problem?", message: "These customized offers prevent you from being exposed to ideas and viewpoints which you might disagree with. This lack of diversity may force you to become narrow minded and puts you at the risk of eventually becoming a victim to your own biases.")
        }))
        
        self.present(alert, animated: true, completion: nil)
    }
    
    func showMessage2(title:String, message:String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.alert)
        
        alert.addAction(UIAlertAction(title: "Back", style: UIAlertActionStyle.default, handler: { (action) in alert.dismiss(animated: true, completion: nil)
            
            self.timer?.invalidate()
            self.ref?.child(biaser.uniqueID).child("Intervention").child("TimeSpent on Message 2").setValue(self.timeSpentonMessage2)
            
            self.startTime = Date().timeIntervalSinceReferenceDate
            
            self.timer = Timer.scheduledTimer(timeInterval: 0.01, target: self, selector: #selector(self.updateCounterforMessage1), userInfo: nil, repeats: true)
            
            self.showMessage1(title: "About this App!", message: "Most news aggregator algorithms, like the kind used in this app, track your behavior. They then use this information to guide you toward news articles that reflect your own ideological preferences. Why is this a problem?")
        }))
        
        alert.addAction(UIAlertAction(title: "Next", style: UIAlertActionStyle.default, handler: { (action) in alert.dismiss(animated: true, completion: nil)
            self.timer?.invalidate()
            self.ref?.child(biaser.uniqueID).child("Intervention").child("TimeSpent on Message 2").setValue(self.timeSpentonMessage2)
            
            self.startTime = Date().timeIntervalSinceReferenceDate
            
            self.timer = Timer.scheduledTimer(timeInterval: 0.01, target: self, selector: #selector(self.updateCounterforMessage3), userInfo: nil, repeats: true)
            self.showMessage3(title: "What can you do?", message: "In this App you have a choice. \n Press “Reset” to break the bias and receive equal number of liberal and conservative sources. \n Or \n Press “Continue” to continue with the suggestions that fit your views.")
        }))
        

        
        self.present(alert, animated: true, completion: nil)
    }
    
    func showMessage3(title:String, message:String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.alert)
        
        alert.addAction(UIAlertAction(title: "Back", style: UIAlertActionStyle.default, handler: { (action) in alert.dismiss(animated: true, completion: nil)
            self.timer?.invalidate()
            self.ref?.child(biaser.uniqueID).child("Intervention").child("TimeSpent on Message 3").setValue(self.timeSpentonMessage3)
            
            self.startTime = Date().timeIntervalSinceReferenceDate
            
            self.timer = Timer.scheduledTimer(timeInterval: 0.01, target: self, selector: #selector(self.updateCounterforMessage2), userInfo: nil, repeats: true)
            self.showMessage2(title: "Why is this a problem?", message: "These customized offers prevent you from being exposed to ideas and viewpoints which you might disagree with. This lack of diversity may force you to become narrow minded and puts you at the risk of eventually becoming a victim to your own biases.")
        }))
        
        alert.addAction(UIAlertAction(title: "Continue", style: UIAlertActionStyle.default, handler: { (action) in alert.dismiss(animated: true, completion: nil)
            print("Continue")
            self.ref?.child(biaser.uniqueID).child("Intervention").child("Choice").setValue("Continue")
            let date = self.getDate()
            self.ref?.child(biaser.uniqueID).child("Intervention").child("Date").setValue(date)
            self.timer?.invalidate()
            self.ref?.child(biaser.uniqueID).child("Intervention").child("TimeSpent on Message 3").setValue(self.timeSpentonMessage3)
        }))
        
        alert.addAction(UIAlertAction(title: "Reset", style: UIAlertActionStyle.default, handler: { (action) in alert.dismiss(animated: true, completion: nil)
            self.ref?.child(biaser.uniqueID).child("Intervention").child("Choice").setValue("Reset")
            let date = self.getDate()
            self.ref?.child(biaser.uniqueID).child("Intervention").child("Date").setValue(date)
            self.timer?.invalidate()
            self.ref?.child(biaser.uniqueID).child("Intervention").child("TimeSpent on Message 3").setValue(self.timeSpentonMessage3)
            biaser.versionType = 2
            biaser.biasingScore = 50
            UserDefaults.standard.set(biaser.biasingScore, forKey: "BiasingScore")
             self.showResetMessage(title: "Reset Successful!", message: "You will receive equal amount of liberal and conservative sources once you close the app!")
            UserDefaults.standard.set(biaser.versionType, forKey: "VersionNum")
        }))
        
        self.present(alert, animated: true, completion: nil)
    }
    
    func showResetMessage(title:String, message:String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.alert)
        
        alert.addAction(UIAlertAction(title: "Done", style: UIAlertActionStyle.default, handler: { (action) in alert.dismiss(animated: true, completion: nil)
            biaser.noBiasing()
        }))
        
        self.present(alert, animated: true, completion: nil)
    }

}
