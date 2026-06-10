# Mobile UI — Transparency &amp; Good Governance

**Scope:** All citizen-mobile UI surfaces for the new module. Aligned with file:.ruler/mobile-rules.md (snake_case files, Riverpod, Dio via `services/api/api_service.dart`).

---

## 1. Feature Folder Layout

A new feature under `apps/mobile/lib/features/transparency/`:

```
features/transparency/
├── data/
│   ├── models/
│   │   ├── transparency_item.dart
│   │   ├── transparency_type.dart            (enum + display metadata)
│   │   └── transparency_attachment.dart
│   └── repositories/
│       └── transparency_repository.dart
└── presentation/
    ├── providers/
    │   ├── transparency_list_provider.dart
    │   └── transparency_detail_provider.dart
    ├── screens/
    │   ├── transparency_category_list_screen.dart
    │   └── transparency_item_detail_screen.dart
    └── widgets/
        ├── transparency_section.dart         (the Home grid)
        ├── transparency_tile.dart            (one of the 6 grid cards)
        └── transparency_metadata_band.dart   (type-specific header on detail)
```

The Home grid (`transparency_section.dart`) is added to file:apps/mobile/lib/features/home/presentation/screens/home_screen.dart as a new `_sectionSliver(context, title: 'Transparency & Good Governance', child: const TransparencySection())` slotted **between** the existing Quick Actions area and the news section.

---

## 2. Home Section — Wireframe

```wireframe

<html>
<head>
<style>
  body { font-family: -apple-system, BlinkMacSystemFont, sans-serif; margin: 0; background:#f4f5f7; }
  .phone { width: 380px; margin: 16px auto; background:#fff; border-radius: 28px; overflow: hidden; box-shadow: 0 6px 20px rgba(0,0,0,0.08); }
  .header { background: linear-gradient(135deg,#0F3D26,#2D6A4F); color:#fff; padding:18px 20px 22px; }
  .header .row { display:flex; align-items:center; gap:10px; }
  .avatar { width:36px; height:36px; border-radius:50%; background:rgba(255,255,255,0.25); }
  .greeting { font-weight:700; font-size:16px; }
  .sub { font-size:12px; opacity:0.85; }
  .search { margin-top:14px; background:#fff; color:#333; border-radius:999px; padding:10px 14px; font-size:13px; }
  .body { padding: 18px 20px; }
  .section-title { font-weight: 700; font-size: 15px; color:#0F3D26; margin: 18px 0 4px; }
  .section-sub { font-size: 12px; color:#666; margin-bottom: 12px; }
  .grid { display:grid; grid-template-columns: repeat(2, 1fr); gap:12px; }
  .tile { background:#fff; border:1px solid #e5e7eb; border-radius:14px; padding:14px 12px; display:flex; gap:10px; align-items:center; box-shadow: 0 1px 2px rgba(0,0,0,0.04); }
  .tile-ico { width: 38px; height: 38px; border-radius:10px; display:flex; align-items:center; justify-content:center; color:#fff; font-size:16px; }
  .ico-p { background:#F59E0B; }
  .ico-b { background:#8B5CF6; }
  .ico-f { background:#10B981; }
  .ico-a { background:#EF4444; }
  .ico-o { background:#3B82F6; }
  .ico-e { background:#EAB308; }
  .tile-label { font-size: 12.5px; font-weight: 600; color:#1f2937; line-height:1.2; }
  .news { margin-top: 22px; }
  .news-card { background:#f9fafb; border-radius:12px; padding:12px; margin-top:8px; }
  .news-thumb { width:100%; height:80px; background:#d1d5db; border-radius:8px; }
  .news-title { font-size:13px; font-weight:600; margin-top:8px; color:#111827; }
  .bottom-nav { display:grid; grid-template-columns: repeat(5,1fr); padding:10px 0 14px; border-top:1px solid #eee; }
  .nav-item { text-align:center; font-size:10px; color:#777; }
  .nav-item.active { color:#EF4444; font-weight:700; }
</style>
</head>
<body>
  <div class="phone">
    <div class="header">
      <div class="row">
        <div class="avatar"></div>
        <div>
          <div class="greeting">Maayong Buntag, Juan!</div>
          <div class="sub">Discover your next favorite spot in the city</div>
        </div>
      </div>
      <div class="search">🔍&nbsp;&nbsp;Search…</div>
    </div>

    <div class="body">
      <div class="section-title">Transparency & Good Governance</div>
      <div class="section-sub">Know where your taxes go</div>

      <div class="grid" data-element-id="transparency-grid">
        <div class="tile" data-element-id="tile-program"><div class="tile-ico ico-p">🏢</div><div class="tile-label">Program and<br/>Projects</div></div>
        <div class="tile" data-element-id="tile-bids"><div class="tile-ico ico-b">💼</div><div class="tile-label">Bids and<br/>Projects</div></div>
        <div class="tile" data-element-id="tile-finance"><div class="tile-ico ico-f">📈</div><div class="tile-label">Financial<br/>Reports</div></div>
        <div class="tile" data-element-id="tile-budget"><div class="tile-ico ico-a">🏛️</div><div class="tile-label">Annual<br/>Budget</div></div>
        <div class="tile" data-element-id="tile-ord"><div class="tile-ico ico-o">📜</div><div class="tile-label">Legislative<br/>Ordinances</div></div>
        <div class="tile" data-element-id="tile-eo"><div class="tile-ico ico-e">🛡️</div><div class="tile-label">Executive<br/>Orders</div></div>
      </div>

      <div class="news">
        <div class="section-title">Discover Latest News</div>
        <div class="section-sub">Latest news and announcement for Gubat</div>
        <div class="news-card">
          <div class="news-thumb"></div>
          <div class="news-title">Brgy. Rizal Road concreting begins next week</div>
        </div>
      </div>
    </div>

    <div class="bottom-nav">
      <div class="nav-item active">Home</div>
      <div class="nav-item">Services</div>
      <div class="nav-item">News</div>
      <div class="nav-item">Emergency</div>
      <div class="nav-item">Account</div>
    </div>
  </div>
</body>
</html>
```

