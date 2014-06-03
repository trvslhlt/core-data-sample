//
//  Education.h
//  CoreData4
//
//  Created by Aditya Narayan on 4/7/14.
//  Copyright (c) 2014 travis holt. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Employee;

@interface Education : NSManagedObject

@property (nonatomic, retain) NSNumber * highSchool;
@property (nonatomic, retain) NSNumber * undergraduate;
@property (nonatomic, retain) NSNumber * masters;
@property (nonatomic, retain) NSNumber * doctorate;
@property (nonatomic, retain) Employee *relationship;

@end
