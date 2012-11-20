/*
 * JBoss, Home of Professional Open Source.
 * Copyright 2012 Red Hat, Inc., and individual contributors
 * as indicated by the @author tags.
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

#import "AGRegisterUserViewController.h"

#import "AGToDoAPIService.h"

#import "LabelEditCell.h"

#import "SVProgressHUD.h"

// Table Sections
enum AGTableSections {
    AGTableSectionMain = 0,
    AGTableSectionRole,
    AGTableNumSections
};

// Table Rows
enum AGMainRows {
    AGTableSecMainRowFirst = 0,
    AGTableSecMainRowLast,
    AGTableSecMainRowEmail,
    AGTableSecMainRowUsername,
    AGTableSecMainRowPassword,
    AGTableSecMainNumRows
};

enum AGRoleRows {
    AGTableSecRoleRow = 0,
    AGTableSecRoleNumRows
};

@implementation AGRegisterUserViewController {
    
    NSMutableDictionary *_userInfo;
    
    UITextField *_textFieldBeingEdited;
}

@synthesize delegate;

- (void)viewDidUnload {
    [super viewDidUnload];
    
    DLog(@"AGRegisterUserViewController viewDidUnLoad");
}

- (void)viewDidLoad {
    [super viewDidLoad];

    self.title = @"Register User";
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Close"
                                                                             style:UIBarButtonItemStylePlain
                                                                            target:self
                                                                            action:@selector(close)];

    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Save"
                                                                              style:UIBarButtonItemStyleDone
                                                                             target:self
                                                                             action:@selector(save)];

    _userInfo = [[NSMutableDictionary alloc] init];
    
    DLog(@"AGRegisterUserViewController viewDidLoad");
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return AGTableNumSections;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    switch (section) {
        case AGTableSectionRole:
            return @"Role";
        default:
            return nil;
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    switch (section) {
        case AGTableSectionMain:
            return AGTableSecMainNumRows;
        case AGTableSectionRole:
            return AGTableSecRoleNumRows;
        default:
            return 0;
    }

}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSUInteger section = [indexPath section];
    NSUInteger row = [indexPath row];
    
    UITableViewCell *cell;
    
    switch (section) {
        case AGTableSectionMain:
        {
            LabelEditCell *editCell = [[LabelEditCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
            editCell.label.textColor = [UIColor colorWithRed:.318 green:0.4 blue:.569 alpha:7.0];
            editCell.txtField.autocapitalizationType = UITextAutocapitalizationTypeNone;
            editCell.txtField.autocorrectionType = UITextAutocorrectionTypeNo;
            editCell.txtField.delegate = self;
            
            switch (row) {
                case AGTableSecMainRowFirst:
                {
                    editCell.label.text = @"First Name";
                    editCell.txtField.text = [_userInfo objectForKey:@"firstname"];
                    editCell.txtField.tag = kUserFirst;
                    break;
                }
                case AGTableSecMainRowLast:
                {
                    editCell.label.text = @"Last Name";
                    editCell.txtField.text = [_userInfo objectForKey:@"lastname"];
                    editCell.txtField.tag = kUserLast;
                    break;
                }
                case AGTableSecMainRowEmail:
                {
                    editCell.label.text = @"Email";
                    editCell.txtField.text = [_userInfo objectForKey:@"email"];
                    editCell.txtField.tag = kUserEmail;
                    break;
                }
                case AGTableSecMainRowUsername:
                {
                    editCell.label.text = @"Username";
                    editCell.txtField.text = [_userInfo objectForKey:@"username"];
                    editCell.txtField.tag = kUserUsername;
                    break;
                }
                case AGTableSecMainRowPassword:
                {
                    editCell.label.text = @"Password";
                    editCell.txtField.secureTextEntry = YES;
                    editCell.txtField.text = [_userInfo objectForKey:@"password"];
                    editCell.txtField.tag = kUserPasswd;
                    break;
                }
            }
            
            cell = editCell;
            break;
        }
        case AGTableSectionRole:
        {
            UITableViewCell *selCell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
            selCell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            
            selCell.textLabel.text = [_userInfo objectForKey:@"role"];
            
            cell = selCell;
            break;
        }
    }
    
    return cell;
}

#pragma mark - Table Delegate Methods

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSUInteger section = [indexPath section];

    switch (section) {
        case AGTableSectionRole:
        {
            AGRoleListViewController *roleListController = [[AGRoleListViewController alloc]
                                                            initWithStyle:UITableViewStyleGrouped];

            roleListController.selectedRole = [_userInfo objectForKey:@"role"];
            roleListController.delegate = self;
            
            [self.navigationController pushViewController:roleListController animated:YES];
            
            break;
        }
    }
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

# pragma mark - Utility Method

- (void)updateModelFromTextField:(UITextField *)textField {
    NSInteger tag = textField.tag;
    
    switch (tag) {
        case kUserFirst:
            [_userInfo setObject:textField.text forKey:@"firstname"];
            break;
        case kUserLast:
            [_userInfo setObject:textField.text forKey:@"lastname"];
            break;
        case kUserEmail:
            [_userInfo setObject:textField.text forKey:@"email"];
            break;
        case kUserUsername:
            [_userInfo setObject:textField.text forKey:@"username"];
            break;
        case kUserPasswd:
            [_userInfo setObject:textField.text forKey:@"password"];
            break;
    }
}

#pragma mark - Action Methods

- (IBAction)close {
    [self dismissModalViewControllerAnimated:YES];
}

- (IBAction)save {
    // check for non completed fields
    if (   [_userInfo objectForKey:@"firstname"] == nil
        || [_userInfo objectForKey:@"lastname"] == nil
        || [_userInfo objectForKey:@"email"] == nil
        || [_userInfo objectForKey:@"username"] == nil
        || [_userInfo objectForKey:@"password"] == nil
        || [_userInfo objectForKey:@"role"] == nil ) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Oops!"
                                                        message:@"All fields must be competed prior to registration!"
                                                       delegate:nil
                                              cancelButtonTitle:@"Bummer"
                                              otherButtonTitles:nil];
        
        [alert show];
        return;
    }
    
    [SVProgressHUD showWithMaskType:SVProgressHUDMaskTypeGradient];

    [AGToDoAPIService enrollUser:_userInfo success:^{
        [SVProgressHUD showSuccessWithStatus:@"Successfully registered!"];
        
        [delegate registerUserViewControllerDelegateDidFinish:self withUserInfo:_userInfo];
        
    } failure:^(NSError *error) {
        [SVProgressHUD dismiss];
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Oops!"
                                                        message:@"An error has occured during register!"
                                                       delegate:nil
                                              cancelButtonTitle:@"Bummer"
                                              otherButtonTitles:nil];
        [alert show];
    }];
}

#pragma mark - AGRoleListViewControllerDelegate delegate

- (void)roleListViewControllerDelegateDidFinish:(AGRoleListViewController *)controller withRole:(NSString *)therole {
    [_userInfo setObject:therole forKey:@"role"];
    
    [self.navigationController popViewControllerAnimated:YES];
    
    [self.tableView reloadData];
}

@end