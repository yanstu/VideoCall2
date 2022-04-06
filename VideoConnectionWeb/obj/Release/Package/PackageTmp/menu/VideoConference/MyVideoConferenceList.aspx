<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="MyVideoConferenceList.aspx.cs" Inherits="VideoConnectionWeb.menu.VideoConference.MyVideoConferenceList" %>
<!DOCTYPE html>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
    <title>视频连线列表</title>
    <script type="text/javascript" src="/js/jquery-3.6.0.min.js"></script>
    <script src="/js/layui/layCommon.js"></script>
    <script src="/js/layui/layui.js"></script>
    <link href="/js/layui/css/layui.css" rel="stylesheet" />
    <link href="/js/layui/css/xadmin.css" rel="stylesheet" />
    <link href="/css/myStyle.css" rel="stylesheet" />
    <script>
        var uModel = GetUserModel(); //用户对象
        var pageNum = 0, pageSize = 20, DataCount = 0, PageCount = 0;//pageNum:当前页数从0开始，pageSize：每页显示总条数，DataCount：数据总条数
        var QYBH = uModel.QYBH;
        var GZRY_PC_JRHY = 1;
        var GZRY_HWKZ = 1;
        var LX = "2";
        var DBKID = "";
        var UserID = uModel.UserID;
        var UserName = uModel.UserName;
        $(function () {
            Search();
            /*  GetTimeCount();*/
        });

        //查询列表
        function Search() {
            var ListTitle = $("#txtListTitle ").val();
            var postData = {
                "PageNum": pageNum + 1,
                "PageSize": pageSize,
                "LX": LX,
                "QYBH": QYBH,
                "UserID": UserID,
                "DBKID": "",
                "Title": ListTitle,
            };
            ApiAjax("<%=AUC.MyVideoConferenceList%>", function (res) {
                $("#tbd1").html("<tr><td colspan='8' style='text-align:center;'>空</td></tr>");
                if (res.Code == 0) {
                    DataCount = res.Data.Total;
                    var tbContent1 = '';
                    for (var i = 0; i < res.Data.Rows.length; i++) {
                        tbContent1 += '<tr>';
                        tbContent1 += "<td style='text-align: center;'>" + (pageSize * pageNum + i + 1) + "</td>";
                        tbContent1 += "<td>" + res.Data.Rows[i].Title + "</td>";
                        tbContent1 += '<td>' + res.Data.Rows[i].TimeStr + '</td>';
                        tbContent1 += '<td>' + res.Data.Rows[i].RoomId + '</td>';
                        tbContent1 += '<td>' + res.Data.Rows[i].CJYH + '</td>';
                        tbContent1 += '<td>' + res.Data.Rows[i].QYMC + '</td>';
                        tbContent1 += '<td>' + res.Data.Rows[i].StatusStr + '</td>';
                        tbContent1 += '<td>';
                        if (GZRY_PC_JRHY == 1) {
                            tbContent1 += '<a href="javascript:void(0);" class="tablelink" onclick=JRHY("' + res.Data.Rows[i].ID + '","' + res.Data.Rows[i].RoomId + '")>进入连线</a>&nbsp;&nbsp;';
                        }
                        if (LX == "2") {
                            if (res.Data.Rows[i].QYBH == QYBH) {
                                tbContent1 += '<a href="javascript:void(0);" class="tablelink" onclick=OpenConferenceControl("' + res.Data.Rows[i].ID + '","' + res.Data.Rows[i].RoomId + '")>会务控制</a>';
                                tbContent1 += '&nbsp;&nbsp;<a href="javascript:void(0);" class="tablelink" onclick=ClickHYZS("' + res.Data.Rows[i].ID + '","' + res.Data.Rows[i].RoomId + '")>会议展示</a>';

                            }
                            else {
                                if (GZRY_HWKZ == 1) {
                                    tbContent1 += '<a href="javascript:void(0);" class="tablelink" onclick=OpenConferenceControl1("' + res.Data.Rows[i].ID + '","' + res.Data.Rows[i].RoomId + '")>会务控制</a>';
                                }
                            }
                        }
                        tbContent1 += '</td>';
                    }

                    if (tbContent1 == "") {
                        $("#tbd1").html("<tr><td colspan='8' style='text-align:center;'>空</td></tr>");
                    } else {
                        $("#tbd1").html(tbContent1);
                    }
                    $("#labDataCount").html(DataCount);
                    $("#labPageNow").html(pageNum + 1);
                    //////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
                    PageCount = DataCount / pageSize + (DataCount % pageSize == 0 ? 0 : 1);
                    var htmlSplitContent = pageNum == 0 ? '' : '<li class="paginItem"><a href="javascript:ToFirstPage();"><</a></li>';
                    if (pageNum < 6) {
                        for (var i = 1; i <= Math.floor(((PageCount) <= 10 ? (PageCount) : 10)); i++) {
                            htmlSplitContent += '<li class="paginItem' + (i == (pageNum + 1) ? ' current' : '') + '"><a href="javascript:ToPage(' + (i - 1) + ');">' + i + '</a></li>';
                        }
                    } else {
                        if ((pageNum + 5) <= Math.floor(PageCount)) {
                            for (var i = pageNum - 4; i <= pageNum + 5; i++) {
                                htmlSplitContent += '<li class="paginItem' + (i == (pageNum + 1) ? ' current' : '') + '"><a href="javascript:ToPage(' + (i - 1) + ');">' + i + '</a></li>';
                            }
                        } else {
                            for (var i = Math.floor(PageCount) - 9; i <= Math.floor(PageCount); i++) {
                                htmlSplitContent += '<li class="paginItem' + (i == (pageNum + 1) ? ' current' : '') + '"><a href="javascript:ToPage(' + (i - 1) + ');">' + i + '</a></li>';
                            }
                        }
                    }
                    htmlSplitContent += (pageNum + 1) == Math.floor(PageCount) ? '' : '<li class="paginItem"><a href="javascript:ToLastPage();">></a></li>';
                    $(".paginList").html(htmlSplitContent);
                } else {
                    alert(res.Msg);
                }
            }, postData, "get");
        }

        //分页跳转
        function ToPage(num) {
            pageNum = num;
            Search();
        }

        //首页跳转
        function ToFirstPage() {
            pageNum = 0;
            Search();
        }

        //末页跳转
        function ToLastPage() {
            pageNum = Math.floor(PageCount) - 1;
            Search();
        }

        //删除
        function Delete(id) {
            layConfirm("确认要删除吗？", function () {
                var postData = {
                    "ids": id,
                };
                ApiAjax("<%=AUC.DeleteVideoConference%>", function (res) {
                    if (res.Code == 0) {
                        layMsg("删除成功！");
                    } else {
                        alert(res.Msg);
                    }
                    Search();
                }, postData, "post");
            })
        }

        function OpenConferenceControl(id, rid) {
            location.href = "../ConferenceControl/ZCRControl.aspx?DataId=" + id + "&RoomId=" + rid;
        }
        function OpenConferenceControl1(id, rid) {
            location.href = "../ConferenceControl/HWRYControl.aspx?DataId=" + id + "&RoomId=" + rid;
        }

        function ClickHYZS(id, pRoomId) {
            var postData = {
                "HYID": id,
                "QYBH": QYBH,
                "UserID": UserID,
                "UserName": UserName,
                "DBKID": DBKID,
                "LX": "4",
                "type": "CheckJRHY",
            };
            ApiAjax("/Handler/VideoConferenceHandler.ashx", function (res) {
                if (res.Code == 0) {
                    window.open("/QZ/big.aspx?p=" + res.Data.JsonStr + "&RoomId=" + res.Data.RoomId);
                } else {
                    layAlert(res.Msg);
                }
            }, postData, "post");
        }

        function JRHY(id, pRoomId) {
            var postData = {
                "HYID": id,
                "QYBH": QYBH,
                "UserID": UserID,
                "UserName": UserName,
                "DBKID": DBKID,
                "LX": LX,
                "type": "CheckJRHY",
            };
            ApiAjax("/Handler/VideoConferenceHandler.ashx", function (res) {
                if (res.Code == 0) {
                    window.open("/QZ/index.aspx?p=" + res.Data.JsonStr + "&RoomId=" + res.Data.RoomId);
                } else {
                    layAlert(res.Msg);
                }
            }, postData, "post");
        }
    </script>
    <style>
        .showNum {
            font-size: 22px;
            color: dodgerblue;
        }
    </style>
