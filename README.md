![Tests](https://img.shields.io/github/actions/workflow/status/DennisDreissen/WebDAVKit/tests.yml?color=brightgreen&label=Tests&logo=github)
![SPM](https://img.shields.io/badge/Swift_Package_Manager-compatible-brightgreen)
![Swift](https://img.shields.io/badge/Swift-6.0_6.1_6.2_6.3-brightgreen)

# WebDAVKit for Swift

This is a lightweight WebDAV client for interacting with WebDAV servers.

> This library was created to support a WebDAV feature in an app I worked on. Currently there's no tagged release since I'm still making changes or adding new operations as needed. If you would like to use this library in one of your projects, please create an issue and I will create an initial `1.0.0` release. The API is mostly stable at this point. There is also an [S3](https://github.com/DennisDreissen/S3Kit) equivalent with a similar API.

 ```swift
let client = WebDAVClient(
    baseURL: URL(string: "https://webdav.example")!,
    credentials: WebDAVCredentials(
        username: "1234",
        password: "abcd"
    )
)

try await client.upload(
    data: Data(),
    path: "folder/example.jpg"
)
 ```
Every method that interacts with WebDAV returns a `WebDAVResponse`. This response contains the result object, the HTTP response status code and a dictionary with all the HTTP response headers. This can be useful when you want to use WebDAV features not covered by this library or in combination with [custom request headers](#custom-headers).
 
## Setup using SPM

 ```swift
dependencies: [
    .package(url: "https://github.com/DennisDreissen/WebDAVKit.git", .upToNextMajor(from: "1.0.0"))
]
 ```

## Usage

### Head

Check if a resource exists and you're allowed to access it. Detailed information about the resource can be retrieved from the HTTP response headers.

 ```swift
let response = try await client.head(path: "folder/example.jpg")
 ```
 
### List

Get details of a resource or a directory of resources. The depth parameter can be set to `target` or `targetAndChildren` and specifies whether you only want details about the resource at that path or also its children if it's a directory.

 ```swift
let response = try await client.list(
    path: "folder/",
    depth: .targetAndChildren
)

let response = try await client.list(
    path: "folder/example.jpg",
    depth: .target
)
 ```

### Data

Downloads a resource into memory and returns its data.
```swift
let response = try await client.data(path: "folder/example.jpg")
```

### Download

Downloads a resource to the disk and returns a URL. Useful to download larger files which can't be held in memory.

```swift
let response = try await client.download(path: "folder/example.jpg")
```

### Upload

#### Using data
```swift
let response = try await client.upload(
    data: Data(),
    path: "folder/example.jpg"
) { progress in
  // Upload progress ranging from 0-1.
}
```

#### Using a file

```swift
let response = try await client.upload(
    file: URL(),
    path: "folder/example.jpg"
) { progress in
  // Upload progress ranging from 0-1.
}
```

### Create directory

```swift
try await client.createDirectory(
    path: "folder/"
)
```

### Move

Moves a resource from its source location to a new destination.  The `overwritePolicy` parameter can be set to `overwrite` or `fail` and specifies whether an existing resource at the destination path should be overwritten or throw an error.

```swift
let response = try await client.move(
    sourcePath: "folder/old.jpg",
    destinationPath: "folder/new.jpg",
    overwritePolicy: .overwrite
)
```

### Copy

Copies a resource to another location.  The `overwritePolicy` parameter can be set to `overwrite` or `fail` and specifies whether an existing resource at the destination path should be overwritten or throw an error.

```swift
let response = try await client.copy(
    sourcePath: "folder/old.jpg",
    destinationPath: "folder/new.jpg",
    overwritePolicy: .overwrite
)
```

### Delete

```swift
try await client.delete(
    path: "folder/example.jpg"
)

try await client.delete(
    path: "folder/"
)
```

### Custom request headers

All methods support passing a `customHeaders` dictionary. These headers will be passed along in the HTTP request to the WebDAV server.

### Errors

```swift
public enum WebDAVError: Error, Sendable, Equatable {
    /// The response from the server is not valid.
    case invalidResponse

    /// Decoding the response body failed.
    case decodingResponseFailed

    /// The server returned an error. Contains the status code returned by the WebDAV server.
    case responseError(statusCode: Int)
}
```
