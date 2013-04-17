//
//  EntityManager.h
//  RabitRun
//
//  Created by zj on 13-04-16.
//  Copyright zj. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/NSManagedObjectModel.h>
#import <CoreData/NSManagedObjectContext.h>
#import <CoreData/NSPersistentStoreCoordinator.h>

@interface EntityManager : NSObject
{
@private
    NSManagedObjectContext         *_managedObjectContext;
    NSManagedObjectModel           *_managedObjectModel;
    NSPersistentStoreCoordinator   *_persistentStoreCoordinator;
}

@property(retain, nonatomic)NSError* lastError;

+ (EntityManager *)createManager:(NSString*)_dbname;

- (BOOL)insert:(NSArray *)array entityName:(NSString *)entityName;//add

- (BOOL)deleteManagedObject:(NSArray *)array entityName:(NSString *)entityName;//delete

- (BOOL)updateObjects:(NSArray *)start toObjects:(NSArray *)result name:(NSString *)entityName;//update

- (NSArray *)searchWithEntityName:(NSString *)entityName predicate:(NSDictionary *)predicate;//search

- (id)init:(NSString*)_dbname;//传数据库的名字

@end

#pragma mark - TestData 测试数据
/*
 
 //添加
 NSMutableArray *array = [NSMutableArray array];
 [array addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"xiaohongmao", @"name", @"12", @"age", nil]];
 [array addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"dahuilang", @"name", @"22", @"age", nil]];
 [array addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"mogu", @"name", @"32", @"age", nil]];
 [array addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"mogu", @"name", @"44", @"age", nil]];
 
 EntityManager* enti = [EntityManager createManager:@"CoredataManagement"];
 BOOL result = [enti insert:array entityName:@"Bill"];
 NSLog(@"insert result :%d", result);
 
 //查询
 NSArray *arr = [enti searchWithEntityName:@"Bill" predicate:nil];
 NSLog(@"插入后查询insert is:%@", arr);
 
 //按条件查询
 arr = [enti searchWithEntityName:@"Bill" predicate:[NSDictionary dictionaryWithObjectsAndKeys:@"mogu", @"name", @"32", @"age", nil]];
 NSLog(@"查询条件arr:%@", arr);
 
 
 //修改
 NSDictionary *dict1 = [NSDictionary dictionaryWithObjectsAndKeys:@"22", @"age", @"dahuilang", @"name", nil];
 NSDictionary *dict2 = [NSDictionary dictionaryWithObjectsAndKeys:@"12", @"age", nil];
 NSArray *arr1 = [NSArray arrayWithObjects:dict1, dict2, nil];
 NSDictionary *dict3 = [NSDictionary dictionaryWithObjectsAndKeys:@"232", @"age", @"dahui", @"name", nil];
 NSDictionary *dict4 = [NSDictionary dictionaryWithObjectsAndKeys:@"192", @"age", nil];
 NSArray *arr2 = [NSArray arrayWithObjects:dict3, dict4, nil];
 [enti updateObjects:arr1 toObjects:arr2 name:@"Bill"];
 
 //删除
 result = [enti deleteManagedObject:[NSArray arrayWithObjects:[NSDictionary dictionaryWithObjectsAndKeys:@"22", @"age", nil], [NSDictionary dictionaryWithObjectsAndKeys:@"mogu", @"name", @"32", @"age", nil], nil] entityName:@"Bill"];
 NSLog(@"delete result :%d", result);
 arr = [enti searchWithEntityName:@"Bill" predicate:nil];
 NSLog(@"after delete is:%@", arr);
 
 
 */

