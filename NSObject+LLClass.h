//
//  NSObject+LLClass.h
//  runtime_func
//
//  Created by ll on 2018/7/6.
//  Copyright © 2018年 l. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <objc/runtime.h>

@interface NSObject (LLClass)

/**
 * 获取该类的所有直接子类
 * @return 所有直接子类所在的数组
 */
+ (NSArray<Class> *)ll_subclasses;

/**
 * 获取该类的所有直接子类和间接子类
 * @return 所有直接子类和间接子类所在的数组
 */
+ (NSArray<Class> *)ll_descendantClasses;

/**
 * 获取该类的所有直接子类和间接子类
 *
 * {
 *    NSObject : {
 *                    UIResponder : {
 *                                        UIView: { ... }
 *
 *                                        ...
 *                                   }
 *
 *                    ...
 *                }
 * }
 * @return 所有子类所在的字典，key为直接子类 value为间接子类所在的字典
 */
+ (NSDictionary<Class, NSDictionary *> *)ll_descendantClassesTree;

/**
 * 获取该类的所有实例变量
 * @return 所有实例变量名称所在的数组
 */
+ (NSArray<NSString *> *)ll_ivarNameList;

/**
 * 获取该类的所有实例方法
 * @return 所有实例方法名称所在的数组
 */
+ (NSArray<NSString *> *)ll_methodNameList;

/**
 * 获取该类遵守的协议（不包括父类所遵守的）
 * @return 遵守的协议名称所在的数组
 */
+ (NSArray<NSString *> *)ll_protocolNameList;

/**
 * 获取该类遵守的所有协议，包括所有父类遵守的协议和协议遵守的协议
 * @return 遵守的协议名称所在的集合
 */
+ (NSSet<NSString *> *)ll_adoptedAllProtocolNameList;

/**
 * 获取该类的实例的所有属性
 * @return 实例所有属性名称所在的数组
 */
+ (NSArray<NSString *> *)ll_propertyNameList;

@end


@interface NSString (LLProtocol)

/**
 * 该协议直接遵守的协议
 * @return 协议名称所在的数组
 */
- (NSArray<NSString *> *)ll_adoptedProtocolNameList;

/**
 * 该协议遵守的所有协议，包括直接遵守和间接遵守的
 * @return 协议名称所在的集合
 */
- (NSSet<NSString *> *)ll_adoptedAllProtocolNameList;

@end
