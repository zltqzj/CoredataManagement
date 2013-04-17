//
//  TestViewController.m
//  CoredataManagement
//
//  Created by Sinosoft on 4/17/13.
//  Copyright (c) 2013 com.Sinosoft. All rights reserved.
//

#import "TestViewController.h"

@interface TestViewController ()

@end

@implementation TestViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    /*
     //添加
     NSMutableArray *array = [NSMutableArray array];
     [array addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"xiaohongmao", @"name", @"12", @"age", nil]];
     [array addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"dahuilang", @"name", @"22", @"age", nil]];
     [array addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"mogu", @"name", @"32", @"age", nil]];
     [array addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"mogu", @"name", @"44", @"age", nil]];
     
     EntityManager *enti = [EntityManager createManager] ;
     BOOL result = [enti insert:array entityName:@"Bill"];
     NSLog(@"insert result :%d", result);
     
     //查询
     NSArray *arr = [enti searchWithEntityName:@"Bill" predicate:nil];
     NSLog(@"插入后查询insert is:%@", arr);

     */
    NSMutableArray *array = [NSMutableArray array];
    [array addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"xiaohongmao", @"name", @"12", @"age", nil]];
    [array addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"dahuilang", @"name", @"22", @"age", nil]];
    [array addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"mogu", @"name", @"32", @"age", nil]];
    [array addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"mogu", @"name", @"44", @"age", nil]];
    EntityManager* enti = [EntityManager createManager:@"CoredataManagement"];
    BOOL result = [enti insert:array entityName:@"Bill"];
    NSLog(@"insert result :%d", result);
    NSArray *arr = [enti searchWithEntityName:@"Bill" predicate:nil];
    NSLog(@"插入后查询insert is:%@", arr);
    
    
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
