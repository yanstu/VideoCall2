using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;

namespace VideoConnectionWeb.Helper
{
    public class ApiUrlConfigHelper
    {
        private string ApiBaseUrl = "";
        public ApiUrlConfigHelper(string _ApiBaseUrl)
        {
            ApiBaseUrl = _ApiBaseUrl;
        }
        
        //登录
        public string Login
        {
            get
            {
                return ApiBaseUrl + "Login/Login";
            }
        }

        //添加视频会议
        public string AddVideoConferenceApi
        {
            get
            {
                return ApiBaseUrl + "VideoConference/AddVideoConference";
            }
        }

        /// <summary>
        /// 分页查询视频会议
        /// </summary>
        public string VideoConferenceList
        {
            get
            {
                return ApiBaseUrl + "VideoConference/VideoConferenceList";
            }
        }

        /// <summary>
        /// 删除视频会议
        /// </summary>
        public string DeleteVideoConference
        {
            get
            {
                return ApiBaseUrl + "VideoConference/DeleteVideoConference";
            }
        }

        /// <summary>
        /// 根据ID查询视频会议
        /// </summary>
        public string FindVideoConferenceById
        {
            get
            {
                return ApiBaseUrl + "VideoConference/FindVideoConferenceById";
            }
        }
        /// <summary>
        /// 修改视频会议
        /// </summary>
        public string UpdateVideoConference
        {
            get
            {
                return ApiBaseUrl + "VideoConference/UpdateVideoConference";
            }
        }

        /// <summary>
        /// 查询可以参加的会议
        /// </summary>
        public string MyVideoConferenceList
        {
            get
            {
                return ApiBaseUrl + "VideoConference/MyVideoConferenceList";
            }
        }
        /// <summary>
        /// 分页查询代表库
        /// </summary>
        public string DBKListPage
        {
            get
            {
                return ApiBaseUrl + "DBK/DBKListPage";
            }
        }


        /// <summary>
        /// 代表库图片列表
        /// </summary>
        public string DBKImgList
        {
            get
            {
                return ApiBaseUrl + "DBK/DBImgList";
            }
        }

        /// <summary>
        /// 代表图片列表不分级显示
        /// </summary>
        public string DBImgListByGZRY3
        {
            get
            {
                return ApiBaseUrl + "DB/DBImgListByGZRY3";
            }
        }
        /// <summary>
        /// 查询所有区域
        /// </summary>
        public string QYList
        {
            get
            {
                return ApiBaseUrl + "LLZ/QYList";
            }
        }
        /// <summary>
        /// 查询所有区域
        /// </summary>
        public string CheckJRHY
        {
            get
            {
                return ApiBaseUrl + "VideoConference/CheckJRHY";
            }
        }

        /// <summary>
        /// 判断是否有进行中的会议
        /// </summary>
        public string HaveConference
        {
            get
            {
                return ApiBaseUrl + "VideoConference/HaveConference";
            }
        }
    }
}