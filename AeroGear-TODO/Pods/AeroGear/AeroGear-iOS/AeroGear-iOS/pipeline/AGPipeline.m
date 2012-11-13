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

#import "AGPipeline.h"
#import "AGPipeConfiguration.h"
#import "AGRestAdapter.h"

// category
@interface AGPipeline ()
// concurrency...
@property (atomic, copy) NSMutableDictionary* pipes;
@end

@implementation AGPipeline {
    // ivars...
    NSURL* _baseURL;
}
@synthesize pipes = _pipes;


- (id)init {
    self = [super init];
    if (self) {
        _pipes = [NSMutableDictionary dictionary];
    }
    return self;
}

- (id)init:(NSURL*) baseURL {
    self = [self init];
    if (self) {
        
        // stash the baseURL, used for the 'add' functions that have no (base)URL argument
        _baseURL = baseURL;
    }
    return self;
}

+(id)pipeline {
    return [[self alloc] init];
}

+(id)pipeline:(NSURL*) baseURL; {
    return [[self alloc] init:baseURL];
}


-(id<AGPipe>) pipe:(void (^)(id<AGPipeConfig> config)) config {

    AGPipeConfiguration* pipeConfig = [[AGPipeConfiguration alloc] init];

    // applying the defaults:
    [pipeConfig baseURL:_baseURL];

    if (config) {
        config(pipeConfig);
    }
    
    NSString* name  = [pipeConfig name];
    NSString* type = [pipeConfig type];
    NSURL* baseURL = [pipeConfig baseURL];
    NSString* endpoint = [pipeConfig endpoint];
    id<AGAuthenticationModule> authModule = [pipeConfig authModule];
    
    // append the endpoint/name and use it as the final URL
    NSURL* finalURL = [self appendEndpoint:endpoint toURL:baseURL];
    return [self add:name url:finalURL type:type authModule:authModule];
}

// a private add, since we really don't have a 'baseURL' on the final URL...
-(id<AGPipe>) add:(NSString*) name url:(NSURL*)url type:(NSString*)type authModule:(id<AGAuthenticationModule>) authModule {
    // TODO check ALL supported types...
    if (! [AGRestAdapter accepts:type]) {
        return nil;
    }
    
    
    id<AGPipe> pipe = [AGRestAdapter pipeForURL:url authModule:authModule];
    [_pipes setValue:pipe forKey:name];
    return pipe;
    
}

// private helper to append the endpoint
-(NSURL*) appendEndpoint:(NSString*)endpoint toURL:(NSURL*)baseURL {
    if (endpoint == nil) {
        endpoint = @"";
    }

    // append the endpoint name and use it as the final URL
    return [baseURL URLByAppendingPathComponent:endpoint];
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
