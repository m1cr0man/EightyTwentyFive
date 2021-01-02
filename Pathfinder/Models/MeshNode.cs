using System.ComponentModel.DataAnnotations.Schema;
using Microsoft.EntityFrameworkCore;
using NetTopologySuite.Geometries;


namespace Pathfinder.Models
{
    public class MeshNodeContext : DbContext
    {
        public DbSet<MeshNode> MeshNodes { get; set; }

        protected override void OnConfiguring(DbContextOptionsBuilder optionsBuilder)
            => optionsBuilder.UseNpgsql(
                "Host=192.168.137.2;Database=pathfinder;Username=pathfinder;Password=[ur]l3H4v3n",
                o => o.UseNetTopologySuite()
            );

        protected override void OnModelCreating(ModelBuilder builder)
        {
            builder.HasPostgresExtension("postgis");

            base.OnModelCreating(builder);
        }
    }

    public class MeshNode
    {
        [Column(TypeName = "geometry (point z)")]
        public CoordinateZ Pos { get; set; }
        public string BlockId { get; set; }
        public float Certainty { get; set; }

        public bool Equals(MeshNode other)
        {
            return Pos.Equals(other.Pos);
        }

    }
}
