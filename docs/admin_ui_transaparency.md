# Web Admin UI — Transparency Content Management

**Scope:** All admin-portal UI for the new module. Aligned with file:.ruler/web-rules.md (kebab-case, business logic in `features/`, oRPC + TanStack Query in `api/`, shadcn UI).

---

## 1. Feature Folder Layout

A new feature under `apps/web/features/admin-transparency/`:

```
features/admin-transparency/
├── api/
│   └── transparency.hooks.ts             # useTransparencyListQuery / useUpsertTransparencyMutation / etc.
├── components/
│   ├── transparency-list-table.tsx
│   ├── transparency-filters-bar.tsx
│   ├── transparency-type-picker.tsx
│   ├── transparency-editor-form.tsx      # form-shell with type-specific subforms
│   ├── transparency-attachments-uploader.tsx
│   ├── transparency-publish-controls.tsx
│   └── type-fields/
│       ├── program-project-fields.tsx
│       ├── bid-procurement-fields.tsx
│       ├── financial-report-fields.tsx
│       ├── annual-budget-fields.tsx
│       ├── legislative-ordinance-fields.tsx
│       └── executive-order-fields.tsx
├── lib/
│   └── transparency-types.ts             # display labels, icons, route slugs
└── server/
    └── transparency.actions.ts           # CSV export server action (Admin only)
```

Routing:

```
app/(admin)/transparency/page.tsx                       # List
app/(admin)/transparency/new/page.tsx                   # Create wizard
app/(admin)/transparency/[id]/edit/page.tsx             # Edit
app/(admin)/transparency/[id]/preview/page.tsx          # Citizen-view preview
```

---

## 2. Sidebar Addition

In file:apps/web/features/admin-layout/nav-items.ts, add to the **"Content &amp; Emergency"** group:

```ts
{ title: "Transparency", url: "/transparency", icon: ShieldCheck, access: "staff" }
```

(`ShieldCheck` is already imported in the file.)

---

## 3. List Screen — Wireframe

