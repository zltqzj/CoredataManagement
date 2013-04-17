//
//  EntityManager.m
//  RabitRun
//
//  Created by zj on 13-04-16.
//  Copyright zj. All rights reserved.
//

#import "EntityManager.h"

@implementation EntityManager

// 返回实体管理对象
+ (EntityManager *)createManager:(NSString*)_dbname
{
    return [[[self class] alloc] init:_dbname];
}

- (id)init:(NSString*)_dbname
{
    if (self = [super init]) {
        
        // 创建管理对象模型（数据库的名字需要修改）
        
        NSString *modelPath = [[NSBundle mainBundle] pathForResource:_dbname ofType:@"momd"];
        NSURL *modelURL = [NSURL fileURLWithPath:modelPath];
        _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
        
        NSError *error = nil;
        _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:_managedObjectModel];
        
        NSURL *storeURL = [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
        
        storeURL = [storeURL URLByAppendingPathComponent:[NSString stringWithFormat:@"%@.sqlite",_dbname]];
        [_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error];
        if (error) {
            self.lastError = error;
        }
        
        _managedObjectContext = [[NSManagedObjectContext alloc] init];
        [_managedObjectContext setPersistentStoreCoordinator:_persistentStoreCoordinator];
        [_managedObjectContext setMergePolicy:NSOverwriteMergePolicy];
    }
    return self;
}

- (void)dealloc
{
    [_managedObjectModel release];
    [_persistentStoreCoordinator release];
    [_managedObjectContext release];
    self.lastError = nil;
    [super dealloc];
}



#pragma mark - Insert
- (BOOL)insert:(NSArray *)array entityName:(NSString *)entityName
{
    if (![self isEntityName:entityName]) {
        return NO;
    }
    __block BOOL flag = YES;
    [array enumerateObjectsUsingBlock: ^(id obj, NSUInteger idx, BOOL *stop){
        @synchronized(self)
        {
            if(![self manageObjectsFromDict:obj entityName:entityName])//判断是否重复插入
            {
                NSEntityDescription *descrip = [NSEntityDescription entityForName:entityName inManagedObjectContext:_managedObjectContext];
                if (descrip == nil){
                    self.lastError = [NSError errorWithDomain:@"create NSEntityDescription faild!" code:1 userInfo:nil];
                    flag = NO;
                    return;
                }
                NSManagedObject *object = [[NSManagedObject alloc] initWithEntity:descrip insertIntoManagedObjectContext:_managedObjectContext];
                
                NSDictionary *dict = (NSDictionary *)obj;
                [dict enumerateKeysAndObjectsUsingBlock: ^(id key, id obj, BOOL *stop){
                    [object setValue:obj forKey:key];
                }];
                [_managedObjectContext insertObject:object];
                [self save];
            }
            else
                NSLog(@"数据重复");
            
        }
    }];
    return flag;
}

#pragma mark - Delete

- (BOOL)deleteManagedObject:(NSArray *)array entityName:(NSString *)entityName
{
    if (![self isEntityName:entityName]) {
        return NO;
    }
    __block BOOL flag = YES;
    @synchronized(self)
    {
        [array enumerateObjectsUsingBlock: ^(id obj, NSUInteger idx, BOOL *stop){
            if (![obj isKindOfClass:[NSDictionary class]])
            {
                flag = NO;
                return;
            }
            NSArray *objects = [self manageObjectsFromDict:obj entityName:entityName];
            if (objects == nil) {
                flag = NO;
                return;
            }
            [objects enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop){
                [_managedObjectContext deleteObject:obj];
                [self save];
            }];
        }];
    }
    return flag;
}

#pragma mark - Update

