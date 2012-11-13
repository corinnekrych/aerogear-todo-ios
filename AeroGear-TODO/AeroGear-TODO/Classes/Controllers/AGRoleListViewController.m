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

#import "AGRoleListViewController.h"

@implementation AGRoleListViewController {
    NSArray *_list;

    NSIndexPath *_currentEditedIndexPath;
    NSIndexPath *_lastSelectedIndexPath;
}

@synthesize delegate;
@synthesize selectedRole;

#pragma mark - View lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];

    self.title = @"Select Role";

    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Done"
                                                                              style:UIBarButtonItemStyleDone
                                                                             target:self
                                                                             action:@selector(save)];

    _list = [[NSArray alloc] initWithObjects:@"simple", @"admin", nil];
    
    DLog(@"AGRoleListViewController viewDidLoad");
}

- (void)viewDidUnload {
    [super viewDidUnload];
    _list = nil;

    DLog(@"AGRoleListViewController viewDidUnLoad");
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [_list count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"CellIdentifier";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    NSUInteger row = [indexPath row];
    
    NSString *role = [_list objectAtIndex:row];

    cell.textLabel.text = role;
    
    if ([selectedRole isEqualToString:role]) {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
        _lastSelectedIndexPath = indexPath;
    } else {
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    
    return cell;
}

#pragma mark - Table Delegate Methods

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    int newRow = [indexPath row];
    int oldRow = (_lastSelectedIndexPath != nil) ? [_lastSelectedIndexPath row] : -1;
    
    if (newRow != oldRow) {
        UITableViewCell *newCell = [tableView cellForRowAtIndexPath: indexPath];
        newCell.accessoryType = UITableViewCellAccessoryCheckmark;
        
        UITableViewCell *oldCell = [tableView cellForRowAtIndexPath:_lastSelectedIndexPath];
        oldCell.accessoryType = UITableViewCellAccessoryNone;

        _lastSelectedIndexPath = indexPath;
        self.selectedRole = [_list objectAtIndex:newRow];
    }
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark - Action Methods

- (IBAction)close {
    [self dismissModalViewControllerAnimated:YES];
}

- (IBAction)save {
    [delegate roleListViewControllerDelegateDidFinish:self withRole:selectedRole];
}

@end
