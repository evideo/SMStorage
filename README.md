# SMStorage

### 入门
随着软件架构的不断发展，底层模块会被不断的封装，于是出现了很多第三方库，SMStorage也是其中一个，为什么会提出此项目？

开发APP久了，就发现数据固化非常常用，而固化无非就文件、数据库、系统（NSUserDefaults、CoreData），那么我们来看下集成这些需要做那些额外工作：

* 文件 - 需要自定义文件格式、序列化、反序列化
* 数据库 - 需要集成sqlite、orm化
* NSUserDefaults - 比较方便，但只适用于存储小数据
* CoreData - 需要构建Data Model文件，类似另外手动建表

以上几种，就NSUserDefaults可以称作傻瓜化。其他都需要引入第三方库、orm化等等，很麻烦。于是我在原来的项目PPSqliteORM基础上，进一步优化产生了SMStorage，我们来看下效果;

```
Student stu; //学生对象，里面有code、name等属性
...

//存储学生
[stu sms_write:nil];

//读取所有学生
[Student sms_read:nil completion:^(NSArray* objects){
	...
}]

//清空所有学生
[Student sms_clear:nil]

```
PS:『一行搞定』可谓是傻瓜化的最高境界.

### 进价

当然SMStorage还提供了一些高级的用法，比如数据筛选、设置主键（防止对象重复）

```
//获取名字是张三的学生
[Student sms_read:@"where name='张三'" completion:^(NSArray* objects){
	...
}]

//设置主键，如不允许学生编号重复
[Student sms_setPrimaryKey:@"code"];
```

### 扩展

* 1. 目前并没有支持所有数据类型，支持类型如下

- [x] 基础类型 int、float、short、double、NSInteger、NSUInteger、BOOL ...
- [x] NSString
- [x] NSDate
- [x] NSNumber
- [x] CGPoint
- [x] CGSize
- [x] CGRect
- [x] CGVector
- [x] CGAffineTransform
- [x] UIEdgeInsets
- [x] UIOffset
- [x] NSRange

* 2. 主键的意义
默认情况下，主键都是nil，但当需要更新对象、删除对象，则必须设置主键，否则内部无法判断对象唯一性。设置对象的操作也很简单

```
//设置主键，如不允许学生编号重复
[Student sms_setPrimaryKey:@"code"];
```
* 3. 筛选条件语法
在删除、查找对象时，可以传递condition进行筛选过滤，筛选的语法同sql，如

```
//只要张三
@"where name='张三'"

//按名字降序
@"order by name desc"

//只获取前10个记录
@"limit 0, 10"
```

### 许可声明
SMStorage遵循MIT许可，大家可以自由修改，但我希望大家能够把好想法分享给我.