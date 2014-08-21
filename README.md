# GeoFire for iOS — Realtime location queries with Firebase

GeoFire is an open-source library for iOS that allows you to store and query a
set of keys based on their geographic location.

At its heart, GeoFire simply stores locations with string keys. Its main
benefit however, is the possibility of querying keys within a given geographic
area - all in realtime.

GeoFire uses [Firebase](https://www.firebase.com/) for data storage, allowing
query results to be updated in realtime as they change. GeoFire *selectively
loads only the data near certain locations, keeping your applications light and
responsive*, even with extremely large datasets.

### Integrating GeoFire with your data

GeoFire is designed as a lightweight add-on to Firebase. However, to keep things
simple, GeoFire stores data in its own format and its own location within
your Firebase. This allows your existing data format and security rules to
remain unchanged and for you to add GeoFire as an easy solution for geo queries
without modifying your existing data.

#### Example
Assume you are building an app to rate bars and you store all information for a
bar, e.g. name, business hours and price range, at `/bars/<bar-id>`. Later, you
want to add the possibility for users to search for bars in their vicinity. This
is where GeoFire comes in. You can store the location for each bar using
GeoFire, using the bar IDs as GeoFire keys. GeoFire then allows you to easily
query which bar IDs (the keys) are nearby. To display any additional information
about the bars, you can load the information for each bar returned by the query
at `/bars/<bar-id>`.

## GeoFire for iOS Beta

GeoFire for iOS is still in an open beta. It will be ready for your production
applications soon, but the API is subject to change until then.

## Downloading GeoFire for iOS

In order to use GeoFire in your project, you need to download the framework and
add it to your project. You also need to [add the Firebase
framework](https://www.firebase.com/docs/ios-quickstart.html) and the
CoreLocation framework to your project.

You can download the latest version of the [GeoFire.framework from
GitHub](dist/GeoFire.framework.zip) or include the GeoFire Xcode project in your
project.

## Quick Start

This is a quick start on how to use GeoFire's core features. There is also a
[full API reference available
online](https://geofire-ios.firebaseapp.com/docs/).

### GeoFire

A `GeoFire` object is used to read and write geo location data to your Firebase
and to create queries.

#### Creating a new GeoFire instance

To create a new `GeoFire` instance you need to attach it to a Firebase reference:

```objective-c
Firebase *geofireRef = [[Firebase alloc] initWithUrl:@"https://<your-firebase>.firebaseio.com/"];
GeoFire *geoFire = [[GeoFire alloc] initWithFirebaseRef:geofireRef];
```
Note that you can point your reference to anywhere in your Firebase, but don't
forget to [setup security rules for
GeoFire](https://github.com/firebase/geofire/blob/master/examples/securityRules/rules.json).

#### Setting location data

In GeoFire you can set and query locations by string keys. To set a location for a key
simply call the `setLocation:forKey` method:

```objective-c
[geoFire setLocation:[[CLLocation alloc] initWithLatitude:37.7853889 longitude:-122.4056973]
              forKey:@"firebase-hq"];
```

Alternatively a callback can be passed which is called once the server
successfully saved the location:
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

To remove a location and delete the location from Firebase simply call:
```objective-c
[geoFire removeKey:@"firebase-hq"];
```

#### Retrieving a location

Retrieving locations happens with callbacks. If the key is not present in
GeoFire, the callback will be called with `nil`. If an error occurred, the
callback is passed the error and location will be `nil`.

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

### Geo Queries

GeoFire allows to query all keys within a geographic area using `GFQuery`
objects. If locations for keys change the query will be updated in realtime (see
"Receiving events for geo queries" below). `GFQuery` parameters can be updated
later to change the size and center of the area that is queried.

```objective-c
CLLocation *center = [[CLLocation alloc] initWithLatitude:37.7832889 longitude:-122.4056973];
// Query locations at [37.7832889, -122.4056973] with a radius of 600 meters
GFCircleQuery *circleQuery = [geoFire queryAtLocation:center withRadius:0.6];

// Query location by region
MKCoordinateSpan span = MKCoordinateSpanMake(0.001, 0.001);
MKCoordinateRegion region = MKCoordinateRegionMake(center.coordinate, span);
GFRegionQuery *regionQuery = [geoFire queryWithRegion:region];
```

#### Receiving events for geo queries

There are 3 kind of events that can occur with a geo query:

1. **Key Entered**: The location of a key now matches the query criteria
2. **Key Exited**: The location of a key does not match the query criteria any more
3. **Key Moved**: The location of a key changed and the location still matches the query criteria

Key entered events will be fired for all keys initially matching the query. Key
moved and key exited events are guaranteed to be preceded by a key entered
event.

To observe events for a geo query you can register a callback with `observeEventType:withBlock:`:

```objective-c
FirebaseHandle queryHandle = [query observeEventType:GFEventTypeKeyEntered withBlock:^(NSString *key, CLLocation *location) {
    NSLog(@"Key '%@' entered the search area and is at location '%@'", key, location);
}];
```

To cancel one or all callbacks for a geo query call
`removeObserverWithFirebaseHandle:` or `removeAllObservers`, respectively.

#### Waiting for queries to be "ready"

Sometimes you want to know when the data for all the initial keys has been
loaded from the server and the corresponding events for those keys have been
fired. For example, you may want to hide a loading animation after your data has
fully loaded. `GFQuery` offers a method to listen for these ready events:

```objective-c
[query observeReadyWithBlock:^{
    NSLog(@"All initial key entered events have been fired!");
}];
```

Note that locations might change while loading the data and key moved and key
exited events might therefore still occur before the ready event was fired. If
the query criteria is updated, the new data is loaded from the server and the
ready event is fired again once all events for the updated query have been
fired. This includes key exited events for keys that no longer match the query.

#### Updating the query criteria

To update the query criteria you can use the `center` and `radius` properties on
the `GFQuery` object. Key exited and key entered events will be fired for
keys moving in and out of the old and new search area, respectively. No key moved
events will be fired; however, key moved events might occur independently.

## API Reference

[A full API reference is available here](https://geofire-ios.firebaseapp.com/docs/)

## Contributing

If you'd like to contribute to GeoFire for iOS, you'll need to run the
following commands to get your environment set up:

```bash
$ git clone https://github.com/firebase/geofire-ios.git
$ cd geofire-ios
$ ./setup.sh
```
