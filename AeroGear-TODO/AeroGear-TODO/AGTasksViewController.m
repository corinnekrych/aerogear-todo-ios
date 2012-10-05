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

#import "AGTasksViewController.h"

#import "AGToDoAPIService.h"
#import "AGTask.h"

#import "UIActionSheet+BlockExtensions.h"
#import "SVProgressHUD.h"

@implementation AGTasksViewController {
    NSMutableArray *_tasks;
}

#pragma mark - View lifecycle

- (void)viewDidUnload {
    [super viewDidUnload];
    
    DLog(@"AGTasksViewController viewDidUnLoad");
    
    _tasks = nil;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    DLog(@"AGTasksViewController viewDidLoad");
    
    self.title = @"Tasks";
	
    // set up toolbar items
    self.navigationItem.leftBarButtonItem = self.editButtonItem;
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd
                                                                                           target:self 
                                                                                           action:@selector(addTask)];
    
    // used to fill up space left and right
    UIBarButtonItem *flexibleSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace
                                                                                   target:nil 
                                                                                   action:nil];
    
    UIBarButtonItem *filterProjectsButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"projects.png"] 
                                                                             style:UIBarButtonItemStylePlain
                                                                            target:self
                                                                            action:@selector(filterByProject)];
    UIBarButtonItem *filterTagsButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"tags.png"] 
                                                                         style:UIBarButtonItemStylePlain
                                                                         target:self 
                                                                        action:@selector(filterByTag)];
    
    UIButton *info = [UIButton buttonWithType:UIButtonTypeInfoLight];
    UIBarButtonItem *infoButton = [[UIBarButtonItem alloc] initWithImage:info.currentImage style:UIBarButtonItemStylePlain target:self action:@selector(displayInfo)];
    
    self.toolbarItems = [NSArray arrayWithObjects:flexibleSpace, filterProjectsButton, filterTagsButton, flexibleSpace, infoButton, nil];
    
    [SVProgressHUD showWithMaskType:SVProgressHUDMaskTypeGradient];
    [AGToDoAPIService initSharedInstanceWithBaseURL:nil success:^{
        [SVProgressHUD dismiss];
    } failure:^(NSError *error) {
        [SVProgressHUD dismiss];        
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Oops!"
                                                        message:[error localizedDescription]
                                                       delegate:nil 
                                              cancelButtonTitle:@"Bummer"
                                              otherButtonTitles:nil];
        [alert show];       

    }];
     
    [self refresh];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return YES;
}

#pragma mark - Table Data Source Methods

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [_tasks count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *SimpleTableIdentifier = @"SimpleTableCellIdentifier";
    
    NSUInteger row = [indexPath row];
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier: SimpleTableIdentifier];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:SimpleTableIdentifier];
    }
    
    AGTask *task = [_tasks objectAtIndex:row];
    
    cell.textLabel.text = task.title;
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    
    return cell;
}

#pragma mark - Table Delegate Methods

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSUInteger row = [indexPath row];
    
    AGTask *task = [_tasks objectAtIndex:row];
    
    AGTaskViewController *taskController = [[AGTaskViewController alloc] initWithStyle:UITableViewStyleGrouped];
    taskController.delegate = self;
    taskController.task = task;
    taskController.hidesBottomBarWhenPushed = YES;
    
	[self.navigationController pushViewController:taskController animated:YES];    
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    NSUInteger row = [indexPath row];
    
    AGTask *task = [_tasks objectAtIndex:row];
    
	if (editingStyle == UITableViewCellEditingStyleDelete) {
        UIActionSheet *yesno = [[UIActionSheet alloc]
                                initWithTitle:@"Are you sure you want to delete it?"
                                completionBlock:^(NSUInteger buttonIndex, UIActionSheet *actionSheet) {
                                    if (buttonIndex == 0) { // Yes proceed
                                        
                                        [SVProgressHUD showWithMaskType:SVProgressHUDMaskTypeGradient];

                                        [[AGToDoAPIService sharedInstance] removeTask:task success:^{
                                            [SVProgressHUD showSuccessWithStatus:@"Successfully deleted!"];
                                            
                                            [_tasks removeObjectAtIndex:row];
                                            
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


#pragma mark - Action Methods
- (IBAction)addTask {
	AGTaskViewController *taskController = [[AGTaskViewController alloc] initWithStyle:UITableViewStyleGrouped];
    taskController.delegate = self;
    taskController.hidesBottomBarWhenPushed = YES;
    
    [self.navigationController pushViewController:taskController animated:YES];        
}

- (IBAction)filterByProject {
    // TODO
}

- (IBAction)filterByTag {
    // TODO
}

- (IBAction)displayInfo {
    // TODO
}

#pragma mark - AGTaskViewController delegate methods

- (void)taskViewControllerDelegateDidFinish:(AGTaskViewController *)controller task:(AGTask *)task {
    if (task.title == nil   || [task.title isEqualToString:@""] 
     || task.dueDate == nil || [task.dueDate isEqualToString:@""]) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Oops!"
                                                        message:@"At least \"Title\" and \"Due Date\" must be completed!"
                                                       delegate:nil 
                                              cancelButtonTitle:@"Bummer"
                                              otherButtonTitles:nil];
        [alert show];
        return;
    }
        
    [SVProgressHUD showWithMaskType:SVProgressHUDMaskTypeGradient];

    BOOL isNewTask = (task.recId == nil? YES: NO);
    
    // save or update Task on server
    [[AGToDoAPIService sharedInstance] postTask:task success:^{
        [SVProgressHUD showSuccessWithStatus:@"Successfully saved!"];

        if (isNewTask) { 
            [_tasks addObject:task]; // add it to the list
        } else { // otherwise update existing one with the new values
            AGTask *editedTask = controller.task;
            [editedTask copyFrom:task];
        }

        [self.navigationController popViewControllerAnimated:YES];
        
        [self.tableView reloadData];

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
    [[AGToDoAPIService sharedInstance] fetchTasks:^(NSMutableArray *tasks) {
        _tasks = tasks;
        
        [self.tableView reloadData];

        [self stopLoading];        
        
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
@end
