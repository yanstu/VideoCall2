<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="ZCRControl.aspx.cs" Inherits="VideoConnectionWeb.menu.ConferenceControl.ZCRControl" %>

<!DOCTYPE html>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
    <title></title>
    <script src="../../js/jquery-3.6.0.min.js"></script>
    <script src="../../js/jquery.signalR-2.4.2.min.js"></script>
    <script src="/signalr/hubs"></script>
    <link href="/css/style2.css" rel="stylesheet" />
    <script src="/js/jquery-easyui-1.4/jquery.easyui.min.js"></script>
    <link href="/js/jquery-easyui-1.4/themes/icon.css" rel="stylesheet" />
    <link href="/js/jquery-easyui-1.4/themes/default/easyui.css" rel="stylesheet" />

    <%--zTree（树形）--%>
    <link href="/js/zTree/css/bootstrapStyle/bootstrapStyle.css" rel="stylesheet" />
    <script src="/js/zTree/js/jquery.ztree.core.js"></script>
    <script src="/js/zTree/js/jquery.ztree.excheck.js"></script>
    <script src="/js/zTree/js/jquery.ztree.exedit.js"></script>

    <script src="/js/My97DatePicker/WdatePicker.js"></script>
    <script src="/js/VideoConferenceMessHelper.js?id=10"></script>
    <script src="/js/layui/layCommon.js"></script>
      <script src="/js/layui/layCommon.js"></script>
    <script src="/js/layui/layui.js"></script>
    <link href="/js/layui/css/layui.css" rel="stylesheet" />
    <link href="/js/layui/css/xadmin.css" rel="stylesheet" />
    <style>
        .tablelist111 tr {
            background: #e7eaf2 !important;
        }

        tbody td {
            padding-left: 5px;
            padding-right: 5px;
        }

        .status-point {
            display: inline-block;
            width: 12px;
            height: 12px;
            border-radius: 50%;
            margin-left:5px;
            margin-right:5px;
        }
        .btnSave1 {
            background-color:steelblue !important;
        }
        a:hover{
            color:skyblue;
        }
        table {  
            /*width:250px;*/  
            table-layout:fixed;  
        }  
        td,#divTitle {  
            white-space:nowrap;  
            overflow:hidden;  
            text-overflow:ellipsis;
        }  
    </style>
    <script>
        var uModel = ""; //用户对象
        var pQYBH = getvl("QYBH");
        var UserCount = 0;//用户数量
        var PageCount = 10;//参会人模式每页条数
        var CHxspPageCount = 25;//参会端小视频模式每页条数
        var XSxspPageCount = 25;//展示端小视频模式每页条数
        var CHxspPageNum = 1;//参会端小视频模式当前页
        var XSxspPageNum = 1;//展示端小视频模式当前页
        if (pQYBH == "0103") {
            uModel = { QYBH: pQYBH, UserID: "", UserName: "六盘水政协" };
        } else {
            uModel = GetUserModel(); //用户对象
        }
        //$.extend($.messager.defaults, {
        //    ok: "确定",
        //    cancel: "取消"
        //});
        var DataId = getvl("DataId");
        var RoomId = getvl("RoomId");
        var UserID = "";
        var UserName = "";
        var setIntervalval = null;
      
        function GetCache() {
            Send(VideoConferenceMess_GetCache, '', '', '', '进入会议', '');
        }

        function GetByID() {
            var postData = {
                "ID": DataId,
            };
            ApiAjax(FindVideoConferenceByIdApi, function (res) {
                if (res.Code == 0) {
                    var userlist = new Array();
                    for (var i = 0; i < res.Data.VideoConferenceCHRY.length; i++) {
                        userlist[i] = {
                            ID: res.Data.VideoConferenceCHRY[i].ID,
                            UserID: res.Data.VideoConferenceCHRY[i].UserID,
                            UserName: res.Data.VideoConferenceCHRY[i].UserName,
                            UserQYBH: res.Data.VideoConferenceCHRY[i].UserQYBH,
                            UserQYMC: res.Data.VideoConferenceCHRY[i].UserQYMC,
                            IsZCR: res.Data.VideoConferenceCHRY[i].HYRole,
                            Type: res.Data.VideoConferenceCHRY[i].Type,
                            CameraState: 0,
                            MicState: 0,
                            RecState: 0
                        }
                    }
                    var data1 = {
                        reCode: VideoConferenceMess_Cache,
                        ReUserid: '',
                        ReUserQYBH: '',
                        ReUserName: '',
                        SendUserID: uModel == null ? "" : uModel.UserID,
                        SendUserName: uModel == null ? "" : uModel.UserName,
                        Content: "存缓存",
                        Data: {
                            Cache: {
                                Title: res.Data.VideoConference["Title"],
                                MessList: [],
                                ProposerList: [],
                                AllowREC: 0,
                                AllowProposer: 0,
                                SpeakerID: "",
                                SpeakerName: "",
                                UserList: userlist
                            }
                        }
                    }
                    $.ajax({
                        url: '/Handler//RedisHandler.ashx',
                        type: "post",
                        data: {
                            "Infotype": 'fb', "channel": RoomId, "mess": JSON.stringify(data1)
                        },
                        dataType: 'html',
                        async: false,
                        beforeSend: function () {
                            layLoading();
                        },
                        success: function (res) {
                            //var a = res;
                            //alert(res);
                            layLoadEnd();
                        },
                        error: function (res) {
                            var a = res;
                            layLoadEnd();
                        }
                    });
                } else {
                    alert(res.Msg);
                }
            }, postData, "get");
        }
        var SpeakerName = '';
        var SpeakerID = '';
        var AllowRECState = 0;
        var AllowProposerState = 0;
        var AllowOpenMic = 0;
        var RecState = 0;
        var VideoConferenceCHRY = new Array();
        var VideoConferenceMessage = new Array();
        var ProposerList = new Array();
        var OnLineList = new Array();
        var OnLineCameraState = new Array();
        var OnLineMicState = new Array();
        var YFYList = new Array();//预发言列表
        function LoadVideoConferenceMess(mess) {
            window.clearInterval(setIntervalval)
            var Data = JSON.parse(mess);
            if (Data.CHRY_ShowCols != 0 && Data.CHRY_ShowRows != 0) {
                PageCount = Data.CHRY_ShowCols * Data.CHRY_ShowRows;
            }
            UserCount = Data.UserList.length;
            if (UserCount > 25) {
                $('#opxsp').hide();
            }

            $('#xspage').html('1');
            XSxspPageNum = 1;
            $('#btnxssyy').attr("style", "background-color: #aaa !important");
            XSxspPageCount = PageCount;
            var XSxspCount = Math.ceil(UserCount / XSxspPageCount);
            if (XSxspCount == 1) {
                $('#btnxsxyy').attr("style", "background-color: #aaa !important");
            }
            else {
                $('#btnxsxyy').attr("style", "");
            }
            $('#xspageCount').html(XSxspCount);
            $('#chpage').html('1');
            CHxspPageNum = 1;
            $('#btnchsyy').attr("style", "background-color: #aaa !important");
            CHxspPageCount = PageCount;
            var CHxspCount = Math.ceil(UserCount / CHxspPageCount);
            if (CHxspCount == 1) {
                $('#btnchxyy').attr("style", "background-color: #aaa !important");
            }
            else {
                $('#btnchxyy').attr("style", "");
            }
            $('#chpageCount').html(CHxspCount);

            YFYList = new Array();
            for (var i = 0; i < Data.UserList.length; i++) {
                if (Data.UserList[i].IsFY == 1) {
                    YFYList.push(Data.UserList[i]);
                }
            }
            YFYList = sortByKey(YFYList, 'XUHAO', 'asc');
            YFYList = sortByKey(YFYList, 'FYSX', 'asc');
            VideoConferenceCHRY = Data.UserList;
            VideoConferenceMessage = Data.MessList;
            ProposerList = Data.ProposerList;
            SpeakerID = Data.SpeakerID;
            SpeakerName = Data.SpeakerName;
            AllowRECState = Data.AllowREC;
            if (AllowRECState == 1) {
                $('#ckbREC')[0].checked = true;
            }
            else {
                $('#ckbREC')[0].checked = false;
            }
            AllowProposerState = Data.AllowProposer;
            if (AllowProposerState == 1) {
                $('#ckbProposer')[0].checked = true;
            }
            else {
                $('#ckbProposer')[0].checked = false;
            }
            AllowOpenMic = Data.AllowOpenMic;
            if (AllowOpenMic == 1) {
                $('#ckbAllowOpenMic')[0].checked = true;
            }
            else {
                $('#ckbAllowOpenMic')[0].checked = false;
            }
            $("#divTitle").html("标题：" + Data.Title);
            $("#divTitle").attr("title", Data.Title);
            $("#divZJY").html("主讲人：" + Data.SpeakerName);
            ShowCHRYList();
            ShowMessList();
            ShowProposerList();
            ShowYFYList();
            LoadModel(Data.XSDModel, Data.CHDModel)
        }
        var oldVideoConferenceCHRY = new Array();
        function Search() {
            oldVideoConferenceCHRY = new Array();
            ShowCHRYList();
        }
        function ShowCHRYList() {//摄像头。麦克风。录制状态。退出房间
            VideoConferenceCHRY = sortByKey(VideoConferenceCHRY, 'XUHAO', 'asc');
            var isNew = false;
            if (oldVideoConferenceCHRY != null && oldVideoConferenceCHRY.length != 0 && oldVideoConferenceCHRY.length == VideoConferenceCHRY.length) {
                for (var j = 0; j < VideoConferenceCHRY.length; j++) {
                    if (VideoConferenceCHRY[j].UserQYBH == uModel.QYBH) {
                        RecState = VideoConferenceCHRY[j].RECState;
                    }
                    var ishave = false;
                    for (var i = 0; i < oldVideoConferenceCHRY.length; i++) {
                        if (oldVideoConferenceCHRY[i].ID == VideoConferenceCHRY[j].ID && oldVideoConferenceCHRY[i].UserName == VideoConferenceCHRY[j].UserName && oldVideoConferenceCHRY[i].XUHAO == VideoConferenceCHRY[j].XUHAO) {
                            ishave = true;
                            continue;
                        }
                    }
                    if (!ishave) {
                        isNew = true;
                        break;
                    }
                }
                if (!isNew)
                    for (var i = 0; i < oldVideoConferenceCHRY.length; i++) {
                        var ishave = false;
                        for (var j = 0; j < VideoConferenceCHRY.length; j++) {
                            if (oldVideoConferenceCHRY[i].ID == VideoConferenceCHRY[j].ID && oldVideoConferenceCHRY[i].UserName == VideoConferenceCHRY[j].UserName) {
                                ishave = true;
                                continue;
                            }
                        }
                        if (!ishave) {
                            isNew = true;
                            break;
                        }
                    }
            } else { isNew = true; }
            if (!isNew) {
                if (RecState == 1) {
                    $('#aREC').html("结束录制");
                }
                else {
                    $('#aREC').html("开始录制");
                }
                for (var i = 0; i < VideoConferenceCHRY.length; i++) {
                    if (VideoConferenceCHRY[i].ID == '126ab7e5bca74e3b9d148578198b25ac') {
                        var a = VideoConferenceCHRY[i].ID;
                    }
                    if (OnLineCameraState[VideoConferenceCHRY[i].ID] == 1) {//优先心跳
                        $('#aCamera' + VideoConferenceCHRY[i].ID).attr("style", "");
                    }
                    //else if (OnLineCameraState[VideoConferenceCHRY[i].ID] == 0) {
                    //    $('#aCamera' + VideoConferenceCHRY[i].ID).attr("style", "color:#888");
                    //}
                    //else if (VideoConferenceCHRY[i].CameraState == 1) {//其次用户列表
                    //    $('#aCamera' + VideoConferenceCHRY[i].ID).attr("style", "");
                    //}
                    else {
                        $('#aCamera' + VideoConferenceCHRY[i].ID).attr("style", "color:#888");
                    }
                    if (OnLineMicState[VideoConferenceCHRY[i].ID] == 1) {
                        $("#aMic" + VideoConferenceCHRY[i].ID).attr("style", "");
                    }
                    //else if (OnLineMicState[VideoConferenceCHRY[i].ID] == 0) {
                    //    $("#aMic" + VideoConferenceCHRY[i].ID).attr("style", "color:#888");
                    //}
                    //else if (VideoConferenceCHRY[i].MicState == 1) {
                    //    $("#aMic" + VideoConferenceCHRY[i].ID).attr("style", "");
                    //}
                    else {
                        $("#aMic" + VideoConferenceCHRY[i].ID).attr("style", "color:#888");
                    }
                }
                return;
            }
            oldVideoConferenceCHRY = VideoConferenceCHRY;
            var SearchName = $('#txtName').val();
            var isOnLine = $('#ckbOnLine')[0].checked;
            var isCameraOpen = $('#ckbCameraOpen')[0].checked;
            var isMicOpen = $('#ckbMicOpen')[0].checked;
            var tbContent1 = "";
            $("#spanrs").html(VideoConferenceCHRY.length);
            for (var i = 0; i < VideoConferenceCHRY.length; i++) {
                if (VideoConferenceCHRY[i].UserQYBH == uModel.QYBH && VideoConferenceCHRY[i].IsZCR == 1) {
                    RecState = VideoConferenceCHRY[i].RECState;
                    UserID = VideoConferenceCHRY[i].ID;
                    UserName = VideoConferenceCHRY[i].UserName;
                    if (RecState == 1) {
                        $('#aREC').html("结束录制");
                    }
                    else {
                        $('#aREC').html("开始录制");
                    }
                }
                if (SearchName != '') {
                    if (VideoConferenceCHRY[i].UserName.indexOf(SearchName) == -1) {
                        continue;
                    }
                }
                if ((isOnLine && (OnLineList[VideoConferenceCHRY[i].ID] != 1 || OnLineList[VideoConferenceCHRY[i].ID] == null))
                    || (isCameraOpen && (OnLineCameraState[VideoConferenceCHRY[i].ID] != 1 || OnLineCameraState[VideoConferenceCHRY[i].ID] == null) && (OnLineList[VideoConferenceCHRY[i].ID] != 1 || OnLineList[VideoConferenceCHRY[i].ID] == null))
                    || (isMicOpen && (OnLineMicState[VideoConferenceCHRY[i].ID] != 1 || OnLineMicState[VideoConferenceCHRY[i].ID] == null) && (OnLineList[VideoConferenceCHRY[i].ID] != 1 || OnLineList[VideoConferenceCHRY[i].ID] == null))) {
                    tbContent1 += '<tr id="tr' + VideoConferenceCHRY[i].ID + '" style="display:none;">';
                }
                else {
                    tbContent1 += '<tr id="tr' + VideoConferenceCHRY[i].ID + '">';
                }
                tbContent1 += "<td style='text-align: center;'>" + (i + 1) + "</td>";
                if (OnLineList[VideoConferenceCHRY[i].ID] == 1) {
                    tbContent1 += '<td title="' + VideoConferenceCHRY[i].UserName + '"><div id="div' + VideoConferenceCHRY[i].ID + '" class="status-point" style=" background-color:#67C23A" />' + VideoConferenceCHRY[i].UserName + '</td>';
                }
                else {
                    tbContent1 += '<td title="' + VideoConferenceCHRY[i].UserName + '"><div id="div' + VideoConferenceCHRY[i].ID + '" class="status-point" style=" background-color:#00000040" />' + VideoConferenceCHRY[i].UserName + '</td>';
                }
                tbContent1 += '<td>';
                if (OnLineList[VideoConferenceCHRY[i].ID] == 1 && (VideoConferenceCHRY[i].CameraState == 1 || OnLineCameraState[VideoConferenceCHRY[i].ID] == 1)) {
                    tbContent1 += '&nbsp;&nbsp;<a href="javascript:void(0);" class="tablelink yhlx" id="aCamera' + VideoConferenceCHRY[i].ID + '" onclick=UpdateCameraState("' + VideoConferenceCHRY[i].ID + '","' + VideoConferenceCHRY[i].UserQYBH + '","' + VideoConferenceCHRY[i].UserName + '",0)>摄像头</a>&nbsp;&nbsp;';
                }
                else {
                    tbContent1 += '&nbsp;&nbsp;<a href="javascript:void(0);" id="aCamera' + VideoConferenceCHRY[i].ID + '" style="color:#888" class="tablelink yhlx" onclick=UpdateCameraState("' + VideoConferenceCHRY[i].ID + '","' + VideoConferenceCHRY[i].UserQYBH + '","' + VideoConferenceCHRY[i].UserName + '",1)>摄像头</a>&nbsp;&nbsp;';
                }
                if (OnLineList[VideoConferenceCHRY[i].ID] == 1 && (VideoConferenceCHRY[i].MicState == 1 || OnLineMicState[VideoConferenceCHRY[i].ID] == 1)) {
                    tbContent1 += '<a href="javascript:void(0);" class="tablelink yhlx" id="aMic' + VideoConferenceCHRY[i].ID + '"';
                }
                else {
                    tbContent1 += '<a href="javascript:void(0);" class="tablelink yhlx" id="aMic' + VideoConferenceCHRY[i].ID + '" style="color:#888" ';
                }
                tbContent1 += ' onclick=UpdateMicState("' + VideoConferenceCHRY[i].ID + '","' + VideoConferenceCHRY[i].UserQYBH + '","' + VideoConferenceCHRY[i].UserName + '",1)>麦克风</a>&nbsp;&nbsp;';
                if (VideoConferenceCHRY[i].IsZCR == 1) {
                    //tbContent1 += '>麦克风</a>&nbsp;&nbsp;';
                    tbContent1 += '<a href="javascript:void(0);" class="tablelink">　　　　</a>&nbsp;&nbsp;<a href="javascript:void(0);" class="tablelink">　　</a>&nbsp;&nbsp;';
                } else {
                    tbContent1 += '<a href="javascript:void(0);" class="tablelink" onclick=SendMessToUser("' + VideoConferenceCHRY[i].ID + '","' + VideoConferenceCHRY[i].UserQYBH + '","' + VideoConferenceCHRY[i].UserName + '")>发送消息</a>&nbsp;&nbsp;';
                    tbContent1 += '<a href="javascript:void(0);" class="tablelink" onclick=CloseUser("' + VideoConferenceCHRY[i].ID + '","' + VideoConferenceCHRY[i].UserQYBH + '","' + VideoConferenceCHRY[i].UserName + '")>关闭</a>&nbsp;&nbsp;';
                }
                tbContent1 += '<a href="javascript:void(0);" class="tablelink" onclick=SetZJR("' + i + '")>设置主讲人</a>';
                tbContent1 += '</td>';
            }

            $("#tb1").html(tbContent1);
        }
        function ShowMessList() {
            var tbContent1 = "";
            for (var i = VideoConferenceMessage.length - 1; i >= 0; i--) {
                tbContent1 += '<tr>';
                tbContent1 += "<td>" + GetTime(VideoConferenceMessage[i].SendDatetime) + "</td>";
                tbContent1 += '<td>' + VideoConferenceMessage[i].SendUserName + '</td>';
                tbContent1 += '<td>' + VideoConferenceMessage[i].ReUserName + '</td>';
                tbContent1 += '<td title="' + VideoConferenceMessage[i].Content + '">' + VideoConferenceMessage[i].Content + '</td>';
            }
            $("#tb3").html(tbContent1);
        }
        function ShowProposerList() {
            var tbContent1 = "";
            for (var i = ProposerList.length - 1; i >= 0; i--) {
                tbContent1 += '<tr>';
                tbContent1 += '<td>' + GetTime(ProposerList[i].ApplyDatetime) + "</td>";
                tbContent1 += '<td title="' + ProposerList[i].ProposerName + '">' + ProposerList[i].ProposerName + '</td>';
                tbContent1 += '<td>';
                tbContent1 += '<a href="javascript:void(0);" class="tablelink" onclick=Speak("' + i + '")>发言</a>';
                tbContent1 += '&nbsp;&nbsp;<a href="javascript:void(0);" class="tablelink" onclick=CloseProposer("' + i + '")>关闭</a>';
                tbContent1 += '</td>';
            }
            $("#tb2").html(tbContent1);
        }
        function Speak(index) {
            //$.messager.confirm
            //    ('确认', "确认开始发言吗？",
            //        function (r) {
            //            if (r) {
            if (OnLineList[ProposerList[index].ProposerID] != 1) { alert('用户不在线'); return; }
            Send(VideoConferenceMess_ProposerListSpeak, ProposerList[index].ProposerID, '', ProposerList[index].ProposerName, '【' + ProposerList[index].ProposerName + '】开始发言', '');
            SpeakerID = ProposerList[index].ProposerID;
            SpeakerName = ProposerList[index].ProposerName;
            //        }
            //    }
            //);
        }
        function ShowYFYList() {
            var tbContent1 = "";
            for (var i = 0; i < YFYList.length; i++) {
                tbContent1 += '<tr>';
                tbContent1 += '<td style="text-align:center">' + YFYList[i].FYSX + "</td>";
                tbContent1 += '<td title="' + YFYList[i].UserName + '">' + YFYList[i].UserName + '</td>';
                tbContent1 += '<td style="text-align:center">';
                tbContent1 += '<a href="javascript:void(0);" class="tablelink" onclick=YFYSpeak("' + i + '")>发言</a>';
                tbContent1 += '</td>';
            }
            $("#tb4").html(tbContent1);
        }
        function YFYSpeak(index) {
            //$.messager.confirm
            //    ('确认', "确认开始发言吗？",
            //        function (r) {
            //            if (r) {
            if (OnLineList[YFYList[index].ID] != 1) { alert('用户不在线'); return; }
            Send(VideoConferenceMess_ProposerListSpeak, YFYList[index].ID, '', YFYList[index].UserName, '【' + YFYList[index].UserName + '】开始发言', '');
            SpeakerID = YFYList[index].ID;
            SpeakerName = YFYList[index].UserName;
            //        }
            //    }
            //);
        }
        function CloseProposer(index) {
            $.messager.confirm
                ('确认', "确认关闭发言吗？",
                    function (r) {
                        if (r) {
                            Send(VideoConferenceMess_ProposerListClose, ProposerList[index].ProposerID, '', ProposerList[index].ProposerName, '关闭【' + ProposerList[index].ProposerName + '】发言', '');
                        }
                    }
                );
        }
        function SetZJR(index) {
            var Userid = VideoConferenceCHRY[index].ID;
            var UserQYBH = VideoConferenceCHRY[index].UserQYBH;
            var UserName1 = VideoConferenceCHRY[index].UserName;
            //if (OnLineList[Userid] != 1) { alert('用户不在线'); return; }
            var data1 = {
                reCode: VideoConferenceMess_ZJR,
                ReUserid: Userid,
                ReUserQYBH: UserQYBH,
                ReUserName: UserName1,
                SendUserID: UserID,
                SendUserName: UserName,
                Content: "设置" + UserName1 + "为主讲人",
                Data: {}
            }
            $.ajax({
                url: '/Handler//RedisHandler.ashx',
                type: "post",
                data: {
                    "Infotype": 'fb', "channel": RoomId, "mess": JSON.stringify(data1)
                },
                dataType: 'html',
                beforeSend: function () {
                    layLoading();
                },
                success: function (res) {
                    //var a = res;
                    if (res == "发布成功") {
                        //alert("设置主讲人消息发布成功");
                        $("#divZJY").html("主讲人：" + UserName1);
                    }
                    else {
                        alert(res);
                    }
                    layLoadEnd();
                },
                error: function (res) {
                    var a = res;
                    layLoadEnd();
                }
            });
        }
        function Send(reCode, ReUserid, ReUserQYBH, ReUserName, Content, State) {
            if (Content == "") {
                alert("请输入发送内容");
                return;
            }
            var data1 = {
                reCode: reCode,
                ReUserid: ReUserid,
                ReUserQYBH: ReUserQYBH,
                ReUserName: ReUserName,
                SendUserID: UserID == "" ? "1" : UserID,
                SendUserName: UserName,
                Content: Content,
                Data: { State: State }
            }
            $.ajax({
                url: '/Handler//RedisHandler.ashx',
                type: "post",
                data: {
                    "Infotype": 'fb', "channel": RoomId, "mess": JSON.stringify(data1)
                },
                dataType: 'html',
                beforeSend: function () {
                    //layLoading();
                },
                success: function (res) {
                    if (res == "发布成功") {
                        if (reCode == VideoConferenceMess_SendToUser) {
                            alert('发送成功');
                            $('#txtMess').val('')
                            $('#dd_SendMess').window('close');
                        }
                        if (reCode == VideoConferenceMess_XXGB) {
                            $('#txtsendmess').val('');
                        }
                    }
                    //var a = res;
                    //alert(res);
                    //layLoadEnd();
                },
                error: function (res) {
                    var a = res;
                    //layLoadEnd();
                }
            });
        }
        function CloseUser(ReUserid, ReUserQYBH, ReUserName) {
            if (OnLineList[ReUserid] != 1) { alert('用户不在线'); return; }
            $.messager.confirm
                ('确认', "确认要关闭用户吗？",
                    function (r) {
                        if (r) {
                            Send(VideoConferenceMess_CloseUser, ReUserid, ReUserQYBH, ReUserName, '关闭用户【' + ReUserName + '】', '');
                        }
                    }
                );
        }
        function UpdateCameraState(ReUserid, ReUserQYBH, ReUserName, State) {
            if (OnLineList[ReUserid] != 1) { alert('用户不在线'); return; }
            var Content = "打开用户【" + ReUserName + "】的摄像头";
            State = 1;
            if (OnLineCameraState[ReUserid] == 1) {
                Content = "关闭用户【" + ReUserName + "】的摄像头";
                State = 0;
            }
            Send(VideoConferenceMess_UpdateUserCamera, ReUserid, ReUserQYBH, ReUserName, Content, State);
        }
        function UpdateMicState(ReUserid, ReUserQYBH, ReUserName, State) {
            if (OnLineList[ReUserid] != 1) { alert('用户不在线'); return; }
            var Content = "打开用户【" + ReUserName + "】的麦克风";
            State = 1;
            if (OnLineMicState[ReUserid] == 1) {
                Content = "关闭用户【" + ReUserName + "】的麦克风";
                State = 0;
            }
            //$.messager.confirm
            //    ('确认', "确认" + Content + "吗？",
            //        function (r) {
            //            if (r) {
            Send(VideoConferenceMess_UpdateUserMic, ReUserid, ReUserQYBH, ReUserName, Content, State);
            //    }
            //});
        }
        function CloseAllMic() {
            //$.messager.confirm
            //    ('确认', "确认关闭所有人的麦克风吗？",
            //        function (r) {
            //            if (r) {
            Send(VideoConferenceMess_CloseAllMic, '', '', '', "关闭所有人的麦克风", '');
            //        }
            //    }
            //);
        }
        function REC() {
            var state = RecState == 1 ? 0 : 1;
            $.messager.confirm
                ('确认', "确认开始录制吗？",
                    function (r) {
                        if (r) {
                            Send(VideoConferenceMess_REC, UserID, '', UserName, '录制', state);
                        }
                    }
                );
        }
        function CancelZJR() {
            $.messager.confirm
                ('确认', "确认取消主讲人吗？",
                    function (r) {
                        if (r) {
                            Send(VideoConferenceMess_CancelZJR, '', '', '', '取消主讲人', '');
                        }
                    }
                );
        }
        function ClearMess() {
            $.messager.confirm
                ('确认', "确认清空消息缓存吗？",
                    function (r) {
                        if (r) {
                            Send(VideoConferenceMess_ClearMess, '', '', '', '清空消息缓存', '');
                            $("#tb3").html('');
                        }
                    }
                );
        }
        function UpdateAllowRECState() {
            var state = 0;
            var msg = "";
            if (AllowRECState == 0) {
                state = 1;
                msg = "允许录制";
            }
            else {
                state = 0;
                msg = "不允许录制";
            }
            $.messager.confirm
                ('确认', "确认" + msg + "吗？",
                    function (r) {
                        if (r) {
                            Send(VideoConferenceMess_AllowREC, '', '', '', msg, state);
                            AllowRECState = state;
                        }
                        if (AllowRECState == 1) {
                            $('#ckbREC')[0].checked = true;
                        }
                        else {
                            $('#ckbREC')[0].checked = false;
                        }
                    }
                );
        }
        function UpdateAllowProposerState() {
            var state = 0;
            var msg = "";
            if (AllowProposerState == 0) {
                state = 1;
                msg = "允许发言";
            }
            else {
                state = 0;
                msg = "不允许发言";
            }
            $.messager.confirm
                ('确认', "确认" + msg + "吗？",
                    function (r) {
                        if (r) {
                            Send(VideoConferenceMess_AllowProposer, '', '', '', msg, state);
                            AllowProposerState = state;
                        }
                        if (AllowProposerState == 1) {
                            $('#ckbProposer')[0].checked = true;
                        }
                        else {
                            $('#ckbProposer')[0].checked = false;
                        }
                    }
                );
        }
        function UpdateAllowOpenMic() {
            var state = 0;
            var msg = "";
            if (AllowOpenMic == 0) {
                state = 1;
                msg = "允许打开麦克风";
            }
            else {
                state = 0;
                msg = "禁止打开麦克风";
            }
            $.messager.confirm
                ('确认', "确认" + msg + "吗？",
                    function (r) {
                        if (r) {
                            Send(VideoConferenceMess_AllowOpenMic, '', '', '', msg, state);
                            AllowOpenMic = state;
                        }
                        if (AllowOpenMic == 1) {
                            $('#ckbAllowOpenMic')[0].checked = true;
                        }
                        else {
                            $('#ckbAllowOpenMic')[0].checked = false;
                        }
                    }
                );
        }
        function SendMessToUser(ReUserid, ReUserQYBH, ReUserName) {
            if (OnLineList[ReUserid] != 1) { alert('用户不在线'); return; }
            $('#txtReUserid').val(ReUserid);
            $('#txtReUserQYBH').val(ReUserQYBH);
            $('#txtReUserName').val(ReUserName);
            $('#spanUserName').html(ReUserName);
            $('#dd_SendMess').window('open');
        }

        function SendMessToUser1() {
            if ($('#txtMess').val() == "") {
                alert("请输入发送内容");
                return;
            }
            Send(VideoConferenceMess_SendToUser, $('#txtReUserid').val(), $('#txtReUserQYBH').val(), $('#txtReUserName').val(), $('#txtMess').val(), '');
        }

    </script>
    <!--参会端和展示端控制-->
    <script>
        var chdsj = 10;//参会端操作等待时长（秒）
        var xsdsj = 10;//显示端操作等待时长（秒）
        var chInterval;
        var xsInterval;
        function ShowModel(ty) {
            var recode = '';
            var state = 0;
            var content = "";
            switch (ty) {
                case "ch1":
                    recode = VideoConferenceMess_AttendMeeting_Model;
                    state = 1;
                    content = "参会端切换主讲人模式";
                    //$('.btnch').attr("style", "");
                    //$('#btnch1').attr("style", "background-color: green;");
                    $('#selch').val('ch1');
                    $('#divch1,#divch2').hide();
                    break;
                case "ch2":
                    recode = VideoConferenceMess_AttendMeeting_Model;
                    state = 2;
                    content = "参会端切换参会人模式";
                    //$('.btnch').attr("style", "");
                    //$('#btnch2').attr("style", "background-color: green;");
                    $('#selch').val('ch2');
                    $('#chpage').html('1');
                    CHxspPageNum = 1;
                    $('#btnchsyy').attr("style", "background-color: #aaa !important");
                    CHxspPageCount = PageCount;
                    var CHxspCount = Math.ceil(UserCount / CHxspPageCount);
                    if (CHxspCount == 1) {
                        $('#btnchxyy').attr("style", "background-color: #aaa !important");
                    }
                    else {
                        $('#btnchxyy').attr("style", "");
                    }
                    $('#chpageCount').html(CHxspCount);
                    $('#divch1').hide();
                    $('#divch2').show();
                    break;
                case "ch3":
                    recode = VideoConferenceMess_AttendMeeting_Model;
                    state = 3;
                    content = "参会端切换小视频模式";
                    //$('.btnch').attr("style", "");
                    //$('#btnch3').attr("style", "background-color: green;");
                    $('#selch').val('ch3');
                    $('#rdoch5')[0].checked = "checked";
                    $('#chpage').html('1');
                    CHxspPageNum = 1;
                    CHxspPageCount = 25;
                    $('#btnchsyy').attr("style", "background-color: #aaa !important");
                    var CHxspCount = Math.ceil(UserCount / CHxspPageCount);
                    if (CHxspCount == 1) {
                        $('#btnchxyy').attr("style", "background-color: #aaa !important");
                    }
                    else {
                        $('#btnchxyy').attr("style", "");
                    }
                    $('#chpageCount').html(CHxspCount);
                    $('#divch1,#divch2').hide();
                    break;
                case "ch4":
                    recode = VideoConferenceMess_AttendMeeting_Model;
                    state = 4;
                    content = "参会端切换自由模式";
                    //$('.btnch').attr("style", "");
                    //$('#btnch2').attr("style", "background-color: green;");
                    $('#selch').val('ch4');
                    $('#chpage').html('1');
                    CHxspPageNum = 1;
                    $('#btnchsyy').attr("style", "background-color: #aaa !important");
                    CHxspPageCount = PageCount;
                    var CHxspCount = Math.ceil(UserCount / CHxspPageCount);
                    if (CHxspCount == 1) {
                        $('#btnchxyy').attr("style", "background-color: #aaa !important");
                    }
                    else {
                        $('#btnchxyy').attr("style", "");
                    }
                    $('#chpageCount').html(CHxspCount);
                    $('#divch1,#divch2').hide();
                    break;
                case "xs1":
                    recode = VideoConferenceMess_Show_Model;
                    state = 1;
                    content = "展示端切换主讲人模式";
                    //$('.btnxs').attr("style", "");
                    //$('#btnxs1').attr("style", "background-color: green;");
                    $('#selxs').val('xs1');
                    $('#divxs1,#divxs2').hide();
                    break;
                case "xs2":
                    recode = VideoConferenceMess_Show_Model;
                    state = 2;
                    content = "展示端切换参会人模式";
                    //$('.btnxs').attr("style", "");
                    //$('#btnxs2').attr("style", "background-color: green;");
                    $('#selxs').val('xs2');
                    $('#xspage').html('1');
                    XSxspPageNum = 1;
                    XSxspPageCount = PageCount;
                    $('#btnxssyy').attr("style", "background-color: #aaa !important");
                    var XSxspCount = Math.ceil(UserCount / XSxspPageCount);
                    if (XSxspCount == 1) {
                        $('#btnxsxyy').attr("style", "background-color: #aaa !important");
                    }
                    else {
                        $('#btnxsxyy').attr("style", "");
                    }
                    $('#xspageCount').html(XSxspCount);
                    $('#divxs1').hide();
                    $('#divxs2').show();
                    break;
                case "xs3":
                    recode = VideoConferenceMess_Show_Model;
                    state = 3;
                    content = "展示端切换小视频模式";
                    //$('.btnxs').attr("style", "");
                    //$('#btnxs3').attr("style", "background-color: green;");
                    $('#selxs').val('xs3');
                    $('#rdoxs5')[0].checked = "checked";
                    $('#xspage').html('1');
                    XSxspPageNum = 1;
                    XSxspPageCount = 25;
                    $('#btnxssyy').attr("style", "background-color: #aaa !important");
                    var XSxspCount = Math.ceil(UserCount / XSxspPageCount);
                    if (XSxspCount == 1) {
                        $('#btnxsxyy').attr("style", "background-color: #aaa !important");
                    }
                    else {
                        $('#btnxsxyy').attr("style", "");
                    }
                    $('#xspageCount').html(XSxspCount);
                    $('#divxs1,#divxs2').show();
                    break;
            }
            if (recode != "") {
                Send(recode, '', '', '', content, state);
            }
        }
        function ShowXSPModel(ty, ty1) {
            var recode = '';
            var state = ty;
            var content = "切换小视频显示模式为：" + ty;
            switch (ty1) {
                case "1":
                    recode = VideoConferenceMess_AttendMeeting_XSPFormat;
                    content = "切换参会端小视频显示模式为：" + ty;
                    switch (ty) {
                        case "3*3":
                            CHxspPageCount = 9;
                            break;
                        case "4*4":
                            CHxspPageCount = 16;
                            break;
                        case "5*5":
                            CHxspPageCount = 25;
                            break;
                    }
                    $('#chpage').html('1');
                    CHxspPageNum = 1;
                    $('#btnchsyy').attr("style", "background-color: #aaa !important");
                    var CHxspCount = Math.ceil(UserCount / CHxspPageCount);
                    if (CHxspCount == 1) {
                        $('#btnchxyy').attr("style", "background-color: #aaa !important");
                    }
                    else {
                        $('#btnchxyy').attr("style", "");
                    }
                    $('#chpageCount').html(CHxspCount);
                    break;
                case "2":
                    recode = VideoConferenceMess_Show_XSPFormat;
                    content = "切换展示端小视频显示模式为：" + ty;
                    switch (ty) {
                        case "3*3":
                            XSxspPageCount = 9;
                            break;
                        case "4*4":
                            XSxspPageCount = 16;
                            break;
                        case "5*5":
                            XSxspPageCount = 25;
                            break;
                    }
                    $('#xspage').html('1');
                    XSxspPageNum = 1;
                    $('#btnxssyy').attr("style", "background-color: #aaa !important");
                    var XSxspCount = Math.ceil(UserCount / XSxspPageCount);
                    if (XSxspCount == 1) {
                        $('#btnxsxyy').attr("style", "background-color: #aaa !important");
                    }
                    else {
                        $('#btnxsxyy').attr("style", "");
                    }
                    $('#xspageCount').html(XSxspCount);
                    break;
            }
            if (recode != "") {
                Send(recode, '', '', '', content, state);
            }
        }
        //参会端倒计时
        function chdDJS() {
            $('#btnchsyy').attr("style", "background-color: #aaa !important").html('上一页(' + (chdsj) + ')').attr('onclick', '');
            $('#btnchxyy').attr("style", "background-color: #aaa !important").html('下一页(' + (chdsj) + ')').attr('onclick', '');
            if (chdsj == 0) {
                $('#btnchsyy').attr("style", "").html('上一页').attr('onclick', 'chPageUp()');
                $('#btnchxyy').attr("style", "").html('下一页').attr('onclick', 'chPageDown()');
                clearInterval(chInterval);
                if (CHxspPageNum == 1) {
                    $('#btnchsyy').attr("style", "background-color: #aaa !important");
                }
                var CHxspCount = Math.ceil(UserCount / CHxspPageCount);
                if (CHxspPageNum == CHxspCount) {
                    $('#btnchxyy').attr("style", "background-color: #aaa !important");
                }
            }
            chdsj--;
        }
        //显示端倒计时
        function xsdDJS() {
            $('#btnxssyy').attr("style", "background-color: #aaa !important").html('上一页(' + (xsdsj) + ')').attr('onclick', '');
            $('#btnxsxyy').attr("style", "background-color: #aaa !important").html('下一页(' + (xsdsj) + ')').attr('onclick', '');
            if (xsdsj == 0) {
                $('#btnxssyy').attr("style", "").html('上一页').attr('onclick', 'xsPageUp()');
                $('#btnxsxyy').attr("style", "").html('下一页').attr('onclick', 'xsPageDown()');
                clearInterval(xsInterval);
                if (XSxspPageNum == 1) {
                    $('#btnxssyy').attr("style", "background-color: #aaa !important");
                }
                var XSxspCount = Math.ceil(UserCount / XSxspPageCount);
                if (XSxspPageNum == XSxspCount) {
                    $('#btnxsxyy').attr("style", "background-color: #aaa !important");
                }
            }
            xsdsj--;
        }
        function chPageUp() {
            if (CHxspPageNum > 1) {
                $('#btnchsyy').attr("style", "background-color: #aaa !important").attr('onclick', '');
                $('#btnchxyy').attr("style", "background-color: #aaa !important").attr('onclick', '');
                chdsj = 10;
                chInterval = setInterval(chdDJS, 1000);
                CHxspPageNum--;
                $('#chpage').html(CHxspPageNum);
                if (CHxspPageNum == 1) {
                    $('#btnchsyy').attr("style", "background-color: #aaa !important");
                }
                Send(VideoConferenceMess_AttendMeeting_Page, '', '', '', "参会端上一页", CHxspPageNum);
                $('#btnchxyy').attr("style", "");

            }
            else {
                alert("已经是第一页了");
                $('#chpage').html('1');
                $('#btnchsyy').attr("style", "background-color: #aaa !important");
            }
        }
        function chPageDown() {
            var CHxspCount = Math.ceil(UserCount / CHxspPageCount);
            if (CHxspPageNum < CHxspCount) {
                $('#btnchsyy').attr("style", "background-color: #aaa !important").attr('onclick', '');
                $('#btnchxyy').attr("style", "background-color: #aaa !important").attr('onclick', '');
                chdsj = 10;
                chInterval = setInterval(chdDJS, 1000);
                CHxspPageNum++;
                $('#chpage').html(CHxspPageNum);
                if (CHxspPageNum == CHxspCount) {
                    $('#btnchxyy').attr("style", "background-color: #aaa !important");
                }
                Send(VideoConferenceMess_AttendMeeting_Page, '', '', '', "参会端下一页", CHxspPageNum);
                $('#btnchsyy').attr("style", "");
            }
            else {
                alert("已经是最后一页了");
                $('#chpage').html(CHxspCount);
                $('#btnchxyy').attr("style", "background-color: #aaa !important");
            }
        }
        function xsPageUp() {
            if (XSxspPageNum > 1) {
                $('#btnxssyy').attr("style", "background-color: #aaa !important").attr('onclick', '');
                $('#btnxsxyy').attr("style", "background-color: #aaa !important").attr('onclick', '');
                xsdsj = 10;
                xsInterval = setInterval(xsdDJS, 1000);
                XSxspPageNum--;
                $('#xspage').html(XSxspPageNum);
                if (XSxspPageNum == 1) {
                    $('#btnxssyy').attr("style", "background-color: #aaa !important");
                }
                Send(VideoConferenceMess_Show_Page, '', '', '', "显示端上一页", XSxspPageNum);
                $('#btnxsxyy').attr("style", "");
            }
            else {
                alert("已经是第一页了");
                $('#xspage').html('1');
                $('#btnxssyy').attr("style", "background-color: #aaa !important");
            }
        }
        function xsPageDown() {
            var XSxspCount = Math.ceil(UserCount / XSxspPageCount);
            if (XSxspPageNum < XSxspCount) {
                $('#btnxssyy').attr("style", "background-color: #aaa !important").attr('onclick', '');
                $('#btnxsxyy').attr("style", "background-color: #aaa !important").attr('onclick', '');
                xsdsj = 10;
                xsInterval = setInterval(xsdDJS, 1000);
                XSxspPageNum++;
                $('#xspage').html(XSxspPageNum);
                if (XSxspPageNum == XSxspCount) {
                    $('#btnxsxyy').attr("style", "background-color: #aaa !important");
                }
                Send(VideoConferenceMess_Show_Page, '', '', '', "显示端下一页", XSxspPageNum);
                $('#btnxssyy').attr("style", "");
            }
            else {
                alert("已经是最后一页了");
                $('#xspage').html(XSxspCount);
                $('#btnxsxyy').attr("style", "background-color: #aaa !important");
            }
        }
        function LoadModel(xsd, chd) {
            switch (xsd.Model) {
                case 1:
                    //$('.btnxs').attr("style", "");
                    //$('#btnxs1').attr("style", "background-color: green;");
                    $('#selxs').val('xs1');
                    $('#divxs1,#divxs2').hide();
                    break;
                case 2:
                    //$('.btnxs').attr("style", "");
                    //$('#btnxs2').attr("style", "background-color: green;");
                    $('#selxs').val('xs2');
                    XSxspPageNum = xsd.Page == 0 ? 1 : xsd.Page;
                    XSxspPageCount = PageCount;
                    $('#xspage').html(XSxspPageNum);
                    $('#btnxssyy').attr("style", "background-color: #aaa !important");
                    var XSxspCount = Math.ceil(UserCount / XSxspPageCount);
                    if (XSxspCount == 1) {
                        $('#btnxsxyy').attr("style", "background-color: #aaa !important");
                    }
                    else {
                        $('#btnxsxyy').attr("style", "");
                    }
                    $('#xspageCount').html(XSxspCount);
                    $('#divxs1').hide();
                    $('#divxs2').show();
                    if (XSxspPageNum == 1) {
                        $('#btnxssyy').attr("style", "background-color: #aaa !important");
                    }
                    else {
                        $('#btnxssyy').attr("style", "");
                    }
                    if (XSxspPageNum == XSxspCount) {
                        $('#btnxsxyy').attr("style", "background-color: #aaa !important");
                    }
                    else {
                        $('#btnxsxyy').attr("style", "");
                    }
                    break;
                case 3:
                    //$('.btnxs').attr("style", "");
                    //$('#btnxs3').attr("style", "background-color: green;");
                    $('#selxs').val('xs3');
                    $('#rdoxs5')[0].checked = "checked";
                    XSxspPageNum = xsd.Page == 0 ? 1 : xsd.Page;
                    XSxspPageCount = 25;
                    switch (xsd.XSPFormat) {
                        case "3*3":
                            XSxspPageCount = 9;
                            $('#rdoxs3')[0].checked = "checked";
                            break;
                        case "4*4":
                            XSxspPageCount = 16;
                            $('#rdoxs4')[0].checked = "checked";
                            break;
                        case "5*5":
                            XSxspPageCount = 25;
                            $('#rdoxs5')[0].checked = "checked";
                            break;
                    }
                    $('#xspage').html(XSxspPageNum);
                    $('#btnxssyy').attr("style", "background-color: #aaa !important");
                    var XSxspCount = Math.ceil(UserCount / XSxspPageCount);
                    if (XSxspCount == 1) {
                        $('#btnxsxyy').attr("style", "background-color: #aaa !important");
                    }
                    else {
                        $('#btnxsxyy').attr("style", "");
                    }
                    $('#xspageCount').html(XSxspCount);
                    $('#divxs1,#divxs2').show();
                    if (XSxspPageNum == 1) {
                        $('#btnxssyy').attr("style", "background-color: #aaa !important");
                    }
                    else {
                        $('#btnxssyy').attr("style", "");
                    }
                    if (XSxspPageNum == XSxspCount) {
                        $('#btnxsxyy').attr("style", "background-color: #aaa !important");
                    }
                    else {
                        $('#btnxsxyy').attr("style", "");
                    }
                    break;
            }
            switch (chd.Model) {
                case 1:
                    //$('.btnch').attr("style", "");
                    //$('#btnch1').attr("style", "background-color: green;");
                    $('#selch').val('ch1');
                    $('#divch1,#divch2').hide();
                    break;
                case 2:
                    //$('.btnch').attr("style", "");
                    //$('#btnch2').attr("style", "background-color: green;");
                    $('#selch').val('ch2');
                    CHxspPageNum = chd.Page == 0 ? 1 : chd.Page;
                    $('#chpage').html(CHxspPageNum);
                    $('#btnchsyy').attr("style", "background-color: #aaa !important");
                    CHxspPageCount = PageCount;
                    var CHxspCount = Math.ceil(UserCount / CHxspPageCount);
                    if (CHxspCount == 1) {
                        $('#btnchxyy').attr("style", "background-color: #aaa !important");
                    }
                    else {
                        $('#btnchxyy').attr("style", "");
                    }
                    $('#chpageCount').html(CHxspCount);
                    $('#divch1').hide();
                    $('#divch2').show();
                    if (CHxspPageNum == 1) {
                        $('#btnchsyy').attr("style", "background-color: #aaa !important");
                    }
                    else {
                        $('#btnchsyy').attr("style", "");
                    }
                    if (CHxspPageNum == CHxspCount) {
                        $('#btnchxyy').attr("style", "background-color: #aaa !important");
                    }
                    else {
                        $('#btnchxyy').attr("style", "");
                    }
                    break;
                case 3:
                    //$('.btnch').attr("style", "");
                    //$('#btnch3').attr("style", "background-color: green;");
                    $('#selch').val('ch3');
                    $('#rdoch5')[0].checked = "checked";
                    CHxspPageNum = chd.Page == 0 ? 1 : chd.Page;
                    CHxspPageCount = 25;
                    switch (chd.XSPFormat) {
                        case "3*3":
                            CHxspPageCount = 9;
                            $('#rdoch3')[0].checked = "checked";
                            break;
                        case "4*4":
                            CHxspPageCount = 16;
                            $('#rdoch4')[0].checked = "checked";
                            break;
                        case "5*5":
                            CHxspPageCount = 25;
                            $('#rdoch5')[0].checked = "checked";
                            break;
                    }
                    $('#chpage').html(CHxspPageNum);
                    $('#btnchsyy').attr("style", "background-color: #aaa !important");
                    var CHxspCount = Math.ceil(UserCount / CHxspPageCount);
                    if (CHxspCount == 1) {
                        $('#btnchxyy').attr("style", "background-color: #aaa !important");
                    }
                    else {
                        $('#btnchxyy').attr("style", "");
                    }
                    $('#chpageCount').html(CHxspCount);
                    $('#divch1,#divch2').hide();
                    if (CHxspPageNum == 1) {
                        $('#btnchsyy').attr("style", "background-color: #aaa !important");
                    }
                    else {
                        $('#btnchsyy').attr("style", "");
                    }
                    if (CHxspPageNum == CHxspCount) {
                        $('#btnchxyy').attr("style", "background-color: #aaa !important");
                    }
                    else {
                        $('#btnchxyy').attr("style", "");
                    }
                    break;
                case 4:
                    //$('.btnch').attr("style", "");
                    //$('#btnch2').attr("style", "background-color: green;");
                    $('#selch').val('ch4');
                    CHxspPageNum = chd.Page == 0 ? 1 : chd.Page;
                    $('#chpage').html(CHxspPageNum);
                    $('#btnchsyy').attr("style", "background-color: #aaa !important");
                    CHxspPageCount = PageCount;
                    var CHxspCount = Math.ceil(UserCount / CHxspPageCount);
                    if (CHxspCount == 1) {
                        $('#btnchxyy').attr("style", "background-color: #aaa !important");
                    }
                    else {
                        $('#btnchxyy').attr("style", "");
                    }
                    $('#chpageCount').html(CHxspCount);
                    $('#divch1,#divch2').hide();
                    if (CHxspPageNum == 1) {
                        $('#btnchsyy').attr("style", "background-color: #aaa !important");
                    }
                    else {
                        $('#btnchsyy').attr("style", "");
                    }
                    if (CHxspPageNum == CHxspCount) {
                        $('#btnchxyy').attr("style", "background-color: #aaa !important");
                    }
                    else {
                        $('#btnchxyy').attr("style", "");
                    }
                    break;
            }
        }
        //排序
        function sortByKey(array, key, sort) {
            if (sort == "asc")
                return array.sort(function (a, b) {
                    var x = a[key]; var y = b[key];
                    return ((x < y) ? -1 : ((x > y) ? 1 : 0));
                });
            else
                return array.sort(function (a, b) {
                    var x = a[key]; var y = b[key];
                    return ((x > y) ? -1 : ((x < y) ? 1 : 0));
                });
        }
    </script>
    <!--接收redis消息-->
    <script type="text/javascript">
        $(function () {
            // Declare a proxy to reference the hub.
            var chat = $.connection.chatHub;
            try {

            // Create a function that the hub can call to broadcast messages.
            chat.client.broadcastMessage = function (channel, message) {
                // Html encode display name and message.
                try {

                    if (channel != "VideoConference:" + RoomId) return;
                    var mess = JSON.parse(message);
                    switch (mess.reCode) {
                        case VideoConferenceMess_ZJR://01设置主讲人
                        case VideoConferenceMess_ProposerListSpeak://20发言申请列表开始发言
                            $("#divZJY").html("主讲人：" + mess.ReUserName);
                            SpeakerID = mess.ReUserid;
                            SpeakerName = mess.ReUserName;
                            break;
                        case VideoConferenceMess_CancelZJR://29取消主讲人
                            $("#divZJY").html("主讲人：");
                            SpeakerID = "";
                            SpeakerName = "";
                            break;
                        case VideoConferenceMess_SendCache://12广播会议缓存
                            LoadVideoConferenceMess(JSON.stringify(mess.Data.VideoConferenceMess));
                            break;
                        case VideoConferenceMess_SendUserList://14广播用户列表
                            VideoConferenceCHRY = mess.Data.UserList;
                            ShowCHRYList();
                            break;
                        case VideoConferenceMess_SendProposerList://19获取发言申请列表
                            ProposerList = mess.Data.ProposerList;
                            ShowProposerList();
                            break;
                        case VideoConferenceMess_RecState://24用户开始/结束录制
                            RecState = mess.Data.State;
                            if (RecState == 1) {
                                $('#aREC').html("结束录制");
                            }
                            else {
                                $('#aREC').html("开始录制");
                            }
                            break;
                        case VideoConferenceMess_SendHeartbeat://26广播心跳
                            var HeartbeatList = mess.Data.HeartbeatList;
                            CLXT(HeartbeatList, mess.ServerDatetime);
                            break;
                        case VideoConferenceMess_DelCache://28清理缓存
                            window.location.href = '../VideoConference/MyVideoConferenceList.aspx?LX=2';
                            break;
                        case VideoConferenceMess_Show_Page://34展示端翻页页码
                            XSxspPageNum = mess.Data.State;
                            $('#xspage').html(XSxspPageNum);
                            if (XSxspPageNum == 1) {
                                $('#btnxssyy').attr("style", "background-color: #aaa !important");
                            }
                            else {
                                $('#btnxssyy').attr("style", "");
                            }
                            var XSxspCount = Math.ceil(UserCount / XSxspPageCount);
                            if (XSxspPageNum == XSxspCount) {
                                $('#btnxsxyy').attr("style", "background-color: #aaa !important");
                            }
                            else {
                                $('#btnxsxyy').attr("style", "");
                            }
                            break;
                        case VideoConferenceMess_AttendMeeting_Page://37参会端翻页页码
                            CHxspPageNum = mess.Data.State;
                            $('#chpage').html(CHxspPageNum);
                            if (CHxspPageNum == 1) {
                                $('#btnchsyy').attr("style", "background-color: #aaa !important");
                            }
                            else {
                                $('#btnchsyy').attr("style", "");
                            }
                            var CHxspCount = Math.ceil(UserCount / CHxspPageCount);
                            if (CHxspPageNum == CHxspCount) {
                                $('#btnchxyy').attr("style", "background-color: #aaa !important");
                            }
                            else {
                                $('#btnchxyy').attr("style", "");
                            }
                            break;
                    }

                    // Add the message to the page.
                    switch (mess.reCode) {
                        case VideoConferenceMess_SendToUser://向用户发送消息MESS 09
                        case VideoConferenceMess_XXGB://广播消息
                            $('#tb3').html('<tr><td>' + GetTime1() + '</td><td>' + mess.SendUserName + '</td><td>' + mess.ReUserName + '</td><td>' + mess.Content + '</td></tr>' + $('#tb3').html());
                            break;
                    }
                    //$('#tb3').html('<tr><td>' + GetDateTime1() + '</td><td>' + mess.SendUserName + '</td><td>' + mess.Content + '</td></tr>' + $('#tb3').html());
                } catch (e) {

                }
            };
            //// Get the user name and store it to prepend to messages.
            //$('#displayname').val(prompt('Enter your name:', ''));
            //// Set initial focus to message input box.
            //$('#message').focus();
            //// Start the connection.
            //$.connection.hub.start().done(function () {
            //    $('#sendmessage').click(function () {
            //        // Call the Send method on the hub.
            //        chat.server.send($('#displayname').val(), $('#message').val());
            //        // Clear text box and reset focus for next comment.
            //        $('#message').val('').focus();
            //    });
            //});
                //断开后处理
                $.connection.hub.disconnected(function () {
                    $.messager.alert("提示", "Hub断开尝试重新连接！");
                    setTimeout(function () {
                        $.connection.hub.start().done(function () {
                            $(".messager-body").window('close');
                            chat.server.reConnect(RoomId);
                        });
                    }, 1000); //3秒后重新连接. 
                });
                $.connection.hub.start().done(function () {
                    if (DataId == "") {
                        alert("没有找到会议");
                    } else {
                        chat.server.reConnect(RoomId);
                        $("#divRoom").html("　编号：" + RoomId);
                        GetCache();
                        //GetByID();
                        setIntervalval = self.setInterval("GetCache()", 2000)
                        setInterval(SendHeartbeat1, 1000);
                        setInterval(GetHeartbeat2, 1000);
                    }
                });
            } catch (e) {
                var aaa = e;
            }
        });


        function SendHeartbeat1() {
            var data1 = {
                reCode: VideoConferenceMess_Heartbeat,
                ReUserid: '',
                ReUserQYBH: uModel.QYBH,
                ReUserName: '',
                SendUserID: UserID,
                SendUserName: UserName,
                Content: '心跳',
                Data: { State: 1 }
            }
            chat.server.sendHeartbeat(RoomId, JSON.stringify(data1));
            //Send(VideoConferenceMess_Heartbeat, '', uModel.QYBH, '', '心跳', 1);
        }
        function GetHeartbeat2() {
            var data1 = {
                reCode: VideoConferenceMess_GetHeartbeat,
                ReUserid: '',
                ReUserQYBH: uModel.QYBH,
                ReUserName: '',
                SendUserID: UserID,
                SendUserName: UserName,
                Content: '获取心跳',
                Data: { State: 1 }
            }
            chat.server.sendHeartbeat(RoomId, JSON.stringify(data1));
        }

        async function CLXT(HeartbeatList, ServerDatetime) {
            var date2 = new Date(ServerDatetime);
            var OnLineCount = 0;
            var MicOpenCount = 0;
            var CameraOpenCount = 0;
            var isOnLine = $('#ckbOnLine')[0].checked;
            var isCameraOpen = $('#ckbCameraOpen')[0].checked;
            var isMicOpen = $('#ckbMicOpen')[0].checked;
            for (var i = 0; i < HeartbeatList.length; i++) {
                if (HeartbeatList[i].HYRYDatetime == '0001-01-01T00:00:00.0000000+08:00') {
                    continue;
                }
                var date1 = new Date(HeartbeatList[i].HYRYDatetime);
                var date3 = date2.getTime() - date1.getTime();
                var seconds = Math.round(date3 / 1000)
                if (HeartbeatList[i].UserID == 'f13ad82883314e14b243062e793669a1') {

                }
                if (seconds <= 3) {
                    $('#div' + HeartbeatList[i].UserID).attr("style", "background-color:#67C23A");
                    OnLineCount++;
                    OnLineList[HeartbeatList[i].UserID] = 1;
                    OnLineCameraState[HeartbeatList[i].UserID] = HeartbeatList[i].CameraState;
                    OnLineMicState[HeartbeatList[i].UserID] = HeartbeatList[i].MicState;
                    if (HeartbeatList[i].MicState == 1) {
                        $("#aMic" + HeartbeatList[i].UserID).attr("style", "");
                        MicOpenCount++;
                    }
                    else {
                        $("#aMic" + HeartbeatList[i].UserID).attr("style", "color:#888");
                    }
                    if (HeartbeatList[i].CameraState == 1) {
                        $("#aCamera" + HeartbeatList[i].UserID).attr("style", "");
                        CameraOpenCount++;
                    }
                    else {
                        $("#aCamera" + HeartbeatList[i].UserID).attr("style", "color:#888");
                    }
                    if ((isCameraOpen && HeartbeatList[i].CameraState != 1)
                        || (isMicOpen && HeartbeatList[i].MicState != 1)) {
                        $("#tr" + HeartbeatList[i].UserID).hide();
                    }
                    else {
                        $("#tr" + HeartbeatList[i].UserID).show();
                    }
                }
                else {
                    $("#aCamera" + HeartbeatList[i].UserID + ",#aMic" + HeartbeatList[i].UserID).attr("style", "color:#888");
                    $('#div' + HeartbeatList[i].UserID).attr("style", "background-color:#00000040");
                    OnLineList[HeartbeatList[i].UserID] = 0;

                    if (isOnLine || isCameraOpen || isMicOpen) {
                        $("#tr" + HeartbeatList[i].UserID).hide();
                    }
                    else {
                        $("#tr" + HeartbeatList[i].UserID).show();
                    }
                }
            }
            $("#spanOnLineCount").html(OnLineCount);
            $("#spanCameraOpenCount").html(CameraOpenCount);
            $("#spanMicOpenCount").html(MicOpenCount);
        }
        function GetDateTime1() {
            var date = new Date();
            //return date.getFullYear() + "-" + (date.getMonth() + 1) + "-" + date.getDate() + " " + date.getHours() + ":" + date.getMinutes() + ":" + date.getSeconds();
            return (date.getMonth() + 1) + "-" + date.getDate() + " " + date.getHours() + ":" + date.getMinutes();
        }
        function GetDateTime(date1) {
            var date = new Date(date1);
            //return date.getFullYear() + "-" + (date.getMonth() + 1) + "-" + date.getDate() + " " + date.getHours() + ":" + date.getMinutes() + ":" + date.getSeconds();
            return (date.getMonth() + 1) + "-" + date.getDate() + " " + date.getHours() + ":" + date.getMinutes();
        }

        function GetTime1() {
            var date = new Date();
            //return date.getFullYear() + "-" + (date.getMonth() + 1) + "-" + date.getDate() + " " + date.getHours() + ":" + date.getMinutes() + ":" + date.getSeconds();
            //return date.getHours() + ":" + date.getMinutes() + ":" + date.getSeconds();
            var h = date.getHours();
            h = h.toString().length === 2 ? h : ('0' + h);
            var m = date.getMinutes();
            m = m.toString().length === 2 ? m : ('0' + m);
            var s = date.getSeconds();
            s = s.toString().length === 2 ? s : ('0' + s);
            return h + ":" + m + ":" + s;
        }
        function GetTime(date1) {
            var date = new Date(date1);
            //return date.getFullYear() + "-" + (date.getMonth() + 1) + "-" + date.getDate() + " " + date.getHours() + ":" + date.getMinutes() + ":" + date.getSeconds();
            var h = date.getHours();
            h = h.toString().length === 2 ? h : ('0' + h);
            var m = date.getMinutes();
            m = m.toString().length === 2 ? m : ('0' + m);
            var s = date.getSeconds();
            s = s.toString().length === 2 ? s : ('0' + s);
            return h + ":" + m + ":" + s;
        }
    </script>
