# SMStorage

### 入门
随着软件架构的不断发展，底层模块会被不断的封装，于是出现了很多第三方库，SMStorage也是其中一个，为什么会提出此项目？开发APP久了，就发现数据固化非常常用，而固化无非就文件、数据库、系统提供（NSUserDefaults、CoreData），那么我们来看下集成这些需要做那些额外工作：

* 文件 - 需要自定义文件格式、序列化、反序列化
* 数据库 - 需要集成sqlite等、orm化
* NSUserDefaults - 比较方便，但只适用于存储小数据
* CoreData - 需要构建Data Model

以上几种，就NSUserDefaults可以成为傻瓜化操作，一行搞定。其他都需要引入第三方库、orm化等等，很麻烦。于是我对数据库进行封装、orm化，并在我原来的项目PPSqliteORM，进一步优化产生了SMStorage，我们来看下效果;

```
Student stu;
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
PS: 『一行搞定』可谓是傻瓜化的最高境界.


### 进价

当然SMStorage还提供了一些高级的用法，比如数据筛选、设置主键（防止重复）

```
//获取名字是张三的学生
[Student sms_read:@"where name='张三'" completion:^(NSArray* objects){
	...
}]
```

### 注意项
目前并没有支持所有数据类型，支持类型如下

[x] NSString
[x] NSDate

