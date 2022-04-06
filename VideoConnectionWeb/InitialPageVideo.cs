using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using VideoConnectionWeb.Helper;

namespace VideoConnectionWeb
{
    public partial class InitialPageVideo : System.Web.UI.Page
    {
        protected override void OnLoad(EventArgs e)
        {
            if (Session["VideoJsonStr"] == null)
            {
                Response.Redirect("/QZ/login.aspx");
            }
            else
            {
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