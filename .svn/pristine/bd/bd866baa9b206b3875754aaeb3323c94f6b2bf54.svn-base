using Microsoft.AspNet.SignalR;
using Microsoft.Owin;
using Owin;
using System;
using System.Threading.Tasks;
using VideoConnectionWeb.Helper;
using VideoConnectionWeb.MyHub;

[assembly: OwinStartup(typeof(VideoConnectionWeb.Startup))]

namespace VideoConnectionWeb
{
    public class Startup
    {
        chatHub hub = new chatHub();
        public void Configuration(IAppBuilder app)
        {
            // 有关如何配置应用程序的详细信息，请访问 https://go.microsoft.com/fwlink/?LinkID=316888
            GlobalHost.Configuration.DefaultMessageBufferSize =500;
            //app.MapSignalR();

            GlobalHost.DependencyResolver.Register(typeof(chatHub), () => hub);
            app.Map("/signalr", map =>
            {
                var hubConfiguration = new HubConfiguration
                {
                    EnableDetailedErrors = true,
                    EnableJSONP = true
                };
                map.RunSignalR(hubConfiguration);
            });
        }
    }
}
