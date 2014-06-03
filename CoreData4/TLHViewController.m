//
//  TLHViewController.m
//  CoreData4
//
//  Created by travis holt on 4/6/14.
//  Copyright (c) 2014 travis holt. All rights reserved.
//

#import "TLHViewController.h"

@interface TLHViewController ()

@end

@implementation TLHViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self initModelcontext];
    [self reloadDataFromContext];


}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark CoreData operations

-(void)initModelcontext {
    
    self.model = [NSManagedObjectModel mergedModelFromBundles:nil];
    self.psc = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:self.model];
    
    NSArray *documentsDirectories = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [documentsDirectories objectAtIndex:0];
    NSString *path = [documentsDirectory stringByAppendingPathComponent:@"store.data"];
    NSURL *storeURL = [NSURL fileURLWithPath:path];
    NSError *error = nil;
    
    if (![self.psc addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error]) {
        [NSException raise:@"Open Failed" format:@"Reason: %@",[error localizedDescription]];
    }
    
    self.context = [[NSManagedObjectContext alloc] init];
    self.context.undoManager = [[NSUndoManager alloc] init];
    self.context.persistentStoreCoordinator = self.psc;
}

-(void)reloadDataFromContext {
    
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    
    NSEntityDescription *entity = [[self.model entitiesByName] objectForKey:@"Employee"];
    request.entity = entity;
    
    NSSortDescriptor *sortByName = [[NSSortDescriptor alloc] initWithKey:@"name" ascending:YES];
    request.sortDescriptors = [NSArray arrayWithObject:sortByName];
    
    NSError *error = nil;
    NSArray *result = [self.context executeFetchRequest:request error:&error];
    if (!result) {
        [NSException raise:@"Fetch failed." format:@"Reason: %@",[error localizedDescription]];
    }
    
    self.employees = [[NSMutableArray alloc] initWithArray:result];
    self.educationRecords = [[NSMutableArray alloc] init];
    
    for (id emp in self.employees) {
        [self.educationRecords addObject:[emp relationship]];
    }
    
    [self.tableView reloadData];
    [self.tableViewEducation reloadData];
}

-(void)createEmployeeWithEmpID:(NSNumber*)empID name:(NSString*)name location:(NSString*)location {
    
    Employee *employee = [NSEntityDescription insertNewObjectForEntityForName:@"Employee" inManagedObjectContext:self.context];
    employee.empID = empID;
    employee.name = name;
    employee.location = location;
    [self.employees addObject:employee];
    
    Education *educationRecord = [NSEntityDescription insertNewObjectForEntityForName:@"Education" inManagedObjectContext:self.context];
    educationRecord.relationship = employee;
    educationRecord.highSchool = [NSNumber numberWithBool:[self.switchHighSchool isOn]];
    educationRecord.undergraduate = [NSNumber numberWithBool:self.switchUndergraduate.on];
    educationRecord.masters = [NSNumber numberWithBool:self.switchGraduate.on];
    educationRecord.doctorate = [NSNumber numberWithBool:[self.switchDoctorate isOn]];
    

    
    
    [self.educationRecords addObject:educationRecord];
    
    [self reloadDataFromContext];
}




#pragma mark UIButton methods

- (IBAction)addEmployee:(id)sender {
    
    if (![self.textName.text isEqualToString:@""] && ![self.textLocation.text isEqualToString:@""]) {
        NSNumber *empID = [NSNumber numberWithInt:[[NSDate date] timeIntervalSince1970]];
        [self createEmployeeWithEmpID:empID name:self.textName.text location:self.textLocation.text];
        [self.view endEditing:YES];
    }
    
    self.textName.text = @"";
    self.textLocation.text = @"";
}

- (IBAction)submitChanges:(id)sender {
    
    if (!editingMode) {
        self.textNameEdit.text = @"";
        self.textLocationEdit.text = @"";
        return;
    }
    Employee *employee = [self.employees objectAtIndex:selectedEmployeeIndex];
    employee.name = self.textNameEdit.text;
    employee.location = self.textLocationEdit.text;
    self.textNameEdit.text = @"";
    self.textLocationEdit.text = @"";
    [self reloadDataFromContext];
    
    editingMode = NO;
    
    [self.view endEditing:YES];
    
    [self reloadDataFromContext];
    
}

- (IBAction)editList:(id)sender {
    
    self.tableView.editing = !self.tableView.editing;
    if ([self.tableView isEditing]) {
        [sender setTitle:@"Done" forState:UIControlStateNormal];
    } else {
        [sender setTitle:@"Edit List" forState:UIControlStateNormal];
    }
    
}

- (IBAction)undo:(id)sender {
    
    [self.context undo];
    [self reloadDataFromContext];
    
}

- (IBAction)redo:(id)sender {
    
    [self.context redo];
    [self reloadDataFromContext];
    
}

- (IBAction)rollbackAll:(id)sender {
    
    [self.context rollback];
    [self reloadDataFromContext];
    
}

- (IBAction)saveEmployeesToDisk:(id)sender {
    
    NSError *error = nil;
    BOOL success;
    success = [self.context save:&error];
    if (!success) {
        [NSException raise:@"Failed to save to disk" format:@"Reason: %@",[error localizedDescription]];
    }
    
}

- (IBAction)removeAllEmployees:(id)sender {
    
    editingMode = NO;
    self.textNameEdit.text = @"";
    self.textLocationEdit.text = @"";
    NSError *error = nil;
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    request.entity = [NSEntityDescription entityForName:@"Employee" inManagedObjectContext:self.context];
    NSArray *result = [self.context executeFetchRequest:request error:&error];
    if (!result) {
        [NSException raise:@"Failed to remove all employees" format:@"Reason: %@",[error localizedDescription]];
    }
    
    for (id employee in result) {
        [self.context deleteObject:employee];
    }
    
    [self reloadDataFromContext];
}



#pragma mark table view methods

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.employees count];
}

-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"reusableCell"];
    
    
    if (tableView == self.tableView) {
        if (!cell) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"reusableCell"];
        }
        Employee *employee = [self.employees objectAtIndex:indexPath.row];
        cell.textLabel.text = employee.name;
        cell.detailTextLabel.text = employee.location;
        
    } else {
        if (!cell) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"reusableCell"];
        }
        Education *educationRecord = [self.educationRecords objectAtIndex:indexPath.row];

        if ([educationRecord.doctorate boolValue]) {
            cell.textLabel.text = @"Doctorate";
        } else if ([educationRecord.masters boolValue]) {
            cell.textLabel.text = @"Masters";
        } else if ([educationRecord.undergraduate boolValue]) {
            cell.textLabel.text = @"Bachelors";
        } else if ([educationRecord.highSchool boolValue]) {
            cell.textLabel.text = @"High School Diploma";
        } else {
            cell.textLabel.text = @"";
        }
        cell.textLabel.textAlignment = NSTextAlignmentRight;
    }
    
    
    return cell;
    
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    selectedEmployeeIndex = indexPath.row;
    editingMode = YES;
    Employee *employee = [self.employees objectAtIndex:indexPath.row];
    self.textNameEdit.text = employee.name;
    self.textLocationEdit.text = employee.location;
    
}

-(void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        Employee *employee = [self.employees objectAtIndex:indexPath.row];
        
        self.textNameEdit.text = @"";
        self.textLocationEdit.text = @"";
        editingMode = NO;
        self.tableView.editing = NO;
        [self.editListButton setTitle:@"Edit List" forState:UIControlStateNormal];
        
        [self.context deleteObject:employee];
        
        [self reloadDataFromContext];
    }
    
}

@end












