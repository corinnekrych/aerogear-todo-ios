/*
 * JBoss, Home of Professional Open Source.
 * Copyright Red Hat, Inc., and individual contributors
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

#define TodoServiceBaseURLString @"https://todoauth-aerogear.rhcloud.com/todo-server/"

@class AGTask;
@class AGTag;
@class AGProject;

@interface AGToDoAPIService : NSObject

@property(strong, nonatomic) NSMutableDictionary *tags;
@property(strong, nonatomic) NSMutableDictionary *projects;

+ (void)initSharedInstanceWithBaseURL:(NSString *)baseURL
                             username:(NSString *)user password:(NSString *)passwd
                              success:(void (^)())success
                              failure:(void (^)(NSError *error))failure;
    
+ (AGToDoAPIService *)sharedInstance;

- (void)fetchTasks:(void (^)(NSMutableArray *tasks))success
           failure:(void (^)(NSError *error))failure;

- (void)postTask:(AGTask *)task
         success:(void (^)())success
         failure:(void (^)(NSError *error))failure;

- (void)removeTask:(AGTask *)task
           success:(void (^)())success
           failure:(void (^)(NSError *error))failure;

- (void)postTag:(AGTag *)tag
         success:(void (^)())success
         failure:(void (^)(NSError *error))failure;

- (void)removeTag:(AGTag *)tag
           success:(void (^)())success
           failure:(void (^)(NSError *error))failure;

- (void)postProject:(AGProject *)proj
        success:(void (^)())success
        failure:(void (^)(NSError *error))failure;

- (void)removeProject:(AGProject *)proj
          success:(void (^)())success
          failure:(void (^)(NSError *error))failure;


- (void)refreshTags:(void (^)())success
            failure:(void (^)(NSError *error))failure;

- (void)refreshProjects:(void (^)())success
                failure:(void (^)(NSError *error))failure;

- (void) logout:(void (^)())success
        failure:(void (^)(NSError *error))failure;

+ (void)enrollUser:(NSDictionary *)userInfo
           success:(void (^)())success
           failure:(void (^)(NSError *error))failure;

@end
