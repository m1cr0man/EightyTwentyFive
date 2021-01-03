using System;
using Microsoft.EntityFrameworkCore.Migrations;
using NetTopologySuite.Geometries;

namespace Pathfinder.Migrations
{
    public partial class InitialCreate : Migration
    {
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.AlterDatabase()
                .Annotation("Npgsql:PostgresExtension:postgis", ",,");

            migrationBuilder.CreateTable(
                name: "MeshNodes",
                columns: table => new
                {
                    WorldId = table.Column<long>(type: "bigint", nullable: false),
                    NodeId = table.Column<string>(type: "text", nullable: false),
                    BlockId = table.Column<string>(type: "text", nullable: true),
                    Pos = table.Column<Point>(type: "geometry (pointz)", nullable: true)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_MeshNodes", x => new { x.WorldId, x.NodeId });
                });

            migrationBuilder.CreateIndex(
                name: "IX_MeshNodes_Pos",
                table: "MeshNodes",
                column: "Pos")
                .Annotation("Npgsql:IndexMethod", "SPGIST")
                .Annotation("Npgsql:IndexOperators", new[] { "spgist_geometry_ops_3d" });
        }

        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropTable(
                name: "MeshNodes");
        }
    }
}
