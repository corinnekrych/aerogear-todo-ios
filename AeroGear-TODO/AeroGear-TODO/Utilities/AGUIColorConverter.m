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

#import "AGUIColorConverter.h"

@implementation AGUIColorConverter


+ (UIColor *)getAsObject:(NSString*) style {
    if ([style isKindOfClass:[NSNull class]])
        return [UIColor whiteColor];
    
    NSArray *tokens = [style componentsSeparatedByString:@"-"];
    
    CGFloat r = [[tokens objectAtIndex:1] floatValue] / 255.0;
    CGFloat g = [[tokens objectAtIndex:2] floatValue] / 255.0;
    CGFloat b = [[tokens objectAtIndex:3] floatValue] / 255.0;
    
    return [UIColor colorWithRed:r green:g blue:b alpha:100];
}

+ (NSString*)getAsString:(UIColor *)color{
    if (color == [UIColor whiteColor]) { //TODO: see why this happens
        return @"project-255-255-255";
    }
    
    const CGFloat *components = CGColorGetComponents(color.CGColor);
    // update style from color
    return [NSString stringWithFormat:@"project-%.0f-%.0f-%.0f", components[0]*255.0, components[1]*255.0, components[2]*255.0];
}


@end
