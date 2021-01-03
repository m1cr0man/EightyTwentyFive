# GeoTurtle Pathfinder API

Geospatial database for minecraft worlds with patfinding and
and block locating features, intended for use with
ComputerCraft and OpenComputers.

## Development

### Working with Migrations

[Docs from MS](https://docs.microsoft.com/en-gb/ef/core/managing-schemas/migrations/?tabs=dotnet-core-cli)

```bash
# Create a new migration
dotnet ef migrations add -o Migrations MyMigrationName
# Do migrations
dotnet ef database update
# Revert (find name first)
dotnet ef migrations list
dotnet ef database update LastMigrationName
# Remove latest migration
dotnet ef migrations remove
```

### Creating new Controllers

```bash
dotnet aspnet-codegenerator controller -outDir Controllers -async -api -name MyItemController -m MyItem -dc MyItemContext
```
