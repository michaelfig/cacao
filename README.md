# Cacao (CORS Access-Control-Allow-Origin) Proxy

Cacao is a localhost Cross-Origin (CORS) proxy.  It allows Javascript running in a web browser to access a remote HTTP resource without cross-origin restrictions.  It runs on several different platforms, and essentially works by adding a `Access-Control-Allow-Origin: *` header to an HTTP response.

## IP Camera Streaming

The main use case is to access a remote streaming MJPEG URL published by an IP Camera, via an `<img>` tag pointing to Cacao.  Without Cacao, this image data is usually marked as cross-origin, and therefore cannot be used as the source for a WebRTC stream.

With Cacao, an `<img crossorigin>` can be copied to a `<canvas>` and then (since CORS is allowed) sent by the browser via WebRTC.  Try loading the (MJPEG sample)[static/mjpeg.html] in your browser to experiment with this capability, and to understand the vanilla Javascript source code.

The [Mediasoup Broadcast Example](https://github.com/michaelfig/mediasoup-broadcast-example) will eventually add support for using Cacao to request media to stream.

## Usage

### Cacao Proxy

Cacao can be run as a localhost proxy server on Linux (and other Unix-like), MacOS, and Windows.

Download a binary package from the [Cacao releases](https://github.com/michaelfig/cacao/releases), if you just want to use the proxy (and not change its code).

If you are a developer, you can run Cacao directly from sources in this project, but you will first need to install the [Dart SDK](https://www.dartlang.org/tools/sdk#install):

```
$ dart --version
$ bin/cacao --help
```

### Cacao Proxy App

See the [Cacao Proxy App](https://github.com/michaelfig/cacao_app) for a graphical app for controlling a builtin Cacao proxy on your mobile device.

Michael FIG <michael+cacao@fig.org>, 2018-12-05
