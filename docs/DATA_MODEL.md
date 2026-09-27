# Data Model

Defines the fields the app manages, exactly where each one lives (native PhotoKit vs. this app's CloudKit metadata layer — see ARCHITECTURE.md § 2.3 `MetadataStore`), and how conflicts and identity are handled across devices.

## 1. Identity

Every record in the app's own store is keyed by `PHAsset.localIdentifier`. This is the load-bearing assumption of the whole metadata layer and is called out as a Phase 0 validation spike in ROADMAP.md — specifically, whether this identifier is stable for an asset synced via iCloud Photos and viewed from a second device (Apple does not fully document this guarantee).

Fallback identity, if `localIdentifier` proves unstable across devices for iCloud-synced assets: a content fingerprint (perceptual hash + original creation date + file size) as a secondary lookup key, reconciled against `localIdentifier` on each device locally. This fallback is not built for v1 unless Phase 0 shows it's necessary.

## 2. Field Placement (authoritative — mirrors SPEC.md § Architecture Principles)

| Field | Store | Type | Notes |
| --- | --- | --- | --- |
| Star rating | Native Photos (`PHAssetChangeRequest.rating`) | Int, 0–5 | 0 = unrated |
| Keywords | Native Photos (`addKeyword`/`removeKeyword`) | [String] | Free-form, shared with Photos.app's own keyword UI |
| Colour flag | App metadata (CloudKit) | Enum: none/red/yellow/green/blue/purple/orange | |
| Pick/Reject | App metadata (CloudKit) | Enum: unset/pick/reject | Independent of star rating |
| Near-dup cluster ID | App metadata (CloudKit) | UUID, nullable | Groups assets found to be near-duplicates |
| Near-dup suggested-keeper flag | App metadata (CloudKit) | Bool | Suggestion only, never authoritative |
| Film: roll ID | App metadata (CloudKit) | String, nullable | |
| Film: frame number | App metadata (CloudKit) | Int, nullable | |
| Film: camera | App metadata (CloudKit) | String, nullable | |
| Film: lens | App metadata (CloudKit) | String, nullable | |
| Film: stock | App metadata (CloudKit) | String, nullable | |
| Film: ISO/box speed | App metadata (CloudKit) | Int, nullable | |
| Film: exposure compensation | App metadata (CloudKit) | Double, nullable | Stops |
| Film: developer | App metadata (CloudKit) | String, nullable | |
| Film: dilution | App metadata (CloudKit) | String, nullable | |
| Film: development time | App metadata (CloudKit) | String, nullable | Free text (mm:ss, temperature-dependent notes) |
| Film: push/pull | App metadata (CloudKit) | Double, nullable | Stops, signed |
| Film: free-text notes | App metadata (CloudKit) | String, nullable | |
| Import batch ID | App metadata (CloudKit) | UUID | Which import session created/first saw this asset |

## 3. CloudKit Record Schema (proposed)

**Record type: `AssetMetadata`**
- `assetLocalIdentifier: String` (indexed, queryable) — join key to `PHAsset`
- `colourFlag: String` (enum, stored as raw string)
- `pickRejectState: String`
- `nearDupClusterID: String?`
- `isSuggestedKeeper: Bool`
- `filmRollID, filmFrameNumber, filmCamera, filmLens, filmStock, filmISO, filmExposureComp, filmDeveloper, filmDilution, filmDevTime, filmPushPull, filmNotes` — as typed above
- `importBatchID: String`
- `modifiedAt: Date` (used for last-writer-wins conflict resolution, see § 4)

**Record type: `ImportBatch`** (optional, for UX like "show me what I imported last Tuesday")
- `id: String`
- `createdAt: Date`
- `sourceDescription: String` (e.g., "SD card — Canon R6", "Folder — Lab scan batch 12")
- `assetCount: Int`

**Record type: `NearDupCluster`** (optional — could instead be fully denormalized onto `AssetMetadata.nearDupClusterID`; a separate record type is only worth it if cluster-level metadata, like "reviewed" state, is needed)
- `id: String`
- `assetLocalIdentifiers: [String]`
- `reviewedAt: Date?`

Private database, one zone per device is not needed — a single custom zone (`AssetMetadataZone`) is sufficient since there's no sharing requirement (SPEC.md explicitly excludes any social/sharing scope).

## 4. Conflict Resolution

Per SPEC.md's constraint of "no custom sync engine," conflict resolution rides on CloudKit's own primitives rather than app-level merge logic, with one explicit rule layered on top:

- **Default:** CloudKit's server-side optimistic concurrency (record change tag) surfaces a conflict when two devices write the same record while offline from each other.
- **App-level resolution rule: last-writer-wins by `modifiedAt`**, applied per-field where practical (e.g., a colour-flag change on device A and a film-note edit on device B to the *same* record should both survive — field-level merge, not whole-record overwrite) — this needs to be validated as buildable within the chosen persistence layer (see ARCHITECTURE.md § 5) during Phase 0, since not every option (e.g., `NSPersistentCloudKitContainer`) makes field-level merge equally easy.
- **What must never happen:** a conflict silently drops a user's pick/reject or rating decision. If field-level merge isn't achievable with the chosen stack, the fallback is whole-record last-writer-wins plus a non-blocking "this asset's flags were updated on another device" surface — never a silent, unannounced loss.

## 5. Native PhotoKit Fields — Read/Write Notes

- Star rating and keyword writes go through a single `PHPhotoLibrary.performChanges` transaction alongside any other native-field changes for that asset, to avoid partial-write states.
- Known gap (tracked in RISK_REGISTER.md): PhotoKit rating writes are not currently confirmed to round-trip into a file's XMP metadata on export — meaning a rating set here may not travel with the file if the user exports/AirDrops it out of Photos. This is a v1-launch-blocking *investigation*, not necessarily a launch blocker in outcome — see RISK_REGISTER.md.

## 6. Schema Evolution

Since this is a CloudKit private database (not a shared/public one), schema changes are low-risk — no migration coordination across users is needed, only across a single user's own devices. New optional fields can be added additively at any time. Removing or renaming a field requires a version-gated read path (old + new field names supported for one release) rather than a hard cutover, since a user's Mac and iPhone may run different app versions transiently after an update.