---

## 3. Category List Screen — Wireframe

```wireframe

<html>
<head>
<style>
  body { font-family:-apple-system,sans-serif; margin:0; background:#f4f5f7;}
  .phone { width: 380px; margin: 16px auto; background:#fff; border-radius:28px; overflow:hidden; box-shadow:0 6px 20px rgba(0,0,0,0.08);}
  .app-bar { background:#0F3D26; color:#fff; padding:14px 16px; display:flex; align-items:center; gap:12px; }
  .back { font-size:20px; }
  .title { font-weight:700; font-size:16px; }
  .filters { display:flex; gap:8px; padding:12px 16px; overflow-x:auto; border-bottom:1px solid #eee; }
  .chip { padding:6px 12px; border:1px solid #d1d5db; border-radius:999px; font-size:12px; color:#374151; background:#fff; white-space:nowrap; }
  .chip.active { background:#0F3D26; color:#fff; border-color:#0F3D26; }
  .search { padding:10px 16px; }
  .search input { width:100%; padding:10px 12px; border-radius:10px; border:1px solid #e5e7eb; font-size:13px; }
  .list { padding: 4px 16px 16px; }
  .item { background:#fff; border:1px solid #e5e7eb; border-radius:12px; padding:12px; margin-bottom:10px; }
  .ref { font-size:11px; color:#6b7280; font-weight:600; letter-spacing:0.5px;}
  .item-title { font-size:14px; font-weight:700; color:#111827; margin-top:4px; line-height:1.3;}
  .meta { font-size:11px; color:#6b7280; margin-top:6px; }
  .badge { display:inline-block; font-size:10px; padding:2px 6px; border-radius:4px; background:#ecfdf5; color:#047857; margin-right:6px; }
  .offline { background:#fef3c7; color:#92400e; font-size:11px; padding:6px 12px; }
</style>
</head>
<body>
  <div class="phone">
    <div class="app-bar"><div class="back">←</div><div class="title">Bids and Projects</div></div>
    <div class="offline" data-element-id="cache-banner">Last updated 12 minutes ago · cached</div>
    <div class="filters">
      <div class="chip active">All</div>
      <div class="chip">FY 2026</div>
      <div class="chip">FY 2025</div>
      <div class="chip">Open</div>
      <div class="chip">Awarded</div>
    </div>
    <div class="search"><input placeholder="Search by title or reference number…"/></div>
    <div class="list">
      <div class="item">
        <div class="ref">IB-2026-007</div>
        <div class="item-title">Invitation to Bid — Concreting of Brgy. Rizal Road</div>
        <div class="meta"><span class="badge">Open</span>ABC ₱4,250,000.00 · Closes 28 Jun 2026</div>
      </div>
      <div class="item">
        <div class="ref">IB-2026-006</div>
        <div class="item-title">Supply & Delivery of School Furniture (3 brgy. schools)</div>
        <div class="meta"><span class="badge">Open</span>ABC ₱1,890,000.00 · Closes 22 Jun 2026</div>
      </div>
      <div class="item">
        <div class="ref">IB-2026-003</div>
        <div class="item-title">Rehabilitation of Public Market — Phase 2</div>
        <div class="meta"><span class="badge" style="background:#dbeafe;color:#1e40af;">Awarded</span>Awarded to Sorsogon Builders Inc. · ₱8,640,000.00</div>
      </div>
    </div>
  </div>
</body>
</html>
```

