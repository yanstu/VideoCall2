using Newtonsoft.Json;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Net;
using System.Net.Http;
using System.Net.Security;
using System.Security.Cryptography.X509Certificates;
using System.Web;
using VideoConnectionWeb.Models;

namespace VideoConnectionWeb.Helper
{
    public class WebServiceHelper
    {   
        
        /// <summary>
        /// 发送post请求
        /// </summary>
        /// <returns></returns>
        public DataResult SendHttpPost(string url, Dictionary<string, string> Dcontent)
        {
            DataResult resObj = new DataResult("访问接口");
            try
            {
                System.Net.ServicePointManager.SecurityProtocol = SecurityProtocolType.Tls12 | SecurityProtocolType.Tls11 | SecurityProtocolType.Tls;
                HttpClientHandler handler = new HttpClientHandler();
                handler.ClientCertificateOptions = ClientCertificateOption.Automatic;
               handler.ServerCertificateCustomValidationCallback = (message, cert, chain, error) => true;//忽略验证证书是否有风险
                                                                                                         // handler.ServerCertificateCustomValidationCallback = Callback;//忽略验证证书是否有风险
                handler.AllowAutoRedirect = true;
                handler.ClientCertificateOptions = ClientCertificateOption.Automatic;
                handler.SslProtocols = System.Security.Authentication.SslProtocols.Tls12;

                var httpClient = new HttpClient(handler);
                httpClient.Timeout = TimeSpan.FromMinutes(30);
                HttpContent content = new FormUrlEncodedContent(Dcontent);
                content.Headers.Add("Token", "abc123sfkj");
               
                //string ApiBaseUrl = ConfigHelper.ApiBaseUrl;
                //string ApiBaseUrl = "https://testvideoapi.gzshifang.com:9011/api/";
                HttpResponseMessage res = httpClient.PostAsync(url, content).Result;
                string responseJson = "";
                if (res.IsSuccessStatusCode)
                {
                    responseJson = res.Content.ReadAsStringAsync().Result;
                    dynamic temp = JsonConvert.DeserializeObject(responseJson);
                    resObj.Code = temp.Code;
                    resObj.Data = temp.Data;
                    //if (temp.Data != null)
                    //{
                    //    resObj.Data = JsonConvert.DeserializeObject(temp.Data.ToString());
                    //}
                    resObj.Msg = temp.Msg;
                }
                else
                {
                    LogHelper.SaveErrLog("调用接口出错【url:" + url + "】错误代码：" + res);
                    throw new Exception("调用接口出错");
                }
            }
            catch (Exception ex)
            {
                LogHelper.SaveErrLog("调用接口发生错误【" + ex.Message + "】", ex);
                throw new Exception("调用接口发生错误");
            }
          
            //if (resObj.Code != 0)
            //{
            //    LogHelper.SaveErrLog("调用接口异常：" + resObj.Msg + "【url:" + url + "】");
            //    throw new Exception("调用接口异常");
            //}
            return resObj;
        }

    }
}