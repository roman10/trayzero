# Android image picker sampling patch

Vendored from the pub.dev `image_picker_android` 0.8.13+17 package, retaining
its BSD license. Only `android`, `lib`, and package metadata are included;
the upstream example app and Dart tests are omitted. Android tests are retained.

`ImageResizer` previously calculated `inSampleSize` using a fresh, undecoded
`BitmapFactory.Options` object. Its dimensions were zero, so every pixel decode
used sample size 1. This patch uses the dimensions already returned by the
bounds-only decode. Final resize dimensions, compression, and EXIF copying are
unchanged.

Regression tests intercept the actual pixel decode options for large landscape
and portrait images, both-axis limits, quality-only compression, and small images.

Run with JDK 21 (required by the upstream Android SDK 36 Robolectric tests)
from `mobile/android` after `flutter pub get` in `mobile`:

```sh
./gradlew :image_picker_android:testDebugUnitTest
```

Remove the path override and this directory once a compatible upstream release
contains the fix and passes these regression cases. Do not edit the global pub
cache. Upstream source:
https://github.com/flutter/packages/tree/main/packages/image_picker/image_picker_android
