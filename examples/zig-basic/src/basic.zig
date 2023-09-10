const std = @import("std");
const worker = @import("worker");

var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
const allocator = arena.allocator();

fn requestFn(resp: *worker.Response, r: *worker.Request) void {

    var payload: []const u8 = "";
    var reqBody = r.body;

    if (reqBody.len == 0) {
        payload = "-";
    } else {
        payload = reqBody;
    }

    const s =
        \\<!DOCTYPE html>
        \\<head>
        \\<title>Wasm Workers Server</title>
        \\<meta name="viewport" content="width=device-width,initial-scale=1">
        \\<meta charset="UTF-8">
        \\<link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/water.css@2/out/water.css">
		\\<style>
		\\body {{ max-width: 1000px; }}
		\\main {{ margin: 5rem 0; }}
		\\h1, p {{ text-align: center; }}
		\\h1 {{ margin-bottom: 2rem; }}
		\\pre {{ font-size: .9rem; }}
		\\pre > code {{ padding: 2rem; }}
		\\p {{ margin-top: 2rem; }}
		\\</style>
        \\</head>
        \\<body>
        \\<main>
        \\<h1>Hello from Wasm Workers Server 👋</h1>
        \\<pre><code>Replying to {s}
        \\Method: {s}
        \\User Agent: {s}
        \\Payload: {s}</code></pre>
        \\<p>
        \\This page was generated by a Zig⚡️ file running in WebAssembly.
        \\</p>
        \\</main>
        \\</body>
    ;

    var body = std.fmt.allocPrint(allocator, s, .{ r.url.path, r.method, "-", payload }) catch undefined; // add useragent

    _ = &resp.headers.append("x-generated-by", "wasm-workers-server");
    _ = &resp.writeAll(body);
}

pub fn main() !void {
    worker.ServeFunc(requestFn);
}
