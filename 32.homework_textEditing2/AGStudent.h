//
//  AGStudent.h
//  32.homework_textEditing2
//
//  Created by MC723 on 25.12.14.
//  Copyright (c) 2014 temateorema. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface AGStudent : NSObject
@property (strong, nonatomic) NSString* firstName;
@property (strong, nonatomic) NSString* lastName;
@property (assign, nonatomic) float averageScore;

+ (AGStudent*) randomSudent;

@end
