using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Configuration;
using NetTopologySuite.Geometries;
using System;

namespace Pathfinder.Models
{
    public class MeshNodeContext : DbContext
    {
        public DbSet<MeshNode> MeshNodes { get; set; }

        public MeshNodeContext(DbContextOptions<MeshNodeContext> options) : base(options) { }

        protected override void OnModelCreating(ModelBuilder builder)
        {
            builder.HasPostgresExtension("postgis");

            builder.Entity<MeshNode>()
                .HasKey(b => new { b.WorldId, b.NodeId });

            // See https://postgis.net/docs/manual-3.1/postgis_usage.html#spgist_indexes
            // Also read https://postgis.net/docs/manual-3.1/postgis_usage.html#using-query-indexes
            builder.Entity<MeshNode>()
                .HasIndex(b => new { b.Pos })
                .HasMethod("SPGIST")
                .HasOperators("spgist_geometry_ops_3d");

            base.OnModelCreating(builder);
        }
    }

    public class MeshNode
    {
        public long WorldId { get; set; }
        public string NodeId { get; set; }
        public string BlockId { get; set; }
        [Column(TypeName = "geometry (pointz)")]
        public Point Pos { get; set; }

        public bool Equals(MeshNode other)
        {
            return Pos.Equals(other.Pos);
        }

        public void GenerateId()
        {
            NodeId = MeshNode.GenerateId((long)Pos.X, (long)Pos.Y, (long)Pos.Z);
        }

        public static string GenerateId(long x, long y, long z) =>
            Base62.ConvertLong(x)
            + ":" + Base62.ConvertLong(y)
            + ":" + Base62.ConvertLong(z);
    }

    public class MeshNodeDTO
    {
        [Required]
        [Positive]
        public long WorldId { get; set; }
        [Required]
        [BlockId]
        public string BlockId { get; set; }
        [Required]
        public long X { get; set; }
        [Required]
        public long Y { get; set; }
        [Required]
        [Positive]
        public long Z { get; set; }
    }
}
