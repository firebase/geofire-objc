# GeoFire for iOS — Realtime location queries with Firebase

GeoFire is an open-source library for iOS that allows you to store and query a
set of items based on their geographic location.

GeoFire uses [Firebase](https://www.firebase.com/) for data storage, allowing
query results to be updated in realtime as they change.  GeoFire does more than
just measure the distance between locations; *it selectively loads only the
data near certain locations, keeping your applications light and responsive*,
even with extremely large datasets.

## Downloading GeoFire for iOS

In order to use GeoFire in your project, you need to download the framework and
add it to your project.  You also need to [add the Firebase
framework](https://www.firebase.com/docs/ios-quickstart.html) and the
CoreLocation framework to your project.

You can download the latest version of the [GeoFire.framework from
GitHub](dist/GeoFire.framework.zip) or include the GeoFire Xcode project in your
project.

## API Reference

[A full API reference is available here](https://geofire-ios.firebaseapp.com/docs/)

## Quick Start

### GeoFire

A `GeoFire` object is used to read and write geolocation data to your Firebase
and to create queries.

#### Creating a new GeoFire instance

To create a new `GeoFire` instance you need to attach it to a Firebase reference.

```objective-c
Firebase *geofireRef = [[Firebase alloc] initWithUrl:@"https://<your-firebase>.firebaseio.com/"];
GeoFire *geoFire = [[GeoFire alloc] initWithFirebaseRef:geofireRef];
```
Note that you can point your reference to anywhere in your Firebase, but don't
forget to [setup security rules for
GeoFire](https://github.com/firebase/geofire/blob/master/examples/securityRules/rules.json).

#### Setting location data

In GeoFire you can set and query locations by key. To set a location for a key
simply call the `setLocation:forKey` method

```objective-c
[geoFire setLocation:[[CLLocation alloc] initWithLatitude:37.7853889 longitude:-122.4056973]
              forKey:@"firebase-hq"];
```

Alternatively a callback can be passed which is called once the server
successfully saved the location
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

To remove a location and delete the location from Firebase simply call
```objective-c
[geoFire removeKey:@"firebase-hq"];
```

#### Retrieving a location

Retrieving locations happens with callbacks. Like with any Firebase reference,
the callback is called once for the initial position and then for every update
of the location. Like that, your app can always stay up-to-date automatically.

```objective-c
[geoFire observeLocationForKey:@"firebase-hq" withBlock:^(CLLocation *location) {
    if (location == nil) {
        NSLog(@"\"firebase-hq\" has no location");
    } else {
        NSLog(@"New location for \"firebase-hq\": %@", location);
    }
}];
```

### Geo Queries

Locations in an area can be queried with an `GFQuery` object. `GFQuery` objects are created with the `GeoFire` object

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

To observe events for a geo query you can register a callback with `observeEventType:withBlock:`.

```objective-c
FirebaseHandle queryHandle = [query observeEventType:GFEventTypeKeyEntered withBlock:^(NSString *key, CLLocation *location) {
    NSLog(@"Key '%@' entered the search area and is at location '%@'", location);
}];
```

To cancel one or all callbacks for a geo query call `removeObserverWithFirebaseHandle:` or `removeAllObservers`.

#### Waiting for queries to be "ready"

Sometimes it's necessary to know when all key entered events have been fired for
the current data (e.g. to hide a loading animation). `GFQuery` adds a method to
listen to ready events.

```objective-c
[query observeReadyWithBlock:^{
    NSLog(@"All initial key entered events have been fired!");
}];
```

The ready event is triggered once all initial data was loaded from the server
and all key entered events were triggered. A ready event is triggered again each
time the query criteria is updated. Note that key moved and key exited events
might still occur before the ready event was triggered.

To remove a single ready callback call `removeObserverWithFirebaseHandle:`. All
callbacks for a `GFQuery` object can be removed with a call to
`removeAllObservers`.

#### Updating the query criteria

To update the query criteria you can use the `center` and `radius` properties on
the `GFQuery` object. Key exited and key entered events will be triggered for
keys moving in and out of the old and new search area respectively. No key moved
events will be triggered, however key moved events might occur independently.

## Contributing

If you'd like to contribute to GeoFire for iOS, you'll need to run the
following commands to get your environment set up:

```bash
$ git clone https://github.com/firebase/geofire-ios.git
$ cd geofire-ios
$ ./setup.sh
```
