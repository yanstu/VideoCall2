using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using VideoConnectionWeb.Helper;
using VideoConnectionWeb.Models;

namespace VideoConnectionWeb
{
    public partial class TestItem : System.Web.UI.Page
    {
        public string QueryMAC = "";
        private string JsonStr = "";
        private string RoomId = "";
        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                QueryMAC = Request.QueryString["MAC"];
                if (!string.IsNullOrEmpty(QueryMAC))
                {
                    QueryMAC = JsonHelper.SetMACFormat(QueryMAC);
                    ApiUrlConfigHelper ApiUrl = new ApiUrlConfigHelper(ConfigHelper.ApiBaseUrl);
                    WebServiceHelper wsh = new WebServiceHelper();
                    Dictionary<string, string> dicContent = new Dictionary<string, string>();
                    dicContent.Add("MAC", QueryMAC);
                    DataResult dr = wsh.SendHttpPost(ApiUrl.HaveConference, dicContent);
                    if (dr.Code == 0)
                    {
                        if (dr.Data != null)
                        {
                            string tempJsonStr = dr.Data.JsonStr;
                            string tempRoomId = dr.Data.RoomId;

                            Session["VideoJsonStr"] = tempJsonStr;
                            string url = "index.aspx?p=" + tempJsonStr + "&RoomId=" + tempRoomId;
                            Response.Redirect(url);
                        }
                    }
                }
            }
        }
    }
}