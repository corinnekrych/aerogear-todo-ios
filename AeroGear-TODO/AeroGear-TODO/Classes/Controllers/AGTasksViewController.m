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

#import "AGTasksViewController.h"

#import "AGProjectsSelectionListViewController.h"
#import "AGTagsSelectionListViewController.h"
#import "AGAboutViewController.h"

#import "AGRegisterUserViewController.h"

#import "AGToDoAPIService.h"
#import "AGTask.h"
#import "AGProject.h"
#import "AGTag.h"

#import "UIActionSheet+BlockExtensions.h"
#import "SVProgressHUD.h"

@implementation AGTasksViewController {
    NSMutableArray *_allTasks;  // all tasks "unfiltered"
    
    AGTask *_filterTask;

    // the server that we are currently connected
    NSString *_host;
    NSString *_username;
    NSString *_password;
    BOOL _useOpenShift;
}

#pragma mark - View lifecycle

- (void)viewDidUnload {
    [super viewDidUnload];
    
    DLog(@"AGTasksViewController viewDidUnLoad");
    
    _allTasks = nil;
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
    
    UIBarButtonItem *settingsButton = [[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@"logout.png"] 
                                                                      style:UIBarButtonItemStylePlain
                                                                     target:self
                                                                     action:@selector(logout)];

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
    UIBarButtonItem *infoButton = [[UIBarButtonItem alloc] initWithImage:info.currentImage
                                                                   style:UIBarButtonItemStylePlain 
                                                                  target:self 
                                                                  action:@selector(displayInfo)];
    
    self.toolbarItems = [NSArray arrayWithObjects:settingsButton, flexibleSpace,
                         filterProjectsButton, filterTagsButton,
                         flexibleSpace, infoButton, nil];
    
    // setup a "dummy" task that will be used for filtering
    _filterTask = [[AGTask alloc] init];
    
    // initialize with an empty section
    self.tableViewData = [[ARTableViewData alloc] initWithSectionDataArray:@[[[ARSectionData alloc] init]]];
    
    // since we are not using Interface Builder
    // we need to register the cell using ARGenericTableViewController
    [self registerClass:[UITableViewCell class] forCellReuseIdentifier:NSStringFromClass([UITableViewCell class])];
    
    // retrieve Tasks
    [SVProgressHUD showWithMaskType:SVProgressHUDMaskTypeGradient];
       
    [self refresh];    
}


- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

    self.navigationController.toolbar.hidden = NO;
    
    // give filter a chance to kick in
    //[self handleFilter];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return YES;
}

#pragma mark - Action Methods
- (IBAction)addTask {
	AGTaskViewController *taskController = [[AGTaskViewController alloc] initWithStyle:UITableViewStyleGrouped];
    taskController.delegate = self;
    taskController.hidesBottomBarWhenPushed = YES;
    
    [self.navigationController pushViewController:taskController animated:YES];        
}

- (IBAction)filterByProject {
    AGProjectsSelectionListViewController *projListController = [[AGProjectsSelectionListViewController alloc] initWithStyle:UITableViewStyleGrouped];
    projListController.task = _filterTask;
    
    UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:projListController];
    
    [self presentModalViewController:navController animated:YES];

}

- (IBAction)filterByTag {
    AGTagsSelectionListViewController *tagsListController = [[AGTagsSelectionListViewController alloc] initWithStyle:UITableViewStyleGrouped];
    tagsListController.task = _filterTask;

    UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:tagsListController];
    
    [self presentModalViewController:navController animated:YES];
}

- (IBAction)displayInfo {
    AGAboutViewController *aboutController = [[AGAboutViewController alloc] init];  
    
    UIViewAnimationTransition trans = UIViewAnimationTransitionFlipFromRight;
    [UIView beginAnimations: nil context: nil];
    [UIView setAnimationDuration:0.8];
    [UIView setAnimationTransition: trans forView: [self.view window] cache: NO];
    
    self.navigationController.toolbar.hidden = YES;
    [self.navigationController pushViewController:aboutController animated: NO];

    [UIView commitAnimations];
}

- (IBAction)logout {
    [SVProgressHUD showWithStatus:@"Logging you out..." maskType:SVProgressHUDMaskTypeGradient];
    
    [[AGToDoAPIService sharedInstance] logout:^{
        [SVProgressHUD dismiss];
        
        [self dismissModalViewControllerAnimated:YES];
        
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
            [[self.tableViewData sectionDataForSection:0] addCellData:[self cellDataForTask:task]];
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
        [SVProgressHUD dismiss];
        
        _allTasks = tasks;
        
        for (AGTask* task in tasks) {
            [[self.tableViewData sectionDataForSection:0] addCellData:[self cellDataForTask:task]];
        }

        //[self.pullRefreshTableViewController stopLoading];
        
        //[self handleFilter];
        
        [self.tableView reloadData];

    } failure:^(NSError *error) {
        [SVProgressHUD dismiss];
        
        [self.pullRefreshTableViewController stopLoading];
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Oops!"
                                                        message:[error localizedDescription]
                                                       delegate:nil 
                                              cancelButtonTitle:@"Bummer"
                                              otherButtonTitles:nil];
        [alert show];
        
    }];
}

