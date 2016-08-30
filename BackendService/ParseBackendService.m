//
//  ParseBackendService.m
//  App
//
//  Created by Coody on 2016/7/4.
//

#import "ParseBackendService.h"

// for BaaS Service
#import <Parse/Parse.h>

// for Properties
static NSString *const kTestProperty = @"Your_parse_Query_Object_TestProperty_Name";

@implementation ParseBackendService

-(instancetype)init{
    self = [super init];
    if ( self ) {
        _objectName = [NSStringFromClass([self class]) copy];
        _errorMsg = nil;
        _errorCode = nil;
    }
    return self;
}

-(void)initialParse{
    // you can put it in AppDelegate's method application:didFinishLaunchingWithOptions:
    [Parse setApplicationId:_parseAppID 
                  clientKey:_parseClientKey];
}

-(void)startBackendServiceWithSuccessBlock:(SuccessBlock)responseSuccessBlock 
                             withFailBlock:(FailBlock)responseFailBlock
{
    /*
        Implement parser parse object here or do whatever you want!
        
        It is simple code.
     */
    
    PFQuery  *query;
    
    {
        query = [PFQuery queryWithClassName:_parseObjectName];
    }
    
    NSError *error;
    PFObject *parseObject = [query getFirstObject:&error];
    
    if ( error ) {
        self.errorCode = [NSNumber numberWithInteger:error.code];
        self.errorMsg = error.description;
        responseFailBlock(self);
    }
    else{
        
        _testProperty = parseObject[kTestProperty];
        
        responseSuccessBlock(self);
        
    }
}

@end
