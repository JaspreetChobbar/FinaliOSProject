//
//  UserData+CoreDataProperties.swift
//  FinaliOSProject
//
//  Created by Jaspreet on 2020-01-20.
//  Copyright © 2020 Jaspreet. All rights reserved.
//
//

import Foundation
import CoreData


extension UserData {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<UserData> {
        return NSFetchRequest<UserData>(entityName: "UserData")
    }

    @NSManaged public var name: String?
    @NSManaged public var birthday: Date?
    @NSManaged public var country: String?
    @NSManaged public var gender: String?
    @NSManaged public var latitude: Double
    @NSManaged public var longitude: Double
    @NSManaged public var photoID: NSNumber?


}
