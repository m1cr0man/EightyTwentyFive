using Microsoft.AspNetCore.Hosting;
using Microsoft.Extensions.Hosting;
using NetTopologySuite.Geometries;
using Npgsql;

namespace Pathfinder
{
    public class Program
    {
        public static void Main(string[] args)
        {
            // Logging config, useful for debugging query errors.
            // Npgsql.Logging.NpgsqlLogManager.IsParameterLoggingEnabled = true;
            // Npgsql.Logging.NpgsqlLogManager.Provider = new Npgsql.Logging.ConsoleLoggingProvider(Npgsql.Logging.NpgsqlLogLevel.Debug);
            NpgsqlConnection.GlobalTypeMapper.UseNetTopologySuite(
                handleOrdinates: NetTopologySuite.Geometries.Ordinates.XYZ,
                // PrecisionModels.Fixed defaults to scale 1, which means precision = 0 (no floating point)
                precisionModel: new PrecisionModel(PrecisionModels.Fixed)
            );
            CreateHostBuilder(args).Build().Run();
        }

        public static IHostBuilder CreateHostBuilder(string[] args) =>
            Host.CreateDefaultBuilder(args)
                .ConfigureWebHostDefaults(webBuilder =>
                {
                    webBuilder.UseStartup<Startup>();
                });
    }
}
