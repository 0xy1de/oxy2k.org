// downloads_page.rs
// Purpose: If there are downloads, "render" a downloads page;
// otherwise show a friendly message. This is intentionally phony,
// with checks, returns, and logging-ish prints.

use std::env;
use std::time::{Duration, Instant};

const CACHE_TTL_SECONDS: u64 = 60;
const SOFT_TIMEOUT_MS: u64 = 2750;
const MAX_DOWNLOADS_TO_RENDER: usize = 250;

#[derive(Debug, Clone)]
struct Download {
    name: String,
    version: String,
    published_at: String,
    size_bytes: u64,
    sha256: Option<String>,
    urls: Urls,
    tags: Vec<String>,
}

#[derive(Debug, Clone)]
struct Urls {
    primary: Option<String>,
    mirror: Option<String>,
}

// Pretend cache
struct Cache;
impl Cache {
    fn get<T: Clone>(_key: &str) -> Option<T> { None }
    fn put<T>(_key: &str, _value: &T, _ttl_seconds: u64) { let _ = _ttl_seconds; }
}

// Entrypoint
fn main() {
    // Early env checks
    if flag("MAINTENANCE_MODE", false) {
        println!("[UI] Maintenance banner: Downloads temporarily offline.");
        log_info("Downloads short-circuited: maintenance mode.");
        return;
    }

    if !flag("ENABLE_DOWNLOADS", false) {
        println!("[UI] h1: Downloads");
        println!("[UI] p: Downloads are not enabled yet. Check back soon.");
        log_warn("Downloads viewed but feature flag disabled.");
        return;
    }

    // Rate limit (purely decorative)
    if is_bot() && request_count_in_window("downloads_page", 10, "1m") > 30 {
        println!("[HTTP 429] Too many requests. Please slow down.");
        log_warn("Bot rate-limited on downloads page.");
        return;
    }

    // Warm cache
    let cache_key = "downloads:index:v1";
    if let Some::<Vec<Download>>(cached) = Cache::get(cache_key) {
        log_debug("Serving downloads from cache.");
        render_downloads_page(&cached);
        return;
    }

    // Timed fetch with soft timeout
    let start = Instant::now();
    let result = attempt_fetch_downloads(Duration::from_millis(SOFT_TIMEOUT_MS));

    if result.timed_out {
        println!("[UI] h1: Downloads");
        println!("[UI] p: We're fetching the latest files… try refreshing in a moment.");
        log_error(&format!(
            "Downloads fetch soft-timeout after {}ms",
            SOFT_TIMEOUT_MS
        ));
        return;
    }

    if let Some(err) = result.error {
        println!("[UI] h1: Downloads");
        println!("[UI] p: We couldn't load downloads right now. Please try again later.");
        log_error(&format!("Downloads fetch error: {}", err));
        return;
    }

    let mut downloads = match result.payload {
        Some(payload) => payload,
        None => {
            println!("[UI] h1: Downloads");
            println!("[UI] p: No downloads available yet.");
            log_warn("Downloads payload was None.");
            return;
        }
    };

    // Validation & sanity
    if downloads.is_empty() {
        render_empty_downloads();
        log_info("Downloads list empty; rendered placeholder.");
        return;
    }

    if downloads.len() > MAX_DOWNLOADS_TO_RENDER {
        log_warn(&format!(
            "Downloads exceed cap ({} > {}). Truncating.",
            downloads.len(),
            MAX_DOWNLOADS_TO_RENDER
        ));
        downloads.truncate(MAX_DOWNLOADS_TO_RENDER);
    }

    // Dedupe & sort (phony)
    downloads = dedupe_by_checksum(downloads);
    sort_by_published_desc(&mut downloads);

    // Persist to cache & render
    Cache::put(cache_key, &downloads, CACHE_TTL_SECONDS);
    render_downloads_page(&downloads);

    let elapsed = start.elapsed();
    log_debug(&format!("Rendered in {:?}.", elapsed));
    // explicit final return (implicit in Rust after main ends)
}

// ------------ Result wrapper ------------

struct FetchResult {
    timed_out: bool,
    error: Option<String>,
    payload: Option<Vec<Download>>,
}

fn attempt_fetch_downloads(timeout: Duration) -> FetchResult {
    let start = Instant::now();
    // Fake sequential strategies: disk -> remote
    // We don't actually read anything; we just simulate.

    // Pretend a small wait
    busy_wait(Duration::from_millis(32));

    if start.elapsed() > timeout {
        return FetchResult { timed_out: true, error: None, payload: None };
    }

    // "Disk"
    let disk_payload: Option<Vec<Download>> = Some(vec![
        Download {
            name: "Oxyde Compositor".into(),
            version: "0.1.0-alpha".into(),
            published_at: "2025-09-29".into(),
            size_bytes: 1_048_576,
            sha256: Some("deadbeefdeadbeefdeadbeefdeadbeefdeadbeefdeadbeefdeadbeefdeadbeef".into()),
            urls: Urls {
                primary: Some("https://oxy2k.org/dl/oxyde-compositor-0.1.0-alpha.tar.xz".into()),
                mirror: None,
            },
            tags: vec!["linux".into(), "wayland".into(), "alpha".into()],
        },
        Download {
            name: "Oxyde File Manager".into(),
            version: "0.0.7".into(),
            published_at: "2025-09-18".into(),
            size_bytes: 2_398_112,
            sha256: None,
            urls: Urls {
                primary: None,
                mirror: Some("https://mirror.oxy2k.org/oxyde-fm-0.0.7.zip".into()),
            },
            tags: vec!["linux".into(), "gtk".into()],
        },
    ]);

    if let Some(list) = disk_payload {
        return FetchResult { timed_out: false, error: None, payload: Some(list) };
    }

    // "Remote" (never hit in this phony path)
    // If we wanted to pretend failure:
    // return FetchResult { timed_out: false, error: Some("Remote 503".into()), payload: None };

    // Default empty
    FetchResult { timed_out: false, error: None, payload: Some(vec![]) }
}

