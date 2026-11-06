# Android release signing

The build uses debug signing when `android/key.properties` is absent. To sign
an APK or app bundle for your own distribution, create a keystore with
`keytool` and set the following values in `android/key.properties`.

```properties
storeFile=/absolute/path/to/your-keystore.p12
storePassword=YOUR_STORE_PASSWORD
keyAlias=YOUR_KEY_ALIAS
keyPassword=YOUR_KEY_PASSWORD
```

Keep the keystore and properties file out of version control. Run
`flutter build apk --release` or `flutter build appbundle --release` from the
repository root.
