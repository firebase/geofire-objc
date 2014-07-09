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

*TODO: add download link*

## API Reference

### GeoFire

A `GeoFire` object is used to read and write geolocation data to your Firebase
and to create queries.

#### Creating a new GeoFire instance

To create a new GeoFire instance you need to attach it to a Firebase location.

```objective-c
Firebase *firebase = [[Firebase alloc] initWithUrl:@"https://<your-firebase>.firebaseio.com/"];
GeoFire *geoFire = [GeoFire newWithFirebase:firebase];
```
Note that you can point to anywhere in your Firebase.

#### Setting location data

In GeoFire you can set and query locations by key. To set a location for a key
simply call the `setLocation:forKey` method

```objective-c
[geoFire setLocation:CLLocationCoordinate2DMake(37.7853889,-122.4056973) forKey:@"firebase-hq"];
```

Alternatively a callback can be passed passed which is called once the server
successfully saved the location
```objective-c
[geoFire setLocation:CLLocationCoordinate2DMake(37.7853889,-122.4056973)
              forKey:@"firebase-hq"
 withCompletionBlock:^(NSError *error) {
     if (error != nil) {
         NSLog(@"Saved location successfully!");
     } else {
         NSLog(@"An error occured: %@", error);
     }
 }];
```

To remove a location and delete the location from Firebase simply call
```objectice-c
[geoFire removeKey:@"firebase-hq"];
```

#### Retrieving a location

Retrieving locations happens with callbacks. Like with any Firebase reference,
the callback is called for every update of the location. Like that, your app
can always stay up-to-date automatically.

```objective-c
[geoFire observeLocationForKey:@"firebase-hq" withBlock:^(CLLocation *location) {
    NSLog(@"New location for "firebase-hq": %@", location);
}];
```

### Geo Queries

Locations in an area can be queried with an GFQuery object. GFQuery objects are created with the GeoFire object

```objective-c
// Query locations at [37.7832889, -122.4056973] with a radius of 1000 meters
GFQuery query = [geoFire queryAtLocation:CLLocationCoordinate2DMake(37.7832889, -122.4056973) withRadius:1000];
```

#### Receiving events for geo query

There are 3 kind of events that can occur with a geo query:
1. **Key Entered**: The location of a key now matches the search criteria
2. **Key Exited**: The location of a key does not match the search criteria any more
3. **Key Moved**: The location of a key changed and the location still matches the search criteria

To observe events for a geo query you can register a callback with `observeEventType:withBlock:`.

```objective-c
FirebaseHandle queryHandle = [query observeEventType:GFEventTypeKeyEntered withBlock:^(NSString *key, CLLocation *location) {
    NSLog(@"Key '%@' entered the search area and is at location '%@'", location);
}];
```

To cancel one ore all callbacks for a geo query call `removeObserverWithFirebaseHandle:` or `removeAllObservers`.

#### Updating the search criteria

To update the search criteria you can use the `center` and `radius` properties on the GFQuery object.

## Contributing

If you'd like to contribute to GeoFire for iOS, you'll need to run the
following commands to get your environment set up:

```bash
$ git clone https://github.com/firebase/geofire-ios.git
$ cd geofire-ios
$ ./setup.sh
```
