using System;
using Microsoft.ApplicationInsights.Extensibility;
using Microsoft.AspNetCore.Builder;
using Microsoft.AspNetCore.Hosting;
using Microsoft.Extensions.Caching.StackExchangeRedis;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.DependencyInjection;
using Microsoft.Extensions.Hosting;
using Serilog;
using Microsoft.OpenApi.Models;
using System.Reflection;
using System.IO;

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
            services.AddSwaggerGen(c =>
            {
                c.SwaggerDoc("v1", new OpenApiInfo
                {
                    Version = "v1",
                    Title = "TestApi",
                    Description = "WebApp to test how well the az cli scripts worked.",
                    TermsOfService = new Uri("https://go.microsoft.com/fwlink/?LinkID=206977"),
                    Contact = new OpenApiContact
                    {
                        Name = "Team",
                        Email = string.Empty,
                        Url = new Uri("https://example.com")
                    }
                });

                // Set the comments path for the Swagger JSON and UI.
                var xmlFile = $"{Assembly.GetExecutingAssembly().GetName().Name}.xml";
                var xmlPath = Path.Combine(AppContext.BaseDirectory, xmlFile);
                c.IncludeXmlComments(xmlPath);
            });
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
            app.UseSwagger();
            app.UseSwaggerUI(c =>
            {
                c.SwaggerEndpoint("/swagger/v1/swagger.json", "TestApi V1");
            });

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
