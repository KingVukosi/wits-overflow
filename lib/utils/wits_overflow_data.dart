name: wits_overflow
description: A new Flutter project.

# The following line prevents the package from being accidentally published to
# pub.dev using `pub publish`. This is preferred for private packages.
publish_to: 'none' # Remove this line if you wish to publish to pub.dev

version: 1.0.0+1

environment:
  sdk: ">=2.12.0 <3.0.0"

dependencies:
  flappy_search_bar: ^1.4.1
  fluttertoast: ^8.0.6
  flutter:
    sdk: flutter


  
    
  # The following adds the Cupertino Icons font to your application.
  # Use with the CupertinoIcons class for iOS style icons.
  cupertino_icons: ^1.0.2

  # google and firebase
  firebase_core: ^1.6.0
  firebase_auth: ^3.1.0
  firebase_analytics: ^5.0.2
  cloud_firestore: ^2.5.1
  google_sign_in: ^5.1.0
  firebase_storage: ^10.0.5

  # Local storage
  flutter_secure_storage: ^4.2.0
  universal_html: ^2.0.8

  # svg files
  flutter_svg: ^0.22.0

  # Api requests
  http: ^0.13.2

  # Environmental Variables
  flutter_dotenv: ^4.0.0-nullsafety.0

  image_picker: ^0.8.4+2

  meta: ^1.3.0
  provider: ^5.0.0-nullsafety.3

dev_dependencies:
  flutter_test:
    sdk: flutter

  fake_cloud_firestore: ^1.1.3
  firebase_auth_mocks: ^0.8.0
  google_sign_in_mocks: ^0.2.1

  



# For information on the generic Dart part of this file, see the
# following page: https://dart.dev/tools/pub/pubspec

# The following section is specific to Flutter.
flutter:

  # The following line ensures that the Material Icons font is
  # included with your application, so that you can use the icons in
  # the material Icons class.
  uses-material-design: true

  # To add assets to your application, add an assets section, like this:
  assets:
    - assets/images/
    - assets/icons/
    - env/.env_dev
    - env/.env_pre
    - env/.env_prod

