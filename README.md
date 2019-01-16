# LLRuntime

### 通过该NSObject的分类，可以更简单地使用runtime函数

##### 获取某个类的所有直接子类，比如：``` [UIScrollView ll_subclasses] ```

##### 获取某个类的所有直接和间接子类，比如：``` [UIScrollView ll_descendantClassesTree] ```
返回的是一个字典，用以展示子类的继承树，形式如：
```objc
{
    NSObject : {
                    UIResponder : {
                                        UIView: { ... }

                                        ...
                                   }

                    ...
                }
}
```
##### 其他方法还有
* 获取某个类的所有实例变量
* 获取某个类的所有实例方法
* 获取某个类遵守的协议
* Method Swizzling 方法交换
* ...
