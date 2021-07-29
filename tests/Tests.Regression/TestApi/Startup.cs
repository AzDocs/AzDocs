using System;
using Microsoft.ApplicationInsights.Extensibility;
using Microsoft.AspNetCore.Builder;
using Microsoft.AspNetCore.Hosting;
using Microsoft.Extensions.Caching.StackExchangeRedis;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.DependencyInjection;
using Microsoft.Extensions.Hosting;
using Serilog;

namespace TestApi
{
    public class Startup
    {
        public Startup(IConfiguration configuration)
        {
            // Setting up configuration from properties + appsettings
            Configuration = new ConfigurationBuilder()
                .AddJsonFile("appsettings.json")
                .AddEnvironmentVariables().Build();

            Log.Logger = new LoggerConfiguration()
                .WriteTo
                .ApplicationInsights(new TelemetryConfiguration
                { InstrumentationKey = Configuration["APPINSIGHTS_INSTRUMENTATIONKEY"] },
                TelemetryConverter.Traces)
                .CreateLogger();
        }

        public IConfiguration Configuration { get; }

        // This method gets called by the runtime. Use this method to add services to the container.
        public void ConfigureServices(IServiceCollection services)
        {
            services.AddControllers();
            services.AddApplicationInsightsTelemetry(Configuration["APPINSIGHTS_INSTRUMENTATIONKEY"]);
            services.AddLogging(loggingBuilder => loggingBuilder.AddSerilog(Log.Logger));

            Action<RedisCacheOptions> redisOptions = (options =>
            {
                options.Configuration = Configuration.GetConnectionString("RedisConnectionString");
            });

            services.AddStackExchangeRedisCache(redisOptions);
        }

        // This method gets called by the runtime. Use this method to configure the HTTP request pipeline.
        public void Configure(IApplicationBuilder app, IWebHostEnvironment env)
        {
            if (env.IsDevelopment())
            {
                app.UseDeveloperExceptionPage();
            }

            app.UseHttpsRedirection();

            app.UseRouting();

            app.UseAuthorization();
            app.UseStaticFiles();
            app.UseEndpoints(endpoints =>
            {
                endpoints.MapControllers();
            });

            // this can be used to log all requests to serilog, disabling for now
            // app.UseSerilogRequestLogging();
        }
    }
}
