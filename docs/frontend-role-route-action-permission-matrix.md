# Frontend Role, Route, and Action Permission Matrix

Frontend-only reference for current access behavior in DISHA HSC Pulse. This file is meant to make role-wise testing easier before backend RLS validation.

Scope:

1. Current frontend route guards
2. Current page/action behavior
3. Required workflow expectation
4. Known gaps from the current implementation
5. Code locations to update later

Last reviewed: 2026-07-08

## Roles

Required roles covered here:

1. System Administrator / Super Admin
2. CEO
3. Group DISHA HSC PIC
4. Group Functional HOD / VP
5. Branch DISHA PIC / Auditor
6. Location Functional HOD / PIC
7. Viewer

## Route Inventory

| Route | Page | Current route protection | Notes |
| --- | --- | --- | --- |
| `/dashboard` | Dashboard | `ProtectedRoute` only | Any logged-in frontend user |
| `/audits/new` | AuditCreation | `FeatureRouteGuard("audit-workbench")` | Used for audit creation and audit list |
| `/audits/:id/conduct` | ConductAudit | `AuditModuleOnly` -> `canViewAuditModule(user)` | Allows any user with `audit-workbench` or `conduct-audit` |
| `/action-center` | ActionCenter | `ProtectedRoute` only | No feature guard |
| `/verification` | Verification | `FeatureRouteGuard("verification")` | Queue page |
| `/reports` | Reports | `FeatureRouteGuard("reports")` | Wrapped by error boundary |
| `/management-review` | ManagementReviewCenter | `FeatureRouteGuard("management-review")` | Executive/governance view |
| `/super-admin` | SuperAdminControlCenter | `AdminOnly` -> `isSuperAdmin(user)` | Blocks plain System Administrator |
| `/masters` | MasterData | `AdminOnly` -> `isSuperAdmin(user)` | Blocks plain System Administrator |
| `/masters/import` | MasterImport | `AdminOnly` -> `isSuperAdmin(user)` | Blocks plain System Administrator |
| `/yokoten` | YokotenLibrary | `FeatureRouteGuard("yokoten")` | Not part of the core workflow here |

Primary route files:

1. `src/App.jsx`
2. `src/auth/ProtectedRoute.jsx`
3. `src/auth/AuthContext.jsx`

## Current Role Profiles

Current frontend role profiles come from `ROLE_PROFILES` in `src/auth/AuthContext.jsx`.

| Role profile id | Label in UI | Current features |
| --- | --- | --- |
| `system-admin` | System Administrator | `dashboard`, `action-center`, `audit-workbench`, `masters`, `reports`, `super-admin` |
| `ceo` | CEO | `dashboard`, `action-center`, `reports`, `management-review` |
| `group-disha` | Group DISHA HSC PIC | `dashboard`, `action-center`, `verification`, `management-review`, `reports`, `yokoten` |
| `group-functional-hod` | Group Functional PIC / HOD | `dashboard`, `action-center`, `reports` |
| `branch-auditor` | Branch DISHA PIC | `dashboard`, `action-center`, `audit-workbench`, `conduct-audit`, `verification`, `reports`, `yokoten` |
| `location-functional-hod` | Location Functional HOD | `dashboard`, `action-center`, `reports` |
| `viewer` | Viewer | `dashboard`, `reports` |

## Role-to-Route Matrix

Meaning:

1. `Yes` = route is currently reachable in frontend
2. `No` = route is blocked in frontend
3. `Partial` = route opens, but action behavior is narrower or inconsistent

| Role | Dashboard | Audit Creation `/audits/new` | Conduct Audit `/audits/:id/conduct` | Action Center | Verification | Reports | Management Review | Masters/Admin |
| --- | --- | --- | --- | --- | --- | --- | --- | --- |
| System Administrator | Yes | Yes | Yes | Yes | No | Yes | No | Partial |
| Super Admin | Yes | Yes | Yes | Yes | No | Yes | No | Yes |
| CEO | Yes | No | No | Yes | No | Yes | Yes | No |
| Group DISHA HSC PIC | Yes | No | No | Yes | Yes | Yes | Yes | No |
| Group Functional HOD / VP | Yes | No | No | Yes | No | Yes | No | No |
| Branch DISHA PIC / Auditor | Yes | Yes | Yes | Yes | Yes | Yes | No | No |
| Location Functional HOD / PIC | Yes | No | No | Yes | No | Yes | No | No |
| Viewer | Yes | No | No | Partial | No | Yes | No | No |

