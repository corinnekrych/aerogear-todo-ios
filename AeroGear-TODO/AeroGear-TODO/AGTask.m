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

#import "AGTask.h"

@implementation AGTask

@synthesize id = _id;
@synthesize title = _title;
@synthesize description = _description;
@synthesize dueDate = _dueDate;
@synthesize tags;
@synthesize project;


- (id)initWithDictionary:(NSDictionary *)dictionary {
    self = [super init];

    if (self) {
        self.id = [dictionary objectForKey:@"id"];
        self.title = [dictionary objectForKey:@"title"];
        self.description = [dictionary objectForKey:@"description"];
        self.dueDate = [dictionary objectForKey:@"date"];
        self.tags = [dictionary objectForKey:@"tags"];
        self.project = [dictionary objectForKey:@"project"];
    }
    
    return self;
}

-(NSDictionary *)dictionary {
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    
    if (self.id != nil)
        [dict setObject:self.id forKey:@"id"];

    [dict setObject:self.title forKey:@"title"];
    [dict setObject:self.description forKey:@"description"];
    [dict setObject:self.dueDate forKey:@"date"];
    [dict setObject:self.tags forKey:@"tags"];    
    [dict setObject:self.project forKey:@"project"];        
        
    return dict;
}

@end
