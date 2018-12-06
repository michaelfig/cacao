# Cacao Proxy - CORS Access-Control-Allow-Origin Proxy

Cacao is a Cross-Origin (CORS) proxy.  It allows Javascript running in a web browser to access a remote HTTP resource without cross-origin restrictions.  It runs on several different platforms, and essentially works by adding a `Access-Control-Allow-Origin: *` header to an HTTP response.

## IP Camera Streaming

The main use case is to access a remote streaming MJPEG URL published by an IP Camera, via an `<img>` tag pointing to Cacao.  Without Cacao, this image data is usually marked as cross-origin, and therefore cannot be used as the source for a WebRTC stream.

With Cacao, the `<img>` can be copied to a `<canvas>` and then (since CORS is allowed) sent by the browser via WebRTC.

TODO: The [Mediasoup Broadcast Example](https://github.com/michaelfig/mediasoup-broadcast-example) will contain an example of using Cacao to make an IP Camera publishable via WebRTC.

TODO: Include other use-cases.

## Usage

### Standalone Cacao Proxy

Cacao can be run as a proxy server on Linux (and other Unix-like), MacOS, and Windows.

You need to install the [Dart SDK](https://www.dartlang.org/tools/sdk#install), then run:
```
$ cd bin
$ cacao --help
```


Michael FIG <michael+cacao@fig.org>, 2018-12-05
