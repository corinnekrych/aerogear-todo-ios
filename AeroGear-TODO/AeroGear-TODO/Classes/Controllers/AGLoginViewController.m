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

#import "AGLoginViewController.h"

#import "AGTasksViewController.h"
#import "AGRegisterUserViewController.h"

#import "AGToDoAPIService.h"

#import "SVProgressHUD.h"

@implementation AGLoginViewController {
    UIImageView *_logo;    
    UITextField *_username;
    UITextField *_password;
    UILabel *_loginTxt;
    UILabel *_registerTxt;
    UIButton *_login;
    UIButton *_register;
}

- (void)viewDidUnload {
    [super viewDidUnload];
    
    DLog(@"AGLoginViewController viewDidUnLoad");
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    UIImage *background = [UIImage imageNamed: @"aerogear_logo.png"];
    _logo = [[UIImageView alloc] initWithImage:background];
    _logo.center = CGPointMake(120, 60);
    
    [self.view addSubview: _logo];
    
    _loginTxt = [[UILabel alloc] initWithFrame:CGRectMake(0, 120, 100, 40)];
    _loginTxt.text = @"Login:";
    _loginTxt.font = [UIFont boldSystemFontOfSize:24];
    
    [self.view addSubview: _loginTxt];
    
    _username = [[UITextField alloc] initWithFrame:CGRectMake(0, 160, 200, 32)];
    _username.borderStyle = UITextBorderStyleRoundedRect;
    _username.placeholder = @"Username";
    _username.autocapitalizationType = UITextAutocapitalizationTypeNone;
    _username.autocorrectionType = UITextAutocorrectionTypeNo;
    _username.delegate = self;
    
    
    _password = [[UITextField alloc] initWithFrame:CGRectMake(0, 206, 200, 32)];
    _password.borderStyle = UITextBorderStyleRoundedRect;
    _password.placeholder = @"Password";
    _password.autocapitalizationType = UITextAutocapitalizationTypeNone;
    _password.autocorrectionType = UITextAutocorrectionTypeNo;
    _password.secureTextEntry = YES;
    _password.delegate = self;
    
    [self.view addSubview:_username];
    [self.view addSubview:_password];
    
    _login = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    _login.frame = CGRectMake(0, 256, 200, 32);
    [_login addTarget:self action:@selector(login:)
        forControlEvents:UIControlEventTouchDown];
    
    [_login setTitle:@"Login" forState:UIControlStateNormal];
    
    [self.view addSubview:_login];

    _registerTxt = [[UILabel alloc] initWithFrame:CGRectMake(0, 310, 240, 40)];
    _registerTxt.text = @"Need an account?";
    _registerTxt.font = [UIFont boldSystemFontOfSize:24];
    
    [self.view addSubview:_registerTxt];
    
    _register = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    _register.frame = CGRectMake(0, 360, 200, 32);
    [_register addTarget:self action:@selector(enroll:)
        forControlEvents:UIControlEventTouchDown];
    [_register setTitle:@"Sign up" forState:UIControlStateNormal];
    
    [self.view addSubview:_register];
    
    // load saved username/password
    [self load];
    
    DLog(@"AGLoginViewController viewDidLoad");
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return YES;
}

# pragma mark - Action Methods

- (IBAction)login:(id)sender {
    if (_username.text == nil || _password.text == nil) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Oops!"
                                                        message:@"Please enter your username and password!"
                                                       delegate:nil
                                              cancelButtonTitle:@"Bummer"
                              
                                              otherButtonTitles:nil];

        [alert show];
        return;
    }
    
    // save username/passwd for future logins
    [self save];
    
    [SVProgressHUD showWithStatus:@"Logging you in..." maskType:SVProgressHUDMaskTypeGradient];
    
    [AGToDoAPIService initSharedInstanceWithBaseURL:TodoServiceBaseURLString username:_username.text password:_password.text success:^{
        [SVProgressHUD dismiss];
        
        AGTasksViewController *tasksController = [[AGTasksViewController alloc] initWithStyle:UITableViewStylePlain];
        UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:tasksController];
        navController.toolbarHidden = NO;
        [navController setModalTransitionStyle:UIModalTransitionStyleFlipHorizontal];
        [self presentModalViewController:navController animated:YES];
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

-(IBAction)enroll:(id)sender {
    AGRegisterUserViewController *registerController = [[AGRegisterUserViewController alloc]
                                                        initWithStyle:UITableViewStyleGrouped];
    
    registerController.delegate = self;
    
    UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:registerController];
    
    [self presentModalViewController:navController animated:YES];
}

#pragma mark - UITextFieldDelegate methods

- (void)textFieldDidEndEditing:(UITextField *)textField {
    [textField resignFirstResponder];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}

# pragma mark - AGRegisterUserViewController delegate

- (void)registerUserViewControllerDelegateDidFinish:(AGRegisterUserViewController *)controller
                                       withUserInfo:(NSDictionary *)info {
    
    _username.text = [info objectForKey:@"username"];
    _password.text = [info objectForKey:@"password"];
    
    [self dismissModalViewControllerAnimated:YES];
}

# pragma mark - load/save methods

- (void)load {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    NSString *username = [defaults objectForKey:@"username"];
    if (username == nil)
        username = @"john"; // set default username
    
    NSString *password = [defaults objectForKey:@"password"];
    if (password == nil)
        password = @"123"; // set default password
    
    _username.text = username;
    _password.text = password;
}

- (void)save {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    [defaults setObject:_username.text forKey:@"username"];
    [defaults setObject:_password.text forKey:@"password"];
}

@end
