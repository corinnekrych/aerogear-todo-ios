/*
 * JBoss, Home of Professional Open Source.
 * Copyright Red Hat, Inc., and individual contributors
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
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
    
    ARTableViewData *tableViewData = [[ARTableViewData alloc] init];
    
    // add the section to the tableView
    [tableViewData addSectionData:[self sectionTitle]];
    [tableViewData addSectionData:[self sectionDescription]];
    [tableViewData addSectionData:[self sectionDueDateProjectTag]];
    
    // setting the tableViewData property will automaticaly reload the tableView
    self.tableViewData = tableViewData;
    
}

- (void)viewWillAppear:(BOOL)animated {
 	[self.tableView reloadData];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return YES;
}


- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
	// in case of "Desciption" height is bigger to accomodate large text
    if(indexPath.section == 1) return 110.0;
    
	return 44.0;
}

- (ARSectionData *)sectionTitle {
    NSString *name = NSStringFromClass([EditCell class]);
    ARSectionData *sectionData = [[ARSectionData alloc] init];
    [self registerClass:[EditCell class] forCellReuseIdentifier:name];
    
    ARCellData *cellData = [[ARCellData alloc] initWithIdentifier:name];
    sectionData.headerTitle = @"Title";
    [cellData setCellConfigurationBlock:^(EditCell *cell) {
        cell.txtField.delegate = self;
        cell.txtField.text = _tempTask.title;
    }];
    
    [sectionData addCellData:cellData];
    return sectionData;
}

- (ARSectionData *)sectionDescription {
    ARSectionData *sectionData = [[ARSectionData alloc] init];
    [self registerClass:[TextViewCell class] forCellReuseIdentifier:NSStringFromClass([TextViewCell class])];
    ARCellData *cellData = [[ARCellData alloc] initWithIdentifier:NSStringFromClass([TextViewCell class])];
    sectionData.headerTitle = @"Description";

    [cellData setCellConfigurationBlock:^(TextViewCell *cell) {
        cell.txtView.delegate = self;
        if (![_tempTask.descr isKindOfClass:[NSNull class]])
            cell.txtView.text = _tempTask.descr;
        
    }];
    [sectionData addCellData:cellData];
    return sectionData;
}

- (ARSectionData *)sectionDueDateProjectTag {
    ARSectionData *sectionData = [[ARSectionData alloc] init];
    [sectionData addCellData:[self cellDueDate]];
    [sectionData addCellData:[self cellProject]];
    [sectionData addCellData:[self cellTag]];
    return sectionData;
}

- (ARCellData *)cellProject {
    [self registerClass:[UITableViewCell class] forCellReuseIdentifier:NSStringFromClass([UITableViewCell class])];
    ARCellData *cellData = [[ARCellData alloc] initWithIdentifier:NSStringFromClass([UITableViewCell class])];
    [cellData setCellConfigurationBlock:^(UITableViewCell *cell) {
        cell.textLabel.text = @"Project:";
        
        AGProject *project = [[AGToDoAPIService sharedInstance].projects objectForKey:_tempTask.projID];
        if (project != nil) {
            cell.textLabel.text = [NSString stringWithFormat:@"Project: %@", project.title];
        }

    }];
    
    [cellData setCellSelectionBlock:^(UITableView *tableView, NSIndexPath *indexPath) {
        AGProjectsSelectionListViewController *projListController = [[AGProjectsSelectionListViewController alloc] initWithStyle:UITableViewStyleGrouped];
        projListController.isEditMode = YES;
        projListController.task = _tempTask;
        
        UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:projListController];
        
        [self presentModalViewController:navController animated:YES];
    }];
    
    return cellData;
}

- (ARCellData *)cellTag {
    [self registerClass:[UITableViewCell class] forCellReuseIdentifier:NSStringFromClass([UITableViewCell class])];
    ARCellData *cellData = [[ARCellData alloc] initWithIdentifier:NSStringFromClass([UITableViewCell class])];
    [cellData setCellConfigurationBlock:^(UITableViewCell *cell) {
        cell.textLabel.text = @"Tags:";
        
                            NSMutableArray *tagDescrs = [[NSMutableArray alloc] init];
                            for (NSNumber *id in _tempTask.tags) {
                                AGTag *tag = [[AGToDoAPIService sharedInstance].tags objectForKey:id];
        
                                if (tag != nil) 
                                    [tagDescrs addObject:tag.title];
                            }
                            NSString *tagString = [tagDescrs componentsJoinedByString:@", "];
                           
        if (![tagString isKindOfClass:[NSNull class]]) {
            cell.textLabel.text= [NSString stringWithFormat:@"Tags: %@", tagString];
        }
        
    }];
    
    [cellData setCellSelectionBlock:^(UITableView *tableView, NSIndexPath *indexPath) {
        AGTagsSelectionListViewController *tagsListController = [[AGTagsSelectionListViewController alloc] initWithStyle:UITableViewStyleGrouped];
        tagsListController.isEditMode = YES;
        tagsListController.task = _tempTask;
        
        UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:tagsListController];
        
        [self presentModalViewController:navController animated:YES];
    }];


    return cellData;
}

- (ARCellData *)cellDueDate {
    [self registerClass:[DateSelectionCell class] forCellReuseIdentifier:NSStringFromClass([DateSelectionCell class])];
    ARCellData *cellData = [[ARCellData alloc] initWithIdentifier:NSStringFromClass([DateSelectionCell class])];
    [cellData setCellConfigurationBlock:^(DateSelectionCell *cell) {
        cell.textLabel.text = @"Due Date";
        cell.detailTextLabel.text = _tempTask.dueDate;
        
        NSDateFormatter *inputFormat = [[NSDateFormatter alloc] init];
        [inputFormat setDateFormat:@"yyyy-MM-dd"];
        NSDate *inputDate = [inputFormat dateFromString: _tempTask.dueDate];
        
        cell.dateValue = inputDate;
        cell.delegate = self;
    }];
    [cellData setEditable:TRUE];
    [cellData setCellSelectionBlock:^(UITableView *tableView, NSIndexPath *indexPath) {
        _textFieldBeingEdited = [tableView cellForRowAtIndexPath:indexPath];

        
    }];
    return cellData;
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
        else if (![_textFieldBeingEdited isKindOfClass:[DateSelectionCell class]]) {
           _tempTask.descr = ((UITextView *)_textFieldBeingEdited).text; 
        } 
        
        [_textFieldBeingEdited resignFirstResponder];
    }
    
    [delegate taskViewControllerDelegateDidFinish:self task:_tempTask];
}
@end