---

## 4. Item Detail Screen — Wireframe

```wireframe

<html>
<head>
<style>
  body { font-family:-apple-system,sans-serif; margin:0; background:#f4f5f7;}
  .phone { width: 380px; margin: 16px auto; background:#fff; border-radius:28px; overflow:hidden; box-shadow:0 6px 20px rgba(0,0,0,0.08);}
  .app-bar { background:#0F3D26; color:#fff; padding:14px 16px; display:flex; align-items:center; gap:12px;}
  .body { padding: 18px;}
  .ref { font-size:11px; color:#6b7280; font-weight:600; letter-spacing:0.5px;}
  .title { font-size:18px; font-weight:800; color:#111827; line-height:1.25; margin-top:6px;}
  .band { background:#f3f4f6; border-radius:10px; padding:10px 12px; margin-top:12px; font-size:12px; color:#374151; line-height:1.5;}
  .band b { color:#0F3D26;}
  .summary { margin-top:14px; font-size:13.5px; color:#1f2937; line-height:1.55;}
  .h-attach { font-size:13px; font-weight:700; color:#0F3D26; margin-top:18px;}
  .att { display:flex; gap:10px; align-items:center; border:1px solid #e5e7eb; border-radius:10px; padding:10px; margin-top:8px;}
  .pdf { width:36px; height:36px; background:#fee2e2; color:#b91c1c; border-radius:8px; display:flex; align-items:center; justify-content:center; font-weight:700; font-size:11px;}
  .file-meta { flex:1;}
  .fname { font-size:13px; font-weight:600; color:#111827;}
  .fsize { font-size:11px; color:#6b7280;}
  .dl { color:#0F3D26; font-size:18px;}
</style>
</head>
<body>
  <div class="phone">
    <div class="app-bar"><div>←</div><div style="font-weight:700;">Legislative Ordinance</div></div>
    <div class="body">
      <div class="ref">ORDINANCE NO. 2026-018</div>
      <div class="title">An Ordinance Reducing Single-Use Plastic in Public Markets</div>

      <div class="band">
        <div><b>Approved:</b> 12 Mar 2026 &nbsp;·&nbsp; <b>Effective:</b> 27 Mar 2026</div>
        <div><b>Principal Author:</b> Hon. M. Dela Cruz</div>
        <div><b>Sponsors:</b> Hon. R. Bautista, Hon. J. Reyes</div>
      </div>

      <div class="summary">This ordinance prohibits the use of single-use plastic carry bags by vendors in all public markets of the Municipality of Gubat, effective 27 March 2026. Violators shall be subject to graduated fines as set forth in Section 7…</div>

      <div class="h-attach">Attachments (2)</div>
      <div class="att">
        <div class="pdf">PDF</div>
        <div class="file-meta">
          <div class="fname">Ordinance_2026-018_Full_Text.pdf</div>
          <div class="fsize">412 KB</div>
        </div>
        <div class="dl">⬇</div>
      </div>
      <div class="att">
        <div class="pdf">PDF</div>
        <div class="file-meta">
          <div class="fname">SB_Minutes_2026-03-12.pdf</div>
          <div class="fsize">186 KB</div>
        </div>
        <div class="dl">⬇</div>
      </div>
    </div>
  </div>
</body>
</html>
```

---

## 5. State Management

- `transparencyListProvider` — `FutureProvider.family<List<TransparencyItem>, TransparencyType>` calls the public list endpoint and caches results in memory + Hive for offline use.
- `transparencyDetailProvider` — `FutureProvider.family<TransparencyItemDetail, String slug>` for the detail screen.
- All providers respect `connectivityProvider`: when offline, prefer cache and surface a "Last updated · cached" banner; when online, refresh on pull-to-refresh.

---

## 6. Routing

- Add three routes to file:apps/mobile/lib/core/navigation/app_router.dart:
  - `/transparency/:type` → `TransparencyCategoryListScreen(type)`
  - `/transparency/:type/:slug` → `TransparencyItemDetailScreen(slug)`
- Each tile in the Home grid uses `context.push('/transparency/$typeSlug')`.
- Push notifications with `metadata.type = "transparency"` and `metadata.slug = "..."` deep-link directly to the detail route.

---

## 7. Accessibility &amp; Theming

- All tiles meet ≥ 44×44 px tap targets.
- Light/dark theme via existing `AppTheme`; tile icons use existing `glassThemeOf(context)` color tokens.
- Tile labels are localized via existing string keys (`transparency.tile.programProjects`, etc.) so Filipino/Visayan translations can be added later.

