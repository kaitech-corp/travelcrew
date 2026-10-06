const {test} = require("node:test");
const assert = require("node:assert/strict");
const {EventEmitter} = require("node:events");
const {PassThrough} = require("node:stream");
const sharp = require("sharp");
const {commonsFile, isPublicAddress, download, commonsPhoto, normalizePhoto, createPhotoCallable} = require("../trip-photos");
const url = "https://upload.wikimedia.org/wikipedia/commons/a/ab/Tokyo.jpg";
const publicLookup = async () => [{address: "208.80.154.224", family: 4}];
function transport({status = 200, headers = {}, data = "photo", inspect = () => {}} = {}) {
  return (_url, options, callback) => {
    inspect(options);
    const req = new EventEmitter(); req.destroy = (e) => req.emit("error", e);
    const res = new PassThrough(); res.statusCode = status; res.headers = headers;
    queueMicrotask(() => { callback(res); if (!res.destroyed) res.end(data); });
    return req;
  };
}
test("suggestions reject arbitrary hosts, credentials, ports, SVG, local files and encoded path injection", () => {
  assert.equal(commonsFile(url), "Tokyo.jpg");
  assert.equal(commonsFile(url + "?utm_source=commons.wikimedia.org&utm_campaign=imageinfo&utm_content=original"), "Tokyo.jpg");
  assert.equal(commonsFile(url.replace("commons/", "commons/thumb/") + "/1600px-Tokyo.jpg"), "Tokyo.jpg");
  for (const value of ["http://127.0.0.1/x.jpg", "https://169.254.169.254/latest/meta-data", "file:///etc/passwd",
    "https://upload.wikimedia.org.evil.test/a.jpg", url.replace("https://", "https://user:pass@"),
    url.replace(".org/", ".org:444/"), url + "?redirect=http://127.0.0.1", url.replace("Tokyo.jpg", "%2fetc.jpg"),
    url.replace("Tokyo.jpg", "x.svg"), url.replace("Tokyo.jpg", "%00x.jpg"), "sandbox:/photo.png"]) {
    assert.throws(() => commonsFile(value), value);
  }
});
test("SSRF defense blocks IPv4, IPv6, mapped private IPs, metadata and mixed DNS answers before connecting", async () => {
  for (const ip of ["127.0.0.1", "10.0.0.1", "172.16.0.1", "192.168.0.1", "169.254.169.254", "0.0.0.0", "224.0.0.1", "::1", "fc00::1", "fe80::1", "::ffff:127.0.0.1", "2001:db8::1"]) assert.equal(isPublicAddress(ip), false, ip);
  assert.equal(isPublicAddress("208.80.154.224"), true);
  let connections = 0;
  await assert.rejects(download(new URL(url), {lookup: async () => [...await publicLookup(), {address: "127.0.0.1", family: 4}], request: () => { connections++; }}), /Unsafe/);
  assert.equal(connections, 0);
});
test("actual socket lookup is pinned, redirects/compression and both declared/streamed oversized responses fail", async () => {
  let calls = 0;
  const result = await download(new URL(url), {lookup: async () => { calls++; return publicLookup(); }, request: transport({inspect(options) {
    assert.equal(options.agent, false);
    options.lookup("upload.wikimedia.org", {}, (error, address) => { assert.equal(error, null); assert.equal(address, "208.80.154.224"); });
    options.lookup("upload.wikimedia.org", {all: true}, (error, addresses) => { assert.equal(error, null); assert.equal(addresses[0].address, "208.80.154.224"); });
    assert.equal(options.headers.Authorization, undefined);
  }})});
  assert.equal(result.toString(), "photo"); assert.equal(calls, 1);
  for (const response of [{status: 302, headers: {location: "http://127.0.0.1/"}}, {headers: {"content-length": "100"}},
    {headers: {"content-encoding": "gzip"}}, {data: "a".repeat(11)}]) {
    await assert.rejects(download(new URL(url), {maxBytes: 10, lookup: publicLookup, request: transport(response)}));
  }
});
test("Commons metadata, not model claims, establishes permitted source/license", async () => {
  const metadata = (license = "CC0", image = url) => Buffer.from(JSON.stringify({query: {pages: {1: {imageinfo: [{url: image,
    descriptionurl: "https://commons.wikimedia.org/wiki/File:Tokyo.jpg", mime: "image/jpeg",
    extmetadata: {LicenseShortName: {value: license}, Artist: {value: "<a href='x'>Photographer</a>"}}}]}}}}));
  let downloads = 0;
  const load = (license, image) => async (target) => {
    if (target.hostname === "commons.wikimedia.org") return metadata(license, image);
    assert.equal(target.search, ""); downloads++; return Buffer.from("photo");
  };
  for (const license of ["CC BY-SA 4.0", "Copyrighted", "", undefined]) {
    if (license === undefined) continue;
    await assert.rejects(commonsPhoto(url, load(license)));
  }
  await assert.rejects(commonsPhoto(url, load("CC0", "https://127.0.0.1/a.jpg")));
  assert.equal(downloads, 0);
  const result = await commonsPhoto(url, load("CC0"));
  assert.equal(result.credit.author, "Photographer"); assert.equal(result.credit.license, "CC0"); assert.equal(downloads, 1);
  await commonsPhoto(url, load("CC0", url + "?utm_source=commons.wikimedia.org&utm_campaign=imageinfo&utm_content=original"));
  assert.equal(downloads, 2);
});
test("normalization rejects non-images/truncation/oversized dimensions and strips metadata", async () => {
  for (const bytes of [Buffer.from("<svg><script>alert(1)</script></svg>"), Buffer.alloc(9 * 1024 * 1024), Buffer.from([255,216,255,...Array(20).fill(0)])]) await assert.rejects(normalizePhoto(bytes));
  const large = await sharp({create: {width: 5000, height: 4000, channels: 3, background: "white"}}).png().toBuffer();
  await assert.rejects(normalizePhoto(large));
  const input = await sharp({create: {width: 2000, height: 1000, channels: 3, background: "blue"}}).withMetadata().png().toBuffer();
  const result = await normalizePhoto(input); const meta = await sharp(result).metadata();
  assert.equal(meta.format, "jpeg"); assert.equal(meta.width, 1600); assert.equal(meta.height, 800); assert.equal(meta.exif, undefined);
});
test("callable requires authentication, refuses forged owner/trip fields and uses only verified caller UID", async () => {
  const calls = []; const handler = createPhotoCallable(async (...args) => { calls.push(args); return {status: "ready"}; });
  await assert.rejects(handler({data: {image_url: url}}), (e) => e.code === "unauthenticated");
  await assert.rejects(handler({auth: {uid: "owner"}, data: {image_url: url, uid: "victim"}}), (e) => e.code === "invalid-argument");
  await assert.rejects(handler({auth: {uid: "owner"}, data: {image_url: url, tripId: "victim-trip"}}));
  await handler({auth: {uid: "owner"}, data: {image_url: url}});
  assert.deepEqual(calls, [["owner", url]]);
});
