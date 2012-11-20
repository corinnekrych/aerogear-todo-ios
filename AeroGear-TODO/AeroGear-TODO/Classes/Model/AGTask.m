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

#import "AGTask.h"

@implementation AGTask

@synthesize recId;
@synthesize title;
@synthesize descr;
@synthesize dueDate;
@synthesize tags;
@synthesize projID;

+ (NSDictionary *)externalRepresentationKeyPathsByPropertyKey {
    return [super.externalRepresentationKeyPathsByPropertyKey mtl_dictionaryByAddingEntriesFromDictionary:@{
        @"recId": @"id",
        @"descr": @"description",
        @"dueDate": @"date",
        @"projID": @"project"
    }];
}

- (id)init {
    if (self = [super init]) {
        self.tags = [[NSMutableArray alloc] init];            
    }
    
    return (self);
}

- (void)copyFrom:(AGTask *)task {
    self.recId = task.recId;
    self.title = task.title;
    self.descr = task.descr;
    self.dueDate = task.dueDate;
    self.tags = task.tags;
    self.projID = task.projID;
}

- (NSString *)description {
    return [NSString stringWithFormat: @"%@ [id=%@, title=%@, description=%@, tags=%@, project=%@]",
            self.class, self.recId, self.title, self.descr, self.tags, self.projID];    
}

@end
