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

#import <Foundation/Foundation.h>
#import "AGPipe.h"
#import "AGPipeConfig.h"
#import "AGAuthenticationModule.h"

/**
 * AGPipeline represents a 'collection' of server connections (pipes). This object provides a standard way to
 * communicate with the server no matter the data format or transport expected.
 */
@interface AGPipeline : NSObject

/**
 * An initializer method to instantiate an empty AGPipeline.
 *
 * @param baseURL the URL of the server
 *
 * @return the AGPipeline object
 */
-(id) init:(NSURL*) baseURL;

/**
 * An initializer method to instantiate an empty AGPipeline.
 *
 * @return the AGPipeline object
 */
-(id) init;

/**
 * A factory method to instantiate an empty AGPipeline.
 *
 * @return the AGPipeline object
 */
+(id) pipeline;

/**
 * A factory method to instantiate an empty AGPipeline.
 *
 * @param baseURL the URL of the server
 *
 * @return the AGPipeline object
 */
+(id) pipeline:(NSURL*) baseURL;

/**
 * Adds a new AGPipe object, based on the give configuration object.
 *
 * @param config A block object which passes in an implementation of the AGPipeConfig protocol.
 * the object is used to configure the AGPipe object.
 *
 * @return the newly created AGPipe object
 */
-(id<AGPipe>) pipe:(void (^)(id<AGPipeConfig> config)) config;

/**
 * Removes a pipe from the AGPipeline object
 *
 * @param name the name of the actual pipe
 *
 * @return the new created AGPipe object
 */
-(id<AGPipe>) remove:(NSString*) name;

/**
 * Look up for a pipe object.
 *
 * @param name the name of the actual pipe
 *
 * @return the new created AGPipe object
 */
-(id<AGPipe>) get:(NSString*) name;

@end