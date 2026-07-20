# DesignToken

Shared design tokens for TimeDraw: colors, corner radii, and Inter fonts.

## Platforms

- iOS 16+
- watchOS 9+

## Adding the package

Add `Shared/DesignToken` as a local Swift package dependency in Xcode, then link the **DesignToken** product to your app target.

```swift
import DesignToken
```

## Fonts

Inter font files ship inside this package. They are **not** loaded via `UIAppFonts` in the app Info.plist.

At app launch, register the fonts **before** using Inter or overriding the system font:

```swift
import DesignToken

init() {
    DesignTokenFonts.register()
    UIFont.overrideInitialize()
}
```

Then use the SwiftUI helpers:

```swift
Text("Hello")
    .font(.interRegular)

Text("Title")
    .font(.interBoldTitle2)
```

Available styles include `interThin`, `interExtraLight`, `interLight`, `interRegular`, `interMedium`, `interSemiBold`, `interBold`, `interExtraBold`, `interBlack`, plus sized variants such as `interClock`, `interFine`, `interTitle`, and `interExtraBoldTitle`.

## Colors and corner radii

```swift
Color.dark
Color.green1
DesignToken.Colors.systemBackground
DesignToken.CornerRadius.listRowRadius
```

## Notes

- Call `DesignTokenFonts.register()` once per process at launch.
- Do not list Inter `.ttf` files under `UIAppFonts`; package fonts are registered at runtime from `Bundle.module`.
