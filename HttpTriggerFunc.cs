using Microsoft.Extensions.Logging;
using Microsoft.Azure.Functions.Worker;
using Microsoft.Azure.Functions.Worker.Http;
using System.Net;
using System.Web;
using IsolatedFunc.Models;

namespace IsolatedFunc
{
    public class HttpTriggerFunc
    {
        private readonly ILogger _logger;

        public HttpTriggerFunc(ILoggerFactory loggerFactory)
        {
            _logger = loggerFactory.CreateLogger<HttpTriggerFunc>();
        }

        [Function("HttpTriggerFunc")]
        public MultiResponse Run([HttpTrigger(AuthorizationLevel.Anonymous, "get", "post")] HttpRequestData req)
        {
            _logger.LogInformation("C# HTTP trigger function processed a request.");
            var name = HttpUtility.ParseQueryString(req.Url.Query).Get("name");

            var message = $"Hello {name}!!";

            var response = req.CreateResponse(HttpStatusCode.OK);
            response.Headers.Add("Content-Type", "text/plain; charset=utf-8");
            response.WriteString(message);

            return new MultiResponse()
            {
                Document = new MyDocument
                {
                    id = System.Guid.NewGuid().ToString(),
                    message = message,
                    name = name
                },
                HttpResponse = response
            };
        }
    }
}