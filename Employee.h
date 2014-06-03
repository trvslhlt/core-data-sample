//
//  Employee.h
//  CoreData4
//
//  Created by Aditya Narayan on 4/7/14.
//  Copyright (c) 2014 travis holt. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Education;

@interface Employee : NSManagedObject

@property (nonatomic, retain) NSNumber * empID;
@property (nonatomic, retain) NSString * location;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) Education *relationship;

@end
