The solution involves ensuring that the observer is removed before the observed object is deallocated.  This prevents the observer from trying to access the memory of a released object.

```objectivec
@interface MyObservedObject : NSObject
@property (nonatomic, strong) NSString *observedProperty;
@end

@implementation MyObservedObject
- (void)dealloc {
    NSLog(@"MyObservedObject deallocated");
}
@end

@interface MyObserver : NSObject
@property (nonatomic, weak) MyObservedObject *observedObject;
@end

@implementation MyObserver
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context {
    // Check if observedObject is still valid before accessing
    if (self.observedObject) {
        NSLog(@"Observed property changed: %@
", [self.observedObject observedProperty]);
    }
}

- (void)removeObserverIfNeeded:(MyObservedObject*) observedObject {
  [observedObject removeObserver:self forKeyPath:@"observedProperty"];
  self.observedObject = nil;
}
@end

int main(int argc, const char * argv[]) {
    @autoreleasepool {
        MyObservedObject *observedObject = [[MyObservedObject alloc] init];
        observedObject.observedProperty = @"Initial Value";
        
        MyObserver *observer = [[MyObserver alloc] init];
        observer.observedObject = observedObject;
        [observedObject addObserver:observer forKeyPath:@"observedProperty" options:NSKeyValueObservingOptionNew context:NULL];
        
        observedObject.observedProperty = @"New Value";
        
        [observer removeObserverIfNeeded:observedObject];
        [observedObject release];
    }
    return 0;
}
```

Here, the observer is removed before the observed object is released. Using `weak` reference also helps.  This prevents crashes by handling potential deallocation scenarios gracefully.