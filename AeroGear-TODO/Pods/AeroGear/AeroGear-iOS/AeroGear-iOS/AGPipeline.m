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

#import "AGPipeline.h"
#import "AGRestAdapter.h"

// category
@interface AGPipeline ()
// concurrency...
@property (atomic, copy) NSMutableDictionary* pipes;
@end

@implementation AGPipeline {
    // ivars...
}
@synthesize pipes = _pipes;


- (id)init
{
    self = [super init];
    if (self) {
        _pipes = [NSMutableDictionary dictionary];
    }
    return self;
}
-(id) initWithPipe:(NSString*) name url:(NSURL*)url {
    self = [self init];
    if (self) {
        // default, is REST Only...
        id<AGPipe> pipe = [AGRestAdapter pipeForURL:url];
        
        [_pipes setValue:pipe forKey:name];
    }
    return self;
}

-(id) initWithPipe:(NSString*) name url:(NSURL*)url type:(NSString*)type {
    
    if (! [type isEqualToString:@"REST"]) {
        return nil;
    }
    
    self = [self init];
    if (self) {
        //TODO: check for (invalid) type
        
        // default, is REST Only...
        id<AGPipe> pipe = [AGRestAdapter pipeForURL:url];
        
        
        [_pipes setValue:pipe forKey:name];
    }
    return self;
}

+(id) pipelineWithPipe:(NSString*) name url:(NSURL*)url {
    return [[self alloc] initWithPipe:name url:url];
}

+(id) pipelineWithPipe:(NSString*) name url:(NSURL*)url type:(NSString*)type {
    return [[self alloc] initWithPipe:name url:url type:type];
}

-(id<AGPipe>) add:(NSString*) name url:(NSURL*)url {
    // default, is REST Only...
    id<AGPipe> pipe = [AGRestAdapter pipeForURL:url];
    
    
    [_pipes setValue:pipe forKey:name];

    return pipe;
}

-(id<AGPipe>) add:(NSString*) name url:(NSURL*)url type:(NSString*)type {
    if (! [type isEqualToString:@"REST"]) {
        return nil;
    }
    
    // default, is REST Only...
    id<AGPipe> pipe = [AGRestAdapter pipeForURL:url];
    
    
    [_pipes setValue:pipe forKey:name];
    
    return pipe;
}

-(id<AGPipe>) remove:(NSString*) name {
    id<AGPipe> pipe = [self get:name];
    [_pipes removeObjectForKey:name];
    
    return pipe;
}

-(id<AGPipe>) get:(NSString*) name {
    return [_pipes valueForKey:name];
}

-(NSString *) description {
    return [NSString stringWithFormat: @"%@ %@", self.class, _pipes];
}

@end
