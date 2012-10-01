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

#import <Foundation/Foundation.h>
#import "AGPipe.h"

/**
 * AGPipeline represents a 'collection' of server connections (pipes) and
 * their corresponding data models. This object provides a standard way to
 * communicate with the server no matter the data format or transport expected.
 *
 * A pipeline must have at least one pipe.
 */
@interface AGPipeline : NSObject

/**
 * An initializer method to instantiate the AGPipeline, which
 * contains a RESTful pipe.
 *
 * @param name the endpoint name of the first AGPipe object
 * @param baseURL the URL of the server
 *
 * @return the AGPipeline object
 */
-(id) initWithPipe:(NSString*) name baseURL:(NSURL*)baseURL;

/**
 * An initializer method to instantiate the AGPipeline, which
 * contains a pipe object. The actual type is determined by the type argument.
 *
 * @param name the endpoint name of the first AGPipe object
 * @param baseURL the URL of the server
 * @param type the type of the actual pipe/connection
 *
 * @return the AGPipeline object
 */
-(id) initWithPipe:(NSString*) name baseURL:(NSURL*)baseURL type:(NSString*)type;

/**
 * An initializer method to instantiate the AGPipeline, which
 * contains a RESTful pipe. The RESTful endpoint is determined by the endpoint argument.
 *
 * @param name the logical name of the first AGPipe object
 * @param baseURL the URL of the server
 * @param endpoint the serivce endpoint name
 *
 * @return the AGPipeline object
 */
-(id) initWithPipe:(NSString*) name baseURL:(NSURL*)baseURL endpoint:(NSString*)endpoint;

/**
 * An initializer method to instantiate the AGPipeline, which
 * contains a pipe object. The actual type is determined by the type argument.
 * The endpoint is determined by the endpoint argument.
 *
 * @param name the logical name of the first AGPipe object
 * @param baseURL the URL of the server
 * @param endpoint the serivce endpoint name
 * @param type the type of the actual pipe/connection
 *
 * @return the AGPipeline object
 */
-(id) initWithPipe:(NSString*) name baseURL:(NSURL*)baseURL endpoint:(NSString*)endpoint type:(NSString*)type;

/**
 * A factory method to instantiate the AGPipeline, which
 * contains a RESTful pipe.
 *
 * @param name the endpoint name of the first AGPipe object
 * @param baseURL the URL of the server
 *
 * @return the AGPipeline object
 */
+(id) pipelineWithPipe:(NSString*) name baseURL:(NSURL*)baseURL;

/**
 * A factory method to instantiate the AGPipeline, which
 * contains a pipe object. The actual type is determined by the type argument.
 *
 * @param name the endpoint name of the first AGPipe object
 * @param baseURL the URL of the server
 * @param type the type of the actual pipe/connection
 *
 * @return the AGPipeline object
 */
+(id) pipelineWithPipe:(NSString*) name baseURL:(NSURL*)baseURL type:(NSString*)type;

/**
 * A factory method to instantiate the AGPipeline, which
 * contains a RESTful pipe. The endpoint is determined by the endpoint argument.
 *
 * @param name the logical name of the first AGPipe object
 * @param baseURL the URL of the server
 * @param endpoint the serivce endpoint name
 *
 * @return the AGPipeline object
 */
+(id) pipelineWithPipe:(NSString*) name baseURL:(NSURL*)baseURL endpoint:(NSString*)endpoint;


/**
 * A factory method to instantiate the AGPipeline, which
 * contains a pipe object. The actual type is determined by the type argument.
 * The endpoint is determined by the endpoint argument.
 *
 * @param name the logical name of the first AGPipe object
 * @param baseURL the URL of the server
 * @param endpoint the serivce endpoint name
 * @param type the type of the actual pipe/connection
 *
 * @return the AGPipeline object
 */
+(id) pipelineWithPipe:(NSString*) name baseURL:(NSURL*)baseURL endpoint:(NSString*)endpoint type:(NSString*)type;


// =====================================
// Adds that leverage the given base URL
// =====================================


/**
 * Adds a new RESTful pipe to the AGPipeline object,
 * leveraging the given baseURL argument.
 *
 * @param name the endpoint name of the actual pipe
 *
 * @return the new created AGPipe object
 */
-(id<AGPipe>) add:(NSString*) name;

/**
 * Adds a new RESTful pipe to the AGPipeline object,
 * leveraging the given baseURL argument.
 *
 * @param name the name of the actual pipe
 * @param endpoint the serivce endpoint, if differs from the pipe name.
 *
 * @return the new created AGPipe object
 */
-(id<AGPipe>) add:(NSString*) name endpoint:(NSString*)endpoint;

/**
 * Adds a new pipe (server connection) to the AGPipeline object,
 * leveraging the given baseURL argument.
 *
 * @param name the endpoint name of the actual pipe
 * @param type the type of the actual pipe/connection
 *
 * @return the new created AGPipe object
 */
-(id<AGPipe>) add:(NSString*) name type:(NSString*)type;

/**
 * Adds a new pipe (server connection) to the AGPipeline object,
 * leveraging the given baseURL argument.
 *
 * @param name the logical name of the actual pipe
 * @param endpoint the serivce endpoint, if differs from the pipe name.
 * @param type the type of the actual pipe/connection
 *
 * @return the new created AGPipe object
 */
-(id<AGPipe>) add:(NSString*) name endpoint:(NSString*)endpoint type:(NSString*)type;


// =======================================
// Adds that specify a different base URL
// =======================================

/**
 * Adds a new RESTful pipe to the AGPipeline object
 *
 * @param name the endpoint name of the actual pipe
 * @param baseURL the URL of the server
 *
 * @return the new created AGPipe object
 */
-(id<AGPipe>) add:(NSString*) name baseURL:(NSURL*)baseURL;

/**
 * Adds a new RESTful pipe to the AGPipeline object
 *
 * @param name the name of the actual pipe
 * @param baseURL the URL of the server
 * @param endpoint the serivce endpoint, if differs from the pipe name.
 *
 * @return the new created AGPipe object
 */
-(id<AGPipe>) add:(NSString*) name baseURL:(NSURL*)baseURL endpoint:(NSString*)endpoint;

/**
 * Adds a new pipe (server connection) to the AGPipeline object
 *
 * @param name the endpoint name of the actual pipe
 * @param baseURL the URL of the server
 * @param type the type of the actual pipe/connection
 *
 * @return the new created AGPipe object
 */
-(id<AGPipe>) add:(NSString*) name baseURL:(NSURL*)baseURL type:(NSString*)type;

/**
 * Adds a new pipe (server connection) to the AGPipeline object
 *
 * @param name the logical name of the actual pipe
 * @param baseURL the URL of the server
 * @param endpoint the serivce endpoint, if differs from the pipe name.
 * @param type the type of the actual pipe/connection
 *
 * @return the new created AGPipe object
 */
-(id<AGPipe>) add:(NSString*) name baseURL:(NSURL*)baseURL endpoint:(NSString*)endpoint type:(NSString*)type;


// ============================
// remove and get functionality
// ============================

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