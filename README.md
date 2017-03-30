## 基于动态代理的、IDE友好的事件管理框架

> 本文介绍的框架可以直接查看源码[QBus](https://github.com/droison/iOSBus)

> Android相同思路的实现版本在[CSKit](https://github.com/droison/CSKit)的MMBus文件夹下。

> 在iOS的app开发中，经常会试用NSNotificationCenter进行广播发送与接收，用来实现线程间的低耦合的通信和事件、数据传递，最终实现软件开发的高内聚，低耦合。

> 但使用过程中，发现其最大的问题就是IDE不友好，针对某个NSNotification不能直接通过XCode进行定位到具体的代码实现位置，只能依赖全局搜索，同时也没有针对参数做IDE的校验，所有值的实用都是在运行时才能确定是否正确，无故放弃了编译语言的优势。针对这些痛点，QBus基于iOS的NSProxy的动态代理特性，实现一种IDE友好的NotificationCenter---> QBus。

> 在Android中，MMBus主要针对替换第三方库otto和EventBus，它实现了跨进程的广播通知，利用Java语言的动态代理特性，实现了和iOS部分相同的效果--->IDE友好，编译时类型校验。

### 基础使用
`Subscriber`：

消息订阅者用于订阅消息，首先需要定义一个属于这类消息的协议(protocol)，例如：

    @protocol NightModeChangeProtocol <NSObject>
    - (void) changeNightMode:(BOOL)night;
    @end

然后需要订阅的对象应该实现这个协议，并在需要接收该广播消息的时候调用下面的方法：

    REGISTER_OBSERVER(NightModeChangeProtocol, self);
    //第一个参数为协议名，第二个参数为协议实现者
    
请一定在不需要接收广播的时候反注册掉该广播，否则会造成内存泄露（这里和NotificationCenter一致）：
    
    UNREGISTER_OBSERVER(NightModeChangeProtocol, self);

多个广播也可以用下面方法全部反注册：

    UNREGISTER_ALL_OBSERVER(self);
    
注册和反注册的位置和NSNotificationCenter使用一致。区别主要在于一个传入selector，这里传入协议。

`Publisher`
订阅发布者，相当于`[[NSNotificationCenter defaultCenter] postNotificationName:object:]`，这里使用下面的方法：

    POST_EVENT(NightModeChangeProtocol, changeNightMode:YES);

第一个参数是协议，第二个参数就是这个协议的方法，方法和参数都填上了，cmd+左键可以直接跳转到实现，和正常调用方法没什么不同，当然也可以直接向下面使用：

    [GET_RECEIVER(NightModeChangeProtocol) changeNightMode:YES];

这里就是通过`GET_RECEIVER`宏直接获取这个协议的动态代理，对所有注册者发送消息。

注：这里的默认广播发布都是在主线程接收，无论你在任何线程发送。

### 高级使用
所有的试用其实都是在`QBus.h`中的宏进行了定义，下面介绍几种不常使用的方法：

`接受者线程处理`
订阅者接收广播的线程订制（默认一定在主线程，可以通过宏进行修改为发布者线程）：

    BUS_POSTTHREAD_METHOD(changeNightMode:(BOOL)night)
    {
        NSLog("night: %d", night)
    }
    
其实就是用`BUS_POSTTHREAD_METHOD`宏对该订阅接收的方法进行包装修饰。

`Producer`
事件生产者的作用是用来生产事件，每个新的订阅者进行订阅后，如果存在生产者都会立即对其进行事件发送。这里具体采用listener的方式，即每个订阅者发送都会自动回调到生产者的固定方法中，具体代码实现如下：
    
    [DEFAULT_BUS addRegisterListener:self]; 
    
上面方法表示self要对Bus的订阅者进行订阅监听。self中具体的监听方法应像如下定义：

    BUS_LISTENER_METHOD(onNightChange:(id<NightModeChangeProtocol>)protocol){
        [protocol changeNightMode:YES];
    }

其中`onNightChange`这个方法名可以随意定义，但方法入参有且只能有一个，且应该是id<Protocol>形式，表示监听一类事件的订阅，每个`REGISTER_OBSERVER(NightModeChangeProtocol, self)`这样的函数调用，都会触发上面的方法。该方法的具体实现就可以对其做相应的事件处理了，随便对任何注册者发消息。

其中，默认监听订阅信息的方法调用在注册者线程，如果想在主线程获取新的注册者信息，请用`BUS_LISTENER_MAIN_METHOD`宏进行修饰。

    
### 设计思路
这里主要就是观察值模式和动态代理模式的运用。

下面先写一个publisher post event的示意图，可以看出大概的结构
![](http://198.35.47.181/blog/_resource/QBusPostMsg.jpg)

下面是一个obj在注册成为一个Subscriber的过程
![](http://198.35.47.181/blog/_resource/QBusReg.jpg)

### 三处小技巧
#### 1、NSProxy的运用
这里我们使用了一个继承自NSProxy的派生类QEventProxy来承担消息转发的种人，这个Proxy是能够实现IDE友好和输入类型编译器自查的关键。

OC的消息发送和转发机制我这里就不做描述了，这里主要介绍NSProxy的使用。
OC中几乎所有的Class都是最终继承自NSObject的，这里说几乎，是因为iOS还有另一个root Class-->NSProxy，从名字可以看出来，这个类就是负责消息转发的。

在实际使用中，一个类，例如`QEventProxy`继承自NSProxy，理论上其可以用于替代任何对象，QBus这里就是在`getReceiver`的时候将合适的`QEventProxy`类型强转成了对应的protocol实现，如此编译器就被欺骗以为可以安全的对其send message了。

在派生NSProxy子类的过程中，注意一定要覆写下面两个方法

```Objective-C
- (void)forwardInvocation:(NSInvocation *)anInvocation;
- (NSMethodSignature*)methodSignatureForSelector:(SEL)aSelector;
```

在对该Proxy发送消息时，会先调用第二个方法`methodSignatureForSelector`以判断方法是否有效，为了避免我们不能获取正确的methodSignature，这里我们定义了一个有9个入参的方法`__magicSelector:b:c:d:e:f:g:h:i:j:k:l:m:`帮其生成methodSignature，使其可以正确通过这个方法，进入转发流程。

具体发送消息会走`forwardInvocation`方法，方法入参包含这次消息的全部内容：selector、arguments和selector的methodSignature，默认的target为当前的proxy对象，我们只需要赋给合适的target就实现了消息的动态转发。

#### 2、实用`宏`对方法进行修饰
此处思路基本来自于ReactNative，fb满满的黑科技，在自定义`BridgeModule`时可以通过宏实现注册，而没有任何代码侵入，可以通过宏修饰方法，同样没有代码侵入。思路如下：

该宏在修饰方法的时候，同时为该方法生成一个指定的新方法，这个新房以固定的prefix开头，以代码行数作为对应方法的唯一名称，该新方法的返回值为被修饰方法的整个方法名和需要绑定的修饰参数。代码如下：

```Objective-C
#define BUS_CONCAT2(A, B) A ## B
#define BUS_CONCAT(A, B) BUS_CONCAT2(A, B)

#define BUS_THREAD_METHOD(thread_name, method) \
BUS_EXTERN_REMAP_METHOD(thread_name, method) \
- (void)method


#define BUS_EXTERN_REMAP_METHOD(thread_name, method) \
+ (NSArray<NSString *> *)BUS_CONCAT(__busthread_export__, \
BUS_CONCAT(thread_name, BUS_CONCAT(__LINE__, __COUNTER__))) { \
return @[@#thread_name, @#method]; \
}
```

在运行时，QBus就可以根据固定prefix的方法，获取其返回值，最终拿到方法最终具有的修饰值，不过此处@#method这个参数最终其实为一个方法的命名的字符串，需要对其进行解析，这就涉及第三个小技巧。

#### 3、字符串method的parse
上面第2部分使用宏修饰方法会返回方法的字符串信息，样子像`changeNightMode:(BOOL)night`这样的，我们使用`QParseMethodSignature`这样一个C方法将字符串parse出相应的selector和arguments。

此处主要copy ReactNative中的方法，略作修改，主要处理protocol的问题：

```Objective-C
SEL QParseMethodSignature(NSString *methodSignature, NSArray<NSString *> **arguments)
{
    const char *input = methodSignature.UTF8String;
    QSkipWhitespace(&input);
    
    NSMutableArray *args;
    NSMutableString *selector = [NSMutableString new];
    while (QParseSelectorPart(&input, selector)) {
        if (!args) {
            args = [NSMutableArray new];
        }
        
        // Parse type
        if (QReadChar(&input, '(')) {
            QSkipWhitespace(&input);
            
            QSkipWhitespace(&input);
            
            QSkipWhitespace(&input);
            
            NSString *type = QParseType(&input);
            QSkipWhitespace(&input);
            
            [args addObject:type];
            QSkipWhitespace(&input);
            QReadChar(&input, ')');
            QSkipWhitespace(&input);
        } else {
            // Type defaults to id if unspecified
            [args addObject:@"id"];
        }
        
        // Argument name
        QParseIdentifier(&input, NULL);
        QSkipWhitespace(&input);
    }
    
    *arguments = [args copy];
    return NSSelectorFromString(selector);
}

```

```Objective-C
NSString *QParseType(const char **input)
{
    NSString *type;
    QParseIdentifier(input, &type);
    QSkipWhitespace(input);
    if (QReadChar(input, '<')) {
        QSkipWhitespace(input);
        NSString *subtype = QParseType(input);
        if (QIsCollectionType(type)) {
            if ([type isEqualToString:@"NSDictionary"]) {
                // Dictionaries have both a key *and* value type, but the key type has
                // to be a string for JSON, so we only care about the value type
                if (![subtype isEqualToString:@"NSString"]) {
                    NSLog(@"QBusParserUtils -- %@ is not a valid key type for a JSON dictionary", subtype);
                }
                QSkipWhitespace(input);
                QReadChar(input, ',');
                QSkipWhitespace(input);
                subtype = QParseType(input);
            }
            if (![subtype isEqualToString:@"id"]) {
                type = [type stringByReplacingCharactersInRange:(NSRange){0, 2 /* "NS" */}
                                                     withString:subtype];
            }
        } else {
            // It's a protocol rather than a generic collection - ignore it
            type = subtype;
        }
        QSkipWhitespace(input);
        QReadChar(input, '>');
    }
    QSkipWhitespace(input);
    QReadChar(input, '*');
    return type;
}

```


