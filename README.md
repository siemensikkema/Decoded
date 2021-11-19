# Decoded

[![CI](https://github.com/siemensikkema/Decoded/actions/workflows/ci.yml/badge.svg)](https://github.com/siemensikkema/Decoded/actions/workflows/ci.yml)
[![](https://img.shields.io/endpoint?url=https%3A%2F%2Fswiftpackageindex.com%2Fapi%2Fpackages%2Fsiemensikkema%2FDecoded%2Fbadge%3Ftype%3Dswift-versions)](https://swiftpackageindex.com/siemensikkema/Decoded)
[![](https://img.shields.io/endpoint?url=https%3A%2F%2Fswiftpackageindex.com%2Fapi%2Fpackages%2Fsiemensikkema%2FDecoded%2Fbadge%3Ftype%3Dplatforms)](https://swiftpackageindex.com/siemensikkema/Decoded)

Decoded is a library that enables capturing the full state of the decoding process:
- any and all decoding errors
- differentiate between _absent_ and _null_  

See the [full documentation](https://decoded.siemensikkema.nl).

# Installation

Add `Decoded` to your `Package.swift` file.

```swift
dependencies: [
    ...
    .package(url: "https://github.com/siemensikkema/Decoded.git", from: "0.4.0"),
]
...
targets: [
    .target(
        name: "MyTarget",
        dependencies: [
            ...
            "Decoded",
        ]
    )
]
```

Import `Decoded` to any file you want to use this library in.

```swift
import Decoded
```
