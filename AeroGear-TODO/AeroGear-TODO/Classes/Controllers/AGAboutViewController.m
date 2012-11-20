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

#import "AGAboutViewController.h"

@implementation AGAboutViewController {
    UIImageView *_logo;
    UITextView *_link;
}

- (void)viewDidUnload {
    [super viewDidUnload];
    
    DLog(@"AGTasksViewController viewDidUnload");    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"About";
    
    self.navigationItem.hidesBackButton = YES;
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone
                                                                                           target:self 
                                                                                           action:@selector(close)];    
    self.view.backgroundColor = [UIColor whiteColor];
    
    UIImage *background = [UIImage imageNamed: @"aerogear_logo.png"];    
    _logo = [[UIImageView alloc] initWithImage:background]; 
    
    [self.view addSubview: _logo];
    
    _link = [[UITextView alloc] initWithFrame:CGRectMake(0, 0, 105, 50)];
    _link.text = @"aerogear.org";
    _link.font = [UIFont boldSystemFontOfSize:14];
    _link.editable = NO;
    _link.dataDetectorTypes = UIDataDetectorTypeLink;
    
    [self.view addSubview:_link];

    [self centerElements];

    DLog(@"AGAboutViewController viewDidUnLoad");
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return YES;
}

-(void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
    [self centerElements];
}

- (void)centerElements {
    CGRect screen = [[UIScreen mainScreen] bounds];
    float pos_y, pos_x;
    pos_y = UIDeviceOrientationIsLandscape([[UIDevice currentDevice] orientation]) ? screen.size.width/2  : screen.size.height/2;
    pos_x = UIDeviceOrientationIsLandscape([[UIDevice currentDevice] orientation]) ? screen.size.height/2 : screen.size.width/2;
    
    _logo.center = CGPointMake(pos_x, pos_y-100);    
    _link.center = CGPointMake(pos_x, pos_y-20);    
}

- (IBAction)close {
    UIViewAnimationTransition trans = UIViewAnimationTransitionFlipFromLeft;
    [UIView beginAnimations: nil context: nil];
    [UIView setAnimationDuration:0.8];
    [UIView setAnimationTransition: trans forView: [self.view window] cache: NO];
    
    [self.navigationController popViewControllerAnimated:NO];
    
    [UIView commitAnimations];    
}

@end
