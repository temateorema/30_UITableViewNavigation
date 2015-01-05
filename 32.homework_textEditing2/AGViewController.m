//
//  AGViewController.m
//  32.homework_textEditing2
//
//  Created by MC723 on 24.12.14.
//  Copyright (c) 2014 temateorema. All rights reserved.
//

#import "AGViewController.h"
#import "AGGroup.h"
#import "AGStudent.h"

@interface AGViewController () <UITableViewDelegate, UITableViewDataSource>

@property (strong, nonatomic) NSMutableArray* groupsArray;
@property (weak, nonatomic) UITableView* tableView;

@end

@implementation AGViewController

//RGB
static inline UIColor *UIColorFromRGBA(int rgb, float a) {
    
    return [UIColor colorWithRed:((float)((rgb & 0xFF0000) >> 16))/255.0
                           green:((float)((rgb & 0xFF00) >> 8))/255.0
                            blue:((float)(rgb & 0xFF))/255.0 alpha:a];
}
static inline UIColor *UIColorFromRGB(int rgb) {
    return UIColorFromRGBA(rgb, 1.f);
}


- (void) loadView {
    [super loadView];
    
    CGRect frame = self.view.bounds;
    frame.origin = CGPointZero;
    
    UITableView* tableView = [[UITableView alloc] initWithFrame: frame
                                                          style: UITableViewStyleGrouped];
    tableView.delegate = self;
    tableView.dataSource = self;
    tableView.allowsSelectionDuringEditing = NO;
    
    //[tableView setSeparatorInset:UIEdgeInsetsZero];
    //[tableView setLayoutMargins:UIEdgeInsetsZero];
    tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    [self.view addSubview: tableView];
    self.tableView = tableView;
}


- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.title = @"Students";
    UIBarButtonItem* editButton = [[UIBarButtonItem alloc]
                                   initWithBarButtonSystemItem: UIBarButtonSystemItemEdit
                                                        target:self
                                                        action:@selector(actionEdit:)];
    self.navigationItem.rightBarButtonItem = editButton;
    
    
    UIBarButtonItem* addButton = [[UIBarButtonItem alloc]
                                   initWithBarButtonSystemItem: UIBarButtonSystemItemAdd
                                                        target:self
                                                        action:@selector(actionAdd:)];
    self.navigationItem.leftBarButtonItem = addButton;
    
    
    self.groupsArray = [NSMutableArray array];
    
    for (int i = 0; i < (arc4random_uniform(6) + 5); i++) {
        
        AGGroup* group = [[AGGroup alloc] init];
        group.groupName = [NSString stringWithFormat:@"Group #%d", i+1];
        
        NSMutableArray* array = [NSMutableArray array];
        
        for (int j = 0; j < (arc4random_uniform(6) + 10); j++) {
            [array addObject:[AGStudent randomSudent]];
        }
        
        group.studentsArray = array;
        [self.groupsArray addObject:group];
    }
    [self.tableView reloadData];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}


# pragma mark - Actions 

- (void) actionEdit: (UIBarButtonItem *) sender {
    
    BOOL isEditing = self.tableView.editing;
    [self.tableView setEditing: !isEditing animated:YES];
    
    UIBarButtonSystemItem item = UIBarButtonSystemItemEdit;
    
    if (self.tableView.editing) {
        item = UIBarButtonSystemItemDone;
    }
    
    UIBarButtonItem* editButton = [[UIBarButtonItem alloc]
                                   initWithBarButtonSystemItem:item
                                                        target:self
                                                        action:@selector(actionEdit:)];
    
    [self.navigationItem setRightBarButtonItem:editButton animated:YES];
}

- (void) actionAdd: (UIBarButtonItem *) sender {
    
    AGGroup* group = [[AGGroup alloc] init];
    group.groupName = [NSString stringWithFormat:@"Group#%d", (int)[self.groupsArray count] +1];
    group.studentsArray = @[[AGStudent randomSudent], [AGStudent randomSudent]];
    
    NSInteger newSectionIndex = 0;
    
    [self.groupsArray insertObject:group atIndex:newSectionIndex];
    
    [self.tableView beginUpdates];
    
    NSIndexSet *insertSections = [NSIndexSet indexSetWithIndex:newSectionIndex];
    [self.tableView insertSections:insertSections withRowAnimation:UITableViewRowAnimationLeft];
    
    
    [[UIApplication sharedApplication] beginIgnoringInteractionEvents];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        if ([[UIApplication sharedApplication] isIgnoringInteractionEvents]) {
            [[UIApplication sharedApplication] endIgnoringInteractionEvents];
        }
    });
    
    [self.tableView endUpdates];
}


#pragma mark - UITableViewDataSource

//Number of sections
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return [self.groupsArray count];
}

//Title of section
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return [[self.groupsArray objectAtIndex:section] groupName];
}

//Number of rows
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    AGGroup* group = [self.groupsArray objectAtIndex:section];
    return [group.studentsArray count];
}

