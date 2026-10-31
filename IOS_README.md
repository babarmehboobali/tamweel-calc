# iPhone (iOS) version — step-by-step (no Mac needed)

App: **Loan Calculator: Tamweel & EMI** · Bundle ID: `com.tamweel.calculator` · Home-screen name: "Loan Calculator" (Arabic phones: "حاسبة التمويل")
Code branch: GitHub `babarmehboobali/tamweel-calc`, branch **`ios`** (the `main` branch is your website — never build from it).
Builds run on **Codemagic** cloud Macs, so you never need a Mac.

---
## Step 1 — Apple Developer account ($99/year)
1. Finish recovering your Apple ID (iforgot.apple.com). Turn on two-factor authentication.
2. Install the **Apple Developer** app on any phone/tablet (or use https://developer.apple.com/programs/enroll/ in a browser).
3. Sign in → **Enroll** → **Individual** → pay $99. Approval: usually 24–48 h. You get an email "Welcome to the Apple Developer Program".

## Step 2 — Create the app in App Store Connect
1. https://appstoreconnect.apple.com → **Apps** → **+** → **New App**.
2. Platform **iOS** · Name `Loan Calculator: Tamweel & EMI` · Primary language **English (U.S.)** · Bundle ID: choose **com.tamweel.calculator** (if it's not in the list, first create it at developer.apple.com → Certificates, IDs & Profiles → Identifiers → **+** → App IDs → App → Explicit `com.tamweel.calculator`) · SKU `tamweel-calc-ios` · Full access.
3. Open **App Information** and copy the **Apple ID** number (e.g. 6740000000). Put it in `codemagic.yaml` → `APP_STORE_APPLE_ID` (or tell Grok Bot).
4. Fill the listing from `store/ios/APP_STORE_LISTING.md` (name, subtitle, keywords, description, URLs, category Finance, age rating, App Privacy). Add the **Arabic** localization with the Arabic texts.
5. Screenshots: upload `store/ios/screenshots/6.9in/en/*` (and `ar/*` in the Arabic page). The 6.5in set is optional backup.

## Step 3 — App Store Connect API key (lets Codemagic sign & upload)
1. App Store Connect → **Users and Access** → **Integrations** → **App Store Connect API** → **Team Keys** → **Generate API Key**.
2. Name `Codemagic`, Access **App Manager** → Generate.
3. **Download the .p8 file** (only possible ONCE — keep it in Drive `03_Signing_Keys`). Note the **Key ID** and the **Issuer ID** shown at the top.

## Step 4 — iOS app in AdMob (separate from Android!)
1. https://apps.admob.com → **Apps** → **Add app** → **iOS** → "Is the app listed?" **No** (link it after it's live) → name `Tamweel Calc iOS`.
2. Copy the **App ID** (`ca-app-pub-1235513372019694~XXXXXXXXXX`) → paste into `ios/Flutter/Release.xcconfig` on line `GAD_APPLICATION_ID = ...` (replace the Google sample ID).
3. Create 4 ad units (Banner, Interstitial, Rewarded, App open) and paste their IDs into `lib/services/ads/ad_ids.dart`:
   `realBannerIos`, `realInterstitialIos`, `realRewardedIos`, `realAppOpenIos`.
   While these are empty, the iPhone app shows Google **test** ads (safe, but no income).
4. AdMob → Privacy & messaging: make sure the GDPR message also covers the iOS app, and create an **IDFA explainer** message (optional, recommended).
5. Never tap your own ads.
(Grok Bot can do steps 2–3 edits for you — just send the IDs.)

## Step 5 — Code on GitHub
Already done by Grok Bot: the full app with iOS support is pushed to branch **`ios`** of `babarmehboobali/tamweel-calc`. Future changes go to that branch.

## Step 6 — Codemagic
1. https://codemagic.io/signup → **Sign up with GitHub** (account babarmehboobali) → allow access to `tamweel-calc`.
2. **Add application** → GitHub → `tamweel-calc` → project type **Flutter App (via codemagic.yaml)**.
3. **Teams → Personal account → Integrations → Developer Portal → Manage keys → Add key**: name it exactly **`tamweel_asc`**, paste Issuer ID, Key ID, upload the .p8.
4. Free tier = 500 macOS M2 minutes/month (a build is ~15–25 min).

## Step 7 — Run the workflows
1. **iOS unsigned compile test** (works even before Apple approves you): Codemagic → app → **Start new build** → branch `ios` → workflow `ios-unsigned-test`. Green = the iPhone project compiles. (It also runs automatically on every push to `ios`.)
2. **iOS release (TestFlight)**: after Steps 1–4, start build → branch `ios` → `ios-release`. Codemagic creates the certificate + provisioning profile automatically, builds the `.ipa`, and uploads it to App Store Connect / TestFlight.

## Step 8 — TestFlight
1. App Store Connect → your app → **TestFlight**. Wait ~10–30 min for "Processing".
2. Add yourself (and a friend with an iPhone) as **Internal tester** → they install the **TestFlight** app and open the invite. You need an iPhone to test — borrow one if possible.
3. Check: first launch shows Google consent → Apple "Allow tracking?" prompt → test ads appear; Arabic switches to RTL; PDF share works.

## Step 9 — Submit for review
1. App Store Connect → **App Store** tab → version 1.0.0 → **Build** → select the TestFlight build.
2. Export compliance is pre-answered (`ITSAppUsesNonExemptEncryption = false`).
3. App Review info: no sign-in needed; notes in `APP_STORE_LISTING.md`.
4. **Add for Review** → **Submit**. Review usually 1–3 days.
5. When live: AdMob → iOS app → **App settings → link to App Store**, so real ads serve. `app-ads.txt` on babarmehboobali.github.io already covers publisher pub-1235513372019694.

---
### What changed in the code for iOS
- `ios/` project: bundle id `com.tamweel.calculator`, iOS 15.0 minimum, iPhone-only, display name EN/AR (`en.lproj`/`ar.lproj/InfoPlist.strings`), `CFBundleLocalizations` en+ar.
- `Info.plist`: `GADApplicationIdentifier` = `$(GAD_APPLICATION_ID)` (Debug = Google sample, Release = placeholder in `Release.xcconfig`), 51 `SKAdNetworkItems` from Google's list, `NSUserTrackingUsageDescription` (EN/AR), photo/camera texts (logo picker), `ITSAppUsesNonExemptEncryption=false`.
- `ios/Podfile`: platform iOS 15.0.
- ATT: `app_tracking_transparency` package; `ConsentService.requestTrackingAuthorization()` runs after UMP consent and before ads (iOS only; no-op on Android).
- `ad_ids.dart`: iOS IDs chosen by platform; Android IDs untouched.
- App icons (all sizes, 1024 without alpha) and launch screen (#065F46 + logo) generated from `assets/branding`.
- `codemagic.yaml`: workflows `ios-unsigned-test` and `ios-release`.

### Build numbers
`pubspec.yaml` version is `1.0.0+13`. On iOS, `ios-release` auto-sets the build number to (latest TestFlight build + 1). Android is unaffected.

### Only verifiable on a Mac / Codemagic / iPhone
CocoaPods install, Xcode compile, signing, the ATT prompt, real ad loading, and visual check of icon/launch screen on a device.
