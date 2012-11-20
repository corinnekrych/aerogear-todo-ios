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

#import "AGTagsSelectionListViewController.h"
#import "AGMetaEditorViewController.h"

#import "AGTask.h"
#import "AGTag.h"
#import "AGToDoAPIService.h"

#import "AGUIColorConverter.h"

#import "UIActionSheet+BlockExtensions.h"
#import "SVProgressHUD.h"

@implementation AGTagsSelectionListViewController {
    NSMutableArray *_todoTags;
    
    NSIndexPath *_currentEditedIndexPath;
}

@synthesize task = _task;
@synthesize isEditMode;

#pragma mark - View lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    DLog(@"AGTagsSelectionListViewController viewDidLoad");    
    
    self.title = @"Select Tag";
    

    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Close" 
                                                                              style:UIBarButtonItemStylePlain 
                                                                             target:self
                                                                             action:@selector(close)];
    if (isEditMode) {
        self.navigationItem.rightBarButtonItem = self.editButtonItem;
        self.tableView.allowsSelectionDuringEditing = YES;
    }

     // initialize our "local" model
    _todoTags = [NSMutableArray arrayWithArray:[[AGToDoAPIService sharedInstance].tags allValues]];    
}

- (void)viewDidUnload {
    [super viewDidUnload];
    
    _todoTags = nil;
    
    DLog(@"AGTagsSelectionListViewController viewDidLoad");    
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return YES;
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (self.editing)
        return [_todoTags count] + 1;
    
    return [_todoTags count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellTagIdentifier = @"CellTagIdentifier";
    
    NSUInteger row = [indexPath row];
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier: CellTagIdentifier];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellTagIdentifier];
    }
    
    cell.editingAccessoryType = UITableViewCellAccessoryDisclosureIndicator;
    
    if (row < [_todoTags count]) {
        AGTag *tag = [_todoTags objectAtIndex:row];
        cell.textLabel.text = tag.title;
        cell.textLabel.textColor = [UIColor blackColor];

        // do we need to checkmark?
        if ([self.task.tags containsObject:tag.recId]) {
            cell.accessoryType = UITableViewCellAccessoryCheckmark;
        } else {
            cell.accessoryType = UITableViewCellAccessoryNone;
        }
    } else {
        cell.textLabel.text = @"Add new Tag...";
        cell.accessoryType = UITableViewCellAccessoryNone;        
    }
    
    return cell;
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSUInteger row = [indexPath row];
    
    if (row < [_todoTags count])
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
        
        AGTag *tag = [_todoTags objectAtIndex:row];
        
        UIActionSheet *yesno = [[UIActionSheet alloc]
                                initWithTitle:@"Are you sure you want to delete it?"
                                completionBlock:^(NSUInteger buttonIndex, UIActionSheet *actionSheet) {
                                    if (buttonIndex == 0) { // Yes proceed
                                        
                                        [SVProgressHUD showWithMaskType:SVProgressHUDMaskTypeGradient];
                                        
                                        [[AGToDoAPIService sharedInstance] removeTag:tag success:^{
                                            [SVProgressHUD showSuccessWithStatus:@"Successfully deleted!"];
                                            
                                            // if the task was associated with the deleted tag, remove it
                                            [self.task.tags removeObject:tag.recId];
                                            
                                            // update "local" model
                                            [_todoTags removeObjectAtIndex:row];
                                            
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
    
    NSArray *paths = [NSArray arrayWithObject: [NSIndexPath indexPathForRow:[_todoTags count] inSection:0]];
    
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

    AGTag *tag;

    if (row < [_todoTags count])
        tag = [_todoTags objectAtIndex:row];

    if (self.editing) {
        AGMetaEditorViewController *metaController = [[AGMetaEditorViewController alloc] initWithStyle:UITableViewStyleGrouped];
        metaController.title =@"Edit Tag";
        metaController.delegate = self;

        if (tag != nil) {
            metaController.name = tag.title;
            metaController.color = [AGUIColorConverter getAsObject:tag.style];
            
            _currentEditedIndexPath = indexPath;            
        }
        
        [self.navigationController pushViewController:metaController animated:YES];


    } else {
        UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];

        if (cell.accessoryType == UITableViewCellAccessoryCheckmark) {
            [self.task.tags removeObject:tag.recId];
            cell.accessoryType = UITableViewCellAccessoryNone;
        } else {
            [self.task.tags addObject:tag.recId];
            cell.accessoryType = UITableViewCellAccessoryCheckmark;
        }
    }
}

#pragma mark - Action Methods

- (IBAction)close {
    [self dismissModalViewControllerAnimated:YES];
}

- (void)metaEditorViewControllerDelegateDidFinish:(AGMetaEditorViewController *)controller withTitle:(NSString *)name andColor:(UIColor *)color {
    if (name == nil || [name isEqualToString:@""]) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Oops!"
                                                        message:@"Please enter a \"Title\" for the tag!"
                                                       delegate:nil 
                                              cancelButtonTitle:@"Bummer"
                                              otherButtonTitles:nil];
        [alert show];
        return;
    }
    
    [SVProgressHUD showWithMaskType:SVProgressHUDMaskTypeGradient];
    
    AGTag *tag;
    
    if (_currentEditedIndexPath == nil) { // is it a new Tag ?
        tag = [[AGTag alloc] init];
    } else {
        tag = [_todoTags objectAtIndex:[_currentEditedIndexPath row]];
    }

    tag.title = name;
    tag.style = [AGUIColorConverter getAsString:color];
    
    // save or update Tag on server
    [[AGToDoAPIService sharedInstance] postTag:tag success:^{
        [SVProgressHUD showSuccessWithStatus:@"Successfully saved!"];
        
         // if new tag add it to our "local" model
        if (_currentEditedIndexPath == nil) {
            [_todoTags addObject:tag];
        } else {
            _currentEditedIndexPath = nil;
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
    [[AGToDoAPIService sharedInstance]refreshTags:^{
        _todoTags = [NSMutableArray arrayWithArray:[[AGToDoAPIService sharedInstance].tags allValues]];
        
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