```wireframe

<html>
<head>
<style>
  body { font-family:-apple-system,sans-serif; margin:0; background:#f3f4f6;}
  .app { display:flex; min-height:780px;}
  .sidebar { width:220px; background:#0F3D26; color:#cfeadc; padding:14px 0;}
  .brand { color:#fff; font-weight:800; padding:6px 18px 16px; border-bottom:1px solid rgba(255,255,255,0.08); font-size:14px;}
  .nav-group { font-size:10px; text-transform:uppercase; opacity:0.6; padding:14px 18px 6px;}
  .nav-item { padding:9px 18px; font-size:13px; display:flex; gap:10px; align-items:center;}
  .nav-item.active { background:rgba(255,255,255,0.10); color:#fff; font-weight:600;}
  .main { flex:1; padding:18px 24px;}
  .crumb { font-size:11px; color:#6b7280;}
  .h1 { font-size:20px; font-weight:800; color:#111827; margin:4px 0 16px;}
  .toolbar { display:flex; justify-content:space-between; align-items:center; margin-bottom:14px; gap:12px; flex-wrap:wrap;}
  .filters { display:flex; gap:8px; flex-wrap:wrap;}
  .filt { padding:6px 12px; background:#fff; border:1px solid #d1d5db; border-radius:8px; font-size:12px;}
  .btn { background:#0F3D26; color:#fff; padding:8px 14px; border-radius:8px; font-size:12px; font-weight:600; border:none; cursor:pointer;}
  .btn-ghost { background:#fff; color:#0F3D26; border:1px solid #0F3D26;}
  table { width:100%; border-collapse:collapse; background:#fff; border-radius:10px; overflow:hidden; box-shadow:0 1px 2px rgba(0,0,0,0.04);}
  th,td { text-align:left; padding:10px 14px; font-size:12.5px; border-bottom:1px solid #f3f4f6;}
  th { background:#f9fafb; font-weight:600; color:#374151; text-transform:uppercase; font-size:10.5px; letter-spacing:0.4px;}
  .badge { font-size:10px; padding:2px 8px; border-radius:6px; font-weight:600;}
  .b-pub { background:#dcfce7; color:#166534;}
  .b-dft { background:#e5e7eb; color:#374151;}
  .b-sch { background:#dbeafe; color:#1e40af;}
  .b-arc { background:#fef3c7; color:#92400e;}
  .actions { color:#6b7280; font-size:14px;}
</style>
</head>
<body>
  <div class="app">
    <div class="sidebar">
      <div class="brand">iGubat · Admin</div>
      <div class="nav-group">Operations</div>
      <div class="nav-item">🏠 Dashboard</div>
      <div class="nav-item">📄 Service Requests</div>
      <div class="nav-item">⚠️ Issue Reports</div>
      <div class="nav-group">Content & Emergency</div>
      <div class="nav-item">📰 Content</div>
      <div class="nav-item">🚨 Emergency</div>
      <div class="nav-item active" data-element-id="nav-transparency">🛡️ Transparency</div>
      <div class="nav-item">🔔 Notifications</div>
      <div class="nav-group">Administration</div>
      <div class="nav-item">👥 User Management</div>
      <div class="nav-item">📊 Analytics</div>
    </div>

    <div class="main">
      <div class="crumb">Content & Emergency / Transparency</div>
      <div class="h1">Transparency & Good Governance</div>

      <div class="toolbar">
        <div class="filters">
          <select class="filt"><option>All Types</option><option>Program & Projects</option><option>Bids & Projects</option><option>Financial Reports</option><option>Annual Budget</option><option>Legislative Ordinances</option><option>Executive Orders</option></select>
          <select class="filt"><option>All Statuses</option><option>Draft</option><option>Scheduled</option><option>Published</option><option>Archived</option></select>
          <input class="filt" placeholder="Fiscal year"/>
          <input class="filt" placeholder="Search title or ref. number"/>
        </div>
        <div>
          <button class="btn-ghost btn" data-element-id="export-csv">Export CSV</button>
          <button class="btn" data-element-id="new-item">+ New Item</button>
        </div>
      </div>

      <table>
        <thead>
          <tr><th>Ref. No.</th><th>Title</th><th>Type</th><th>FY</th><th>Status</th><th>Published</th><th>Author</th><th></th></tr>
        </thead>
        <tbody>
          <tr>
            <td>EO No. 2026-05</td>
            <td>Pacific Coast Cleanliness Drive</td>
            <td>Executive Order</td>
            <td>2026</td>
            <td><span class="badge b-pub">Published</span></td>
            <td>02 May 2026</td>
            <td>Maria Santos</td>
            <td class="actions">⋮</td>
          </tr>
          <tr>
            <td>Ord. No. 2026-018</td>
            <td>Single-Use Plastic Reduction</td>
            <td>Legislative Ordinance</td>
            <td>2026</td>
            <td><span class="badge b-sch">Scheduled</span></td>
            <td>27 Mar 2026</td>
            <td>Maria Santos</td>
            <td class="actions">⋮</td>
          </tr>
          <tr>
            <td>IB-2026-007</td>
            <td>Concreting of Brgy. Rizal Road</td>
            <td>Bids & Projects</td>
            <td>2026</td>
            <td><span class="badge b-pub">Published</span></td>
            <td>10 Jun 2026</td>
            <td>BAC Secretariat</td>
            <td class="actions">⋮</td>
          </tr>
          <tr>
            <td>AB-2026</td>
            <td>Annual Budget FY 2026</td>
            <td>Annual Budget</td>
            <td>2026</td>
            <td><span class="badge b-dft">Draft</span></td>
            <td>—</td>
            <td>Budget Office</td>
            <td class="actions">⋮</td>
          </tr>
          <tr>
            <td>SAOB-Q4-2025</td>
            <td>Statement of Allotments & Balances Q4 2025</td>
            <td>Financial Report</td>
            <td>2025</td>
            <td><span class="badge b-arc">Archived</span></td>
            <td>10 Feb 2026</td>
            <td>Treasury</td>
            <td class="actions">⋮</td>
          </tr>
        </tbody>
      </table>
    </div>
  </div>
</body>
</html>
```

---

## 4. Editor Screen — Wireframe

