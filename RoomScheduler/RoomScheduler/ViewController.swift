//
//  ViewController.swift
//  RoomScheduler
//
//  Created by Mike Henry on 10/29/15.
//  Copyright © 2015 Mike Henry. All rights reserved.
//

import UIKit
import EventKit

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var timeBeginDatePicker  :UIDatePicker!
    @IBOutlet weak var timeDurationSlider   :UISlider!
    @IBOutlet weak var timeDurationLabel    :UILabel!
    @IBOutlet weak var scheduleButton       :UIButton!
    @IBOutlet weak var scheduleTableView    :UITableView!
    @IBOutlet weak var introTextLabel        :UILabel!
    var scheduleArray = []
    let eventStore = EKEventStore()

    
    //MARK: - Display Methods
    
    func setIntroText (sender: UILabel) {
        introTextLabel.text = "Book a Room \nchoose a date and time to get started"
    }
    
    func createAttributedString() {
        let myMuteString = NSMutableAttributedString()
        let font1 = UIFont(name: "Avenir-Light", size: 14.0)
        let attrib1 = [NSFontAttributeName: font1!]
        
        let introAttribString = NSAttributedString(string: "My name is ", attributes: attrib1)
        let font2 = UIFont(name: "AvenirNext-Bold", size: 16.0)
        
        let nameAttribString = NSAttributedString(string: "Mike!", attributes: [NSFontAttributeName : font2!, NSForegroundColorAttributeName : UIColor.redColor()])
        
        let closeAttribString = NSAttributedString(string: " and don't mess", attributes: attrib1)
        
        myMuteString.appendAttributedString(introAttribString)
        myMuteString.appendAttributedString(nameAttribString)
        myMuteString.appendAttributedString(closeAttribString)
        
//        attribLabel.attributedText = myMuteString
    }
    
    
    //MARK: - Room Scheduler Methods
    
    @IBAction func newRoomBooking(sender: UIButton) {
        print("Schedule It button pressed")
        let roomEvent = EKEvent(eventStore: eventStore)
        roomEvent.calendar = eventStore.defaultCalendarForNewEvents
        roomEvent.title = "Reserved Event"
        roomEvent.startDate = timeBeginDatePicker.date
        roomEvent.endDate = NSDate().dateByAddingTimeInterval(Double(timeDurationSlider.value))
        do {
            try eventStore.saveEvent(roomEvent, span: .ThisEvent, commit: true)
        } catch {
            print("Save Error")
        }
        timeDurationSlider.value = 1600 // reset slider value
        timeDurationLabel.text = "30" // reset label value
        retrieveRoomBookings()
        scheduleTableView.reloadData()
        
        
        
        // added predicate from Retrieve method below. Doesn't work
//        let calendars = eventStore.calendarsForEntityType(.Event)
//        let predicate = eventStore.predicateForEventsWithStartDate(roomEvent.startDate, endDate: roomEvent.endDate, calendars: calendars)
//        print("Predicate:\(predicate)")
//        let events = eventStore.eventsMatchingPredicate(predicate)
//        if events.count == 0 {
//            do {
//                try eventStore.saveEvent(roomEvent, span: .ThisEvent, commit: true)
//            } catch {
//                print("Save Error")
//            }
//            timeDurationSlider.value = 1600 // reset slider value
//            timeDurationLabel.text = "30" // reset label value
//            retrieveRoomBookings()
//            scheduleTableView.reloadData()
//        } else {
//            print("Event Count Error")
//        }
//        
        
        
//        let range = NSMakeRange(0, self.scheduleTableView.numberOfSections)
//        let sections = NSIndexSet(indexesInRange: range)
//        self.scheduleTableView.reloadSections(sections, withRowAnimation: .Automatic)
        
    }
    
    @IBAction func timeDurationSliderValue(sender: UISlider) {
        print(timeDurationSlider.value)
        timeDurationLabel.text = String(Int(timeDurationSlider.value / 60))
//        let addTime = timeDurationSlider.value
//        let endTime = NSNumberFormatter(
    }
    
    func retrieveRoomBookings() {
        let calendars = eventStore.calendarsForEntityType(.Event)
        let startDate = NSDate() // time starting now
        let endDate = NSDate(timeIntervalSinceNow: 604800) // 7 days in advance
        let predicate = eventStore.predicateForEventsWithStartDate(startDate, endDate: endDate, calendars: calendars)
        let events = eventStore.eventsMatchingPredicate(predicate)
        if events.count > 0 {
            for event in events {
                print(event.title)
            }
            scheduleArray = events
//            print(scheduleArray)
        }
    }
    
    //MARK: - Table View Methods
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return scheduleArray.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("cell", forIndexPath: indexPath) as! CustomTableViewCell
        let booking = scheduleArray[indexPath.row]
        
        cell.eventTitleLabel.text = booking.title
        
        let startDateFormatter = NSDateFormatter()
        startDateFormatter.dateFormat = "hh:mm a"
        cell.eventStartLabel.text = startDateFormatter.stringFromDate(booking.startDate)
        
        let endDateFormatter = NSDateFormatter()
        endDateFormatter.dateFormat = "hh:mm a"
        cell.eventEndLabel.text = endDateFormatter.stringFromDate(booking.endDate)
        
        let dayFormatter = NSDateFormatter()
        dayFormatter.dateFormat = "EEEE"
        let dayIcon = dayFormatter.stringFromDate(booking.startDate)
        let dayDisplay = UIImage(named: "icon_\(dayIcon)")
        cell.dayImage.image = dayDisplay
        
        return cell
    }
    
    
    //MARK: - Permission Methods

    func requestAccesstoEKType(type: EKEntityType) {
        eventStore.requestAccessToEntityType(type) { (accessGranted, Error) -> Void in
            if accessGranted {
                print("Granted")
            } else {
                print("Not Granted")
            }
        }
    }
    
    func checkEKAuthorizationStatus(type: EKEntityType) {
        let status = EKEventStore.authorizationStatusForEntityType(type)
        switch status {
        case .NotDetermined:
            print("Not Determined")
            requestAccesstoEKType(type) // we added this after we crated the method above
        case .Authorized:
            print("Authorized")
        case .Restricted, .Denied:
            print("Restricted/Denied")
        }
    }
    
    
    //MARK: - Life Cycle Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        checkEKAuthorizationStatus(.Event)
        checkEKAuthorizationStatus(.Reminder)
        setIntroText(introTextLabel)
        retrieveRoomBookings()
        
        
        timeBeginDatePicker.minimumDate = NSDate() // TODO: Come back to this
        

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()

    }


}


/// do a search just like we do when we fetch the array, except if we return greater than 0, don't allow the event to be saved; use in-class example if needed