//Cells
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.row == 0) {
        static NSString* addStudentIdentifier = @"AddStudentCell";
        
        UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:addStudentIdentifier];
        
        if (!cell) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:addStudentIdentifier];
            
            cell.textLabel.text = @"Add student";
            cell.textLabel.textColor = [UIColor blueColor];
        }
        return cell;
        
    } else {
        static NSString* identifire = @"Cell";
        
        UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:identifire];
        
        if (!cell) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1
                                          reuseIdentifier:identifire];
        }
        AGGroup* group = [self.groupsArray objectAtIndex:indexPath.section];
        AGStudent* student = [group.studentsArray objectAtIndex:indexPath.row];
        
        
        //Separators Adjustment
        
        self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        
        UIView *separatorView = [[UIView alloc] initWithFrame:CGRectMake(0, 44, 1024, 0.5)];
        separatorView.layer.borderColor = [UIColor colorWithRed:0.8 green:0.8 blue:0.8 alpha:0.7f].CGColor;
        separatorView.layer.borderWidth = 1.0;
        [cell.contentView addSubview:separatorView];
        
        if ([cell respondsToSelector:@selector(layoutMargins)]) {
            cell.layoutMargins = UIEdgeInsetsMake(0, 0, 0, 0);
        }
        cell.textLabel.text = [NSString stringWithFormat:@"%@ %@", student.firstName, student.lastName];
        cell.detailTextLabel.text = [NSString stringWithFormat:@"%1.2f", student.averageScore];
        
        
        if (student.averageScore > 4.0f) {
            cell.detailTextLabel.textColor = UIColorFromRGB(0xd0b972c);
            
        } else if (student.averageScore < 3.0f) {
            cell.detailTextLabel.textColor = UIColorFromRGB(0xbb2727);
            
        } else if (student.averageScore <= 4.0f) {
            cell.detailTextLabel.textColor = UIColorFromRGB(0xfa9f33);
        }
        
        return cell;
    }
}


- (BOOL) tableView: (UITableView *) tableView canMoveRowAtIndexPath: (NSIndexPath *) indexPath {
    return indexPath.row > 0;
}

//MOVING ROWS
- (void) tableView: (UITableView *) tableView  moveRowAtIndexPath: (NSIndexPath *) sourceIndexPath toIndexPath: (NSIndexPath*) destinationIndexPath {
    
    AGGroup* group = [self.groupsArray objectAtIndex:sourceIndexPath.section];
    AGStudent* student = [group.studentsArray objectAtIndex:sourceIndexPath.row];
    
    NSMutableArray* tempArray = [NSMutableArray arrayWithArray:group.studentsArray];
    
    
    if (sourceIndexPath.section == destinationIndexPath.section) {
        
        [tempArray exchangeObjectAtIndex:sourceIndexPath.row
                       withObjectAtIndex:destinationIndexPath.row];
        group.studentsArray = tempArray;
        
    } else {
        
        [tempArray removeObject:student];
        group.studentsArray = tempArray;
        
        AGGroup* destinationGroup = [self.groupsArray objectAtIndex:destinationIndexPath.section];
        
        tempArray = [NSMutableArray arrayWithArray:destinationGroup.studentsArray];
        [tempArray insertObject:student atIndex:destinationIndexPath.row];
        
        destinationGroup.studentsArray = tempArray;
    }
}


//DELETING ROWS
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        
        AGGroup* group = [self.groupsArray objectAtIndex:indexPath.section];
        
        AGStudent* student = [group.studentsArray objectAtIndex:indexPath.row - 1];
        
        NSMutableArray* tempArray = [NSMutableArray arrayWithArray:group.studentsArray];
        [tempArray removeObject: student];
        group.studentsArray = tempArray;
        
        [tableView beginUpdates];
        
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:
        UITableViewRowAnimationLeft];
        
        [tableView endUpdates];
    }
}


#pragma mark - UITableViewDelegate

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
    return indexPath.row == 0 ? UITableViewCellEditingStyleNone : UITableViewCellEditingStyleDelete;
}

- (NSIndexPath *)tableView:(UITableView *)tableView targetIndexPathForMoveFromRowAtIndexPath:(NSIndexPath *)sourceIndexPath toProposedIndexPath:(NSIndexPath*)proposedDestinationIndexPath {
        
        if (proposedDestinationIndexPath.row == 0) {
            return sourceIndexPath;
            
        } else {
            return proposedDestinationIndexPath;
        }
}


//ADD NEW ROW
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (indexPath.row == 0) {
        AGGroup* group = [self.groupsArray objectAtIndex:indexPath.section];
        
        NSMutableArray* tempArray = nil;
        
        if (group.studentsArray) {
            tempArray = [NSMutableArray arrayWithArray:group.studentsArray];
            
        } else {
            tempArray = [NSMutableArray array];
        }
        
        NSInteger newStudentIndex = 0;
        [tempArray insertObject:[AGStudent randomSudent] atIndex:newStudentIndex];
        group.studentsArray = tempArray;
        
        
        [self.tableView beginUpdates];
        
        NSIndexPath* newIndexPath = [NSIndexPath indexPathForItem:newStudentIndex + 1 inSection:indexPath.section];
        
        [self.tableView insertRowsAtIndexPaths:@[newIndexPath] withRowAnimation:UITableViewRowAnimationLeft];
        
        [self.tableView endUpdates];
        
        
        [[UIApplication sharedApplication] beginIgnoringInteractionEvents];
        double delayInSeconds = 0.3;
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
            if ([[UIApplication sharedApplication] isIgnoringInteractionEvents]) {
                [[UIApplication sharedApplication] endIgnoringInteractionEvents];
            }
        });
        
    }
}
@end