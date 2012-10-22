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

#import "AGSettingsViewController.h"

#import "SwitchCell.h"
#import "EditCell.h"

// Table Sections
enum AGTableStngsSections {
    AGTableStngsSectionOpenShift = 0,
    AGTableStngsSectionUser,
    AGTableStngsSectionHost,    
    AGTableStngsNumSections
};

// Table Rows
enum AGStngOpenShiftRows {
    AGTableStngSecOpenShiftRow = 0,
    AGTableStngSecOpenShiftNumRows,
};

enum AGStngUserRows {
    AGTableStngSecUserRowUsername,
    AGTableStngSecUsersRowPass,
    AGTableStngSecUserNumRows,
};

enum AGStngHostRows {
    AGTableStngSecHostRow = 0,
    AGTableStngSecHostNumRows
};

@implementation AGSettingsViewController {
    UITextField *_textFieldBeingEdited;
}

@synthesize delegate;
@synthesize host;
@synthesize username;
@synthesize password;
@synthesize isOpenShift;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    DLog(@"AGSettingsViewController viewDidLoad");        
    
    self.title = @"Login";
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Close" 
                                                                             style:UIBarButtonItemStylePlain 
                                                                            target:self
                                                                            action:@selector(close)];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Login" 
                                                                              style:UIBarButtonItemStyleDone 
                                                                             target:self
                                                                             action:@selector(login)];
    
}

- (void)viewDidUnload {
    [super viewDidUnload];
    
    DLog(@"AGSettingsViewController viewDidUnload");            
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return YES;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    if (isOpenShift)
        return 2;
    
    return AGTableStngsNumSections;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    switch (section) {
        case AGTableStngsSectionOpenShift:
            return nil;
        case AGTableStngsSectionUser:
            return @"User Details";
        case AGTableStngsSectionHost:
            return @"Hostname";            
        default:
            return nil;
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    switch (section) {
        case AGTableStngsSectionOpenShift:
            return AGTableStngSecOpenShiftNumRows;
        case AGTableStngsSectionUser:
            return AGTableStngSecUserNumRows;
        case AGTableStngsSectionHost:
            return AGTableStngSecHostNumRows;
        default:
            return 0;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSUInteger row = [indexPath row];    
    NSUInteger section = [indexPath section];

    id cell;
    
    switch (section) {
        case AGTableStngsSectionOpenShift:
        {
            SwitchCell *switcherCell = [[SwitchCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
            switcherCell.toggler.on = isOpenShift;
            switcherCell.label.text = @"Use OpenShift";
            [switcherCell.toggler addTarget:self action:@selector(toggle:) forControlEvents:UIControlEventValueChanged];
            
            cell = switcherCell;
            break;
        }
        case AGTableStngsSectionUser:
        {
            EditCell *editCell = [[EditCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
            editCell.txtField.autocapitalizationType = UITextAutocapitalizationTypeNone;
            editCell.txtField.autocorrectionType = UITextAutocorrectionTypeNo;
            
            editCell.txtField.delegate = self;
            
            switch (row) {
                case AGTableStngSecUserRowUsername:
                    editCell.txtField.text = self.username;
                    editCell.txtField.placeholder = @"enter username";
                    editCell.txtField.tag = kServerUserRowIndex;

                    break;
                case AGTableStngSecUsersRowPass:
                    editCell.txtField.text = self.password;                    
                    editCell.txtField.placeholder = @"enter password";                    
                    editCell.txtField.secureTextEntry = YES;                    
                    editCell.txtField.tag = kServerPasswdRowIndex;

                    break;
            }
            
            cell = editCell;
            break;
        }
            
        case AGTableStngsSectionHost:
        {
            EditCell *editCell = [[EditCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
            editCell.txtField.text = self.host;
            editCell.txtField.tag = kServerHostRowIndex;            
            editCell.txtField.autocapitalizationType = UITextAutocapitalizationTypeNone;
            editCell.txtField.autocorrectionType = UITextAutocorrectionTypeNo;
            
            editCell.txtField.placeholder = @"http://<your host>";            
            editCell.txtField.delegate = self;            

            cell = editCell;
            break;
        }
    }
    
    return cell;
}

#pragma mark - UITextFieldDelegate methods

- (void)textFieldDidBeginEditing:(UITextField *)textField {
    _textFieldBeingEdited = textField;
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    [self updateModelFromTextField:textField];
    
    [textField resignFirstResponder];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    
    return YES;
}

#pragma mark - Action Methods

- (IBAction)close {
    [self dismissModalViewControllerAnimated:YES];
}

- (IBAction)login {
    if (_textFieldBeingEdited != nil)
        [self updateModelFromTextField:_textFieldBeingEdited];
    
    [delegate settingsEditorViewControllerDelegateDidFinish:self withHostname:self.host 
                                                andUserName:self.username andPassword:self.password
                                                isOpenShift:self.isOpenShift];
}

- (IBAction)toggle:(id)sender {
    UISwitch *toggler = (UISwitch *)sender;
    self.isOpenShift = toggler.on;

    if (!toggler.on)
        self.host = @""; // reset host;
    
    [self.tableView reloadData];
}

# pragma mark - Utility Method
    
- (void) updateModelFromTextField:(UITextField *)textField {
    NSInteger tag = textField.tag;
    
    switch (tag) {
        case kServerUserRowIndex:
            self.username = textField.text;
            break;
        case kServerPasswdRowIndex:
            self.password = textField.text;
            break;
        case kServerHostRowIndex:
            self.host = textField.text;
            break;
    }
}    
@end
