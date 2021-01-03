using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using Pathfinder.Models;

namespace Pathfinder.Controllers
{
    [Route("api/[controller]")]
    [ApiController]
    public class MeshNodeController : ControllerBase
    {
        private readonly MeshNodeContext _context;

        public MeshNodeController(MeshNodeContext context)
        {
            _context = context;
        }

        // GET: api/MeshNode
        [HttpGet]
        public async Task<ActionResult<IEnumerable<MeshNode>>> GetMeshNodes()
        {
            return await _context.MeshNodes.ToListAsync();
        }

        // GET: api/MeshNode/5
        [HttpGet("{id}")]
        public async Task<ActionResult<MeshNode>> GetMeshNode(long id)
        {
            var meshNode = await _context.MeshNodes.FindAsync(id);

            if (meshNode == null)
            {
                return NotFound();
            }

            return meshNode;
        }

        // PUT: api/MeshNode/5
        // To protect from overposting attacks, see https://go.microsoft.com/fwlink/?linkid=2123754
        [HttpPut("{id}")]
        public async Task<IActionResult> PutMeshNode(long id, MeshNode meshNode)
        {
            if (id != meshNode.Id)
            {
                return BadRequest();
            }

            _context.Entry(meshNode).State = EntityState.Modified;

            try
            {
                await _context.SaveChangesAsync();
            }
            catch (DbUpdateConcurrencyException)
            {
                if (!MeshNodeExists(id))
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
        // To protect from overposting attacks, see https://go.microsoft.com/fwlink/?linkid=2123754
        [HttpPost]
        public async Task<ActionResult<MeshNode>> PostMeshNode(MeshNode meshNode)
        {
            _context.MeshNodes.Add(meshNode);
            await _context.SaveChangesAsync();

            return CreatedAtAction("GetMeshNode", new { id = meshNode.Id }, meshNode);
        }

        // DELETE: api/MeshNode/5
        [HttpDelete("{id}")]
        public async Task<IActionResult> DeleteMeshNode(long id)
        {
            var meshNode = await _context.MeshNodes.FindAsync(id);
            if (meshNode == null)
            {
                return NotFound();
            }

            _context.MeshNodes.Remove(meshNode);
            await _context.SaveChangesAsync();

            return NoContent();
        }

        private bool MeshNodeExists(long id)
        {
            return _context.MeshNodes.Any(e => e.Id == id);
        }
    }
}
