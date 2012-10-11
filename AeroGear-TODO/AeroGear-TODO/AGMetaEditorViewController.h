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

#import <UIKit/UIKit.h>

#import "HRColorPickerViewController.h"

@protocol AGMetaEditorViewControllerDelegate;

@interface AGMetaEditorViewController : UITableViewController <UITextFieldDelegate, HRColorPickerViewControllerDelegate>

@property(copy, nonatomic) NSString *name;
@property(strong, nonatomic) UIColor *color;

@property (weak, nonatomic) id <AGMetaEditorViewControllerDelegate> delegate;

@end

@protocol AGMetaEditorViewControllerDelegate <NSObject>
- (void)metaEditorViewControllerDelegateDidFinish:(AGMetaEditorViewController *)controller withTitle:(NSString *)name andColor:(UIColor *)color;
@end