Notes:

1. `System Administrator` is marked `Partial` for Masters/Admin because the role profile grants access, but `AdminOnly` allows only `isSuperAdmin(user)`.
2. `Viewer` is marked `Partial` for Action Center because the route is reachable by direct URL even though the sidebar hides it.

## Route and Action Matrix By Role

### System Administrator / Super Admin

| Area | Current frontend behavior | Required behavior | Gap |
| --- | --- | --- | --- |
| Audit creation | Allowed | Allowed for admin | Aligned |
| Conduct audit | Allowed | Usually should not be the normal actor, but can be support/admin if desired | Needs business confirmation |
| CAPA/action workspace | Allowed | Admin oversight is fine | Aligned if admin should supervise |
| Masters/admin pages | Only Super Admin truly allowed | System Administrator / Super Admin should work | Plain System Administrator blocked by route |
| Reports | Allowed | Allowed | Aligned |

Current code:

1. `src/auth/AuthContext.jsx` role profile grants `masters` and `super-admin`
2. `src/App.jsx` `AdminOnly` checks only `isSuperAdmin(user)`

### CEO

| Area | Current frontend behavior | Required behavior | Gap |
| --- | --- | --- | --- |
| Dashboard | Allowed | Allowed | Aligned |
| Action Center | Allowed | Final approval only where required | Broader than required |
| Financial approval | Handled through Action Center | Allowed where required | Works conceptually, but not isolated to final approval only |
| Management review | Allowed | Allowed | Aligned |
| Reports | Allowed | Allowed | Aligned |

### Group DISHA HSC PIC

| Area | Current frontend behavior | Required behavior | Gap |
| --- | --- | --- | --- |
| Review/approval | Allowed | Allowed | Aligned in principle |
| Verification queue | Allowed | Allowed | Aligned in route terms |
| Action Center editing | Can update PIC work because `adminView` enables `canUpdate` | Should review/approve, not act as PIC owner | Too much edit power |
| Reports | Allowed | Allowed | Aligned |

### Group Functional HOD / VP

| Area | Current frontend behavior | Required behavior | Gap |
| --- | --- | --- | --- |
| Dashboard | Allowed | Allowed | Aligned |
| Action Center | Allowed | Department work/review visibility | Likely usable, but no dedicated approval lane |
| Reports | Allowed | Allowed | Aligned |
| Management review | Not allowed | Depends on business expectation | Needs confirmation |

### Branch DISHA PIC / Auditor

| Area | Current frontend behavior | Required behavior | Gap |
| --- | --- | --- | --- |
| Audit creation | Allowed | Admin creates audit | Too much access |
| Conduct audit | Allowed | Allowed | Aligned |
| Mark OK/NG/NA | Allowed | Allowed | Aligned |
| Assign PIC and tentative closure date for NG | Allowed | Allowed | Aligned |
| Verification | Allowed | Auditor verifies closure | Aligned in route terms |
| Reports | Allowed | Allowed | Aligned |

### Location Functional HOD / PIC

| Area | Current frontend behavior | Required behavior | Gap |
| --- | --- | --- | --- |
| Action Center visibility | Route allowed | Should see only NG/action items assigned to them | Current list is broader than assigned-only |
| CAPA/action submission | Allowed when item is assigned or collaborator | Allowed | Aligned for update logic |
| Reports | Allowed | Allowed as read-only history | Aligned |

Important detail:

1. Assignment matching checks `assigned_pic_user_id`
2. Assignment matching checks `pic_for_ng_user_id`
3. Assignment matching checks `pic_for_ng_mobile`
4. The bug is not field coverage
5. The bug is that fetched `assignedRows` are not the rows rendered

### Viewer

| Area | Current frontend behavior | Required behavior | Gap |
| --- | --- | --- | --- |
| Dashboard | Allowed | Allowed | Aligned |
| Reports | Allowed | Allowed | Aligned |
| Edit actions | No role-profile feature for action work | Should not edit anything | Mostly aligned |
| Direct URL Action Center | Route opens | Should be blocked | Route guard missing |

## Page-Level Action Matrix

### Audit Creation

