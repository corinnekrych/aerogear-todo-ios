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
#import "AGConfig.h"
#import "AGAuthenticationModule.h"

/**
 * Represents the public API to configure AGPipe objects.
 */
@protocol AGPipeConfig <AGConfig>

/**
 * Applies the baseURL to the configuration.
 *
 * @param baseURL The baseURL of the actual AGPipe object.
 */
-(void) baseURL:(NSURL*) baseURL;

/**
 * Applies the baseURL to the configuration.
 * If no endpoint is specified, the name will be used as its value.
 *
 * @param endpoint The baseURL of the actual AGPipe object.
 */
-(void) endpoint:(NSString*) endpoint;

/**
 * Applies the recordId to the configuration.
 *
 * @param recordId The name of the field used to uniquely identify a "record" in the data
 */
-(void) recordId:(NSString*)recordId;

/**
 * Applies the AGAuthenticationModule object to the configuration.
 *
 * @param authModule The AGAuthenticationModule of the actual AGPipe object.
 */
-(void) authModule:(id<AGAuthenticationModule>) authModule;

@end
