<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="VideoConference.aspx.cs" Inherits="VideoConnectionWeb.menu.VideoConference.VideoConference" %>

<!DOCTYPE html>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
    <title>视频连线</title>
    <script type="text/javascript" src="/js/jquery-3.6.0.min.js"></script>
    <script src="/js/layui/layCommon.js"></script>
    <script src="/js/layui/layui.js"></script>
    <link href="/js/layui/css/layui.css" rel="stylesheet" />
    <link href="/js/layui/css/xadmin.css" rel="stylesheet" />
    <link href="/css/myStyle.css" rel="stylesheet" />

    <link href="/css/style2.css" rel="stylesheet" />
    <script src="/js/jquery-3.6.0.min.js"></script>
    <script src="/js/jquery-easyui-1.4/jquery.easyui.min.js"></script>
    <link href="/js/jquery-easyui-1.4/themes/icon.css" rel="stylesheet" />
    <link href="/js/jquery-easyui-1.4/themes/default/easyui.css" rel="stylesheet" />

    <%--zTree（树形）--%>
    <link href="/js/zTree/css/bootstrapStyle/bootstrapStyle.css" rel="stylesheet" />
    <script src="/js/zTree/js/jquery.ztree.core.js"></script>
    <script src="/js/zTree/js/jquery.ztree.excheck.js"></script>
    <script src="/js/zTree/js/jquery.ztree.exedit.js"></script>

    <script src="/js/Common.js?v=20191105"></script>
    <script src="/js/My97DatePicker/WdatePicker.js"></script>
    <script src="/js/ApiHelper.js?v=20211022"></script>

    <script>
        var uModel = GetUserModel(); //用户对象
        var id = getvl("id");
        $(function () {
            $("#tbd1").html("<tr><td colspan='8' style='text-align:center;'>空</td></tr>");
            if (uModel.QYBH == "00") {//贵州省才要小视屏模式
                $(".tr_XSPMS").show();
            }
            if (id == "") {
                BJQX = true;
                ModelData = {
                    QYMC: uModel.QYMC,
                    QYBH: uModel.QYBH,
                    CJYH: uModel.UserName,
                    CHRY_ShowRows: 0,
                    CHRY_ShowCols: 0
                };
                for (var v in ModelData) {
                    if ($("#txt" + v).length > 0) {
                        $("#txt" + v).val(ModelData[v]);
                    }
                }
                AddDWItem(1, uModel.QYMC, uModel.QYBH);
                ShowCHRYList();
                $("#btnsave").show();
            } else {
                GetByID();
            }
            if (uModel.QYBH.length < 6) {//省级和市级都可以选下级区域的代表
                $("#divTree").css("display", "inline-block");
                $("#divDBList").css({ "width": "640px" });
                $("#divDBTabList").css({ "width": "623px" });

            }
        });

        var BJQX = false;//编辑权限
        function GetByID() {
            var postData = {
                "ID": id,
            };
            ApiAjax("<%=AUC.FindVideoConferenceById%>", function (res) {
                if (res.Code == 0) {
                    ModelData = res.Data.VideoConference;
                    VideoConferenceCHRY = res.Data.VideoConferenceCHRY;
                    for (var v in ModelData) {
                        if ($("#txt" + v).length > 0) {
                            $("#txt" + v).val(ModelData[v]);
                        }
                    }
                    $("input[name=rdoZT][value=" + ModelData.Status + "]").attr("checked", true);
                    //if (ModelData.IsLZ == 1) {
                    //    $('#rdoLZ')[0].checked = "checked";
                    //} else {
                    //    $('#rdoBLZ')[0].checked = "checked";
                    //}
                    if (ModelData.XSPMS == 1) {
                        $('#rdoXSPMS1')[0].checked = "checked";
                    } else {
                        $('#rdoXSPMS0')[0].checked = "checked";
                    }

                    if (ModelData.CJRLX == 2) {//代表创建的
                        $(".DBNone").hide();
                        $("#labTS").css("left", "520px");
                    }
                    if (ModelData.CJYHID == uModel.UserID || uModel.IsLLZAdmin == 1) {//工作人员创建的会议或用户是管理员 可以修改
                        $("#btnsave").show();
                        BJQX = true;
                        $("#showAddCHRY").show();
                    } else {
                        $("#showAddCHRY").remove();
                    }


                    ShowCHRYList();
                } else {
                    layAlert(res.Msg);
                }
            }, postData, "get");
        }
        var ModelData = "";
        var VideoConferenceCHRY = new Array();
        function ShowCHRYList() {
            $(".btnMove").hide();
            var tbContent1 = "";
            for (var i = 0; i < VideoConferenceCHRY.length; i++) {
                VideoConferenceCHRY[i]["XUHAO"] = i + 1;
                VideoConferenceCHRY[i]["tempIndex"] = i;
                if (BJQX) {
                    tbContent1 += '<tr class="showTr" onclick="ClickShowTr(this)" data-Index="' + VideoConferenceCHRY[i].tempIndex + '">';
                } else {
                    tbContent1 += '<tr>';
                }
                tbContent1 += "<td style='text-align: center;' class='rowNum'>" + (i + 1) + "</td>";
                tbContent1 += '<td  style="text-align:center;">' + VideoConferenceCHRY[i].UserName;
                if (BJQX) {
                    tbContent1 += '<button class="btnIconXG"></button>';
                }
                tbContent1 += '</td>';
                tbContent1 += '<td  style="text-align:center;">' + GetCHRYTypeStr(VideoConferenceCHRY[i].Type) + '</td>';
                tbContent1 += '<td  style="text-align:center;">' + VideoConferenceCHRY[i].UserQYMC + '</td>';

                tbContent1 += '<td  style="text-align:center;">' + (VideoConferenceCHRY[i].IsFY == 0 ? "" : "是") + '</td>';
                tbContent1 += '<td  style="text-align:center;">' + (VideoConferenceCHRY[i].FYSX == 0 ? "" : VideoConferenceCHRY[i].FYSX) + '</td>';

                tbContent1 += '<td style="text-align:center;">';
                if (BJQX) {
                    tbContent1 += '<a href="javascript:void(0);" class="tablelink" onclick=ClickSetFY(event,"' + i + '")>设置发言</a>&nbsp;&nbsp;';
                    if (VideoConferenceCHRY[i].Type == 2 && VideoConferenceCHRY[i].UserQYBH == ModelData.QYBH) {//是创建人的区域单位

                    } else {
                        tbContent1 += '<a href="javascript:void(0);" class="tablelink" onclick=DeleteCHRY("' + i + '")>删除</a>&nbsp;&nbsp;';
                    }
                }
                tbContent1 += '</td>';
            }

            if (tbContent1 == "") {
                $("#tbd1").html("<tr><td colspan='8' style='text-align:center;'>空</td></tr>");
            } else {
                $("#tbd1").html(tbContent1);
            }

            $(".btnIconXG").click(function (event) {
                $('#dd_Mess_XGMC').window('open');
                XGTr = $(this).parent().parent();
                var index1 = GetVideoConferenceCHRYIndex(XGTr[0]);
                $("#txtMC").val(VideoConferenceCHRY[index1].UserName);

                //防止有滚动条时，弹出窗不居中
                $("#dd_Mess_XGMC").window("move", { top: $(document).scrollTop() + ($(window).height() - $('#dd_Mess_XGMC').height()) * 0.5 });

                event.stopPropagation();
                event.preventDefault();
                return false;
            });

        }

        function DeleteCHRY(index) {
            VideoConferenceCHRY.splice(index, 1);
            ShowCHRYList();
        }

        var boolIsSave = false;
        //保存
        function ClickSave(IsSetDB, SHLX) {
            if (boolIsSave) {
                console.log("正在保存！");
                return;
            }

            var Title = $("#txtTitle").val();
            var Time = $("#txtTimeStr").val();
            /* var SFLZ = ($('#rdoLZ')[0].checked ? "1" : "0");*/
            var SFLZ = "0";
            if ($("input[name=rdoZT]:checked").length == 0) {
                layMsg("请选择状态！");
                return;
            }
            var Status = $("input[name=rdoZT]:checked").val();
            if (Title == "") {
                layMsg("请输入标题！");
                return;
            }
            if (Time == "") {
                layMsg("请选择开始时间！");
                return;
            }
            var XSPMS = ($('#rdoXSPMS1')[0].checked ? "1" : "0");

            var ZCRID = $("#txtZCRID").val();
            var ZCRName = $("#txtZCRID").find("option:selected").text();
            if (ZCRID == "") {
                ZCRName = "";
            }

            var CHRY_ShowRows = $("#txtCHRY_ShowRows").val();
            var CHRY_ShowCols = $("#txtCHRY_ShowCols").val();
            if (CHRY_ShowRows == "") {
                CHRY_ShowRows = 0;
            }
            if (CHRY_ShowCols == "") {
                CHRY_ShowCols = 0;
            }
            if (Number(CHRY_ShowRows) > 10) {
                layMsg("最大只能设置10行！");
                return;
            }
            if (Number(CHRY_ShowCols) > 3) {
                layMsg("最大只能设置3列！");
                return;
            }
            if (Number(CHRY_ShowRows) == 0 && Number(CHRY_ShowCols) != 0) {
                layMsg("行为0时，列只能为0！");
                return;
            }
            if (Number(CHRY_ShowRows) != 0 && Number(CHRY_ShowCols) == 0) {
                layMsg("列为0时，行只能为0！");
                return;
            }
            if (Number(CHRY_ShowRows) * Number(CHRY_ShowCols) > 24) {
                layMsg("行乘以列不能大于24！");
                return;
            }
            if (id == "") {
                var VideoConference = {
                    Title: Title,
                    RoomId: 0,
                    Time: Time,
                    Status: Status,
                    QYBH: uModel.QYBH,
                    QYMC: uModel.QYMC,
                    CJYHID: uModel.UserID,
                    CJYH: uModel.UserName,
                    YQM: 0,
                    IsLZ: SFLZ,
                    CJRLX: uModel.UserType == 4 ? "2" : "1",
                    ZCRID: ZCRID,
                    ZCRName: ZCRName,
                    CHRY_ShowRows: CHRY_ShowRows,
                    CHRY_ShowCols: CHRY_ShowCols,
                    XSPMS: XSPMS
                };
                var data = { VideoConference: VideoConference, VideoConferenceCHRY: VideoConferenceCHRY };
                var postData = { VCP: JSON.stringify(data) };

                ApiAjax("<%=AUC.AddVideoConferenceApi%>", function (res) {
                    boolIsSave = false;
                    if (res.Code == 0) {
                        layAlert("操作成功！", function () {
                            location.href = "VideoConferenceList.aspx";
                        });
                    } else {
                        layAlert(res.Msg);
                    }
                }, postData, "post");
            } else {
                ModelData.Title = Title;
                ModelData.Time = Time;
                ModelData.Status = Status;
                ModelData.IsLZ = SFLZ;
                ModelData.ZCRID = ZCRID;
                ModelData.ZCRName = ZCRName;
                ModelData.CHRY_ShowRows = CHRY_ShowRows;
                ModelData.CHRY_ShowCols = CHRY_ShowCols;
                ModelData.XSPMS = XSPMS;
                var data = { VideoConference: ModelData, VideoConferenceCHRY: VideoConferenceCHRY };
                var postData = { VCP: JSON.stringify(data) };

                ApiAjax("<%=AUC.UpdateVideoConference%>", function (res) {
                    boolIsSave = false;
                    if (res.Code == 0) {
                        layAlert("操作成功！", function () {
                            location.href = "VideoConferenceList.aspx";
                        });

                    } else {
                        layAlert(res.Msg);
                    }
                }, postData, "post");
            }
        }

        function GetCHRYTypeStr(t) {
            if (t == 1) {
                return "工作人员";
            } else if (t == 2) {
                return "单位";
            } else if (t == 3) {
                return "代表";
            } else if (t == 4) {
                return "群众";
            }
            return "";
        }

        function ClickAddQZ() {
            $("#txtQZMC").val("");
            $('#dd_Mess_addQZ').window('open');
            //防止有滚动条时，弹出窗不居中
            $("#dd_Mess_addQZ").window("move", { top: $(document).scrollTop() + ($(window).height() - $('#dd_Mess_addQZ').height()) * 0.5 });
        }

        function AddQZ() {
            var QZMC = $("#txtQZMC").val();

            if (QZMC == "") {
                layMsg("请输入群众名称！");
                return;
            }
            for (var i = 0; i < VideoConferenceCHRY.length; i++) {
                if (VideoConferenceCHRY[i].Type == 4 && VideoConferenceCHRY[i].UserName == QZMC) {
                    layMsg("此群众名称已添加！");
                    return;
                }
            }
            var tempAdd = {
                ID: "",
                UserID: "",
                UserName: QZMC,
                Type: 4,
                UserQYMC: "",
                UserQYBH: "",
                DBKID: "",
                XUHAO: 0,
                HYRole: 0,
                IsFY: 0,
                FYSX: 0
            };
            if ($(".selectRow").length == 1) {
                var addIndex = GetVideoConferenceCHRYIndex($(".selectRow")[0]);
                VideoConferenceCHRY.splice(addIndex, 0, tempAdd);
            } else {
                VideoConferenceCHRY.push(tempAdd);
            }

            ShowCHRYList();
            $("#txtQZMC").val("");
        }


        function IsChecked(tempDBID) {
            for (var i = 0; i < VideoConferenceCHRY.length; i++) {
                if (VideoConferenceCHRY[i].Type == 3 && VideoConferenceCHRY[i].DBKID == tempDBID) {
                    return true;
                }
            }
            return false;
        }
        //点击添加代表
        function ClickSelectDB() {
            if (uModel.QYBH.length < 6) {
                ConvertQYList();
            }
            pageNum = 0;
            pageSize = 20;
            GetDBList();
            $('#dbInfo').window('open');
            //防止有滚动条时，弹出窗不居中
            $("#dbInfo").window("move", { top: $(document).scrollTop() + ($(window).height() - $('#dbInfo').height()) * 0.5 });
            $('#divdbinfo').show();
        }

        function QRSelectDB() {
            $('input[name=cboDB]:checked').each(function (i) {
                var tempDBKID = $(this).val();
                var tempDBMC = $(this).attr("data-XM");
                if (IsChecked(tempDBKID) == false) {
                    var tempAdd = {
                        ID: "",
                        UserID: "",
                        UserName: tempDBMC,
                        Type: 3,
                        UserQYMC: $(this).attr("data-QYMC"),
                        UserQYBH: $(this).attr("data-QYBH"),
                        DBKID: tempDBKID,
                        XUHAO: 0,
                        HYRole: 0,
                        IsFY: 0,
                        FYSX: 0
                    }
                    if ($(".selectRow").length == 1) {
                        var addIndex = GetVideoConferenceCHRYIndex($(".selectRow")[0]);
                        VideoConferenceCHRY.splice(addIndex, 0, tempAdd);
                    } else {
                        VideoConferenceCHRY.push(tempAdd);
                    }
                }
            });
            ShowCHRYList();
            $('#dbInfo').window('close');
        }

        function SearchDB() {
            pageNum = 0;
            pageSize = 20;
            GetDBList();
        }

        function SearchDBReset() {
            $("#txtXM").val("");
            $(".SearchStyle").removeClass("SearchStyle");
        }

        var DBList = new Array();
        //查询代表
        function GetDBList() {
            $("#divDBList").html("");
            $("#tbdDBList").html("");
            if (uModel.LLZLX == 4 || uModel.LLZLX == 5 || uModel.LLZLX == 6) {//乡镇和街道联络站从驻站代表中选择
                ApiAjax("<%=AUC.DBImgListByGZRY3%>", function (res) {
                    var tbContent1 = "";
                    if (res.Code == 0) {
                        for (var i = 0; i < res.Data.length; i++) {
                            var str = "";
                            if (IsChecked(res.Data[i].DBKID)) {//判断是否选中
                                str = 'checked="true"';
                            }
                            tbContent1 += '<label class="labCbo"><input class="cboDB" ' + str + ' name="cboDB" type="checkbox" value="' + res.Data[i].DBKID + '" data-XM="' + res.Data[i].XM + '" data-QYBH="' + res.Data[i].QYBH + '" data-QYMC="' + res.Data[i].QYMC + '"/>' + res.Data[i].XM + '</label>';
                        }
                    } else {
                        layMsg(res.Msg);
                    }
                    $("#divDBList").html(tbContent1);
                }, { LLZID: uModel.LLZID }, "get");

            } else {
                var IsAll = 0;
                var QYBH_P = uModel.QYBH;
                if (GetQYBH == "0") {//搜索本级包含下级
                    $("#divDBList").hide();
                    $("#divDBTabList").css("display", "inline-block");
                    pageSize = 20;
                    IsAll = 1;
                    if (QYBH_P == "00") {
                        QYBH_P = "";
                    }
                } else {
                    pageNum = 0;
                    pageSize = 999999;
                    $("#divDBTabList").hide();
                    $("#divDBList").css("display", "inline-block");
                    QYBH_P = GetQYBH;
                }
                if (GetQYBH == "00") {//省人大显示2个代表库
                    $("#divDBList").html('<div class="SRD" style="font-weight: bold; padding-bottom: 10px;">全国人大代表库</div><div id = "divQGRDDB" class= "SRD" ></div ><div class="SRD" style="font-weight: bold; padding-bottom: 10px; padding-top: 10px;">省人大代表库</div><div id="divSRDDBK" class="SRD"></div>');
                    GetQGAndSRDDB();
                    return;
                }
                var postData = { XM: $("#txtXM").val(), QYBH: QYBH_P, PageNum: pageNum + 1, PageSize: pageSize, "IsAll": IsAll };
                ApiAjax("<%=AUC.DBKListPage%>", function (res) {
                    DBList = res.Data.Rows;
                    var tbContent1 = "";
                    if (res.Code == 0) {
                        for (var i = 0; i < res.Data.Rows.length; i++) {
                            var str = "";
                            if (IsChecked(res.Data.Rows[i].DBKID)) {//判断是否选中
                                str = 'checked="true"';
                            }
                            var tempCbo = '<input class="cboDB" ' + str + ' name="cboDB" type="checkbox" value="' + res.Data.Rows[i].DBKID + '" data-XM="' + res.Data.Rows[i].XM + '" data-QYBH="' + res.Data.Rows[i].QYBH + '" data-QYMC="' + res.Data.Rows[i].QYMC + '"/>';
                            if (GetQYBH == "0") {//搜索本级包含下级
                                tbContent1 += '<tr>';
                                tbContent1 += '<td style="text-align:center;">' + tempCbo + (pageSize * pageNum + i + 1) + '</td>';
                                tbContent1 += '<td>' + res.Data.Rows[i].XM + '</td>';
                                tbContent1 += '<td>' + res.Data.Rows[i].JC + '</td>';
                                tbContent1 += '<td>' + res.Data.Rows[i].QYMC + '</td>';
                                tbContent1 += '</tr>';
                            } else {
                                tbContent1 += '<label class="labCbo">' + tempCbo + (res.Data.Rows[i].XM) + '</label>';;
                            }

                        }
                    } else {
                        layAlert(res.Msg);
                    }
                    if (GetQYBH == "0") {//搜索本级包含下级
                        $("#tbdDBList").html(tbContent1);
                        DataCount = res.Data.Total;
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
                        $("#divDBList").html(tbContent1);
                    }

                }, postData, "get");
            }
        }

        function GetQGAndSRDDB() {
            ApiAjax("<%=AUC.DBKImgList%>", function (res) {
                DBList = res.Data;
                var tbContent1 = "";
                if (res.Code == 0) {
                    for (var i = 0; i < res.Data.length; i++) {
                        var str = "";
                        if (IsChecked(res.Data[i].DBKID)) {//判断是否选中
                            str = 'checked="true"';
                        }
                        tbContent1 += '<label class="labCbo"><input class="cboDB" ' + str + ' name="cboDB" type="checkbox" value="' + res.Data[i].DBKID + '" data-XM="' + res.Data[i].XM + '" data-QYBH="' + res.Data[i].QYBH + '" data-QYMC="' + res.Data[i].QYMC + '"/>' + res.Data[i].XM + '</label>';
                    }
                } else {
                    layAlert(res.Msg);
                }
                $("#divSRDDBK").html(tbContent1);
            }, { XM: $("#txtXM").val(), QYBH: "00" }, "get");

            ApiAjax("<%=AUC.DBKImgList%>", function (res) {
                DBList = res.Data;
                var tbContent1 = "";
                if (res.Code == 0) {
                    for (var i = 0; i < res.Data.length; i++) {
                        var str = "";
                        if (IsChecked(res.Data[i].DBKID)) {//判断是否选中
                            str = 'checked="true"';
                        }
                        tbContent1 += '<label class="labCbo"><input class="cboDB" ' + str + ' name="cboDB" type="checkbox" value="' + res.Data[i].DBKID + '" data-XM="' + res.Data[i].XM + '" data-QYBH="' + res.Data[i].QYBH + '" data-QYMC="' + res.Data[i].QYMC + '"/>' + res.Data[i].XM + '</label>';
                    }
                } else {
                    layAlert(res.Msg);
                }
                $("#divQGRDDB").html(tbContent1);
            }, { XM: $("#txtXM").val(), QYBH: "1" }, "get");
        }

        //分页跳转
        function ToPage(num) {
            pageNum = num;
            GetDBList();
        }

        //首页跳转
        function ToFirstPage() {
            pageNum = 0;
            GetDBList();
        }

        //末页跳转
        function ToLastPage() {
            pageNum = Math.floor(PageCount) - 1;
            GetDBList();
        }

        //点击添加单位
        function ClickSelectDW() {
            ConvertQYList();
            $('#dwInfo').window('open');
            //防止有滚动条时，弹出窗不居中
            $("#dwInfo").window("move", { top: $(document).scrollTop() + ($(window).height() - $('#dwInfo').height()) * 0.5 });
            if (zTreeObj2 != "") {
                zTreeObj2.checkAllNodes(false);
                zTreeObj2.cancelSelectedNode();
            }
        }

        function QRSelectDW() {
            //var tempList = new Array();
            //for (var i = 0; i < VideoConferenceCHRY.length; i++) {
            //    if (VideoConferenceCHRY[i].Type != 2) {
            //        tempList.push(VideoConferenceCHRY[i]);
            //    }
            //}
            //VideoConferenceCHRY = tempList;//把Type为2的不要了，重新设置
            var checkedNodes = zTreeObj2.getCheckedNodes();
            for (var i = 0; i < checkedNodes.length; i++) {
                var tempQYBH = checkedNodes[i].id;
                var tempQYMC = checkedNodes[i].name;
                var isHave = IsHaveDW(tempQYBH);
                if (isHave == true) {
                    continue;
                }
                AddDWItem(0, tempQYMC, tempQYBH)
            }
            ShowCHRYList();
            $('#dwInfo').window('close');
        }

        function AddDWItem(tempHYRole, tempQYMC, tempQYBH) {
            var tempAdd = {
                ID: "",
                UserID: "",
                UserName: tempQYMC,
                Type: 2,
                UserQYMC: tempQYMC,
                UserQYBH: tempQYBH,
                DBKID: "",
                XUHAO: 0,
                HYRole: tempHYRole,
                IsFY: 0,
                FYSX: 0
            };
            if ($(".selectRow").length == 1) {
                var addIndex = GetVideoConferenceCHRYIndex($(".selectRow")[0]);
                VideoConferenceCHRY.splice(addIndex, 0, tempAdd);
            } else {
                VideoConferenceCHRY.push(tempAdd);
            }
        }

        function IsHaveDW(tempQYBH) {
            for (var i = 0; i < VideoConferenceCHRY.length; i++) {
                if (VideoConferenceCHRY[i].Type == 2 && VideoConferenceCHRY[i].UserQYBH == tempQYBH) {
                    return true;
                }
            }
            return false;
        }

        function ClickShowTr(obj) {
            if ($(obj).hasClass('selectRow')) {
                $(".selectRow").removeClass("selectRow");
                $(".btnMove").hide();
            } else {
                $(".selectRow").removeClass("selectRow");
                $(obj).addClass("selectRow");
                $(".btnMove").show();
            }
        }

        //获取参会人员数组中的下表
        function GetVideoConferenceCHRYIndex(obj) {
            var tempIndex = $(obj).attr("data-Index");
            for (var i = 0; i < VideoConferenceCHRY.length; i++) {
                if (VideoConferenceCHRY[i].tempIndex == tempIndex) {
                    return i;
                }
            }
            return -1;
        }

        //数组的2个元素换位置和交换 XUHAO 的值
        function SwapArray(index1, index2) {
            if (index1 > -1 && index2 > -1) {
                var temp1 = VideoConferenceCHRY[index1];
                var temp2 = VideoConferenceCHRY[index2];
                var tempXUHAO = temp1.XUHAO;
                temp1.XUHAO = temp2.XUHAO;
                temp2.XUHAO = tempXUHAO;

                VideoConferenceCHRY[index1] = temp2;
                VideoConferenceCHRY[index2] = temp1;
            }
        }

        function ClickMoveUp() {
            if ($(".selectRow").length == 1) {
                if ($(".selectRow").prev().length > 0) {
                    var tempRow = $(".selectRow");
                    var tempPrev = $(".selectRow").prev();

                    var rowNum = tempRow.children(".rowNum").html();
                    var rowNumPrev = tempPrev.children(".rowNum").html();
                    tempRow.children(".rowNum").html(rowNumPrev);
                    tempPrev.children(".rowNum").html(rowNum);

                    var index1 = GetVideoConferenceCHRYIndex(tempRow[0]);
                    var index2 = GetVideoConferenceCHRYIndex(tempPrev[0]);
                    SwapArray(index1, index2);
                    var tempRow
                    SwapNode(tempRow[0], tempPrev[0]);

                    var tempDiv = $("#divCHRY");
                    tempDiv.animate({
                        scrollTop: tempRow.offset().top - tempDiv.offset().top + tempDiv.scrollTop() - 200
                    });
                }
            }
        }

        function ClickMoveDwon() {
            if ($(".selectRow").length == 1) {
                if ($(".selectRow").next().length > 0) {
                    var tempRow = $(".selectRow");
                    var tempNext = $(".selectRow").next();

                    var rowNum = tempRow.children(".rowNum").html();
                    var rowNumNext = tempNext.children(".rowNum").html();
                    tempRow.children(".rowNum").html(rowNumNext);
                    tempNext.children(".rowNum").html(rowNum);

                    var index1 = GetVideoConferenceCHRYIndex(tempRow[0]);
                    var index2 = GetVideoConferenceCHRYIndex(tempNext[0]);
                    SwapArray(index1, index2);
                    SwapNode(tempRow[0], tempNext[0]);

                    var tempDiv = $("#divCHRY");
                    tempDiv.animate({
                        scrollTop: tempRow.offset().top - tempDiv.offset().top + tempDiv.scrollTop() - 150
                    });
                    ;
                }
            }
        }

        //两个标签换位
        function SwapNode(node1, node2) {
            var parent = node1.parentNode;//父节点
            var t1 = node1.nextSibling;//两节点的相对位置
            var t2 = node2.nextSibling;

            //如果是插入到最后就用appendChild
            if (t1) parent.insertBefore(node2, t1);
            else parent.appendChild(node2);
            if (t2) parent.insertBefore(node1, t2);
            else parent.appendChild(node1);
        }


        var XGTr = "";
        function ClickSaveXGMC() {
            var tempXM = Trim($("#txtMC").val());
            if (tempXM == "") {
                layMsg("请输入名称！");
                return;
            }
            for (var i = 0; i < VideoConferenceCHRY.length; i++) {
                if (VideoConferenceCHRY[i].UserName == tempXM) {
                    layMsg("此名称已存在！");
                    return;
                }
            }
            var index1 = GetVideoConferenceCHRYIndex(XGTr[0]);
            VideoConferenceCHRY[index1].UserName = tempXM;
            ShowCHRYList();
            $('#dd_Mess_XGMC').window('close');
        }
        // 去除前后空格
        function Trim(str) {
            return str.replace(/^(\s|\u00A0)+/, '').replace(/(\s|\u00A0)+$/, '').replace(/&nbsp;/g, '');
        }

        //只能输入正整数
        function CheckIsNumber(obj) {
            if (obj.value.length == 1) { obj.value = obj.value.replace(/[^1-9] /g, '') } else { obj.value = obj.value.replace(/\D/g, '') }
        }

        var SetFYIndex = "";
        function ClickSetFY(e, index) {
            SetFYIndex = index;
            $("#txtSetFY_MC").val(VideoConferenceCHRY[SetFYIndex].UserName);
            $("input[name=rdoIsFY][value=" + VideoConferenceCHRY[SetFYIndex].IsFY + "]").attr("checked", true);
            $("#txtSetFY_FYSX").val(VideoConferenceCHRY[SetFYIndex].FYSX);
            IsFYChange();
            $('#dd_Mess_SetFY').window('open');
            //防止有滚动条时，弹出窗不居中
            $("#dd_Mess_SetFY").window("move", { top: $(document).scrollTop() + ($(window).height() - $('#dd_Mess_SetFY').height()) * 0.5 });
            e.stopPropagation();
            e.preventDefault();
        }

        function ClickSaveSetFY() {
            if ($("input[name=rdoIsFY]:checked").length == 0) {
                layMsg("请选择是否发言！");
                return;
            }
            var tempIsFY = $("input[name=rdoIsFY]:checked").val();
            var tempFYSX = $("#txtSetFY_FYSX").val();
            if (tempIsFY == "0") {
                tempFYSX = 0;
            } else {
                if (tempFYSX == "") {
                    layMsg("请输入发言顺序！");
                    return;
                }
                tempFYSX = Number(tempFYSX);
            }
            VideoConferenceCHRY[SetFYIndex].FYSX = tempFYSX;
            VideoConferenceCHRY[SetFYIndex].IsFY = Number(tempIsFY);
            ShowCHRYList();
            $('#dd_Mess_SetFY').window('close');
        }

        function IsFYChange() {
            var tempIsFY = $("input[name=rdoIsFY]:checked").val();
            if (tempIsFY == "0") {
                $("#txtSetFY_FYSX").attr("disabled", "disabled");
                $("#txtSetFY_FYSX").val("");
            } else {
                $("#txtSetFY_FYSX").removeAttr("disabled");
            }
        }
    </script>
    <style>
        .labCbo {
            display: inline-block;
            margin: 5px;
            width: 65px;
        }

        .cboDB {
            position: relative;
            top: 2px;
        }

        .selectRow td {
            background-color: dodgerblue;
            color: white;
        }

        .btnMove {
            display: none;
        }
    </style>
