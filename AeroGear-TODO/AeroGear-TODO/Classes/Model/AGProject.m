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

#import "AGProject.h"

@implementation AGProject

@synthesize recId;
@synthesize title;
@synthesize style;

- (id)initWithDictionary:(NSDictionary *)dictionary {
    if (self = [super init]) {
        self.recId = [dictionary objectForKey:@"id"];
        self.title = [dictionary objectForKey:@"title"];
        self.style = [dictionary objectForKey:@"style"];
    }
    
    return (self);
}

-(NSDictionary *)dictionary {
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    
    if (self.recId != nil)
        [dict setObject:[self.recId stringValue] forKey:@"id"];
    
    [dict setObject:self.title forKey:@"title"];
    [dict setObject:self.style forKey:@"style"];
    
    return dict;
}

- (NSString *)description {
    return [NSString stringWithFormat: @"%@ [id=%@, title=%@, description=%@]",
            self.class, self.recId, self.title, self.style];
}

@end
