/*
 * JBoss, Home of Professional Open Source.
 * Copyright 2012 Red Hat, Inc., and individual contributors
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

#import "AGProjectsSelectionListViewController.h"
#import "AGMetaEditorViewController.h"

#import "AGTask.h"
#import "AGProject.h"
#import "AGToDoAPIService.h"

#import "AGUIColorConverter.h"

#import "UIActionSheet+BlockExtensions.h"
#import "SVProgressHUD.h"

@implementation AGProjectsSelectionListViewController {
    NSMutableArray *_todoProjects;
    
    NSIndexPath *_currentEditedIndexPath;
    NSIndexPath *_lastSelectedIndexPath;
}

@synthesize task = _task;
@synthesize isEditMode;

#pragma mark - View lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    DLog(@"AGProjectsSelectionListViewController viewDidLoad");    
    
    self.title = @"Select Project";
    

    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Close" 
                                                                              style:UIBarButtonItemStylePlain 
                                                                             target:self
                                                                             action:@selector(close)];

    if (isEditMode) {
        self.navigationItem.rightBarButtonItem = self.editButtonItem;
        self.tableView.allowsSelectionDuringEditing = YES;
    }

    // initialize our "local" model
    _todoProjects = [NSMutableArray arrayWithArray:[[AGToDoAPIService sharedInstance].projects allValues]];    
}

- (void)viewDidUnload {
    [super viewDidUnload];
    
    _todoProjects = nil;
    
    DLog(@"AGProjectsSelectionListViewController viewDidLoad");    
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return YES;
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (self.editing)
        return [_todoProjects count] + 1;
    
    return [_todoProjects count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellProjIdentifier = @"CellProjIdentifier";
    
    NSUInteger row = [indexPath row];

    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier: CellProjIdentifier];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellProjIdentifier];
    }

    cell.editingAccessoryType = UITableViewCellAccessoryDisclosureIndicator;
    
    if (row < [_todoProjects count]) {
        AGProject *proj = [_todoProjects objectAtIndex:row];
        cell.textLabel.text = proj.title;
        cell.textLabel.textColor = [UIColor blackColor];

        // do we need to checkmark?
        if ([self.task.projID isEqualToNumber:proj.recId]) {
            cell.accessoryType = UITableViewCellAccessoryCheckmark;
            
            _lastSelectedIndexPath = [NSIndexPath indexPathForRow:row inSection:0];
            
        } else {
            cell.accessoryType = UITableViewCellAccessoryNone;
        }
    } else {
        cell.textLabel.text = @"Add new Project...";
        cell.accessoryType = UITableViewCellAccessoryNone;        
    }
    
    return cell;
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSUInteger row = [indexPath row];
    
    if (!self.editing) {  // disable swipe if not in edit mode
        return UITableViewCellEditingStyleNone;
    }
        
    if (row < [_todoProjects count])
        return UITableViewCellEditingStyleDelete;
    else
        return UITableViewCellEditingStyleInsert;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    NSUInteger row = [indexPath row];
    
 	if (editingStyle == UITableViewCellEditingStyleDelete) {
        
        AGProject *proj = [_todoProjects objectAtIndex:row];
        
        UIActionSheet *yesno = [[UIActionSheet alloc]
                                initWithTitle:@"Are you sure you want to delete it?"
                                completionBlock:^(NSUInteger buttonIndex, UIActionSheet *actionSheet) {
                                    if (buttonIndex == 0) { // Yes proceed
                                        
                                        [SVProgressHUD showWithMaskType:SVProgressHUDMaskTypeGradient];
                                        
                                        [[AGToDoAPIService sharedInstance] removeProject:proj success:^{
                                            [SVProgressHUD showSuccessWithStatus:@"Successfully deleted!"];
                                            
                                            // if the task was associated with the deleted project, remove it
                                            if ([self.task.projID isEqualToNumber:proj.recId]) 
                                                self.task.projID = nil;
                                            
                                            // reset the "selection"
                                            if (_lastSelectedIndexPath.row == indexPath.row)
                                                _lastSelectedIndexPath = nil;
                                            
                                            // update "local" model
                                            [_todoProjects removeObjectAtIndex:row];
                                            
                                            // refresh table view
                                            NSArray *paths = [NSArray arrayWithObject: [NSIndexPath indexPathForRow:row inSection:0]];
                                            [[self tableView] deleteRowsAtIndexPaths:paths withRowAnimation:UITableViewRowAnimationTop];                                    
                                            
                                        } failure:^(NSError *error) {
                                            [SVProgressHUD dismiss];        
                                            
                                            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Oops!"
                                                                                            message:[error localizedDescription]
                                                                                           delegate:nil 
                                                                                  cancelButtonTitle:@"Bummer"
                                                                                  otherButtonTitles:nil];
                                            [alert show];
                                            
                                        }];
                                    }
                                }
                                
                                cancelButtonTitle:@"Cancel"
                                destructiveButtonTitle: @"Yes"
                                otherButtonTitles:nil];
        
        [yesno showInView:self.navigationController.toolbar];
   	}  
}

- (void)setEditing:(BOOL)editing animated:(BOOL)animated {
    [super setEditing:editing animated:animated];
    [self.tableView setEditing:editing animated:animated];
    
    NSArray *paths = [NSArray arrayWithObject: [NSIndexPath indexPathForRow:[_todoProjects count] inSection:0]];
    
    if (self.editing) {
        [[self tableView] insertRowsAtIndexPaths:paths
                                withRowAnimation:UITableViewRowAnimationLeft];
    } else {
        [[self tableView] deleteRowsAtIndexPaths:paths
                                withRowAnimation:UITableViewRowAnimationLeft];
    }
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSUInteger row = [indexPath row];

    AGProject *proj;

    if (row < [_todoProjects count])
        proj = [_todoProjects objectAtIndex:row];

    if (self.editing) {
        AGMetaEditorViewController *metaController = [[AGMetaEditorViewController alloc] initWithStyle:UITableViewStyleGrouped];
        metaController.title =@"Edit Project";
        metaController.delegate = self;

        if (proj != nil) {
            metaController.name = proj.title;
            metaController.color = [AGUIColorConverter getAsObject:proj.style];
            
            _currentEditedIndexPath = indexPath;
        }
        
        [self.navigationController pushViewController:metaController animated:YES];

    } else {
        int newRow = [indexPath row];
        int oldRow = (_lastSelectedIndexPath != nil) ? [_lastSelectedIndexPath row] : -1;
        
        if (newRow != oldRow) {
            UITableViewCell *newCell = [tableView cellForRowAtIndexPath:indexPath];
            newCell.accessoryType = UITableViewCellAccessoryCheckmark;
            self.task.projID = proj.recId;
            
            UITableViewCell *oldCell = [tableView cellForRowAtIndexPath:_lastSelectedIndexPath];
            oldCell.accessoryType = UITableViewCellAccessoryNone;
         
            _lastSelectedIndexPath = indexPath;
        } else {
            UITableViewCell *newCell = [tableView cellForRowAtIndexPath:indexPath];
            newCell.accessoryType = UITableViewCellAccessoryNone;
            self.task.projID = nil;
            _lastSelectedIndexPath = nil;
        }
        
        [tableView deselectRowAtIndexPath:indexPath animated:YES];        
    }
}

#pragma mark - Action Methods

- (IBAction)close {
    [self dismissModalViewControllerAnimated:YES];
}

- (void)metaEditorViewControllerDelegateDidFinish:(AGMetaEditorViewController *)controller withTitle:(NSString *)name andColor:(UIColor *)color {
    if (name == nil || [name isEqualToString:@""]) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Oops!"
                                                        message:@"Please enter a \"Title\" for the Project!"
                                                       delegate:nil 
                                              cancelButtonTitle:@"Bummer"
                                              otherButtonTitles:nil];
        [alert show];
        return;
    }
    
    [SVProgressHUD showWithMaskType:SVProgressHUDMaskTypeGradient];
    
    AGProject *proj;
    
    if (_currentEditedIndexPath == nil) { // is it a new Project ?
        proj = [[AGProject alloc] init];
    } else {
        proj = [_todoProjects objectAtIndex:[_currentEditedIndexPath row]];
    }

    proj.title = name;
    proj.style = [AGUIColorConverter getAsString:color];
    
    // save or update Project on server
    [[AGToDoAPIService sharedInstance] postProject:proj success:^{
        [SVProgressHUD showSuccessWithStatus:@"Successfully saved!"];
        
        // if new project add it to our "local" model
        if (_currentEditedIndexPath == nil) {
            [_todoProjects addObject:proj];
        } else {
            _currentEditedIndexPath = nil; // reset it
        }
        
        [self.tableView reloadData];
        [self.navigationController popViewControllerAnimated:YES];

    } failure:^(NSError *error) {
        [SVProgressHUD dismiss];        
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Oops!"
                                                        message:@"An error has occured during save!"
                                                       delegate:nil 
                                              cancelButtonTitle:@"Bummer"
                                              otherButtonTitles:nil];
        [alert show];       
    }];    
}

# pragma mark - PullToRefresh action

- (void)refresh {
    [[AGToDoAPIService sharedInstance]refreshProjects:^{
        
        _todoProjects = [NSMutableArray arrayWithArray:[[AGToDoAPIService sharedInstance].projects allValues]];
        
        [self.tableView reloadData];
    
        [self stopLoading];
      
    } failure:^(NSError *error) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Oops!"
                                                        message:@"An error has occured during refresh!"
                                                       delegate:nil 
                                              cancelButtonTitle:@"Bummer"
                                              otherButtonTitles:nil];
        [alert show];        
    }];
}

@end
