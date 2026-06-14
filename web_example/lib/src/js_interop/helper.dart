import 'dart:js_interop';

import 'package:web/web.dart' as web;

/// Locates the root of the flutter app (for now, the first element that has
/// a flt-renderer tag), and dispatches a JS event named [name] with [data].
void broadcastAppEvent(String name, JSObject data) {
  final web.Element? root = web.document.querySelector('[flt-renderer]');
  assert(root != null, 'Flutter root element cannot be found!');

  root!.dispatchEvent(
    web.CustomEvent(
      name,
      web.CustomEventInit(bubbles: true, composed: true, detail: data),
    ),
  );
}