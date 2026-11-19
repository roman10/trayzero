# Android release signing

Release builds (`flutter build appbundle --release`) need a Java keystore.
The keystore and credentials are intentionally NOT in source control.

## One-time setup

```bash
cd mobile/android

# Generate the upload keystore. KEEP THIS FILE AND PASSWORD SAFE — losing it
# means you can never publish another update under the same Play listing.
# PKCS12 is the modern default; JKS is deprecated.
keytool -genkeypair -v \
  -keystore app/upload-keystore.jks \
  -keyalg RSA -keysize 2048 -validity 10000 \
  -alias upload \
  -storetype PKCS12

# Create key.properties (gitignored). Replace passwords + alias.
# storeFile is resolved relative to the :app module, so the path is the
# bare filename (not "app/upload-keystore.jks").
cat > key.properties <<EOF
storeFile=upload-keystore.jks
storePassword=CHANGE_ME
keyAlias=upload
keyPassword=CHANGE_ME
EOF
```

## Verify

```bash
cd mobile
flutter build appbundle --release
# → build/app/outputs/bundle/release/app-release.aab
```

## CI signing (recommended)

Encode the keystore once: `base64 -i mobile/android/app/upload-keystore.jks | pbcopy`
and store as `ANDROID_KEYSTORE_BASE64` in GitHub Actions secrets, plus
`ANDROID_KEY_PASSWORD`, `ANDROID_KEY_ALIAS`, `ANDROID_STORE_PASSWORD`. Then in
the release workflow:

```yaml
- name: Decode keystore
  run: |
    echo "${{ secrets.ANDROID_KEYSTORE_BASE64 }}" | base64 --decode > mobile/android/app/upload-keystore.jks
- name: Write key.properties
  run: |
    cat > mobile/android/key.properties <<EOF
    storeFile=app/upload-keystore.jks
    storePassword=${{ secrets.ANDROID_STORE_PASSWORD }}
    keyAlias=${{ secrets.ANDROID_KEY_ALIAS }}
    keyPassword=${{ secrets.ANDROID_KEY_PASSWORD }}
    EOF
```

## Backup

Back up `upload-keystore.jks` + the password to **two** places (e.g. 1Password
+ a printed paper copy in a safe). If you lose them, you cannot ship updates
to the existing Play listing — you would have to publish a new app under a
new package name, losing reviews / installs.
