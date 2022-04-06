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
    /// LoginHandler 的摘要说明
    /// </summary>
    public class LoginHandler : IHttpHandler, IRequiresSessionState
    {

        public void ProcessRequest(HttpContext context)
        {
            context.Response.ContentType = "text/plain";
            string type = context.Request.Form["type"];
            DataResult dr = new DataResult("");
            ApiUrlConfigHelper ApiUrl = new ApiUrlConfigHelper(ConfigHelper.ApiBaseUrl);

            try
            {
                switch (type)
                {
                    case "CheckJRHY":
                        dr = new DataResult("进入视频连线");
                        string XM = context.Request["XM"];
                        string YQM = context.Request["YQM"];
                        string YZM = context.Request["YZM"];
                        if (!string.IsNullOrEmpty(YZM))
                        {
                            if (context.Session["myCheckCode"] != null)
                            {
                                if (YZM == context.Session["myCheckCode"].ToString().ToUpper())
                                {
                                    WebServiceHelper wsh = new WebServiceHelper();
                                    Dictionary<string, string> dicContent = new Dictionary<string, string>();
                                    dicContent.Add("YQM", context.Request.Form["YQM"]);
                                    dicContent.Add("XM", context.Request.Form["XM"]);
                                    dicContent.Add("LX", "1");
                                    dr = wsh.SendHttpPost(ApiUrl.CheckJRHY, dicContent);
                                    if (dr.Code == 0)
                                    {
                                        context.Session["VideoJsonStr"] = (string)dr.Data.JsonStr;
                                    }
                                }
                                else
                                {
                                    dr.SetMsgWarning("验证码不正确！");
                                }
                            }
                            else
                            {
                                dr.SetMsgWarning("验证码已过期！");
                            }
                        }
                        else
                        {
                            dr.SetMsgWarning("请输入验证码！");
                        }
                      
                        break;
                    case "Login":
                        dr = new DataResult("用户登录");
                        UserLogin(context,dr, ApiUrl);
                        break;
                    case "LoginOut":
                        context.Session["VideoJsonStr"] = null;
                        context.Session["LoginUser"] = null;
                        break;
                    default:

                        break;
                }
            }
            catch (Exception ex)
            {
                dr.SetMsgError(ex);
            }
            context.Response.Write(JsonHelper.SerializeJSON(dr));
        }

        private static void UserLogin(HttpContext context, DataResult dr, ApiUrlConfigHelper ApiUrl)
        {
            string LoginName = context.Request["LoginName"];
            string Password = context.Request["Password"];
            string CheckCode = context.Request["CheckCode"].ToUpper();
            if (!string.IsNullOrEmpty(CheckCode))
            {
                if (context.Session["myCheckCode"] != null)
                {
                    if (CheckCode == context.Session["myCheckCode"].ToString().ToUpper())
                    {
                        WebServiceHelper wsh = new WebServiceHelper();
                        Dictionary<string, string> dicContent = new Dictionary<string, string>();
                        dicContent.Add("LoginID", LoginName);
                        dicContent.Add("Pwd", Password);
                        dicContent.Add("LX", "1");
                        DataResult dr1 = wsh.SendHttpPost(ApiUrl.Login, dicContent);
                        if (dr1.Code == 0)
                        {
                            UsersModel user = new UsersModel();
                            user.LLZID = dr1.Data.LLZID;
                            user.QYBH = dr1.Data.QYBH;
                            user.QYMC = dr1.Data.QYMC;
                            user.UserID = dr1.Data.UserId;
                            user.UserName = dr1.Data.UserName;
                            user.UserType = dr1.Data.UserType;
                            user.Token = dr1.Data.Token;
                            dr.Data = user;
                            context.Session["LoginUser"] = user;

                        }
                        else
                        {
                            dr.SetMsgWarning("账号或密码错误！");
                        }
                    }
                    else
                    {
                        dr.SetMsgWarning("验证码不正确！");
                    }
                }
                else
                {
                    dr.SetMsgWarning("验证码已过期！");
                }
            }
            else
            {
                dr.SetMsgWarning("请输入验证码！");
            }
            context.Session["myCheckCode"] = "";
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