</head>
<body>
    <div class="place">
        <span>位置：</span>
        <ul class="placeul">
            <li><a id="divPlice" href="#">视频连线列表</a></li>
        </ul>
    </div>
    <div class="rightinfo">
        <div class="layui-row">
            标题：<input type="text" id="txtListTitle" class="layui-input layui-input-inline" style="width: 220px;" />
            &nbsp;&nbsp;
            <button class="layui-btn" onclick="Search()" style="margin-left: 10px;"><i class="layui-icon"></i>搜索</button>
            <button class="layui-btn layui-btn-normal" onclick="location.reload();"><i class="layui-icon"></i>重置</button>
        </div>
        <table class="layui-table" style="font-size: 15px; margin-top: 10px;">
            <thead>
                <tr>
                    <th style="width: 50px; text-align: center;">序号</th>
                    <th style="min-width: 100px;">标题</th>
                    <th style="width: 150px;">开始时间</th>
                    <th style="width: 80px;">连线编号</th>
                    <th style="width: 100px;">创建人</th>
                    <th style="width: 100px;">区域</th>
                    <th style="width: 100px;">状态</th>
                    <th style="width: 190px;">操作</th>
                </tr>
            </thead>
            <tbody id="tbd1">
            </tbody>
        </table>
        <div class="pagin">
            <div class="message">共<i class="blue">&nbsp;<label id="labDataCount">0</label>&nbsp;</i>条记录，当前显示第&nbsp;<i class="blue">&nbsp;<label id="labPageNow">0</label>&nbsp;</i>页</div>
            <ul class="paginList">
            </ul>
        </div>
    </div>
</body>
</html>
