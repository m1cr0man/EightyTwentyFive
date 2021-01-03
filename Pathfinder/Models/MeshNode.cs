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
            builder.Entity<MeshNode>().HasKey(x => x.Id);

            base.OnModelCreating(builder);
        }
    }

    public class MeshNode
    {
        public long Id { get; set; }
        [Column(TypeName = "geometry (pointz)")]
        public Point Pos { get; set; }
        public string BlockId { get; set; }
        public float Certainty { get; set; }

        public bool Equals(MeshNode other)
        {
            return Pos.Equals(other.Pos);
        }

    }
}