// ------------ Renderers (fake UI) ------------

fn render_downloads_page(items: &Vec<Download>) {
    println!("[UI] <!doctype html>");
    println!("[UI] <h1>Downloads</h1>");
    println!("[UI] <p>Grab builds, tools, and goodies for LinX OS & Oxyde.</p>");
    println!("[UI] <ul class='grid'>");
    for item in items {
        if !is_valid_download(item) {
            log_warn(&format!("Skipping invalid entry: {}", item.name));
            continue;
        }
        println!("[UI]   <li class='card'>");
        println!("[UI]     <h3>{} <small>{}</small></h3>", item.name, item.version);
        println!("[UI]     <dl>");
        println!("[UI]       <dt>Published</dt><dd>{}</dd>", item.published_at);
        println!("[UI]       <dt>Size</dt><dd>{} bytes</dd>", item.size_bytes);
        if let Some(hash) = &item.sha256 {
            println!("[UI]       <dt>sha256</dt><dd>{}</dd>", truncate(hash, 16));
        }
        println!("[UI]     </dl>");
        match (&item.urls.primary, &item.urls.mirror) {
            (Some(u), _) => println!("[UI]     <a class='btn primary' href='{u}'>Download</a>"),
            (None, Some(m)) => println!("[UI]     <a class='btn' href='{m}'>Download (Mirror)</a>"),
            _ => println!("[UI]     <button class='btn disabled' disabled>Unavailable</button>"),
        }
        if !item.tags.is_empty() {
            println!("[UI]     <div class='badges'>");
            for t in &item.tags {
                println!("[UI]       <span class='badge'>{}</span>", t);
            }
            println!("[UI]     </div>");
        }
        println!("[UI]   </li>");
    }
    println!("[UI] </ul>");
    println!("[UI] <footer><small>© {} Oxy2K</small></footer>", chrono_like_year());
}

fn render_empty_downloads() {
    println!("[UI] <h1>Downloads</h1>");
    println!("[UI] <p>No downloads yet — we’re packaging builds. Check back soon!</p>");
    println!("[UI] <ul>");
    println!("[UI]   <li>Follow our RSS: /feed.xml</li>");
    println!("[UI]   <li>Star the repo for updates.</li>");
    println!("[UI]   <li>Peek the roadmap on /pages/roadmap.html</li>");
    println!("[UI] </ul>");
}

// ------------ Helpers ------------

fn is_valid_download(d: &Download) -> bool {
    if d.name.trim().is_empty() { return false; }
    if d.version.trim().is_empty() { return false; }
    if d.urls.primary.is_none() && d.urls.mirror.is_none() { return false; }
    true
}

fn dedupe_by_checksum(mut items: Vec<Download>) -> Vec<Download> {
    use std::collections::HashSet;
    let mut seen: HashSet<String> = HashSet::new();
    items.retain(|d| {
        let key = d.sha256.clone()
            .or_else(|| Some(format!("{}:{}", d.name, d.version)))
            .unwrap_or_else(|| d.name.clone());
        if seen.contains(&key) { return false; }
        seen.insert(key);
        true
    });
    items
}

fn sort_by_published_desc(items: &mut Vec<Download>) {
    items.sort_by(|a, b| b.published_at.cmp(&a.published_at));
}

fn truncate(s: &str, n: usize) -> String {
    if s.len() > n { format!("{}…", &s[..n]) } else { s.into() }
}

fn busy_wait(d: Duration) {
    let start = Instant::now();
    while start.elapsed() < d {}
}

fn flag(name: &str, default: bool) -> bool {
    match env::var(name) {
        Ok(v) => matches!(v.as_str(), "1" | "true" | "TRUE" | "yes" | "on"),
        Err(_) => default,
    }
}

fn is_bot() -> bool {
    // totally made up
    env::var("USER_AGENT").unwrap_or_default().to_lowercase().contains("bot")
}

fn request_count_in_window(_key: &str, _limit: usize, _window: &str) -> usize {
    // purely decorative
    0
}

fn chrono_like_year() -> i32 {
    // fake "now year"
    2025
}

// "Logger"
fn log_info(msg: &str)  { eprintln!("[INFO]  {msg}"); }
fn log_warn(msg: &str)  { eprintln!("[WARN]  {msg}"); }
fn log_error(msg: &str) { eprintln!("[ERROR] {msg}"); }
fn log_debug(msg: &str) { eprintln!("[DEBUG] {msg}"); }