//
//  ViewController.m
//  BackendServiceManagerDemo
//
//  Created by Coody on 2016/8/9.
//

#import "ViewController.h"

#import "ParseBackendService.h"
#import "BackendServiceManager.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    ParseBackendService *parseBaasClass = [[ParseBackendService alloc] init];
    parseBaasClass.parseAppID = @"Your_Parse_App_ID";
    parseBaasClass.parseClientKey = @"Your_Parse_Client_Key";
    parseBaasClass.parseObjectName = @"Your_Parse_Object_Name";
    
    [[BackendServiceManager sharedInstance] addServicesWithClasses:@[parseBaasClass]];
    [[BackendServiceManager sharedInstance] startGetBaasWithSuccessBlock:^(id<BackendServiceObject_Protocol> baasClass) {
        
        // Do whatever you want after you get baas service object
        NSLog(@"\n\nGet Baas Service success!\nBaaS name:%@\n\n", NSStringFromClass([baasClass class]));
        
    } withFailBlock:^{
        
        // all baas fail.
        // you can add alert or do something to client user.
        // get error msg and error code from BaaS object (follow <BackendServiceObject_Protocol>)
        
        for ( id <BackendServiceObject_Protocol> baasObj in [BackendServiceManager sharedInstance].backendServiceObjectArray ) {
            
            NSLog(@"\n\nGet Baas Service fail!\nBaaS Service Class name: %@\nError Code: %@\nErrorMsg: %@\n\n" , NSStringFromClass([baasObj class]) , baasObj.errorCode , baasObj.errorMsg);
            
        }
        
    }];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
