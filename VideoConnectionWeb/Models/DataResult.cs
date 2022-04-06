using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using VideoConnectionWeb.Helper;

namespace VideoConnectionWeb.Models
{
    [Serializable]
    public class DataResult
    {
        private int _Code = 0;
        private string _Msg = "";
        private dynamic _Data;
        private string _IP = "";
        private string _Name;

        public DataResult(string pName)
        {
            this._Name = pName;
            _Msg = this.Name + "成功";
        }

        public DataResult(string pName, HttpContext context)
        {
            this._Name = pName;
            _Msg = this.Name + "成功";
            IP = GetClientIP(context);//获取客户端IP地址：
        }

        /// <summary>
        /// 获取客户端IP地址
        /// </summary>
        /// <param name="context"></param>
        /// <returns></returns>
        private string GetClientIP(HttpContext context)
        {
            string result = context.Request.ServerVariables["HTTP_X_FORWARDED_FOR"];
            if (string.IsNullOrEmpty(result))
            {
                result = context.Request.ServerVariables["REMOTE_ADDR"];
            }
            return result;
        }

        /// <summary>
        /// 操作
        /// </summary>
        public string Name { get => _Name; }

        /// <summary>
        /// 状态码
        /// </summary>
        public int Code { get => _Code; set => _Code = value; }

        /// <summary>
        /// 消息提示
        /// </summary>
        public string Msg { get => _Msg; set => _Msg = value; }

        /// <summary>
        /// 数据对象
        /// </summary>
        public dynamic Data { get => _Data; set => _Data = value; }

        /// <summary>
        /// IP地址
        /// </summary>
        public string IP { get => _IP; set => _IP = value; }


        /// <summary>
        /// 设置消息  
        /// </summary>
        /// <param name="msg"></param>
        public void SetMsg(string msg)
        {
            _Msg = msg;
        }

        /// <summary>
        /// 设置警告消息  
        /// </summary>
        /// <param name="msg"></param>
        public void SetMsgWarning(string msg)
        {
            _Msg = msg;
            _Code = -1;
        }

        /// <summary>
        /// 设置警告消息  
        /// </summary>
        /// <param name="msg"></param>
        public void SetMsgWarning(string msg, int code)
        {
            _Msg = msg;
            _Code = code;
        }
       

        /// <summary>
        /// 设置错误消息 错误消息会自动加上 _Name+"出错！异常信息会输出在日志中
        /// </summary>
        /// <param name="e"></param>
        public void SetMsgError(Exception e)
        {
            _Msg = Name + "出错！";
            LogHelper.SaveErrLog(_Msg, e);
            _Code = -1;
        }
       

        /// <summary>
        /// 设置错误消息 错误消息会自动加上 _Name+"出错！
        /// </summary>
        /// <param name="str"></param>
        public void SetMsgError(string str)
        {
            _Msg = Name + "出错！" + str;
            _Code = -1;
        }

        /// <summary>
        /// 设置错误消息 错误消息会自动加上 _Name+"出错！
        /// </summary>
        /// <param name="str"></param>
        public void SetMsgError(string str, string logStr)
        {
            _Msg = Name + "出错！" + str;
            _Code = -1;
        }

        /// <summary>
        /// 设置登录过期错误
        /// </summary>
        public void SetErrorLoginGQ()
        {
            _Msg = "您的登录已过期，请重新登录！";
            _Code = -103;
        }
    }
}