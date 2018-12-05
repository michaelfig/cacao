# Cacao - Client Access-Control-Allow-Origin

Cacao is a Cross-Origin (CORS) proxy.  It allows Javascript running in a web browser to access a remote HTTP resource without cross-origin restrictions.  It works by proxying requests to a remote server, and adding the `Access-Control-Allow-Origin: *` header to the returned result.

## IP Camera Streaming

The main use case is to access a remote streaming MJPEG URL published by an IP Camera, via an `<img>` tag pointing to a local Cacao proxy.  Without Cacao, this image data is marked as cross-origin, and therefore cannot be used as the source for a WebRTC stream.

With Cacao, the `<img>` can be copied to a `<canvas>` and then since CORS is allowed, sent by the browser via WebRTC.

TODO: The [Mediasoup Broadcast Example](https://github.com/michaelfig/mediasoup-broadcast-example) will contain an example of using Cacao to make an IP Camera publishable via WebRTC.

## Usage

You need to install the [Dart VM](https://www.dartlang.org/tools/sdk#install), then run:
```
$ cd bin
$ cacao --help
```

TODO: Create releases of just the Dart VM, Cacao snapshot, and wrapper script for common platforms.

Michael FIG <michael+cacao@fig.org>, 2018-12-04
