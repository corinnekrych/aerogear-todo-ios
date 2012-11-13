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
#import "AGStore.h"
#import "AGStoreConfig.h"

/**
 * AGDataManager manages different AGStore implementations. It is basically a
 * factory that hides the concrete instanciation of a specific AGStore implementation.
 * The class offers simple APIs to add, remove or get access to a 'data store'.
 *
 * NOTE: Right now, there is NO automatic data sync. This is up to the user.
 */
@interface AGDataManager : NSObject

/**
 * A factory method to instantiate the AGDataManager object.
 *
 * @return the AGDataManager object
 */
+(id) manager;

/**
 * Adds a new AGStore object, based on the give configuration object.
 *
 * @param config A block object which passes in an implementation of the AGStoreConfig protocol.
 * the object is used to configure the AGStore object.
 *
 * @return the newly created AGStore object
 */
-(id<AGStore>) store:(void (^)(id<AGStoreConfig> config)) config;

/**
 * Removes a AGStore implemention from the AGDataManager. The store to be removed
 * is determined by the storeName argument.
 *
 * @param storeName The name of the actual data store object.
 */
-(id<AGStore>)remove:(NSString*) storeName;

/**
 * Loads a given AGStore implemention, based on the given storeName argument.
 *
 * @param storeName The name of the actual data store object.
 */
-(id<AGStore>)get:(NSString*) storeName;

@end