</head>
<body>
    <div style="width:1300px;margin-left:auto;margin-right:auto;position:relative;">
    <div class="place">
        <span>位置：</span>
        <ul class="placeul">
            <li><a id="divPlice" href="#">视频连线</a></li>
        </ul>
    </div>
    <table style="margin: 10px; border: 1px solid #999; width: 1000px; margin-top: 10px; margin-left: 150px;" class="tableAddMess">
        <tr>
            <th style="text-align: right; background-color: rgba(0,0,0,0.15);">标题：</th>
            <td colspan="3">
                <input type="text" value="" id="txtTitle" class="inputClass fontSize" style="border: 1px solid #ccc; width: 95%;" maxlength="100" /><label style="color: red;">*</label>
            </td>
        </tr>
        <tr>
            <th style="text-align: right; background-color: rgba(0,0,0,0.15);">开始时间：</th>
            <td style="width: 370px;">
                <input type="text" value="" id="txtTimeStr" class="inputClass fontSize" style="border: 1px solid #ccc; width: 95%;" readonly="true" onclick="WdatePicker({ dateFmt: 'yyyy-MM-dd HH:mm', readOnly: true })" /><label style="color: red;">*</label></td>
            <th style="text-align: right; background-color: rgba(0,0,0,0.15);">状态：</th>
            <td>
                <label class="fontSize">
                    <input type="radio" name="rdoZT" value="0" checked="checked" style="height: initial; width: initial;" />&nbsp;准备中</label>&nbsp;&nbsp;
                <label class="fontSize" style="display: inline-block; margin-left: 1em;">
                    <input type="radio" name="rdoZT" value="1" style="height: initial; width: initial; margin-left: 0;" />&nbsp;进行中</label>&nbsp;&nbsp;
                <label class="fontSize" style="display: inline-block; margin-left: 1em;">
                    <input type="radio" name="rdoZT" value="2" style="height: initial; width: initial; margin-left: 0;" />&nbsp;已结束</label>&nbsp;&nbsp;
                <label class="fontSize" style="display: inline-block; margin-left: 1em;">
                    <input type="radio" name="rdoZT" value="3" style="height: initial; width: initial; margin-left: 0;" />&nbsp;取消</label>&nbsp;&nbsp;

            </td>
            <%--  <th style="text-align: right; background-color: rgba(0,0,0,0.15);">是否录制：</th>
            <td>
                <input type="radio" name="rdoIsLZ" id="rdoLZ" value="1" style="height: initial; width: initial;" />&nbsp;<label for="rdoLZ" class="fontSize">录制</label>&nbsp;&nbsp;
                <input type="radio" name="rdoIsLZ" id="rdoBLZ" value="0" style="height: initial; width: initial; margin-left: 0;" checked="checked" />&nbsp;<label for="rdoBLZ" class="fontSize">不录制</label></td>--%>
        </tr>
        <%-- <tr>
            <th style="text-align: right; background-color: rgba(0,0,0,0.15);">主持人：</th>
            <td colspan="3">
                <select id="txtZCRID" class="inputClass fontSize" style="width: 95%; height: 25px;">
                    <option value="">--请选择--</option>
                </select>
            </td>
        </tr>--%>
        <tr class="DBNone">
            <th style="text-align: right; background-color: rgba(0,0,0,0.15);">显示行列：</th>
            <td title="用来设置视频连线时每页显示参会人员的行数和列数">
                <input type="number" step="1" min="0" max="10" value="" id="txtCHRY_ShowRows" class="inputClass fontSize" style="border: 1px solid #ccc; width: 40px;" onkeyup="CheckIsNumber(this)" onafterpaste="CheckIsNumber(this)" />行&nbsp;
                <input type="number" step="1" min="0" max="3" value="" id="txtCHRY_ShowCols" class="inputClass fontSize" style="border: 1px solid #ccc; width: 40px;" onkeyup="CheckIsNumber(this)" onafterpaste="CheckIsNumber(this)" />列
                <label style="color: red;">（注：行不能大于10，列不能大于3）</label>
            </td>

            <th style="text-align: right; background-color: rgba(0,0,0,0.15);">小视频模式：</th>
            <td>
                <input type="radio" name="rdoXSPMS" id="rdoXSPMS0" value="0" style="height: initial; width: initial; margin-left: 0;" checked="checked" />&nbsp;<label for="rdoXSPMS0" class="fontSize">位置顺序</label>&nbsp;&nbsp;
                <input type="radio" name="rdoXSPMS" id="rdoXSPMS1" value="1" style="height: initial; width: initial;" />&nbsp;<label for="rdoXSPMS1" class="fontSize">层级顺序</label>
            </td>
        </tr>
        <tr class="tr_XSPMS" style="display: none;">
            <%-- <th style="text-align: right; background-color: rgba(0,0,0,0.15);display:none;">视频连线编号：</th>
            <td style="display:none;">
                <input type="text" value="" id="txtRoomId" class="inputClass fontSize" style="border: 1px solid #ccc; width: 95%;" readonly="true" placeholder="保存后，自动生成！" />
            </td>--%>
            <th style="text-align: right; background-color: rgba(0,0,0,0.15);">邀请码：</th>
            <td colspan="3">
                <input type="text" value="" id="txtYQM" class="inputClass fontSize" style="border: 1px solid #ccc; width: 150px;" readonly="true" placeholder="保存后，自动生成！" />
                <label style="color: red;">（注：群众参会使用）</label>
            </td>
        </tr>
        <tr style="display: none;">
            <th style="text-align: right; background-color: rgba(0,0,0,0.15);">创建人：</th>
            <td>
                <input type="text" value="" id="txtCJYH" class="inputClass fontSize" style="border: 1px solid #ccc; width: 95%;" readonly="true" />
            </td>
            <th style="text-align: right; background-color: rgba(0,0,0,0.15);">创建人区域：</th>
            <td>
                <input type="text" value="" id="txtQYMC" class="inputClass fontSize" style="border: 1px solid #ccc; width: 95%;" readonly="true" />
            </td>
        </tr>
    </table>
    <div id="divCHRY" style="max-height: 480px; overflow-y: auto; width: 1024px; margin: 10px; margin-top: 10px; margin-left: 150px;">
        <table class="tablelist" style="font-size: 15px; border: 1px solid #999; width: 1000px;">
            <thead>
                <tr>
                    <th colspan="8" style="text-align: center">视频连线用户</th>
                </tr>
                <tr>
                    <th style="width: 50px; text-align: center;">序号</th>
                    <th style="min-width: 80px; text-align: center;">名称</th>
                    <th style="min-width: 80px; text-align: center;">类型</th>
                    <th style="min-width: 80px; text-align: center;">区域</th>
                    <th style="width: 90px; text-align: center; text-indent: 0;">是否发言</th>
                    <th style="width: 90px; text-align: center; text-indent: 0;">发言顺序</th>
                    <th style="width: 180px; text-align: center;">操作</th>
                </tr>
            </thead>
            <tbody id="tbd1">
            </tbody>
        </table>
    </div>
    <div id="showAddCHRY" style="text-align: right; margin: 10px; margin: auto; width: 1000px; margin-top: 10px;">
        <button class="btnSave btnMove" href="javascript:void(0)" style="position: absolute; left: 150px;" onclick="ClickMoveUp()">上移</button>
        <button class="btnSave btnMove" href="javascript:void(0)" style="position: absolute; left: 222px;" onclick="ClickMoveDwon()">下移</button>
        <label id="labTS" style="color: red; position: absolute; left: 450px; margin-top: 8px;" class="btnMove">（注：选中时添加将添加在选中用户的前面。重复点击取消选中。）</label>
        <a class="btnSave DBNone" href="javascript:void(0)" style="" onclick="ClickSelectDW()">添加单位</a>
        <a class="btnSave" href="javascript:void(0)" style="" onclick="ClickSelectDB()">添加代表</a>
        <a class="btnSave" href="javascript:void(0)" style="" onclick="ClickAddQZ()">添加群众</a>
    </div>
    <div style="text-align: center; margin: 10px; margin: auto; width: 1000px; margin-top: 10px;">
        <a id="btnsave" class="btnSave" href="javascript:void(0)" style="margin-right: 50px; display: none;" onclick="ClickSave(1)">保存</a>
        <a class="btnCancel" href="javascript:void(0)" onclick="window.history.back();">取消</a>
    </div>

    <div id="dd_Mess_addQZ" class="easyui-window" data-options="title:'添加群众',iconCls:'icon-add',maximizable:false,minimizable: false,collapsible: false,modal:false" closed="true" style="width: 400px; height: 160px; padding: 15px 5px 5px 5px; overflow: hidden">
        <table style="margin: 5px auto;">
            <tr>
                <td style="text-align: right;">群众名称：</td>
                <td>
                    <input id="txtQZMC" onpropertychange="textMaxLength(this,20)" oninput="textMaxLength(this,20)" type="text" name="name" class="inputClass" style="width: 230px; border: 1px #ccc solid;" /><label style="color: red; font-weight: 800; font-size: 16px;"> *</label>
                </td>
            </tr>
            <tr style="height: 5px;" />
            <tr>
                <td id="tdAddBtn" style="text-align: center;" colspan="4">
                    <br />
                    <input name="" type="button" class="btnSave" value="确认" onclick="AddQZ()" />&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
                            <input name="" type="button" class="btnCancel" value="取消" onclick="$('#dd_Mess_addQZ').window('close'); " />
                </td>
            </tr>
        </table>
    </div>

    <div id="dbInfo" class="easyui-window" data-options="title:'选择代表',iconCls:'icon-ok',minimizable: false,closed:true,maximizable:false,collapsible:false" style="width: 870px; height: 500px; padding: 5px; margin-bottom: 50px;">
        <div id="divdbinfo" style="display: none;">
            姓名：<input id="txtXM" type="text" class="dfinput" />
            <a class="btnSave" href="javascript:void(0)" onclick="SearchDB();">搜索</a>  <a class="btnCancel" href="javascript:void(0)" onclick="SearchDBReset()">重置</a>
        </div>
        <div>
            <div id="divTree" style="vertical-align: top; display: none; width: 200px; height: 400px; margin-top: 10px; overflow-y: auto;">
                <ul id="ulTree" class="ztree"></ul>
            </div>
            <div id="divDBList" style="vertical-align: top; display: inline-block; margin-top: 10px; overflow-y: auto; height: 400px; width: 850px;">
            </div>
            <div id="divDBTabList" style="vertical-align: top; display: inline-block; margin-top: 10px; height: 400px; width: 850px; display: none;">
                <div style="overflow-y: auto; height: 355px;">
                    <table class="tablelist" style="font-size: 14px;">
                        <thead>
                            <tr>
                                <th id="thxh" style="min-width: 60px; width: 70px; text-align: center;">序号</th>
                                <th style="min-width: 80px;">姓名</th>
                                <th style="min-width: 80px;">届次</th>
                                <th style="min-width: 80px;">区域</th>

                            </tr>
                        </thead>
                        <tbody id="tbdDBList">
                        </tbody>
                    </table>
                </div>
                <div class="pagin">
                    <div class="message">共<i class="blue">&nbsp;<label id="labDataCount">0</label>&nbsp;</i>条记录，当前显示第&nbsp;<i class="blue">&nbsp;<label id="labPageNow">0</label>&nbsp;</i>页</div>
                    <ul class="paginList">
                    </ul>
                </div>
            </div>
        </div>
        <div style="text-align: center; margin-top: 10px; position: absolute; bottom: 10px; width: 100%;">
            <a class="btnSave" href="javascript:void(0)" onclick="QRSelectDB();">确认</a>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
            <a class="btnCancel" href="javascript:void(0)" onclick="$('#dbInfo').window('close');">取消</a>
        </div>
    </div>
    <div id="dwInfo" class="easyui-window" data-options="title:'选择单位',iconCls:'icon-ok',minimizable: false,closed:true,maximizable:false,collapsible:false" style="width: 500px; height: 500px; padding: 5px; margin-bottom: 50px;">

        <div>
            <div id="divTree2" style="vertical-align: top; width: 480px; height: 420px; margin-top: 10px; overflow-y: auto;">
                <ul id="ulTree2" class="ztree"></ul>
            </div>
        </div>
        <div style="text-align: center; margin-top: 10px; position: absolute; bottom: 10px; width: 100%;">
            <a class="btnSave" href="javascript:void(0)" onclick="QRSelectDW();">确认</a>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
            <a class="btnCancel" href="javascript:void(0)" onclick="$('#dwInfo').window('close');">取消</a>
        </div>
    </div>

    <div id="dd_Mess_XGMC" class="easyui-window" data-options="title:'修改名称',iconCls:'icon-add',maximizable:false,minimizable: false,collapsible: false,modal:false" closed="true" style="width: 400px; height: 160px; padding: 15px 5px 5px 5px; overflow: hidden">
        <table style="margin: 5px auto;">
            <tr>
                <td style="text-align: right;">名称：</td>
                <td>
                    <input id="txtMC" onpropertychange="textMaxLength(this,20)" oninput="textMaxLength(this,20)" type="text" name="name" class="inputClass" style="width: 230px; border: 1px #ccc solid;" /><label style="color: red; font-weight: 800; font-size: 16px;"> *</label>
                </td>
            </tr>
            <tr style="height: 5px;" />
            <tr>
                <td style="text-align: center;" colspan="4">
                    <br />
                    <input name="" type="button" class="btnSave" value="确认" onclick="ClickSaveXGMC()" />&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
                            <input name="" type="button" class="btnCancel" value="取消" onclick="$('#dd_Mess_XGMC').window('close'); " />
                </td>
            </tr>
        </table>
    </div>
    <div id="dd_Mess_SetFY" class="easyui-window" data-options="title:'设置发言',iconCls:'icon-add',maximizable:false,minimizable: false,collapsible: false,modal:false" closed="true" style="width: 400px; height: 260px; padding: 15px 5px 5px 5px; overflow: hidden">
        <table style="margin: 5px auto;">
            <tr>
                <td style="text-align: right;">名称：</td>
                <td>
                    <input id="txtSetFY_MC" onpropertychange="textMaxLength(this,20)" oninput="textMaxLength(this,20)" type="text" name="name" class="inputClass" style="width: 230px; border: none;" disabled="disabled" />
                </td>
            </tr>
            <tr style="height: 15px;" />
            <tr>
                <td style="text-align: right;">是否发言：</td>
                <td>
                    <label>
                        <input type="radio" value="1" name="rdoIsFY" onchange="IsFYChange()" />发言</label>
                    &nbsp;&nbsp;&nbsp;&nbsp;
                     <label>
                         <input type="radio" value="0" name="rdoIsFY" onchange="IsFYChange()" />不发言</label>
                </td>
            </tr>
            <tr style="height: 15px;" />
            <tr>
                <td style="text-align: right;">发言顺序：</td>
                <td>
                    <input id="txtSetFY_FYSX" type="number" onpropertychange="textMaxLength(this,4);IsNumber(this);" oninput="textMaxLength(this,4);IsNumber(this);" class="inputClass" style="width: 230px; border: 1px #ccc solid;" />
                </td>
            </tr>
            <tr style="height: 5px;" />
            <tr>
                <td style="text-align: center;" colspan="4">
                    <br />
                    <input name="" type="button" class="btnSave" value="确认" onclick="ClickSaveSetFY()" />&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
                            <input name="" type="button" class="btnCancel" value="取消" onclick="$('#dd_Mess_SetFY').window('close'); " />
                </td>
            </tr>
        </table>
    </div>
        </div>
    <script>
        var isGetQY = false;
        var GetQYBH = uModel.QYBH;
        // 将区域数据转换为tree
        function ConvertQYList() {
            // Tree 配置
            if (isGetQY == true) {
                return;
            }
            isGetQY = true;

            ApiAjax("<%=AUC.QYList%>", function (res) {
                var tbContent1 = "";
                if (res.Code == 0) {
                    var QYData = new Array();
                    for (var i = 0; i < res.Data.length; i++) {
                        QYData.push({ RangeID: res.Data[i].QYBH, RangeName: res.Data[i].MC });
                        AddQYData(QYData, res.Data[i]);
                    }
                    BingTree1(QYData);
                    BingTree2(QYData);
                } else {
                    layMsg(res.Msg);
                }
                $("#divQGRDDB").html(tbContent1);
            }, { QYBH: uModel.QYBH }, "get");


        }

        function AddQYData(QYData, temp) {
            if (temp.Child == null) {
                return;
            }
            for (var i = 0; i < temp.Child.length; i++) {
                QYData.push({ RangeID: temp.Child[i].QYBH, RangeName: temp.Child[i].MC });
                AddQYData(QYData, temp.Child[i]);
            }
        }

        //设置树形
        function BingTree1(res) {
            var setting = {
                view: {
                    selectedMulti: false
                },
                check: {
                    enable: false
                },
                data: {
                    simpleData: {
                        enable: true
                    }
                },
                edit: {
                    drag: false, // 禁止拖动
                    enable: true,
                    showRemoveBtn: false,
                    showRenameBtn: false,
                    //removeTitle: "删除",
                    //renameTitle: "重命名"
                },
                callback: {
                    onClick: function (event, treeId, treeNode) {
                        GetQYBH = treeNode.id;
                        GetDBList();
                    },
                    onRename: function (event, treeId, treeNode, isCancel) {
                        ////////////////////修改////////////////////////////

                        ////////////////////////////////////////////////
                    },
                    onRemove: function (event, treeId, treeNode) {
                        ////////////////////删除////////////////////////////

                        ////////////////////////////////////////////////
                    }
                }
            };

            var zNodes = new Array();
            var temp = new Array();
            temp['id'] = "0";
            temp['name'] = "全部";
            temp['pId'] = "";
            zNodes.push(temp);
            for (var i = 0; i < res.length; i++) {
                var code = res[i].RangeID;
                //if (uModel.QYBH != "00") {
                //    if (code.indexOf(uModel.QYBH) != 0) {//区域编号的前两位，不等于用户区域的不显示
                //        continue;
                //    }
                //}
                var temp = new Array();
                if (code == "00") { // 省
                    temp['id'] = code,
                        temp['name'] = res[i].RangeName,
                        temp['pId'] = ""//,
                    //temp['open'] = true
                } else if (code.length == 2) {  // 市
                    temp['id'] = code,
                        temp['name'] = res[i].RangeName,
                        temp['pId'] = "00"//,
                    // temp['open'] = false
                } else if (code.length == 4) { // 区
                    temp['id'] = code,
                        temp['name'] = res[i].RangeName,
                        temp['pId'] = code.substring(0, 2)//,
                    //temp['open'] = false
                } else if (code.length == 6) { // 乡镇
                    temp['id'] = code,
                        temp['name'] = res[i].RangeName,
                        temp['pId'] = code.substring(0, 4)//,
                    // temp['open'] = false
                }
                if (typeof (temp['name']) != "undefined") {
                    zNodes.push(temp);
                }
            }

            // 初始化
            var treeObj = $.fn.zTree.init($("#ulTree"), setting, zNodes);
            // 默认展开第一级
            var nodes = treeObj.getNodes();
            if (nodes.length > 0) {
                for (var i = 0; i < nodes.length; i++) {
                    treeObj.expandNode(nodes[i], true, false, false);
                }
            }
        }

        var zTreeObj2 = "";
        //设置树形
        function BingTree2(res) {
            var setting = {
                view: {
                    selectedMulti: false
                },
                check: {
                    //enable需要设置为true
                    enable: true,
                    //样式设置为checkbox 复选框 也可以设置为单选框 radioButton
                    chkStyle: 'checkbox',
                    //Y-勾选节点
                    //N-取消勾选
                    //p-parent 是否关联父节点
                    //s-sun 是否关联子节点
                    chkboxType: {
                        'Y': '',
                        'N': ''
                    },
                },
                data: {
                    simpleData: {
                        enable: true
                    }
                },
                edit: {
                    drag: false, // 禁止拖动
                    enable: true,
                    showRemoveBtn: false,
                    showRenameBtn: false,
                    //removeTitle: "删除",
                    //renameTitle: "重命名"
                },
                callback: {
                    onClick: function (event, treeId, treeNode) {

                    },
                    onRename: function (event, treeId, treeNode, isCancel) {
                        ////////////////////修改////////////////////////////

                        ////////////////////////////////////////////////
                    },
                    onRemove: function (event, treeId, treeNode) {
                        ////////////////////删除////////////////////////////

                        ////////////////////////////////////////////////
                    }
                }
            };

            var zNodes = new Array();
            //var temp = new Array();
            //temp['id'] = "0";
            //temp['name'] = "全部";
            //temp['pId'] = "";
            //zNodes.push(temp);
            for (var i = 0; i < res.length; i++) {
                var code = res[i].RangeID;
                //if (uModel.QYBH != "00") {
                //    if (code.indexOf(uModel.QYBH) != 0) {//区域编号的前两位，不等于用户区域的不显示
                //        continue;
                //    }
                //}
                var temp = new Array();
                if (code == "00") { // 省
                    temp['id'] = code,
                        temp['name'] = res[i].RangeName,
                        temp['pId'] = ""//,
                    //temp['open'] = true
                } else if (code.length == 2) {  // 市
                    temp['id'] = code,
                        temp['name'] = res[i].RangeName,
                        temp['pId'] = "00"//,
                    // temp['open'] = false
                } else if (code.length == 4) { // 区
                    temp['id'] = code,
                        temp['name'] = res[i].RangeName,
                        temp['pId'] = code.substring(0, 2)//,
                    //temp['open'] = false
                } else if (code.length == 6) { // 乡镇
                    temp['id'] = code,
                        temp['name'] = res[i].RangeName,
                        temp['pId'] = code.substring(0, 4)//,
                    // temp['open'] = false
                }
                if (typeof (temp['name']) != "undefined") {
                    zNodes.push(temp);
                }
            }

            // 初始化
            zTreeObj2 = $.fn.zTree.init($("#ulTree2"), setting, zNodes);
            // 默认展开第一级
            var nodes = zTreeObj2.getNodes();
            if (nodes.length > 0) {
                for (var i = 0; i < nodes.length; i++) {
                    zTreeObj2.expandNode(nodes[i], true, false, false);
                }
            }
        }
    </script>
</body>
</html>
