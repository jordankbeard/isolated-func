using Microsoft.Azure.Functions.Worker;
using Microsoft.Azure.Functions.Worker.Http;

namespace IsolatedFunc.Models
{
    public class MultiResponse
    {
        [CosmosDBOutput("my-database", "my-container",
            ConnectionStringSetting = "CosmosDbConnectionString", CreateIfNotExists = true)]
        public MyDocument? Document { get; set; }
        public HttpResponseData? HttpResponse { get; set; }
    }
}