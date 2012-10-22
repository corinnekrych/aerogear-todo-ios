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

#define kServerHostRowIndex 0
#define kServerUserRowIndex 1
#define kServerPasswdRowIndex 2

@protocol AGSettingsViewControllerDelegate;

@interface AGSettingsViewController : UITableViewController <UITextFieldDelegate>

@property(copy, nonatomic) NSString *host;
@property(copy, nonatomic) NSString *username;
@property(copy, nonatomic) NSString *password;
@property(nonatomic) BOOL isOpenShift;

@property (weak, nonatomic) id <AGSettingsViewControllerDelegate> delegate;

@end

@protocol AGSettingsViewControllerDelegate <NSObject>
- (void)settingsEditorViewControllerDelegateDidFinish:(AGSettingsViewController *)controller 
                                         withHostname:(NSString *)host
                                          andUserName:(NSString *)user
                                          andPassword:(NSString *)passwd
                                          isOpenShift:(BOOL)isOpenShift;

@end


