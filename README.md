# Decoded

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
