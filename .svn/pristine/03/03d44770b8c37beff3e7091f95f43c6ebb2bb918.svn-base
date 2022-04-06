<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="DoDL.aspx.cs" Inherits="VideoConnectionWeb.DoDL" %>

<!DOCTYPE html>
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
    <meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
    <title>视频连线</title>
    <script type="text/javascript" src="/js/jquery-3.6.0.min.js"></script>
    <script src="js/layui/layCommon.js"></script>
    <script src="js/layui/layui.js"></script>
    <link href="js/layui/css/layui.css" rel="stylesheet" />
    <link href="js/layui/css/xadmin.css" rel="stylesheet" />
    <style>
        .loginbox {
        }

            .loginbox ul {
            }

                .loginbox ul li {
                    font-family: "宋体";
                }

        span {
            margin: 0;
            padding: 0;
            display: block;
        }
    </style>

    <script type="text/javascript">
        if (window != top) top.location.href = location.href;
        var chk;

        $(function () {
            $('.loginbox').css({ 'position': 'absolute', 'left': ($(window).width() - 692) / 2 });
            $(window).resize(function () {
                $('.loginbox').css({ 'position': 'absolute', 'left': ($(window).width() - 692) / 2 });
            })
            sessionStorage.clear();
        });

        function LoginCheck() {
            var userName = $("#txtUserName").val();
            var pwd = $("#txtPwd").val();
            var checkcode = $("#txtYZM").val();
            if (userName == "") {
                layAlert("请输入用户名！");
                return;
            }
            if (pwd == "") {
                layAlert("请输入密码！");
                return;
            }
            if (checkcode == "") {
                layAlert("请输入验证码！");
                return;
            }
    
            $.ajax({
                url: 'Handler/LoginHandler.ashx',
                data: {
                    'LoginName': userName,
                    'Password': pwd,
                    'CheckCode': checkcode,
                    'type':"Login",
                },
                type: "post",
                dataType: 'json',
                async: true,
                beforeSend: function () {
                    layLoading();
                },
                success: function (res) {
                    change();//防止暴力破解，刷新
                    $("#CheckCode").val("");
                    if (res.Code == 0) {
                        
                        sessionStorage.setItem("User", JSON.stringify(res.Data));
                        location.href = "menu/VideoConference/VideoConferenceList.aspx";
                    } else {
                        layAlert(res.Msg);
                    }
                    layLoadEnd();
                },
                error: function (res) {
                    change();
                    console.error(res);
                    layLoadEnd();
                }
            });
        }

        function test(snCodeText) {
            chk = snCodeText;
            $("#CheckCode").val("");
        }

        document.onkeydown = function (event) {
            if (!event) {
                event = window.event;
            }
            if (event.keyCode == 13) {
                if ($(".layui-layer").length == 0) {
                    $("#btnLogin").click();

                }
            }
        }
    </script>

</head>


<body class="login-bg">
    <div class="login layui-anim layui-anim-up">
        <div class="message">视频连线</div>
        <div id="darkbannerwrap" style="margin-bottom: 0;"></div>

        <div class="layui-tab layui-tab-brief" lay-filter="docDemoTabBrief">
            <form method="post" class="layui-form">
                <input id="txtUserName" name="username" placeholder="登录账号" type="text" value="" lay-verify="required" class="layui-input" />
                <hr class="hr15" />
                <input id="txtPwd" name="password" lay-verify="required" placeholder="密码" value="" type="password" class="layui-input" />
                <hr class="hr15" />
                <div>
                    <input id="txtYZM" placeholder="验证码" type="text" value="" maxlength="4" class="layui-input" style="display: inline-block; width: 150px;" />
                    <img id="myCheckCode" src="image.aspx" />
                    <a href="javascript:change();">换一张</a>
                    <script>
                        function change() {
                            var img = document.getElementById("myCheckCode");
                            img.src = img.src + '?';
                        }
                    </script>
                </div>
                <hr class="hr15" />
                <a id="btnLogin" class="layui-btn" onclick="LoginCheck()" style="width: 100%;">登录</a>
                <hr class="hr20" />
            </form>
        </div>
    </div>
</body>
</html>
