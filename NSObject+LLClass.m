//
//  NSObject+LLClass.m
//  runtime_func
//
//  Created by ll on 2018/7/6.
//  Copyright © 2018年 l. All rights reserved.
//

#import "NSObject+LLClass.h"

@implementation NSObject (LLClass)

+ (NSArray<Class> *)ll_subclasses
{
    NSMutableArray<Class> *subclasses = [NSMutableArray array];
    unsigned int count;
    Class *classes = objc_copyClassList(&count);
    for (unsigned int i = 0; i < count; i++) {
        Class cls = classes[i];
        if (self == class_getSuperclass(cls)) {
            [subclasses addObject:cls];
        }
    }
    free(classes);
    return subclasses.copy;
}

+ (NSArray<Class> *)ll_descendantClasses
{
    _ll_descendantClasses = [NSMutableArray array];
    [self _ll_traversalSubclass];
    return _ll_descendantClasses.copy;
}
NSMutableArray *_ll_descendantClasses;
+ (void)_ll_traversalSubclass
{
    NSArray *subclasses = [self ll_subclasses];
    for (Class cls in subclasses) {
        [_ll_descendantClasses addObject:cls];
        [cls _ll_traversalSubclass];
    }
}

+ (NSDictionary<Class, NSDictionary *> *)ll_descendantClassesTree
{
    _ll_descendantClassesTree = [NSMutableDictionary dictionary];
    [self _ll_traversalSubclassAddToDictionary:_ll_descendantClassesTree];
    return _ll_descendantClassesTree.copy;
}
NSMutableDictionary *_ll_descendantClassesTree;
+ (void)_ll_traversalSubclassAddToDictionary:(NSMutableDictionary *)dictionary
{
    NSArray *subclasses = [self ll_subclasses];
    for (Class cls in subclasses) {
        NSMutableDictionary *mutableDictionary = [NSMutableDictionary dictionary];
        dictionary[(id<NSCopying>)cls] = mutableDictionary;
        [cls _ll_traversalSubclassAddToDictionary:mutableDictionary];
    }
}

+ (NSArray<NSString *> *)ll_ivarNameList
{
    NSMutableArray *ivarArray = [NSMutableArray array];
    unsigned int count;
    Ivar *ivars = class_copyIvarList(self, &count);
    for (unsigned int i = 0; i < count; i++) {
        Ivar v = ivars[i];
        const char * name = ivar_getName(v);
        NSString *ivarName = [[NSString alloc] initWithCString:name encoding:NSUTF8StringEncoding];
        [ivarArray addObject:ivarName];
    }
    free(ivars);
    return ivarArray.copy;
}

+ (NSArray<NSString *> *)ll_methodNameList
{
    NSMutableArray *methodArray = [NSMutableArray array];
    unsigned int count;
    Method *methods = class_copyMethodList(self, &count);
    for (unsigned int i = 0; i < count; i++) {
        Method m = methods[i];
        const char * name = sel_getName(method_getName(m));
        NSString *methodName = [[NSString alloc] initWithCString:name encoding:NSUTF8StringEncoding];
        [methodArray addObject:methodName];
    }
    free(methods);
    return methodArray.copy;
}

+ (NSArray<NSString *> *)ll_protocolNameList
{
    NSMutableArray *protocolArray = [NSMutableArray array];
    unsigned int count;
    Protocol * __unsafe_unretained *protocols = class_copyProtocolList(self, &count);
    for (unsigned int i = 0; i < count; i++) {
        Protocol *protocol = protocols[i];
        const char * name = protocol_getName(protocol);
        NSString *protocolName = [[NSString alloc] initWithCString:name encoding:NSUTF8StringEncoding];
        [protocolArray addObject:protocolName];
    }
    free(protocols);
    return protocolArray.copy;
}

+ (NSSet<NSString *> *)ll_adoptedAllProtocolNameList
{
    _ll_classAdoptedAllProtocolNameList = [NSMutableSet setWithArray:[self ll_protocolNameList]];
    [self _ll_traversalSuperclassProtocol:self];
    NSArray *copyList = _ll_classAdoptedAllProtocolNameList.copy;
    for (NSString *p in copyList) {
        [_ll_classAdoptedAllProtocolNameList addObjectsFromArray:[p ll_adoptedAllProtocolNameList].allObjects];
    }
    return _ll_classAdoptedAllProtocolNameList.copy;
}
NSMutableSet *_ll_classAdoptedAllProtocolNameList;
+ (void)_ll_traversalSuperclassProtocol:(Class)cls
{
    Class superclass = class_getSuperclass(cls);
    if (superclass == Nil) return;
    NSArray *protocols = [superclass ll_protocolNameList];
    if (protocols.count) {
        [_ll_classAdoptedAllProtocolNameList addObjectsFromArray:protocols];
    }
    [self _ll_traversalSuperclassProtocol:superclass];
}

+ (NSArray<NSString *> *)ll_propertyNameList
{
    NSMutableArray *propertyArray = [NSMutableArray array];
    unsigned int count;
    objc_property_t *properties = class_copyPropertyList(self, &count);
    for (unsigned int i = 0; i < count; i++) {
        objc_property_t property = properties[i];
        const char * name = property_getName(property);
        NSString *propertyName = [[NSString alloc] initWithCString:name encoding:NSUTF8StringEncoding];
        [propertyArray addObject:propertyName];
    }
    free(properties);
    return propertyArray.copy;
}

+ (void)ll_swizzleMethod:(SEL)s1 method:(SEL)s2
{
    Method m1 = class_getInstanceMethod(self, s1);
    Method m2 = class_getInstanceMethod(self, s2);
    method_exchangeImplementations(m1, m2);
}

+ (void)ll_swizzleClassMethod:(SEL)s1 method:(SEL)s2
{
    [object_getClass(self) ll_swizzleMethod:s1 method:s2];
}

@end


@implementation NSString (LLProtocol)

- (NSArray<NSString *> *)ll_adoptedProtocolNameList
{
    Protocol *protocol = objc_getProtocol(self.UTF8String);
    if (NULL == protocol) return nil;
    NSMutableArray *protocolArray = [NSMutableArray array];
    unsigned int count;
    Protocol * __unsafe_unretained *protocols = protocol_copyProtocolList(protocol, &count);
    for (unsigned int i = 0; i < count; i++) {
        Protocol *protocol = protocols[i];
        const char * name = protocol_getName(protocol);
        NSString *protocolName = [[NSString alloc] initWithCString:name encoding:NSUTF8StringEncoding];
        [protocolArray addObject:protocolName];
    }
    free(protocols);
    return protocolArray.copy;
}

- (NSSet<NSString *> *)ll_adoptedAllProtocolNameList
{
    _ll_protocolAdoptedAllProtocolNameList = [NSMutableSet set];
    [self _ll_traversalAdoptedProtocol];
    return _ll_protocolAdoptedAllProtocolNameList.copy;
}
NSMutableSet *_ll_protocolAdoptedAllProtocolNameList;
- (void)_ll_traversalAdoptedProtocol
{
    NSArray *protocols = [self ll_adoptedProtocolNameList];
    for (NSString *p in protocols) {
        [_ll_protocolAdoptedAllProtocolNameList addObject:p];
        [p _ll_traversalAdoptedProtocol];
    }
}

@end
