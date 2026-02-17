# Database Query Commands

Useful PostgreSQL queries for the EventOrganising database.

## View All Users with Their Roles

```sql
SELECT 
  u.email, 
  u."fullName", 
  array_agg(DISTINCT r.role) as roles, 
  u."createdAt"
FROM "User" u
LEFT JOIN "Role" r ON u.id = r."userId"
GROUP BY u.id, u.email, u."fullName", u."createdAt"
ORDER BY u."createdAt" DESC;
```

## View Users by Role Count

```sql
SELECT 
  r.role, 
  COUNT(DISTINCT u.id) as user_count
FROM "User" u
JOIN "Role" r ON u.id = r."userId"
GROUP BY r.role
ORDER BY user_count DESC;
```

## View All Service Listings with Details

```sql
SELECT 
  id,
  title,
  location,
  address,
  pincode,
  "propertyType",
  capacity,
  "eventTypes",
  amenities,
  status,
  "submittedAt",
  "publishedAt"
FROM "ServiceListing"
ORDER BY "submittedAt" DESC;
```

## View Service Providers (Venue Owners)

```sql
SELECT 
  sp.id, 
  u.email,
  u."fullName",
  sp.status,
  sp."kycDocumentUrl",
  sp."createdAt"
FROM "ServiceProvider" sp
JOIN "User" u ON sp."userId" = u.id
ORDER BY sp."createdAt" DESC;
```

## View Verification Assignments

```sql
SELECT 
  va.id,
  sl.title as service_title,
  sl.status as service_status,
  u_assigned_by.email as assigned_by_manager,
  u_provider.email as nodal_officer,
  va.status as verification_status,
  va.notes,
  va."createdAt"
FROM "VerificationAssignment" va
JOIN "ServiceListing" sl ON va."serviceId" = sl.id
JOIN "User" u_assigned_by ON va."assignedById" = u_assigned_by.id
JOIN "ServiceProvider" sp ON va."providerId" = sp.id
JOIN "User" u_provider ON sp."userId" = u_provider.id
ORDER BY va."createdAt" DESC;
```

## Count Statistics

```sql
SELECT 
  (SELECT COUNT(*) FROM "User") as total_users,
  (SELECT COUNT(*) FROM "ServiceListing") as total_services,
  (SELECT COUNT(*) FROM "ServiceListing" WHERE status = 'PENDING') as pending_services,
  (SELECT COUNT(*) FROM "ServiceListing" WHERE status = 'PUBLISHED') as published_services,
  (SELECT COUNT(*) FROM "ServiceProvider") as total_providers,
  (SELECT COUNT(*) FROM "VerificationAssignment") as total_verifications;
```

## Users Who Can Submit Services (PROVIDER role)

```sql
SELECT 
  u.email,
  u."fullName",
  sp.status as provider_status,
  COUNT(s.id) as services_submitted
FROM "User" u
JOIN "Role" r ON u.id = r."userId" AND r.role = 'PROVIDER'
LEFT JOIN "ServiceProvider" sp ON u.id = sp."userId"
LEFT JOIN "ServiceListing" s ON u.id = s."ownerId"
GROUP BY u.id, u.email, u."fullName", sp.status
ORDER BY services_submitted DESC;
```

## Quick Start

1. **View all users:**
   ```bash
   psql -U postgres -d eventorganising -c "SELECT * FROM \"User\";"
   ```

2. **View all services:**
   ```bash
   psql -U postgres -d eventorganising -c "SELECT * FROM \"ServiceListing\";"
   ```

3. **View all roles:**
   ```bash
   psql -U postgres -d eventorganising -c "SELECT * FROM \"Role\";"
   ```

