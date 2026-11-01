# Row-level security per entity

One report serves every hospital and health unit. Each one must see only its own rows, while the purchasing body sees everything.

## Approach (design)
RLS filters rows **before** measures run, so no measure needs an entity-specific version. Every KPI, percentage and table recalculates automatically for the viewer.

## Role definition (mapping table)

```dax
// Role "Entity" — filter on the entity dimension
DIM_ENTITY[EntityCode]
    = LOOKUPVALUE (
        UserEntityMap[EntityCode],
        UserEntityMap[UserEmail], USERPRINCIPALNAME ()
    )
```

`UserEntityMap` is maintained by the business (a SharePoint list ingested into the Lakehouse), so adding a user doesn't require republishing the report.

For a user with access to several entities:

```dax
DIM_ENTITY[EntityCode]
    IN CALCULATETABLE (
        VALUES ( UserEntityMap[EntityCode] ),
        UserEntityMap[UserEmail] = USERPRINCIPALNAME ()
    )
```

## Rollout
1. Test with **View as → Other user** in Desktop.
2. In the Service, assign Entra ID security groups to the role.
3. Share the report or app with those groups only.
4. Keep the purchasing team in a group with no RLS role and workspace access, so they see all rows.

## Watch out
- Measures using `REMOVEFILTERS` on entity columns still respect RLS (RLS can't be removed by DAX), but they will show the overall figure *within what the user can see*, which may confuse. Label them clearly.
- Report links shared outside the workspace must go through the app or a security group; a direct link to the report doesn't bypass RLS, but it will show an access request to people outside the groups.
