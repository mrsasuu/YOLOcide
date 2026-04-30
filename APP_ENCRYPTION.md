# App Encryption Documentation

**YOLOcide**
Last updated: April 29, 2025

---

## Summary

YOLOcide **does not use non-exempt encryption**. The app qualifies for the standard encryption exemption under the U.S. Export Administration Regulations (EAR).

The correct Info.plist value is:

```xml
<key>ITSAppUsesNonExemptEncryption</key>
<false/>
```

---

## Encryption used

| What | How | Exempt? |
|------|-----|---------|
| HTTPS network calls (auth endpoints) | TLS via Apple's `URLSession` / `NSURLSession` | ✅ Yes — standard OS-provided encryption |
| Apple Sign In | Handled entirely by Apple's AuthenticationServices framework | ✅ Yes — Apple-managed |
| Google Sign In | OAuth 2.0 over HTTPS via `ASWebAuthenticationSession` | ✅ Yes — standard OS-provided encryption |
| Local data storage | `UserDefaults` — no encryption applied | ✅ Yes — no encryption |

---

## Proprietary or non-standard algorithms

None. The app does not implement any custom or proprietary cryptographic algorithms. All encryption is delegated to Apple's operating system frameworks.

---

## Exemption basis

This app qualifies for the encryption exemption under **EAR §740.17(b)(3) / Category 5 Part 2 Note 4** (the "publicly available" / "mass market" exemption) because:

1. It uses only encryption that is standard, publicly available, and built into Apple's OS
2. It does not implement, embed, or distribute any encryption library
3. The primary function of the app is not encryption

---

## No further documentation required

Because `ITSAppUsesNonExemptEncryption` is `false`, no additional export compliance documentation (ERN — Encryption Registration Number) is required for App Store distribution.
