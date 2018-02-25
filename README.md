# GeoFire for iOS — Realtime location queries with Firebase

GeoFire is an open-source library for iOS that allows you to store and query a
set of keys based on their geographic location.

At its heart, GeoFire simply stores locations with string keys. Its main
benefit however, is the possibility of querying keys within a given geographic
area - all in realtime.

GeoFire uses the [Firebase](https://firebase.google.com/?utm_source=geofire-objc) database for
data storage, allowing query results to be updated in realtime as they change.
GeoFire *selectively loads only the data near certain locations, keeping your
applications light and responsive*, even with extremely large datasets.

A compatible GeoFire client is also available for [Java](https://github.com/firebase/geofire-java)
and [JavaScript](https://github.com/firebase/geofire-js).

### Integrating GeoFire with your data

GeoFire is designed as a lightweight add-on to Firebase. However, to keep things
simple, GeoFire stores data in its own format and its own location within
your Firebase database. This allows your existing data format and security rules to
remain unchanged and for you to add GeoFire as an easy solution for geo queries
without modifying your existing data.

### Example Usage
Assume you are building an app to rate bars and you store all information for a
bar, e.g. name, business hours and price range, at `/bars/<bar-id>`. Later, you
want to add the possibility for users to search for bars in their vicinity. This
is where GeoFire comes in. You can store the location for each bar using
GeoFire, using the bar IDs as GeoFire keys. GeoFire then allows you to easily
query which bar IDs (the keys) are nearby. To display any additional information
about the bars, you can load the information for each bar returned by the query
at `/bars/<bar-id>`.


## Upgrading GeoFire

### Upgrading from Geofire 1.x to 2.x

**NOTE: Currently, GeoFire 2.x is not available via CocoaPods, and must be downloaded as source and included in a Firebase 3.x project. You can follow [#48](https://github.com/firebase/geofire-objc/issues/48) for the latest on the CocoaPods release.**

With the [expansion of Firebase at Google I/O 2016](https://firebase.googleblog.com/2016/05/firebase-expands-to-become-unified-app-platform.html), we've added a
number of new features to Firebase, and have changed initialization to incorporate
them more easily. See our [setup instructions](https://firebase.google.com/docs/ios/setup) for more info on installing and initializing the Firebase 3.x.x SDK.

### Upgrading from GeoFire 1.0.x to 1.1.x

With the release of GeoFire for iOS 1.1.0, this library now uses [the new query functionality found in
Firebase 2.0.0](https://firebase.googleblog.com/2014/11/firebase-now-with-more-querying.html). As a
result, you will need to upgrade to Firebase 2.x.x and add a new `.indexOn` rule to your Security
and Firebase Rules to get the best performance. You can view [the updated rules
here](https://github.com/firebase/geofire-js/blob/master/examples/securityRules/rules.json)
and [read our docs for more information about indexing your data](https://firebase.google.com/docs/database/security/indexing-data).


## Downloading GeoFire for iOS

**NOTE: CocoaPods is only available for Firebase 2.x and Geofire 1.x. Download the code directly and include it in your project for now. You can follow [#48](https://github.com/firebase/geofire-objc/issues/48) for the latest on the CocoaPods release.**

If you're using [CocoaPods](http://cocoapods.org/?q=geofire) with Firebase 2.x and GeoFire 1.x, add
the following to your `Podfile`:

```
pod 'GeoFire', '~> 1.1'
```

### Using GeoFire with Swift

GeoFire supports Swift out of the box! In order to use GeoFire and Swift from CocoaPods, add the `use_frameworks!` line to your `Podfile`, like so:

````
use_frameworks!

pod 'GeoFire', '~> 1.1'
````

To use the Firebase 3.x frameworks, you can [download the `Firebase
Database` and `Firebase Analytics` frameworks](https://firebase.google.com/docs/ios/setup#frameworks?utm_source=geofire-objc)
and add them and the `CoreLocation` framework to your project; otherwise, you can use the Firebase 3.x CocoaPods, and include GeoFire as source.

Either way, you must download the GeoFire source code via Github and include it in your project.

```
git clone https://github.com/firebase/geofire-objc.git
```

<!---
You can download the latest version of the [GeoFire.framework from the releases
page](https://github.com/firebase/geofire-objc/releases) or include the GeoFire
Xcode project from this repo in your project.
--->

## Getting Started with Firebase

GeoFire requires the Firebase database in order to store location data. You can [sign up here for a free
account](https://firebase.google.com/console/?utm_source=geofire-objc).


## GeoFire for iOS Quickstart

This is a quickstart on how to use GeoFire's core features. There is also a
[full API reference available
online](https://geofire-ios.firebaseapp.com/docs/).

### GeoFire

A `GeoFire` object is used to read and write geo location data to your Firebase database
and to create queries. To create a new `GeoFire` instance you need to attach it to a Firebase database reference:

##### Objective-C
```objective-c
FIRDatabaseRef *geofireRef = [[FIRDatabase database] reference];
GeoFire *geoFire = [[GeoFire alloc] initWithFirebaseRef:geofireRef];
```

##### Swift
````swift
let geofireRef = FIRDatabase.database().reference()
let geoFire = GeoFire(firebaseRef: geofireRef)
````

Note that you can point your reference to anywhere in your Firebase database, but don't
forget to [set up security rules for
GeoFire](https://github.com/firebase/geofire-js/blob/master/examples/securityRules).

#### Setting location data

In GeoFire you can set and query locations by string keys. To set a location for a key
simply call the `setLocation:forKey` method:

##### Objective-C
```objective-c
[geoFire setLocation:[[CLLocation alloc] initWithLatitude:37.7853889 longitude:-122.4056973]
              forKey:@"firebase-hq"];
```

##### Swift
````swift
geoFire.setLocation(CLLocation(latitude: 37.7853889, longitude: -122.4056973), forKey: "firebase-hq")
````

Alternatively a callback can be passed which is called once the server
successfully saves the location:

##### Objective-C
```objective-c
[geoFire setLocation:[[CLLocation alloc] initWithLatitude:37.7853889 longitude:-122.4056973]
              forKey:@"firebase-hq"
 withCompletionBlock:^(NSError *error) {
     if (error != nil) {
         NSLog(@"An error occurred: %@", error);
     } else {
         NSLog(@"Saved location successfully!");
     }
 }];
```

##### Swift
````swift
geoFire.setLocation(CLLocation(latitude: 37.7853889, longitude: -122.4056973), forKey: "firebase-hq") { (error) in
  if (error != nil) {
    print("An error occured: \(error)")
  } else {
    print("Saved location successfully!")
  }
}
````

To remove a location and delete the location from your database simply call:

##### Objective-C
```objective-c
[geoFire removeKey:@"firebase-hq"];
```

##### Swift
````swift
geoFire.removeKey("firebase-hq")
````

#### Retrieving a location

Retrieving locations happens with callbacks. If the key is not present in
GeoFire, the callback will be called with `nil`. If an error occurred, the
callback is passed the error and the location will be `nil`.

##### Objective-C
```objective-c
[geoFire getLocationForKey:@"firebase-hq" withCallback:^(CLLocation *location, NSError *error) {
    if (error != nil) {
        NSLog(@"An error occurred getting the location for \"firebase-hq\": %@", [error localizedDescription]);
    } else if (location != nil) {
        NSLog(@"Location for \"firebase-hq\" is [%f, %f]",
              location.coordinate.latitude,
              location.coordinate.longitude);
    } else {
        NSLog(@"GeoFire does not contain a location for \"firebase-hq\"");
    }
}];
```

##### Swift
````swift
geoFire.getLocationForKey("firebase-hq") { (location, error) in
  if (error != nil) {
    print("An error occurred getting the location for \"firebase-hq\": \(error.localizedDescription)")
  } else if (location != nil) {
    print("Location for \"firebase-hq\" is [\(location.coordinate.latitude), \(location.coordinate.longitude)]")
  } else {
    print("GeoFire does not contain a location for \"firebase-hq\"")
  }
}
````

### Geo Queries

GeoFire allows you to query all keys within a geographic area using `GFQuery`
objects. As the locations for keys change, the query is updated in realtime and fires events
letting you know if any relevant keys have moved. `GFQuery` parameters can be updated
later to change the size and center of the queried area.

##### Objective-C
```objective-c
CLLocation *center = [[CLLocation alloc] initWithLatitude:37.7832889 longitude:-122.4056973];
// Query locations at [37.7832889, -122.4056973] with a radius of 600 meters
GFCircleQuery *circleQuery = [geoFire queryAtLocation:center withRadius:0.6];

// Query location by region
MKCoordinateSpan span = MKCoordinateSpanMake(0.001, 0.001);
MKCoordinateRegion region = MKCoordinateRegionMake(center.coordinate, span);
GFRegionQuery *regionQuery = [geoFire queryWithRegion:region];
```

#### Swift
````swift
let center = CLLocation(latitude: 37.7832889, longitude: -122.4056973)
// Query locations at [37.7832889, -122.4056973] with a radius of 600 meters
var circleQuery = geoFire.queryAtLocation(center, withRadius: 0.6)

// Query location by region
let span = MKCoordinateSpanMake(0.001, 0.001)
let region = MKCoordinateRegionMake(center.coordinate, span)
var regionQuery = geoFire.queryWithRegion(region)
````

#### Receiving events for geo queries

There are three kinds of events that can occur with a geo query:

1. **Key Entered**: The location of a key now matches the query criteria.
2. **Key Exited**: The location of a key no longer matches the query criteria.
3. **Key Moved**: The location of a key changed but the location still matches the query criteria.

Key entered events will be fired for all keys initially matching the query as well as any time
afterwards that a key enters the query. Key moved and key exited events are guaranteed to be
preceded by a key entered event.

To observe events for a geo query you can register a callback with `observeEventType:withBlock:`:

##### Objective-C
```objective-c
FIRDatabaseHandle queryHandle = [query observeEventType:GFEventTypeKeyEntered withBlock:^(NSString *key, CLLocation *location) {
    NSLog(@"Key '%@' entered the search area and is at location '%@'", key, location);
}];
```

##### Swift
````swift

var queryHandle = query.observeEventType(.KeyEntered, withBlock: { (key: String!, location: CLLocation!) in
  print("Key '\(key)' entered the search area and is at location '\(location)'")
})

````

To cancel one or all callbacks for a geo query, call
`removeObserverWithFirebaseHandle:` or `removeAllObservers:`, respectively.

#### Waiting for queries to be "ready"

Sometimes you want to know when the data for all the initial keys has been
loaded from the server and the corresponding events for those keys have been
fired. For example, you may want to hide a loading animation after your data has
fully loaded. `GFQuery` offers a method to listen for these ready events:

##### Objective-C
```objective-c
[query observeReadyWithBlock:^{
    NSLog(@"All initial data has been loaded and events have been fired!");
}];
```

##### Swift
````swift

query.observeReadyWithBlock({
  print("All initial data has been loaded and events have been fired!")
})

````

Note that locations might change while initially loading the data and key moved and key
exited events might therefore still occur before the ready event was fired.

When the query criteria is updated, the existing locations are re-queried and the
ready event is fired again once all events for the updated query have been
fired. This includes key exited events for keys that no longer match the query.

#### Updating the query criteria

To update the query criteria you can use the `center` and `radius` properties on
the `GFQuery` object. Key exited and key entered events will be fired for
keys moving in and out of the old and new search area, respectively. No key moved
events will be fired as a result of the query criteria changing; however, key moved
events might occur independently.


## API Reference

[A full API reference is available here](https://geofire-ios.firebaseapp.com/docs/).

## Deployment

- `git pull` to update the master branch
- tag and push the tag for this release
- `./build.sh` to build a binary
- From your macbook that already has been granted permissions to Firebase CocoaPods, do `pod trunk push`
- Update [firebase-versions](https://github.com/firebase/firebase-clients/blob/master/versions/firebase-versions.json) with the changelog for this release.
- Add the compiled `target/GeoFire.framework.zip` to the release

## Contributing

If you'd like to contribute to GeoFire for iOS, you'll need to run the
following commands to get your environment set up:


```bash
$ git clone https://github.com/firebase/geofire-objc.git
$ cd geofire-objc
$ pod install
$ open Geofire.xcworkspace
```