</head>
<body>
    <div style="padding: 10px; width: 1200px; margin-left: auto; margin-right: auto;">
        <div style="padding:10px 5px; height:21px; background-color: #e7eaf2;">
            <div id="divTitle" style="float: left; width: 65%;">标题</div>
            <div id="divRoom" style="float: left; width: 15%;">编号：</div>
            <div id="divZJY" style="float: left; width: 20%;">主讲人：</div>
        </div>
        <div style="margin: 10px 0; padding:10px 5px; height:35px; background-color: #e7eaf2;">
            <a class="btnSave1" href="javascript:void(0)" style="" onclick="CloseAllMic()" title="关闭除主讲人和主持人外所有的麦克风">关闭麦克风</a>
            <a class="btnSave1" href="javascript:void(0)" style="width: 120px;" onclick="UpdateMicState(SpeakerID,'',SpeakerName,1)">打开主讲人麦克风</a>
            <a class="btnSave1" href="javascript:void(0)" id="aREC" style="display:none;" onclick="REC()">录制</a>
            <a class="btnSave1" href="javascript:void(0)" style="" onclick="CancelZJR()">取消主讲人</a>
            
            广播消息
            <input type="text" name="name" id="txtsendmess" value="" style="width: 450px; height: 24px;border: 1px solid;background-color: #e7eaf2" onkeyup="textMaxLength(this,100)" onkeydown="textMaxLength(this,100)" />
            <a class="btnSave1" href="javascript:void(0)" style="" onclick="Send(VideoConferenceMess_XXGB,'','','',$('#txtsendmess').val(),'')">发送</a>
            <input type="checkbox" name="name" id="ckbREC" onchange="UpdateAllowRECState()" style="display:none;"/><label for="ckbREC" style="display:none;">允许录制</label>
            <input type="checkbox" name="name" id="ckbProposer" onchange="UpdateAllowProposerState()" /><label for="ckbProposer">允许发言</label>
            <input type="checkbox" name="name" id="ckbAllowOpenMic" onchange="UpdateAllowOpenMic()" /><label for="ckbAllowOpenMic">允许打开麦克风</label>
        </div>
        <div style="float: left; height: 75px; width:560px; background-color: #e7eaf2; padding-left:5px;">
            <div style="height: 30px; line-height: 30px;">参会端</div>
           
                <div style="float:left">
                    <select id="selch" onchange="ShowModel($(this).val())" style="height: 35px;width: 140px;background-color: #e7eaf2">
                        <option value="ch2">主讲人+小视频模式</option>
                        <option value="ch1">主讲人模式</option>
                        <option id="opxsp" value="ch3">小视频模式</option>
                        <option value="ch4">自由模式</option>
                    </select>
                    <%--<a class="btnSave1 btnch" id="btnch2" href="javascript:void(0)" style="background-color: green;" onclick="ShowModel('ch2')">参会人模式</a>
                    <a class="btnSave1 btnch" id="btnch1" href="javascript:void(0)" style="" onclick="ShowModel('ch1')">主讲人模式</a>
                    <a class="btnSave1 btnch" id="btnch3" href="javascript:void(0)" style="" onclick="ShowModel('ch3')">小视频模式</a>--%>
                </div>
                <div style="float:left;margin-left:5px;display:none;" id="divch1">
                    <span style="line-height:35px; height: 35px;display: inline-block;">小视频版面：</span>
                    <input type="radio" name="ch" id="rdoch3" onchange="ShowXSPModel('3*3','1')" /><label for="rdoch3">3*3</label>
                    <input type="radio" name="ch" id="rdoch4" onchange="ShowXSPModel('4*4','1')" /><label for="rdoch4">4*4</label>
                    <input type="radio" name="ch" checked="checked" id="rdoch5" onchange="ShowXSPModel('5*5','1')" /><label for="rdoch5">5*5</label>
                </div>
                <div style="float:left;margin-left:5px;" id="divch2">
                    <a class="btnSave1" href="javascript:void(0)" id="btnchsyy" style="background-color: #aaa !important;" onclick="chPageUp()">上一页</a>
                    <span style="line-height:35px; height: 35px;display: inline-block;"><span id="chpage">1</span>/<span id="chpageCount">1</span></span>
                    <a class="btnSave1" href="javascript:void(0)" id="btnchxyy" style="background-color: #40d0a7;" onclick="chPageDown()">下一页</a>
                </div>
        </div>
        <div style="float: right; height: 75px; width:620px; background-color: #e7eaf2; padding-left:5px;">
            <div style="height: 30px; line-height: 30px;">显示端</div>
                <div style="float:left">
                    <select id="selxs" onchange="ShowModel($(this).val())" style="height: 35px;width: 140px;background-color: #e7eaf2">
                        <option value="xs2">主讲人+小视频模式</option>
                        <option value="xs1">主讲人模式</option>
                        <option value="xs3">小视频模式</option>
                    </select>
                  <%--  <a class="btnSave1 btnxs" id="btnxs2" href="javascript:void(0)" style="background-color: green;" onclick="ShowModel('xs2')">参会人模式</a>
                    <a class="btnSave1 btnxs" id="btnxs1" href="javascript:void(0)" style="" onclick="ShowModel('xs1')">主讲人模式</a>
                    <a class="btnSave1 btnxs" id="btnxs3" href="javascript:void(0)" style="" onclick="ShowModel('xs3')">小视频模式</a>--%>
                </div>
                <div style="float:left;margin-left:5px;display:none;" id="divxs1">
                    <span style="line-height:35px; height: 35px;display: inline-block;">版面：</span>
                    <input type="radio" name="xs" id="rdoxs3" onchange="ShowXSPModel('3*3','2')" /><label for="rdoxs3">3*3</label>
                    <input type="radio" name="xs" id="rdoxs4" onchange="ShowXSPModel('4*4','2')" /><label for="rdoxs4">4*4</label>
                    <input type="radio" name="xs" checked="checked" id="rdoxs5" onchange="ShowXSPModel('5*5','2')" /><label for="rdoxs5">5*5</label>
                </div>
                <div style="float:left;margin-left:5px;" id="divxs2">
                    <a class="btnSave1" href="javascript:void(0)" id="btnxssyy" style="background-color: #aaa !important;" onclick="xsPageUp()">上一页</a>
                    <span style="line-height:35px; height: 35px;display: inline-block;"><span id="xspage">1</span>/<span id="xspageCount">1</span></span>
                    <a class="btnSave1" href="javascript:void(0)" id="btnxsxyy" style="background-color: #40d0a7;" onclick="xsPageDown()">下一页</a>
                </div>
        </div>
        <div style="width: 560px; float: left; height: 520px; margin-top: 10px; padding-left:5px;background-color: #e7eaf2">
            <div style="height: 70px; line-height: 30px; border-bottom:1px solid #ccc"> 参会总人数：<span id="spanrs">0</span>人
            <label style="margin-left:30px;">姓名：</label><input type="text" name="name" id="txtName" value="" style="width: 70px; height: 24px;border: 1px solid;background-color: #e7eaf2" />
            <a class="btnSave1" href="javascript:void(0)" style="margin-left:10px; margin-top:5px;" onclick="Search()">搜索</a>
                <br />
                <input type="checkbox" name="name" id="ckbOnLine" onchange="Search()" /><label for="ckbOnLine"> 在线</label>：
                <span id="spanOnLineCount">0</span>人　　<input type="checkbox" name="name" id="ckbCameraOpen" onchange="Search()" /><label for="ckbCameraOpen"> 摄像头打开</label>：
                <span id="spanCameraOpenCount">0</span>人　　<input type="checkbox" name="name" id="ckbMicOpen" onchange="Search()" /><label for="ckbMicOpen"> 麦克风打开</label>：
                <span id="spanMicOpenCount">0</span>人
            </div>
            <div style="width: 555px; float: left; height: 435px; margin-top: 10px; overflow-y: auto; ">
                <table class="tablelist tablelist111">
                    <thead>
                        <tr>
                            <th style="width: 60px;">序号</th>
                            <th>名称</th>
                            <th style="width: 320px;">状态</th>
                        </tr>
                    </thead>
                    <tbody id="tb1">
                    </tbody>
                </table>
            </div>
        </div>
        <div style="width: 245px; float: right; height: 255px; margin-top: 10px; overflow-y: auto; background-color: #e7eaf2; margin-left:10px;">
            <div style="height: 30px; line-height: 30px;">预设发言</div>
            <table class="tablelist tablelist111">
                <thead>
                    <tr>
                        <th style="width: 60px;">序号</th>
                        <th style="width: 110px;">姓名</th>
                        <th>操作</th>
                    </tr>
                </thead>
                <tbody id="tb4">
                </tbody>
            </table>
        </div>
        <div style="width: 370px; float: right; height: 255px; margin-top: 10px; overflow-y: auto; background-color: #e7eaf2">
            <div style="height: 30px; line-height: 30px;">申请发言</div>
            <table class="tablelist tablelist111">
                <thead>
                    <tr>
                        <th style="width: 80px;">时间</th>
                        <th style="width: 140px;">姓名</th>
                        <th>操作</th>
                    </tr>
                </thead>
                <tbody id="tb2">
                </tbody>
            </table>
        </div>
        <div style="width: 625px; float: right; height: 255px; margin-top: 10px; overflow-y: auto; background-color: #e7eaf2;">
            <div style="height: 30px; line-height: 30px;">消息<a class="btnSave1" href="javascript:void(0)" style="height: 25px;line-height: 25px;margin-left: 10px;width: 80px;" onclick="ClearMess()">清空消息</a></div>
            <table class="tablelist tablelist111">
                <thead>
                    <tr>
                        <th style="width: 80px;">时间</th>
                        <th style="width: 100px;">发送人</th>
                        <th style="width: 100px;">接收人</th>
                        <th>内容</th>
                    </tr>
                </thead>
                <tbody id="tb3">
                </tbody>
            </table>
        </div>

        <div id="dd_SendMess" class="easyui-window" data-options="title:'发送消息',iconCls:'icon-add',minimizable: false,closed:true,maximizable:false,collapsible:false" style="width: 400px; height: 160px; padding: 25px; margin-bottom: 50px;">
            <div>给用户【<span id="spanUserName"></span>】发送消息</div>
            <div style="margin-top: 20px;">
                <input type="hidden" id="txtReUserid" name="name" value="" />
                <input type="hidden" id="txtReUserQYBH" name="name" value="" />
                <input type="hidden" id="txtReUserName" name="name" value="" />
                <input type="text" name="name" id="txtMess" value="" style="width: 340px; height: 24px;" onkeyup="textMaxLength(this,100)" onkeydown="textMaxLength(this,100)" />
            </div>
            <div style="text-align: center; margin-top: 10px; position: absolute; bottom: 10px; width: 100%;">
                <a class="btnSave" href="javascript:void(0)" onclick="SendMessToUser1();">发送</a>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
                <a class="btnCancel" href="javascript:void(0)" onclick="$('#dd_SendMess').window('close');">取消</a>
            </div>
        </div>
    </div>
</body>
</html>
