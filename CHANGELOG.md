## 0.3.2

- Implement `../PATH` and `./PATH` URLs relative to Cacao's program file.
- Use MJPEG DataLen header if Content-Length doesn't exist.
- Make serveFile send 404's and directory index based on the filesystem contents.
- Send no-cache headers from serveHttp.

## 0.3.1

- Fix HTTP proxy connection leak.
- Improve file proxy error messages.
- Get mjpeg.html working on Firefox and Chrome without relying on nonstandard behaviour.

## 0.3.0

- Crib `pub run grinder package` from [dart-sass](https://github.com/sass/dart-sass).
- Clean up `serve` API in preparation for UI development.
