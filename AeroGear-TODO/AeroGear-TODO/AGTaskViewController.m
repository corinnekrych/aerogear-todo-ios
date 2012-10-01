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

#import "AGTask.h"

#import "EditCell.h"
#import "TextViewCell.h"
#import "SelectionCell.h"

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
    UITextField *_textFieldBeingEdited;
}

@synthesize task = _task;

-(void)dealloc {
    DLog(@"AGTaskViewController dealloc");    
}

#pragma mark - View lifecycle

- (void)viewDidUnload {
    DLog(@"AGTaskViewController viewDidUnLoad");
    
    [super viewDidUnload];
}

- (void)viewDidLoad {
    self.title = @"New Task";
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Save" style:UIBarButtonItemStyleDone target:self action:@selector(save)];
    
    [super viewDidLoad];
    
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
    
    id cell;

    switch (section) {
        case AGTableSectionTitle:
        {
            EditCell *titleCell = [EditCell cellForTableView:tableView];
            titleCell.txtField.delegate = self;

            titleCell.txtField.text = self.task.title;
            
            cell = titleCell;
            
            break;
        }
        case AGTableSectionDescr:
        {
            TextViewCell *descrCell = [TextViewCell cellForTableView:tableView];
            descrCell.textView.delegate = self;
            
            descrCell.textView.text = self.task.description;
            
            cell = descrCell;
            break;            
        }
        case AGTableSectionDueProjTag:
        {
            SelectionCell *selCell = [SelectionCell cellForTableView:tableView];
            selCell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            
            switch (row) {
                case AGTableSecDueProjTagRowDue:
                    selCell.textLabel.text = @"Due Date";
                    selCell.detailTextLabel.text = self.task.dueDate;
                    break;
                case AGTableSecDueProjTagRowProj:
                    selCell.textLabel.text = @"Project";
                    selCell.detailTextLabel.text = [self.task.project description];
                    
                    //TODO remove when functionality is implemented
                    selCell.textLabel.alpha = 0.439216f;
                    selCell.detailTextLabel.alpha = 0.439216f;
                    selCell.userInteractionEnabled = NO;
                    break;
                case AGTableSecDueProjTagRowTag:
                    selCell.textLabel.text = @"Tags";
                    selCell.detailTextLabel.text = [self.task.tags description];                  
                    
                    //TODO remove when functionality is implemented
                    selCell.textLabel.alpha = 0.439216f;
                    selCell.detailTextLabel.alpha = 0.439216f;                    
                    selCell.userInteractionEnabled = NO;
                    break;
            }   
            
            cell = selCell;
            break;
        }
    }
    
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
}

#pragma mark - UITextFieldDelegate methods
- (void)textFieldDidBeginEditing:(UITextField *)textField {
    _textFieldBeingEdited = textField;
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    /*
	NSNumber *tagAsNum = [[NSNumber alloc] initWithInt:textField.tag];
	// textfield.text password is not initialized to '' for password fields
    if (textField.text == nil)
        return;
    
    [_tempValues setObject:textField.text forKey:tagAsNum];
     */
    [textField resignFirstResponder];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];

    return YES;
}

- (void)textViewDidEndEditing:(UITextView *)textView {
}

#pragma mark - Action Methods

- (IBAction)save {
    // TODO
}

@end
