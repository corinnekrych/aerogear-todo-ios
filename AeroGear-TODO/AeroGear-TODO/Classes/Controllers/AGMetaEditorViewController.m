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

#import "AGMetaEditorViewController.h"

#import "EditCell.h"
#import "SelectionCell.h"

// Table Sections
enum AGTableMetaSections {
    AGTableMetaSectionTitle = 0,
    AGTableMetaSectionColor,
    AGTableMetaNumSections
};

// Table Rows
enum AGMetaTitleRows {
    AGTableMetaSecTitleRowTitle = 0,
    AGTableMetaSecTitleNumRows,
};

enum AGMetaColorRows {
    AGTableMetaSecColorRowColor = 0,
    AGTableMetaSecColorNumRows,
};


@implementation AGMetaEditorViewController {
    UITextField *_textFieldBeingEdited;
}

@synthesize name = _name;
@synthesize color = _color;

@synthesize delegate;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    DLog(@"AGMetaEditorViewController viewDidLoad");        
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Save" 
                                                                              style:UIBarButtonItemStyleDone 
                                                                             target:self
                                                                             action:@selector(save)];
    // default is white
    if (self.color == nil)
        self.color = [UIColor whiteColor];    
}

- (void)viewDidUnload {
    [super viewDidUnload];
    
    DLog(@"AGMetaEditorViewController viewDidUnload");            
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return YES;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return AGTableMetaNumSections;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    switch (section) {
        case AGTableMetaSectionTitle:
            return @"Title";
        case AGTableMetaSectionColor:
            return @"Color";
        default:
            return nil;
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    switch (section) {
        case AGTableMetaSectionTitle:
            return AGTableMetaSecTitleNumRows;
        case AGTableMetaSectionColor:
            return AGTableMetaSecColorNumRows;
        default:
            return 0;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSUInteger section = [indexPath section];
    
    id cell;
    
    switch (section) {
        case AGTableMetaSectionTitle:
        {
            EditCell *editCell = [EditCell cellForTableView:tableView];
            editCell.txtField.delegate = self;
            editCell.txtField.text = self.name;
            
            cell = editCell;
            break;
        }
        case AGTableMetaSectionColor:
        {
            SelectionCell *colorCell = [SelectionCell cellForTableView:tableView];
            colorCell.backgroundColor = self.color;
            colorCell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            cell = colorCell;
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
        case AGTableMetaSectionColor:
            switch (row) {
                case AGTableMetaSecColorRowColor:
                {
                    HRColorPickerViewController *colorController = [HRColorPickerViewController cancelableColorPickerViewControllerWithColor:self.color];
                    colorController.delegate = self;
                    [self.navigationController pushViewController:colorController animated:YES];
                    break;
                }
            }
    }
}
    
#pragma mark - UITextFieldDelegate methods

- (void)textFieldDidBeginEditing:(UITextField *)textField {
    _textFieldBeingEdited = textField;
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    self.name = textField.text;

    [textField resignFirstResponder];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    
    return YES;
}


#pragma mark - Action Methods

- (IBAction)save {
    if (_textFieldBeingEdited != nil)
        self.name = _textFieldBeingEdited.text;
    
    [delegate metaEditorViewControllerDelegateDidFinish:self withTitle:self.name andColor:self.color];
}


#pragma mark - ColorPickerDelegate methods

- (void)setSelectedColor:(UIColor*)color{
    self.color = color;
    
    [self.tableView reloadData];
    
    //[hexColorLabel setText:[NSString stringWithFormat:@"#%06x",HexColorFromUIColor(color)]];
}


@end
