using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.SessionState;
using VideoConnectionWeb.Helper;
using VideoConnectionWeb.Models;

namespace VideoConnectionWeb.Handler
{
    /// <summary>
    /// VideoConferenceHandler 的摘要说明
    /// </summary>
    public class VideoConferenceHandler : IHttpHandler, IRequiresSessionState
    {

        public void ProcessRequest(HttpContext context)
        {
            context.Response.ContentType = "text/plain";
            string type = context.Request.Form["type"];
            UsersModel LogUser = new UsersModel();
            if (context.Session != null)
            {
                var user = context.Session["LoginUser"];
                if (user != null)
                {
                    LogUser = (UsersModel)user;
                }
            }
            ApiUrlConfigHelper ApiUrl = new ApiUrlConfigHelper(ConfigHelper.ApiBaseUrl);
            if (LogUser != null)
            {
                if (type == "CheckJRHY")
                {
                    WebServiceHelper wsh = new WebServiceHelper();
                    Dictionary<string, string> dicContent = new Dictionary<string, string>();
                    dicContent.Add("HYID", context.Request.Form["HYID"]);
                    dicContent.Add("QYBH", LogUser.QYBH);
                    dicContent.Add("UserID", LogUser.UserID);
                    dicContent.Add("UserName", LogUser.UserName);
                    dicContent.Add("DBKID", context.Request.Form["DBKID"]);
                    dicContent.Add("LX", context.Request.Form["LX"]);
                    DataResult dr = wsh.SendHttpPost(ApiUrl.CheckJRHY, dicContent);
                    if (dr.Code == 0)
                    {
                        context.Session["VideoJsonStr"] = (string)dr.Data.JsonStr;
                    }
                    context.Response.Write(JsonHelper.SerializeJSON(dr));
                }
            }
        }

        public bool IsReusable
        {
            get
            {
                return false;
            }
        }
    }
}