using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using Pathfinder.Models;
using NetTopologySuite.Geometries;
using NetTopologySuite;

namespace Pathfinder.Controllers
{
    [Route("api/[controller]")]
    [ApiController]
    public class MeshNodeController : ControllerBase
    {
        private readonly MeshNodeContext _context;
        private readonly GeometryFactory _geometryFactory;

        public MeshNodeController(MeshNodeContext context)
        {
            _context = context;
            _geometryFactory = NtsGeometryServices.Instance.CreateGeometryFactory(new PrecisionModel(PrecisionModels.Fixed));
        }

        // GET: api/MeshNode
        [HttpGet]
        public async Task<ActionResult<IEnumerable<MeshNodeDTO>>> GetMeshNodes()
        {
            return await _context.MeshNodes.Select(x => ItemToDTO(x)).ToListAsync();
        }

        // GET: api/MeshNode/123/5/3/-14
        [HttpGet("{worldId}/{x}/{y}/{z}")]
        public async Task<ActionResult<MeshNodeDTO>> GetMeshNode(long worldId, long x, long y, long z)
        {
            var blockId = MeshNode.GenerateId(x, y, z);
            var item = await _context.MeshNodes.FindAsync(worldId, blockId);

            if (item == null)
            {
                return NotFound();
            }

            return ItemToDTO(item);
        }

        // PUT: api/MeshNode/1/5/3/-14
        [HttpPut("{worldId}/{x}/{y}/{z}")]
        public async Task<IActionResult> PutMeshNode(long worldId, long x, long y, long z, MeshNodeDTO dto)
        {
            if (worldId != dto.WorldId || x != dto.X || y != dto.Y || z != dto.Z)
            {
                return BadRequest();
            }

            var blockId = MeshNode.GenerateId(x, y, z);
            var item = await _context.MeshNodes.FindAsync(worldId, blockId);
            if (item == null)
            {
                return NotFound();
            }

            item.BlockId = dto.BlockId;

            try
            {
                await _context.SaveChangesAsync();
            }
            catch (DbUpdateConcurrencyException)
            {
                if (!MeshNodeExists(worldId, blockId))
                {
                    return NotFound();
                }
                else
                {
                    throw;
                }
            }

            return NoContent();
        }

        // POST: api/MeshNode
        [HttpPost]
        public async Task<ActionResult<MeshNode>> PostMeshNode(MeshNodeDTO dto)
        {
            var item = DTOToItem(dto);
            _context.MeshNodes.Add(item);
            await _context.SaveChangesAsync();

            return CreatedAtAction("GetMeshNode", new
            {
                WorldId = dto.WorldId,
                X = dto.X,
                Y = dto.Y,
                Z = dto.Z
            }, ItemToDTO(item));
        }

        // DELETE: api/MeshNode/1/5/3/-14
        [HttpDelete("{worldId}/{x}/{y}/{z}")]
        public async Task<IActionResult> DeleteMeshNode(long worldId, long x, long y, long z)
        {
            var blockId = MeshNode.GenerateId(x, y, z);
            var item = await _context.MeshNodes.FindAsync(worldId, blockId);
            if (item == null)
            {
                // Idempotent
                return NoContent();
            }

            _context.MeshNodes.Remove(item);
            await _context.SaveChangesAsync();

            return NoContent();
        }

        private bool MeshNodeExists(long worldId, string id)
        {
            return _context.MeshNodes.Any(e => e.WorldId == worldId && e.NodeId == id);
        }

        private static MeshNodeDTO ItemToDTO(MeshNode node) =>
            new MeshNodeDTO
            {
                WorldId = node.WorldId,
                BlockId = node.BlockId.ToLower(),
                X = (long)node.Pos.X,
                Y = (long)node.Pos.Y,
                Z = (long)node.Pos.Z
            };

        private MeshNode DTOToItem(MeshNodeDTO dto)
        {
            MeshNode item = new MeshNode
            {
                WorldId = dto.WorldId,
                BlockId = dto.BlockId,
                Pos = _geometryFactory.CreatePoint(new CoordinateZ((double)dto.X, (double)dto.Y, (double)dto.Z))
            };
            // NodeId will always be the same for the same position
            item.GenerateId();
            return item;
        }
    }
}
