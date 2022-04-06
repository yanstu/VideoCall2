﻿
//消息协议
const VideoConferenceMess_Cache = "00"; //存缓存
const VideoConferenceMess_ZJR = "01"; //设置主讲人
const VideoConferenceMess_AllowREC = "02"; //允许录制
const VideoConferenceMess_CloseAllMic = "03"; //关闭除主讲人和主持人外所有的麦克风
const VideoConferenceMess_CloseUserMic = "04"; //关闭用户的麦克风，包括主讲人，但不控制主持人
const VideoConferenceMess_UpdateOwnCamera = "05"; //用户打开/关闭自己的摄像头
const VideoConferenceMess_UpdateOwnMic = "06"; //用户打开/关闭自己的麦克风
const VideoConferenceMess_CloseUser = "07"; //关闭用户，退出房间
const VideoConferenceMess_XXGB = "08"; //广播消息
const VideoConferenceMess_SendToUser = "09"; //向用户发送消息MESS
const VideoConferenceMess_Proposer = "10"; //申请发言
const VideoConferenceMess_GetCache = "11"; //取会议缓存
const VideoConferenceMess_SendCache = "12"; //广播会议缓存
const VideoConferenceMess_GetUserList = "13"; //获取用户列表
const VideoConferenceMess_SendUserList = "14"; //广播用户列表
const VideoConferenceMess_CloseProposer = "15"; //关闭发言申请
const VideoConferenceMess_UpdateCache = "16"; //修改会议缓存
const VideoConferenceMess_REC = "17"; //开始/结束录制
const VideoConferenceMess_AllowProposer = "18"; //允许发言
const VideoConferenceMess_SendProposerList = "19"; //获取发言申请列表
const VideoConferenceMess_ProposerListSpeak = "20"; //发言申请列表开始发言
const VideoConferenceMess_ProposerListClose = "21"; //发言申请列表关闭
const VideoConferenceMess_UpdateUserCamera = "22"; //打开/关闭用户的摄像头
const VideoConferenceMess_UpdateUserMic = "23"; //打开/关闭用户的麦克风
const VideoConferenceMess_RecState = "24"; //用户开始/结束录制
const VideoConferenceMess_Heartbeat = "25"; //心跳State 0会议1会务
const VideoConferenceMess_SendHeartbeat = "26"; //广播心跳
const VideoConferenceMess_GetHeartbeat = "27"; //获取心跳
const VideoConferenceMess_DelCache = "28"; //清理缓存
const VideoConferenceMess_CancelZJR = "29"; //取消主讲人
const VideoConferenceMess_AspectRatio = "30"; //发送长宽比
const VideoConferenceMess_ClearMess = "31"; //清空消息缓存
const VideoConferenceMess_Show_Model = "32";//展示端模式1.主讲人模式2.参会人模式3.小视频模式
const VideoConferenceMess_Show_XSPFormat = "33";//展示端小视频显示行列模式
const VideoConferenceMess_Show_Page = "34";//展示端翻页页码
const VideoConferenceMess_AttendMeeting_Model = "35";//参会端模式1.主讲人模式2.参会人模式3.小视频模式4.自由模式
const VideoConferenceMess_AttendMeeting_XSPFormat = "36";//参会端小视频显示行列模式（已弃用）
const VideoConferenceMess_AttendMeeting_Page = "37";//参会端翻页页码
const VideoConferenceMess_AllowOpenMic = "38";//是否允许打开麦克风1允许0不允许
