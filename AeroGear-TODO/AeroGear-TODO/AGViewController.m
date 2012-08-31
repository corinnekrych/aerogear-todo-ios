//
//  AGViewController.m
//  AeroGear-TODO
//
//  Created by matzew on 31.08.12.
//  Copyright (c) 2012 JBoss. All rights reserved.
//

#import "AGViewController.h"
#import "AeroGear.h"

@interface AGViewController ()

@end

@implementation AGViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}

- (IBAction)sendRequest:(id)sender {
    // some SIMPLE loadings.....
    NSURL* projectsURL = [NSURL URLWithString:@"http://todo-aerogear.rhcloud.com/todo-server/projects/"];
    AGPipeline* todo = [AGPipeline pipelineWithPipe:@"projects" url:projectsURL type:@"REST"];
    
    id<AGPipe> projects = [todo get:@"projects"];
    
    [projects read:^(id responseObject) {
        NSLog(@"We got these projects: %@", [responseObject description]);
        
    } failure:^(NSError *error) {
        
        NSLog(@"SAVE: An error occured! \n%@", error);
    }];
}
@end
