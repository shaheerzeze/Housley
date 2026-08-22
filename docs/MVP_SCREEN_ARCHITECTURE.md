# Housely tenant-first MVP interface architecture

Status: interface-complete prototype, mock data first. Supabase is deliberately deferred.

## Product boundary

Housely V1 covers account access, create/join Home, adaptive Home, household membership, private splitting and manual settlements, recurring commitments, Vault, move-in/move-out evidence, inventory and ownership, approval-based Home Changes, lightweight tasks, activity, notifications, privacy, data controls and support.

It does not simulate Open Banking, automatic money movement, landlord access to private household data, rent reporting, insurance, marketplace, contractor dispatch, AI damage decisions or subscriptions.

## Navigation contract

- Permanent destinations: Home, Split, Vault, Stuff, You.
- Household, Changes, Tasks and Timeline are Home-level destinations.
- Notifications are global.
- The floating action menu contains only actions available to the current role.
- Detail and creation flows sit above the persistent shell and return to their originating destination.
- The complete route library is available at `/mvp-screens`; state variations are available at `/state-lab`.

## Role and state model

Roles are Home Admin (every named tenant has equal admin powers), Member and Temporary Resident. Lifecycle is No Home, New, Setting Up, Active, Moving Out and Archived. Priority is independent: None, Setup, Rent due soon, Overdue, Task attention or Move-out.

Home is composed from role + lifecycle + priority. Joining never counts as Home setup. Setup contains exactly tenancy, rent, recurring payments and move-in protection.

## Privacy invariants

- Split groups and balances are visible only to participants.
- Personal Vault files are visible only to their owner until explicitly shared.
- Locked evidence is read-only; replacement creates a new record.
- Ownership transfer preserves history.
- Legal/financial Home changes show before/after values and require relevant approval.
- A landlord cannot see private splits, groceries, balances, personal inventory, personal documents or household-only activity.
- Housely records manual settlement status in V1; it does not claim to transfer money.

## UX quality contract

Every route must provide a clear screen title, concise outcome-oriented explanation, one primary action, a visible recovery path and contextual privacy language where needed. Data screens must support populated, loading, empty, offline, service-error, permission-lost and read-only states through the shared scenario gate.

Layouts use the existing Housely tokens, DM Sans, sentence case, minimum 48px targets, restrained motion and responsive content width. Financial/destructive changes require review before confirmation. Colour never communicates status alone.

## Review sequence

1. Run `/state-lab` for every Home role/lifecycle/priority combination.
2. Run `/mvp-screens` and open every product area.
3. Validate phone, tablet portrait and wide landscape.
4. Validate 200% text, keyboard focus, labels and reduced motion.
5. Verify all creation flows have cancel/back, validation, review and success behavior.
6. Verify all destructive flows explain impact and require confirmation.
7. Only after prototype approval, replace the mock repository with Supabase implementations.

