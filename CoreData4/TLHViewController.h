//
//  TLHViewController.h
//  CoreData4
//
//  Created by travis holt on 4/6/14.
//  Copyright (c) 2014 travis holt. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>
#import "Employee.h"
#import "Education.h"

@interface TLHViewController : UIViewController <UITableViewDelegate, UITableViewDataSource>
{
    BOOL editingMode;
    BOOL selectedEmployeeIndex;
}

//text fields
@property (weak, nonatomic) IBOutlet UITextField *textName;
@property (weak, nonatomic) IBOutlet UITextField *textNameEdit;
@property (weak, nonatomic) IBOutlet UITextField *textLocation;
@property (weak, nonatomic) IBOutlet UITextField *textLocationEdit;

//buttons
@property (weak, nonatomic) IBOutlet UIButton *editListButton;


//switches
@property (weak, nonatomic) IBOutlet UISwitch *switchHighSchool;
@property (weak, nonatomic) IBOutlet UISwitch *switchUndergraduate;
@property (weak, nonatomic) IBOutlet UISwitch *switchGraduate;
@property (weak, nonatomic) IBOutlet UISwitch *switchDoctorate;

//table view
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UITableView *tableViewEducation;

//core data
@property(nonatomic)NSManagedObjectModel *model;
@property(nonatomic)NSManagedObjectContext *context;
@property(nonatomic)NSPersistentStoreCoordinator *psc;
@property(nonatomic)NSMutableArray *employees;
@property(nonatomic)NSMutableArray *educationRecords;


-(void)initModelcontext;
-(void)reloadDataFromContext;
-(void)createEmployeeWithEmpID:(NSNumber*)empID name:(NSString*)name location:(NSString*)location;


- (IBAction)addEmployee:(id)sender;
- (IBAction)submitChanges:(id)sender;
- (IBAction)editList:(id)sender;
- (IBAction)undo:(id)sender;
- (IBAction)redo:(id)sender;
- (IBAction)rollbackAll:(id)sender;
- (IBAction)saveEmployeesToDisk:(id)sender;
- (IBAction)removeAllEmployees:(id)sender;



@end