```wireframe

<html>
<head>
<style>
  body { font-family:-apple-system,sans-serif; margin:0; background:#f3f4f6;}
  .wrap { max-width: 980px; margin: 18px auto; background:#fff; padding:22px 28px; border-radius:12px; box-shadow:0 1px 3px rgba(0,0,0,0.06);}
  .crumb { font-size:11px; color:#6b7280;}
  h1 { font-size:20px; margin:4px 0 18px;}
  .grid2 { display:grid; grid-template-columns:1fr 1fr; gap:14px;}
  .field { display:flex; flex-direction:column; margin-bottom:12px;}
  label { font-size:11.5px; font-weight:600; color:#374151; margin-bottom:4px; text-transform:uppercase; letter-spacing:0.3px;}
  input,select,textarea { padding:8px 10px; border:1px solid #d1d5db; border-radius:8px; font-size:13px;}
  textarea { min-height: 90px; resize: vertical;}
  fieldset { border:1px solid #e5e7eb; border-radius:10px; padding:14px 16px; margin-top:14px;}
  legend { font-size:12px; font-weight:700; color:#0F3D26; padding:0 6px;}
  .att { display:flex; gap:10px; align-items:center; border:1px dashed #d1d5db; padding:10px; border-radius:8px;}
  .toolbar { display:flex; justify-content:flex-end; gap:10px; margin-top:18px;}
  .btn { padding:9px 16px; border-radius:8px; font-size:12.5px; font-weight:600; cursor:pointer; border:none;}
  .btn-primary { background:#0F3D26; color:#fff;}
  .btn-ghost { background:#fff; color:#0F3D26; border:1px solid #0F3D26;}
  .btn-danger { background:#fff; color:#b91c1c; border:1px solid #fecaca;}
  .row-toggle { display:flex; gap:14px; align-items:center; padding:10px 0;}
</style>
</head>
<body>
  <div class="wrap">
    <div class="crumb">Transparency / New Item</div>
    <h1>New Transparency Item</h1>

    <div class="field">
      <label>Type</label>
      <select data-element-id="type-picker">
        <option>Program and Projects</option>
        <option selected>Legislative Ordinance</option>
        <option>Bids and Projects</option>
        <option>Financial Report</option>
        <option>Annual Budget</option>
        <option>Executive Order</option>
      </select>
    </div>

    <div class="grid2">
      <div class="field"><label>Reference Number</label><input value="Ord. No. 2026-018"/></div>
      <div class="field"><label>Fiscal Year</label><input value="2026"/></div>
    </div>

    <div class="field"><label>Title</label><input value="An Ordinance Reducing Single-Use Plastic in Public Markets"/></div>
    <div class="field"><label>Summary (1–2 paragraphs)</label><textarea>This ordinance prohibits the use of single-use plastic carry bags…</textarea></div>
    <div class="field"><label>Body (Markdown / Rich Text)</label><textarea style="min-height:160px;">## Section 1. Title…</textarea></div>

    <fieldset>
      <legend>Type-Specific — Legislative Ordinance</legend>
      <div class="grid2">
        <div class="field"><label>Date Approved</label><input value="2026-03-12"/></div>
        <div class="field"><label>Effective Date</label><input value="2026-03-27"/></div>
        <div class="field"><label>Principal Author</label><input value="Hon. M. Dela Cruz"/></div>
        <div class="field"><label>Sponsors</label><input value="Hon. R. Bautista, Hon. J. Reyes"/></div>
      </div>
    </fieldset>

    <fieldset>
      <legend>Attachments (max 10, ≤10 MB each, PDF/JPG/PNG)</legend>
      <div class="att">📎 Ordinance_2026-018_Full_Text.pdf · 412 KB <button class="btn btn-ghost" style="margin-left:auto;">Remove</button></div>
      <div class="att" style="margin-top:8px;">📎 SB_Minutes_2026-03-12.pdf · 186 KB <button class="btn btn-ghost" style="margin-left:auto;">Remove</button></div>
      <button class="btn btn-ghost" style="margin-top:8px;">+ Upload File</button>
    </fieldset>

    <fieldset>
      <legend>Publish Controls</legend>
      <div class="row-toggle"><input type="checkbox" checked/> <span>Notify subscribers on publish</span></div>
      <div class="field"><label>Schedule Publish At (leave blank to publish now)</label><input value="2026-03-27T08:00"/></div>
    </fieldset>

    <div class="toolbar">
      <button class="btn btn-danger" data-element-id="delete">Permanently Delete</button>
      <button class="btn btn-ghost">Save Draft</button>
      <button class="btn btn-ghost">Preview</button>
      <button class="btn btn-ghost">Archive</button>
      <button class="btn btn-primary">Schedule & Publish</button>
    </div>
  </div>
</body>
</html>
```

> The **Permanently Delete** button is rendered only when `useRole().portalRole === "admin"` (uses the existing `canAccess` helper in `core/lib/roles.ts`).

---

## 5. Data Hooks

`features/admin-transparency/api/transparency.hooks.ts` exposes:

- `useTransparencyListQuery(filters)`
- `useTransparencyDetailQuery(id)`
- `useCreateTransparencyMutation()`
- `useUpdateTransparencyMutation()`
- `usePublishTransparencyMutation()`
- `useArchiveTransparencyMutation()`
- `useDeleteTransparencyMutation()` *(passes `permanent` flag; mutation only enabled when role is admin)*

All hooks follow the `orpc.igubat.admin.transparency.*` pattern from file:.ruler/web-rules.md.

---

## 6. RBAC Boundaries

- The `/transparency` route group is gated by the staff guard already used by `/content` and `/emergency`.
- Within the editor, the permanent-delete button + the **Export CSV** button on the list page are gated to `access: "admin"` via `canAccess`. Direct API call without admin returns 403 from the backend (`TransparencyService.requireAdmin()`).