| Action | Current behavior |
| --- | --- |
| Open page | Any role with `audit-workbench` |
| Create audit | Any role with `canAccessAuditModule(user)` or `isSystemAdmin(user)` |
| Continue to checklist | Same as above |

Gap:

1. Branch Auditor currently has `audit-workbench`
2. `canAccessAuditModule(user)` also treats conduct permission and workbench permission as the same capability

### Conduct Audit

| Action | Current behavior |
| --- | --- |
| Open conduct page | Any role with `audit-workbench` or `conduct-audit` |
| Edit checklist answers | Same as above |
| Save draft | Same as above |
| Submit audit | Same as above |

Gap:

1. Current conduct access is not assignment-aware
2. Current conduct access is broader than the auditor-only workflow

### Action Center

| Action | Current behavior |
| --- | --- |
| Open page | Any authenticated user by direct URL |
| See NG list | Scoped by department/location, but not restricted to assigned-only for PIC users |
| Update action | `adminView` or assigned PIC or collaborator |
| Submit for review | Same as update |
| Approve closure | `reviewerView` or `adminView` |
| Expense approval | Group DISHA or CEO depending stage, plus System Admin |

Gap:

1. Owner visibility bug: page builds `assignedRows`, then renders `validRows`
2. Reviewer roles can update action-owner work because `adminView` also grants `canUpdate`
3. Route is not feature-guarded

### Verification

| Action | Current behavior |
| --- | --- |
| Open verification queue | Any role with `verification` feature |
| See queue contents | All CAPAs in verification statuses from context |
| Open verification item | Navigates to Action Center |

Gap:

1. Queue is not filtered by assigned auditor, audit owner, or scope in this page

### Management Review

| Action | Current behavior |
| --- | --- |
| Open page | Any role with `management-review` feature |
| See metrics | All loaded audits/CAPAs/Yokoten in context |
| Export/print | Allowed |

Gap:

1. Page is role-gated, but not scope-gated

## Hidden Button vs Direct URL Check

| Case | Current result |
| --- | --- |
| Viewer does not see Action Center in sidebar | True |
| Viewer can still hit `/action-center` directly | True |
| System Administrator sees Masters in profile navigation model | True |
| System Administrator can open `/masters` | False |

Conclusion:

1. Some permissions are enforced only by navigation visibility
2. Some permissions are enforced only by route guards
3. Route and navigation are not fully aligned

## Assigned PIC Field Usage Check

Current frontend code uses these fields where applicable:

| Field | Usage |
| --- | --- |
| `assigned_pic_user_id` | Read and match in Action Center |
| `pic_for_ng_user_id` | Read and match in Action Center |
| `pic_for_ng_mobile` | Read and match in Action Center |

Conduct Audit save mapping also writes:

1. `assigned_pic_user_id`
2. `pic_for_ng_user_id`
3. `pic_for_ng_mobile`

## Authentication Model Note

Current frontend login is local-session based:

1. User is read from `app_users`
2. Role mappings are read from `user_access_mappings`
3. Session is stored in `localStorage`
4. Login does not establish a Supabase auth identity

Why this matters:

1. Frontend route access may succeed
2. Backend writes can still fail under RLS if they expect `auth.uid()`
3. Frontend permission testing and backend permission testing are currently separate concerns

## Recommended Fix Order

Suggested order for future implementation:

1. Guard `/action-center` with a feature-based route guard
2. Fix Action Center assigned-owner filtering to use `assignedRows` for PIC-facing views
3. Split `audit-workbench` from `conduct-audit` in both route guards and page edit checks
4. Replace `AdminOnly` with a capability check that matches the intended System Administrator access model
5. Scope `Verification.jsx` by role and assignment
6. Decide whether frontend identity must be linked to Supabase auth before RLS validation

## Source Files

Primary files reviewed:

1. `src/App.jsx`
2. `src/auth/AuthContext.jsx`
3. `src/auth/ProtectedRoute.jsx`
4. `src/components/AppShell.jsx`
5. `src/pages/AuditCreation.jsx`
6. `src/pages/ConductAudit.jsx`
7. `src/pages/ActionCenter.jsx`
8. `src/pages/Verification.jsx`
9. `src/pages/ManagementReviewCenter.jsx`
10. `src/pages/ReportsDashboard.jsx`
