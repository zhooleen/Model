# Model
Automatically convert JSON to model,  archive/unarchive model, convert model to JSON

> 有很多开源的框架能实现JSON与MODEL之间的互相自动转换，也能实现自动序列化与反序列化。
> 
> 很好奇！
> 
> 学习了Objective－C runtime,于是乎，写就了这个demo
>
> 当然，在自己的项目中加入自己写的demo的实现，也是很不错的选择。

#Usage
1. Declare & implementation a Model, just named XYZModel
```Objective-C
typedef XYZProperty @property(strong, nonatomic, nonatomic)
@interface XYZModel : RTModel
XYZProperty NSString *title;
XYZProperty NSString *subtitle;
@end @implementation XYZModel @end
```
2. test it
```Objective-C
NSDictionary *json = @{@"title":@"You are a nice man.",
                      @"subtitle":@"But I just treat you as my brother."};
XYZModel *model = [[XYZModel alloc] initWithJSON:json];
NSDictionary *json2 = model.JSONObject;
//compare json & json2
```
