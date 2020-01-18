USE AdventureWorks
GO

CREATE NONCLUSTERED INDEX idx_city ON Person.Address(City) INCLUDE (AddressLine1)
GO

CREATE NONCLUSTERED INDEX idx_city2 ON Person.Address(City) INCLUDE (AddressLine1, AddressLine2)
WHERE AddressLine2 IS NOT NULL
GO

CREATE SPATIAL INDEX sidx_spatiallocation
   ON Person.Address(SpatialLocation)
   USING GEOGRAPHY_GRID
   WITH (GRIDS = (MEDIUM, LOW, MEDIUM, HIGH ),
    CELLS_PER_OBJECT = 64);
GO

ALTER INDEX ALL
ON Person.Address
REBUILD
GO

ALTER INDEX IX_Person_LastName_FirstName_MiddleName
ON Person.Address
REORGANIZE
GO

ALTER INDEX PK_Address_AddressID
ON Person.Address
DISABLE
GO

SELECT * FROM Person.Address
GO

ALTER INDEX PK_Address_AddressID
ON Person.Address
REBUILD
GO

SELECT * FROM Person.Address
GO