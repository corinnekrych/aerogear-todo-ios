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

#import <UIKit/UIKit.h>

#import "DateSelectionCell.h"

@protocol AGTaskViewControllerDelegate;

@class AGTask;

@interface AGTaskViewController : UITableViewController <UITextFieldDelegate, UITextViewDelegate, DateSelectionCellDelegate>

@property(strong, nonatomic) AGTask *task;

@property (weak, nonatomic) id <AGTaskViewControllerDelegate> delegate;

@end

@protocol AGTaskViewControllerDelegate <NSObject>
- (void)taskViewControllerDelegateDidFinish:(AGTaskViewController *)controller task:(AGTask *)task;
@end