- (BOOL)updateObjects:(NSArray *)start toObjects:(NSArray *)result name:(NSString *)entityName
{
    if (![self isEntityName:entityName] ||start == nil || result == nil || start.count != result.count){
        return NO;
    }
    __block BOOL flag = YES;
    @synchronized(self)
    {
        [start enumerateObjectsUsingBlock: ^(id obj, NSUInteger idx, BOOL *stop){
            NSManagedObject *manageObj = [[self manageObjectsFromDict:obj entityName:entityName] lastObject];
            if (!manageObj) {
                flag = NO;
                return;
            }
            NSDictionary *dict = [result objectAtIndex:idx];
            NSDictionary *firstDic = (NSDictionary *)obj;
            [firstDic enumerateKeysAndObjectsUsingBlock: ^(id key, id obj, BOOL *stop){
                [manageObj setValue:[dict objectForKey:key] forKey:key];
            }];
            
            [_managedObjectContext refreshObject:manageObj mergeChanges:YES];
            [self save];
        }];
    }
    return flag;
}



#pragma mark - Search
- (NSArray *)searchWithEntityName:(NSString *)entityName predicate:(NSDictionary *)predicate
{
    if (![self isEntityName:entityName]) {
        return nil;
    }
    NSPredicate *pre = [self predicateWithDictionary:predicate];
    NSFetchRequest *requset = [NSFetchRequest fetchRequestWithEntityName:entityName];
    [requset setPredicate: pre];
    NSArray *array = [_managedObjectContext executeFetchRequest:requset error:nil];
    return [self arrayWithManagedObjects:array];
}


#pragma mark - 持久化
- (BOOL)save
{
    NSError *error = nil;
    @synchronized(self)
    {
        [_managedObjectContext save:&error];
    }
    if (error) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:[error domain] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
        [alert show];
        [alert release];
        self.lastError = error;
        return NO;
    }
    return YES;
}

#pragma mark - customMethod
// 条件，参数为字典类型。
- (NSPredicate *)predicateWithDictionary:(NSDictionary *)dict
{
    @synchronized(self)
    {
        NSPredicate *pre = nil;
        if (dict) {
            NSMutableString *str = [NSMutableString string];
            __block int idx = 0;
            [dict enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop){
                if (idx == 0) {
                    [str appendFormat:@"%@ == '%@'", key, obj];
                    idx++;
                }
                else
                    [str appendFormat:@" && %@ == '%@'", key, obj];
            }];
            NSString *string = [NSString stringWithFormat:@" %@ %@ %@ ", @"(", str, @")"];
            pre = [NSPredicate predicateWithFormat: string];
        }
        return pre;
    }
}

//把包含NSManagedObject的数组 转换成 包含字典的数组
- (NSArray *)arrayWithManagedObjects:(NSArray *)objects
{
    @synchronized(self)
    {
        NSMutableArray *retArray = [NSMutableArray array];
        if (objects){
            NSManagedObject *object = [objects objectAtIndex:0];
            NSArray *keys = [[[object entity] propertiesByName] allKeys];
            
            [objects enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop){
                NSManagedObject *manageObj = (NSManagedObject *)obj;
                NSMutableDictionary *dict = [NSMutableDictionary dictionary];
                [keys enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop){
                    [dict setValue:[manageObj valueForKey:obj] forKey:obj];
                }];
                [retArray addObject:dict];
            }];
        }
        return retArray;
    }
}


// 用字典 查找匹配的 NSManagedObject
- (NSArray *)manageObjectsFromDict:(NSDictionary *)dict entityName:(NSString *)entityName
{
    NSPredicate *predicate = [self predicateWithDictionary:dict];
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:entityName];
    if (request == nil) {
        return nil;
    }
    [request setPredicate:predicate];
    NSError *error = nil;
    NSArray *objects = [_managedObjectContext executeFetchRequest:request error:&error];
    if (error || !objects || objects.count == 0) {
        self.lastError = error;
        return nil;
    }
    return objects;
}

// 判断实体名字
- (BOOL)isEntityName:(NSString *)entityName
{
    NSArray *names = [[_managedObjectModel entitiesByName] allKeys];
    __block BOOL flag = NO;
    [names enumerateObjectsUsingBlock: ^(id obj, NSUInteger idx, BOOL *stop){
        if ([entityName isEqualToString:obj]) {
            flag = YES;
            return;
        }
    }];
    return flag;
}




@end