- (ARCellData*)cellDataForTask:(AGTask *)task {

    ARCellData *cellData = [[ARCellData alloc] initWithIdentifier:NSStringFromClass([UITableViewCell class])];

    [cellData setEditable:YES];
    
    [cellData setCellDeleteBlock:^(UITableView *tableView, NSIndexPath *indexPath) {
        UIActionSheet *yesno = [[UIActionSheet alloc]
                                initWithTitle:@"Are you sure you want to delete it?"
                                completionBlock:^(NSUInteger buttonIndex, UIActionSheet *actionSheet) {
                                    if (buttonIndex == 0) { // Yes proceed
                                        
                                        [SVProgressHUD showWithMaskType:SVProgressHUDMaskTypeGradient];
                                        
                                        [[AGToDoAPIService sharedInstance] removeTask:task success:^{
                                            [SVProgressHUD showSuccessWithStatus:@"Successfully deleted!"];
                                            
                                            [_allTasks removeObject:task];
                                            // TODO: [_tasks removeObject:task];
                                            
                                            [self.tableViewData removeCellDataAtIndexPath:indexPath];
                                            
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
        //}
        
    }];
    
    [cellData setCellConfigurationBlock:^(UITableViewCell *cell) {
        cell.textLabel.text = task.title;
    }];
    
    [cellData setCellSelectionBlock:^(UITableView *tableView, NSIndexPath *indexPath) {
        AGTaskViewController *taskController = [[AGTaskViewController alloc] initWithStyle:UITableViewStyleGrouped];
        taskController.task = task;
        
        UIViewAnimationTransition trans = UIViewAnimationTransitionFlipFromRight;
        [UIView beginAnimations: nil context: nil];
        [UIView setAnimationDuration:0.4];
        [UIView setAnimationTransition: trans forView: [self.view window] cache: NO];
        
        [self.navigationController pushViewController:taskController animated:NO];
        
        [UIView commitAnimations];
        
    }];
    
    return cellData;
}

// since ARGenericTableViewController by default removes the cell
// in its commitEditingStyle, we override the behaviour to let
// the block decide whether to delete or not
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        ARCellData *cellData = [self.tableViewData cellDataAtIndexPath:indexPath];
        
        if (cellData.cellDeleteBlock) {
            cellData.cellDeleteBlock(tableView,indexPath);
        }
    }
}

# pragma mark - Filter

/*
- (void)handleFilter {
    if (_allTasks == nil) // remote data not yet fetched, nothing to do
        return;
    
    // reset filtering
    _tasks = [NSMutableArray arrayWithArray:_allTasks];

    BOOL hasProjectFilter = _filterTask.projID != nil;
    BOOL hasTagsFilter = [_filterTask.tags count] != 0;
    
    if (hasProjectFilter || hasTagsFilter) {
        NSMutableArray *toRemove;
        
        if (hasProjectFilter) {
            toRemove =  [[NSMutableArray alloc] init];            
            
            for (AGTask *task in _tasks) {
                if (hasProjectFilter && ![task.projID isEqualToNumber:_filterTask.projID]) {
                    [toRemove addObject:task];
                }
            }

            [_tasks removeObjectsInArray:toRemove];
        }
        
        if (hasTagsFilter) {
            toRemove =  [[NSMutableArray alloc] init];            
            
            for (AGTask *task in _tasks) {
                NSMutableArray *tmpFilteredTags = [NSMutableArray arrayWithArray:_filterTask.tags];
                
                [tmpFilteredTags removeObjectsInArray:task.tags];
                if ([tmpFilteredTags count] != 0) {
                    [toRemove addObject:task];
                }
            }
            
           [_tasks removeObjectsInArray:toRemove];          
        }

        // setup table header;
        UILabel *labelView = [[UILabel alloc] initWithFrame:CGRectMake(16, 0, 100, 25)];
        labelView.backgroundColor = [UIColor lightGrayColor];
        labelView.font = [UIFont boldSystemFontOfSize:14.0];
        labelView.textColor = [UIColor whiteColor];
        // setup header title
        NSMutableString *txtFilter = [NSMutableString string];
        if (hasProjectFilter) {
            
            AGProject *project = [[AGToDoAPIService sharedInstance].projects objectForKey:_filterTask.projID];
            [txtFilter appendFormat:@"Project: %@ ", project.title];
        }
        
        if (hasTagsFilter) {
            [txtFilter appendString:@"Tags: "];
            
            NSMutableArray *tagTitles = [[NSMutableArray alloc]init];

            for (NSNumber *tagId in _filterTask.tags) {
                AGTag *tag = [[AGToDoAPIService sharedInstance].tags objectForKey:tagId];
                [tagTitles addObject:tag.title];
            }
            
            [txtFilter appendString:[tagTitles componentsJoinedByString:@", "]];
        }
        
        labelView.text = txtFilter;

        self.tableView.tableHeaderView = labelView;
        
    } else {
        self.tableView.tableHeaderView = nil;
    }
    
    [self.tableView reloadData];
}
*/
@end
