/*
 * JBoss, Home of Professional Open Source
 * Copyright 2012, Red Hat, Inc., and individual contributors
 * by the @authors tag. See the copyright.txt in the distribution for a
 * full listing of individual contributors.
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 * http://www.apache.org/licenses/LICENSE-2.0
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

#import "AGTaskViewController.h"
#import "AGProjectsSelectionListViewController.h"
#import "AGTagsSelectionListViewController.h"

#import "AGTask.h"
#import "AGTag.h"
#import "AGProject.h"

#import "AGToDoAPIService.h"

#import "SVProgressHUD.h"
#import "EditCell.h"
#import "TextViewCell.h"
#import "DateSelectionCell.h"

// Table Sections
enum AGTableSections {
    AGTableSectionTitle = 0,
    AGTableSectionDescr,
    AGTableSectionDueProjTag,
    AGTableNumSections
};

// Table Rows
enum AGTitleRows {
    AGTableSecTitleRowTitle = 0,
    AGTableSecTitleNumRows,
};

enum AGDescrRows {
    AGTableSecDescrRowDescr = 0,
    AGTableSecDescrNumRows,
};

enum AGDueProjTagRows {
    AGTableSecDueProjTagRowDue = 0,
    AGTableSecDueProjTagRowProj,
    AGTableSecDueProjTagRowTag,
    AGTableSecDueProjTagNumRows    
};

@implementation AGTaskViewController {
    id _textFieldBeingEdited;
    
    AGTask *_tempTask;
}

@synthesize task = _task;
@synthesize delegate;

#pragma mark - View lifecycle

- (void)viewDidUnload {
    [super viewDidUnload];
        
    DLog(@"AGTaskViewController viewDidUnLoad");
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    if (self.task == nil) {
        self.title = @"New Task";
    } else {
        self.title = @"Edit Task";
    }

    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Save" 
                                                                              style:UIBarButtonItemStyleDone 
                                                                             target:self
       
                                                                             action:@selector(save)];
    
    if(self.task == nil) { // new Task
        _tempTask = [[AGTask alloc] init];
        // TEMP HACK that sets the date, will be removed once the Date Editor is implemented 
        _tempTask.dueDate = @"2010-01-01";
    
    } else // edit Task (make a copy so the changes are not immediately applied to the original Task object)
        _tempTask = [self.task copy];
}

- (void)viewWillAppear:(BOOL)animated {
 	[self.tableView reloadData];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return YES;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return AGTableNumSections;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    switch (section) {
        case AGTableSectionTitle:
            return @"Title";
        case AGTableSectionDescr:
            return @"Description";
        default:
            return nil;
    }
}

- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
	// in case of "Desciption" height is bigger to accomodate large text
    if(indexPath.section == AGTableSectionDescr) return 110.0;

	return 44.0;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    switch (section) {
        case AGTableSectionTitle:
            return AGTableSecTitleNumRows;
        case AGTableSectionDescr:
            return AGTableSecDescrNumRows;
        case AGTableSectionDueProjTag:
            return AGTableSecDueProjTagNumRows;
        default:
            return 0;
    }    
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSUInteger section = [indexPath section];
    NSUInteger row = [indexPath row];
    
    UITableViewCell *cell;

    switch (section) {
        case AGTableSectionTitle:
        {
            EditCell *titleCell = [[EditCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
            titleCell.txtField.delegate = self;
            titleCell.txtField.text = _tempTask.title;
            
            cell = titleCell;
            break;
        }
        case AGTableSectionDescr:
        {
            TextViewCell *descrCell = [[TextViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
            descrCell.txtView.delegate = self;
            descrCell.txtView.text = _tempTask.descr;
            
            cell = descrCell;
            break;            
        }
        case AGTableSectionDueProjTag:
        {
            switch (row) {
                case AGTableSecDueProjTagRowDue:
                {
                    DateSelectionCell *dateCell = [[DateSelectionCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:nil];
                    dateCell.textLabel.text = @"Due Date";
                    dateCell.detailTextLabel.text = _tempTask.dueDate;
                    
                    NSDateFormatter *inputFormat = [[NSDateFormatter alloc] init];
                    [inputFormat setDateFormat:@"yyyy-MM-dd"];
                    NSDate *inputDate = [inputFormat dateFromString: _tempTask.dueDate];

                    dateCell.dateValue = inputDate;
                    dateCell.delegate = self;
                    
                    cell = dateCell;                    
                    break;
                }
                case AGTableSecDueProjTagRowProj:
                {
                    UITableViewCell *selCell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:nil];
                    selCell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;

                    selCell.textLabel.text = @"Project";

                    AGProject *project = [[AGToDoAPIService sharedInstance].projects objectForKey:_tempTask.projID];
                    selCell.detailTextLabel.text = project.title;

                    cell = selCell;                    
                    break;
                }
                case AGTableSecDueProjTagRowTag:
                {
                    UITableViewCell *selCell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:nil];
                    selCell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;

                    selCell.textLabel.text = @"Tags";

                    NSMutableArray *tagDescrs = [[NSMutableArray alloc] init];
                    for (NSNumber *id in _tempTask.tags) {
                        AGTag *tag = [[AGToDoAPIService sharedInstance].tags objectForKey:id];
                        
                        if (tag != nil) // TODO: why this?
                            [tagDescrs addObject:tag.title];
                    }
                    
                    selCell.detailTextLabel.text = [tagDescrs componentsJoinedByString:@", "];               

                    cell = selCell;                    
                    break;
                }
            }   

            break;
        }
    }
    
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSUInteger section = [indexPath section];
    NSUInteger row = [indexPath row];

    switch (section) {
        case AGTableSectionDueProjTag:
            switch (row) {
                case AGTableSecDueProjTagRowProj:
                {
                    AGProjectsSelectionListViewController *projListController = [[AGProjectsSelectionListViewController alloc] initWithStyle:UITableViewStyleGrouped];
                    projListController.isEditMode = YES;
                    projListController.task = _tempTask;
                    
                    UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:projListController];
                    
                    [self presentModalViewController:navController animated:YES];
                    
                    break;
                }
                case AGTableSecDueProjTagRowTag:
                {
                    AGTagsSelectionListViewController *tagsListController = [[AGTagsSelectionListViewController alloc] initWithStyle:UITableViewStyleGrouped];
                    tagsListController.task = _tempTask;

                    UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:tagsListController];
                    
                    [self presentModalViewController:navController animated:YES];
                    
                    break;
                }
            }
            break;
    }
}
 
#pragma mark - UITextFieldDelegate methods

- (void)textFieldDidBeginEditing:(UITextField *)textField {
    _textFieldBeingEdited = textField;
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    _tempTask.title = textField.text;
          
    [textField resignFirstResponder];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];

    return YES;
}

#pragma mark - UITextViewDelegate methods
- (void)textViewDidBeginEditing:(UITextView *)textView {
    _textFieldBeingEdited = textView;
}

- (void)textViewDidEndEditing:(UITextView *)textView {
    _tempTask.descr = textView.text;
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    if ([text isEqualToString:@"\n"]) {
        [textView resignFirstResponder];
    }
    
    return YES;
}

# pragma mark - DateSelectionCell delegate methods

- (void)tableViewCell:(DateSelectionCell *)cell didEndEditingWithDate:(NSDate *)date {
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM-dd"];
    
    _tempTask.dueDate = [formatter stringFromDate:date];
    
    [self.tableView reloadData];
}

#pragma mark - Action Methods

- (IBAction)save {
    // handle the case where the keyboard is still open
    // and the user clicks "Save" so the delegates( [*]DidEndEditing)
    // are not yet called to update the model
    if (_textFieldBeingEdited != nil) {
        if ([_textFieldBeingEdited isKindOfClass:[UITextField class]])
            _tempTask.title = ((UITextField *)_textFieldBeingEdited).text;
        else
            _tempTask.descr = ((UITextView *)_textFieldBeingEdited).text;
        
        
        [_textFieldBeingEdited resignFirstResponder];        
    }

    [delegate taskViewControllerDelegateDidFinish:self task:_tempTask];
}

@end
