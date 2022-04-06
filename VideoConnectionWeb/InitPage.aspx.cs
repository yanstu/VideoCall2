using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace VideoConnectionWeb
{
    public partial class InitPage : System.Web.UI.Page
    {
       
        protected override void OnLoad(EventArgs e)
        {
            if (Session["Token"] == null)
            {
                Response.Redirect("/DoDL.aspx");
            }
            base.OnLoad(e);
        }
    }
}