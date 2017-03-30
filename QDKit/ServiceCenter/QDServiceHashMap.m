//
//  QDServiceHashMap.m
//  QDKitDemo
//
//  Created by SongChai on 2017/3/30.
//  Copyright © 2017年 Personal. All rights reserved.
//

#import "QDServiceHashMap.h"
#import <objc/runtime.h>



@interface QDService(link)

- (void) setNextService:(QDService<QDService>*) service;
- (QDService<QDService>*) nextService;

- (void) setLastService:(QDService<QDService>*) service;
- (QDService<QDService>*) lastService;

- (void) clearLink;
@end

@implementation QDService(link)

- (void)setNextService:(QDService<QDService> *)service {
    if (service == nil) {
        return;
    }
    objc_setAssociatedObject(self, @selector(nextService), service, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (QDService<QDService> *)nextService {
    return objc_getAssociatedObject(self, @selector(nextService));
}

- (void)setLastService:(QDService<QDService> *)service {
    if (service == nil) {
        return;
    }
    objc_setAssociatedObject(self, @selector(lastService), service, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (QDService<QDService> *)lastService {
    return objc_getAssociatedObject(self, @selector(lastService));
}

- (void)clearLink {
    objc_removeAssociatedObjects(self);
}
@end

@interface QDServiceHashMap() {
    QDService<QDService>* _headerService;
    NSMutableDictionary* _dictionary;
}
@end

@implementation QDServiceHashMap
@synthesize headerService = _headerService;

- (instancetype)init {
    self = [super init];
    _dictionary = [NSMutableDictionary dictionary];
    return self;
}

- (id)objectForKey:(Class)aKey {
    return [_dictionary objectForKey:NSStringFromClass(aKey)];
}

- (void)setObject:(QDService<QDService> *)anObject forKey:(Class)aKey {
    [_dictionary setObject:anObject forKey:NSStringFromClass(aKey)];
    
    if (_headerService == nil) {
        _headerService = anObject;
    } else {
        [self insertObject:anObject];
    }
    
    [anObject addObserver:self forKeyPath:@"level" options:(NSKeyValueObservingOptionOld|NSKeyValueObservingOptionNew) context:nil];
}

- (void)removeObjectForKey:(Class)aKey {
    QDService* service = [self objectForKey:aKey];
    if (service) {
        [service removeObserver:self forKeyPath:@"level"];
        if (service.lastService) {
            service.lastService.nextService = service.nextService;
        } else {
            _headerService = service.nextService;
            if (_headerService) {
                _headerService.lastService = nil;
            }
        }
        [service clearLink];
    }
    [_dictionary removeObjectForKey:NSStringFromClass(aKey)];
}

- (void)removeAllObjects {
    _headerService = nil;
    for (QDService* service in [_dictionary allValues]) {
        [service clearLink];
        [service removeObserver:self forKeyPath:@"level"];
    }
    [_dictionary removeAllObjects];
}

-(NSArray<QDService<QDService> *> *)allValues{
    if (_headerService) {
        NSMutableArray* result = [[NSMutableArray alloc] initWithCapacity:_dictionary.count];
        QDService<QDService>* root = _headerService;
        while (root) {
            [result addObject:root];
            root = root.nextService;
        }
        return result;
    }
    
    return nil;
}

-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object
                       change:(NSDictionary<NSString *,id> *)change context:(void *)context{
    if([keyPath isEqualToString:@"level"] && [object isKindOfClass:[QDService class]] && [object conformsToProtocol:@protocol(QDService)]) {
        QDService<QDService>* anObj = object;
        
        //清理与obj相关的链表链接  ---> 可以优化
        if (anObj == _headerService) {
            _headerService = anObj.nextService;
            if (_headerService) {
                _headerService.lastService = nil;
            }
        } else {
            anObj.lastService.nextService = anObj.nextService;
            anObj.nextService.lastService = anObj.lastService;
        }
        
        [self insertObject:anObj];
    }
}

- (void) insertObject:(QDService<QDService>*) anObject {
    QDService<QDService>* root = _headerService;
    
    while (true) {
        if (anObject.level > root.level) {
            if (root.lastService) {
                root.lastService.nextService = anObject;
                anObject.lastService = root.lastService;
            } else {
                _headerService = anObject;
            }
            anObject.nextService = root;
            root.lastService = anObject;
            break;
        }
        if (root.nextService) {
            root = root.nextService;
        } else {
            root.nextService = anObject;
            anObject.lastService = root;
            break;
        }
    }
}


- (void)dealloc {
    [self removeAllObjects];
}


@end
