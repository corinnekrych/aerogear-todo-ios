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

#import "AGTask.h"

@implementation AGTask

@synthesize recId = _recId;
@synthesize title = _title;
@synthesize descr= _descr;
@synthesize dueDate = _dueDate;
@synthesize tags = _tags;
@synthesize projID;

- (id)init {
    if (self = [super init]) {
        self.tags = [[NSMutableArray alloc] init];            
    }
    
    return (self);
}

- (id)initWithDictionary:(NSDictionary *)dictionary {
    if (self = [super init]) {
        self.recId = [dictionary objectForKey:@"id"];
        self.title = [dictionary objectForKey:@"title"];
        self.descr = [dictionary objectForKey:@"description"];
        self.dueDate = [dictionary objectForKey:@"date"];
        
        if ([dictionary objectForKey:@"tags"] != nil)
            self.tags = [dictionary objectForKey:@"tags"];
        
        if ([dictionary objectForKey:@"project"] != nil)
            self.projID = [dictionary objectForKey:@"project"];
    }
    
    return (self);
}

-(NSDictionary *)dictionary {
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    
    if (self.recId != nil)
        [dict setObject:[self.recId stringValue] forKey:@"id"];

    [dict setObject:self.title forKey:@"title"];
    [dict setObject:self.dueDate forKey:@"date"];

    if (self.descr != nil)
        [dict setObject:self.descr forKey:@"description"];        
        
    if (self.tags != nil)
        [dict setObject:self.tags forKey:@"tags"];    
    
    if (self.projID != nil)
        [dict setObject:self.projID forKey:@"project"];        
        
    return dict;
}

- (void)copyFrom:(AGTask *)task {
    self.recId = task.recId;
    self.title = task.title;
    self.descr = task.descr;
    self.dueDate = task.dueDate;
    self.tags = task.tags;
    self.projID = task.projID;
}

- (id)copyWithZone:(NSZone *)zone {
    AGTask *task;
    
    task = [[[self class] allocWithZone:zone] init];
    
    task.recId = self.recId;
    task.title = self.title;
    task.descr = self.descr;
    task.dueDate = self.dueDate;
    task.tags = [NSMutableArray arrayWithArray:self.tags];
    task.projID = self.projID;
    
    return task;
}

- (BOOL)isEqual: (id)other {
    if (![other isKindOfClass:[AGTask class]])
        return NO;
    
    AGTask *otherTask = (AGTask *) other;
    
    return ([self.recId isEqualToNumber:otherTask.recId]);
}

- (NSString *)description {
    return [NSString stringWithFormat: @"%@ [id=%@, title=%@, description=%@, tags=%@, project=%@]",
            self.class, self.recId, self.title, self.descr, self.tags, self.projID];    
}

@end
