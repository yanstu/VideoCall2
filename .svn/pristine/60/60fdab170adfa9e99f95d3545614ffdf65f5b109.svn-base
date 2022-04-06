using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using VideoConnectionWeb.Helper;

namespace VideoConnectionWeb
{
    public partial class InitPage : System.Web.UI.Page
    {
        protected override void OnLoad(EventArgs e)
        {
            if (Session["LoginUser"] == null)
            {
                Response.Redirect("/DoDL.aspx");
            }
            else {
                ApiBaseUrl = ConfigHelper.ApiBaseUrl;
                HubBaseUrl = ConfigHelper.HubBaseUrl;
                AUC = new ApiUrlConfigHelper(ApiBaseUrl);
            }
            base.OnLoad(e);
        }
        public string ApiBaseUrl = "";
        public string HubBaseUrl = "";
        public ApiUrlConfigHelper AUC = null;
    }
}