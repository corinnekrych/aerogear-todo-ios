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

#import "AGToDoAPIService.h"

#import "AGTask.h"
#import "AGTag.h"
#import "AGProject.h"

#import <AeroGear/AeroGear.h>

static AGToDoAPIService *__sharedInstance;

@implementation AGToDoAPIService {
    id<AGPipe> _tasksPipe;
    id<AGPipe> _tagsPipe;
    id<AGPipe> _projectsPipe;
    
    id<AGAuthenticationModule> _restAuthModule;
}

@synthesize tags = _tags;
@synthesize projects = _projects;

+ (void)initSharedInstanceWithBaseURL:(NSString *)baseURL
                             username:(NSString *)user
                             password:(NSString *)paswd
                              success:(void (^)())success
                              failure:(void (^)(NSError *error))failure {

    __sharedInstance = [[AGToDoAPIService alloc] initWithBaseURL:[NSURL URLWithString:baseURL]
                                                        username:user password:paswd 
                                                         success:success failure:failure];
}

- (id)initWithBaseURL:(NSURL *)projectsURL
             username:(NSString *)user
             password:(NSString *)passwd
              success:(void (^)())success
              failure:(void (^)(NSError *error))failure {

    if (self = [super init]) {
        
        AGAuthenticator* authenticator = [AGAuthenticator authenticator];
        
        _restAuthModule = [authenticator auth:^(id<AGAuthConfig> config) {
            [config name:@"restAuthMod"];
            [config baseURL:projectsURL];
        }];
        
        [_restAuthModule login:user password:passwd success:^(id object) {

            AGPipeline* pipeline = [AGPipeline pipeline:projectsURL];
            
            // setup pipes
            _tasksPipe = [pipeline pipe:^(id<AGPipeConfig> config) {
                [config name:@"tasks"];
                [config authModule:_restAuthModule];
                [config type:@"REST"];
            }];
            
            _tagsPipe = [pipeline pipe:^(id<AGPipeConfig> config) {
                [config name:@"tags"];
                [config authModule:_restAuthModule];
                [config type:@"REST"];
            }];
            
            _projectsPipe = [pipeline pipe:^(id<AGPipeConfig> config) {
                [config name:@"projects"];
                [config authModule:_restAuthModule];
                [config type:@"REST"];
            }];

            // initialize tags and projects
            [self refreshTags:^{
                [self refreshProjects:^{
                    success();
                } failure:^(NSError *error) {
                    failure(error);
                }];
            } failure:^(NSError *error) {
                failure(error);
            }];            
            
        } failure:^(NSError *error) {
            failure(error);
        }];
    }
    
    
    return (self);
}

+ (AGToDoAPIService *)sharedInstance {
    return __sharedInstance;
}

- (void)fetchTasks:(void (^)(NSMutableArray *tasks))success
           failure:(void (^)(NSError *error))failure {
    
    [_tasksPipe read:^(id responseObject) {
        NSMutableArray *tasks = [NSMutableArray array];
        
        for (id taskDict in responseObject) {
            AGTask *task = [AGTask modelWithExternalRepresentation:taskDict];
            
            [tasks addObject:task];
        }
        
        success(tasks);
        
    } failure:^(NSError *error) {
        
        failure(error);
    }];
}

- (void)postTask:(AGTask *)task
         success:(void (^)())success
         failure:(void (^)(NSError *error))failure {
    
    [_tasksPipe save:[task externalRepresentation] success:^(id responseObject) {
        if (task.recId == nil) { // new task
            // if it is a new task, set the id
            task.recId = [responseObject objectForKey:@"id"];
        }
        
        success();
        
    } failure:^(NSError *error) {
        failure(error);
    }];
}

- (void)removeTask:(AGTask *)task
           success:(void (^)())success
           failure:(void (^)(NSError *error))failure {
    
    [_tasksPipe remove:task.recId success:^(id responseObject) {
        success(success);
        
    } failure:^(NSError *error) {
        failure(error);
    }];
}

- (void)postTag:(AGTag *)tag
         success:(void (^)())success
         failure:(void (^)(NSError *error))failure {
    
    [_tagsPipe save:[tag externalRepresentation] success:^(id responseObject) {
        if (tag.recId == nil) { // new tag
            NSNumber *tagId = [responseObject objectForKey:@"id"];
            
            // if it is a new tag, set the id
            tag.recId = tagId;
           
            // ...and add it to our local "cache" list
            [self.tags setObject:tag forKey:tagId];
        }
        
        success();
        
    } failure:^(NSError *error) {
        failure(error);
    }];
}


- (void)removeTag:(AGTag *)tag
          success:(void (^)())success
          failure:(void (^)(NSError *error))failure {
    
    [_tagsPipe remove:tag.recId success:^(id responseObject) {

        // update our "cache"
        [self.tags removeObjectForKey:tag.recId];
        
        success(success);
        
    } failure:^(NSError *error) {
        failure(error);
    }];
}

- (void)postProject:(AGProject *)proj
            success:(void (^)())success
            failure:(void (^)(NSError *error))failure {

    [_projectsPipe save:[proj externalRepresentation] success:^(id responseObject) {
        if (proj.recId == nil) { // new tag
            NSNumber *projId = [responseObject objectForKey:@"id"];
            
            // if it is a new project, set the id
            proj.recId = projId;
            
            // ...and add it to our local "cache" list
            [self.projects setObject:proj forKey:projId];
        }
        
        success();
        
    } failure:^(NSError *error) {
        failure(error);
    }];    
}

- (void)removeProject:(AGProject *)proj
              success:(void (^)())success
              failure:(void (^)(NSError *error))failure {
 
    [_projectsPipe remove:proj.recId success:^(id responseObject) {
        
        // update our "cache"
        [self.projects removeObjectForKey:proj.recId];
        
        success(success);
        
    } failure:^(NSError *error) {
        failure(error);
    }];    
}

- (void)refreshTags:(void (^)())success
            failure:(void (^)(NSError *error))failure  {
    
    [_tagsPipe read:^(id responseObject) {
        self.tags = [[NSMutableDictionary alloc] init];
        
        for (id tagDict in responseObject) {
            AGTag *tag = [AGTag modelWithExternalRepresentation:tagDict];
            
            [self.tags setObject:tag forKey:[tagDict objectForKey:@"id"]];
        }
        
        success();
        
    } failure:^(NSError *error) {
        failure(error);
    }];
}

- (void)refreshProjects:(void (^)())success
                failure:(void (^)(NSError *error))failure {
    
    // retrieve projects
    [_projectsPipe read:^(id responseObject) {
        self.projects = [[NSMutableDictionary alloc] init];
        
        for (id projDict in responseObject) {
            AGProject *proj = [AGProject modelWithExternalRepresentation:projDict];
            
            [self.projects setObject:proj forKey:[projDict objectForKey:@"id"]];
        }
        
        success();
        
    } failure:^(NSError *error) {
        failure(error);
    }];            
}

- (void) logout:(void (^)())success
        failure:(void (^)(NSError *error))failure {
    [_restAuthModule logout:success failure:failure];
}

+ (void)enrollUser:(NSDictionary *)userInfo
           success:(void (^)())success
           failure:(void (^)(NSError *error))failure {
 
    AGAuthenticator* authenticator = [AGAuthenticator authenticator];
    id<AGAuthenticationModule> restAuthModule = [authenticator auth:^(id<AGAuthConfig> config) {
        [config name:@"restAuthMod"];
        [config baseURL:[NSURL URLWithString:TodoServiceBaseURLString]];
    }];

    [restAuthModule enroll:userInfo success:success failure:failure];
}
@end
