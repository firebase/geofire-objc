
Pod::Spec.new do |s|
s.name             = "GeoFire"
s.version      = "2.0.0"
s.summary      = "Realtime location queries with Firebase."
s.homepage     = "https://github.com/firebase/geofire-objc"
s.license      = 'MIT'
s.author       = "Firebase"
s.source       = { :git => "https://github.com/firebase/geofire-objc.git", :tag => s.version }
s.platform     = :ios, '7.0'
s.source_files = "GeoFire/**/*.{h,m}"
s.ios.dependency  'Firebase', '~> 3.2'
s.framework = 'CoreLocation'
s.requires_arc = true
end
