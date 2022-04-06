
/*弹出层*/
/*
    参数解释：
    title   标题
    url     请求的url
    id      需要操作的数据id
    w       弹出层宽度（缺省调默认值）
    h       弹出层高度（缺省调默认值）
    isfull  是否全屏  
    cancelMsg 是否显示关闭提示
*/
function x_admin_show(title, url, w, h, isfull, cancelMsg) {
    if (title == null || title == '') {
        title = false;
    };
    if (url == null || url == '') {
        url = "404.html";
    };
    if (url.indexOf("?") != -1) {
        var strUrl = url.split("?")[0];
        var strParameter = url.split("?")[1];
        url = strUrl + "?v=" + Math.random() + "&" + strParameter;
    } else {
        url = url + "?v=" + Math.random();
    }

    if (w == null || w == '') {
        w = ($(window).width() * 0.9);
    };
    if (h == null || h == '') {
        h = ($(window).height() - 50);
    };
    
    var area = [w + 'px', h + 'px'];
    if (isfull) {
        area = ['99%', '99%'];
    }
    var tempIndex = layer.open({
        type: 2,
        area: area,
        fix: false, //不固定
        maxmin: false,
        shadeClose: false,
        shade: 0.4,
        title: title,
        content: url,
        cancel: function (index) {
            if (cancelMsg) {
                layConfirm("确定关闭吗?", function (res) {
                    if (res) {
                        layer.close(index);
                    } else {

                    }
                });
                return false;
            } else {
                return true;
            }
        }
        //end: function () {

        //}
    });
    if (isfull) {//弹出最大化
        layer.full(tempIndex);

    }
}

/*关闭弹出框口*/
function x_admin_close(ty) {
    if (ty == 1) {
        layConfirm("确定关闭吗?", function (res) {
            if (res) {
                var index = parent.layer.getFrameIndex(window.name);
                parent.layer.close(index);
            }
        });
    } else {
        var index = parent.layer.getFrameIndex(window.name);
        parent.layer.close(index);
    }
}

var LoadingLayero = "";
function layLoading(loadstr) {
    if (loadstr) {
        if (LoadingLayero != "") {
            LoadingLayero.find('.layui-layer-content').text(loadstr);
        } else {
            var index = layer.load(2, {
                content: loadstr, shade: [0.5, '#f5f5f5'], success: function (layero) {
                    layero.find('.layui-layer-content').css('padding-top', '8px');
                    layero.find('.layui-layer-content').css('padding-left', '40px');
                    layero.find('.layui-layer-content').css('width', '200px');
                    //layero.find('.layui-layer-content').css('background-color', '#00ff90');
                    //layero.find('.layui-layer-content').text(loadstr);
                    LoadingLayero = layero;
                }
            })
        }
    } else {
        var index = layer.load(2, { shade: [0.5, '#f5f5f5'] });
    }

}

function layLoadEnd() {
    LoadingLayero = "";
    layer.closeAll('loading'); //关闭加载层
}



function layAlert(str, fn) {
    try {
        var layAlertKeyFn = "";//监控按下回车事件，实现回车确认
        if (fn) {
            var index = layer.alert(str, {
                icon: 0, closeBtn: 0
                , success: function () {
                    layAlertKeyFn = function (event) {
                        if (event.keyCode === 13) {
                            $(".layui-layer-btn0").click();
                            return false; //阻止系统默认回车事件
                        } else if (event.keyCode == 27) {
                            $(".layui-layer-btn1").click();
                            return false;
                        }
                    };
                    $(document).on('keydown', layAlertKeyFn); //监听键盘事件，关闭层
                }, end: function () {
                    $(document).off('keydown', layAlertKeyFn); //解除键盘关闭事件
                }
            }, function (layIndex) {
                layer.close(layIndex);
                fn();
            });
        } else {
            layer.alert(str);
        }
    } catch (e) {

    }
}
function layMsg(str) {
    //提示层
    layer.msg(str);
}


///询问框
///str：显示的信息
///yesFn：确认 调用的方法
///yesFn：取消 调用的方法
//notClose：传入true代表不关闭弹窗
function layConfirm(str, yesFn, noFn, notClose) {
    var layConfirmKeyFn = "";//监控按下回车事件，实现回车确认
    //询问框
    layer.confirm(str, {
        btn: ['确认', '取消'] //按钮
        , success: function () {
            layConfirmKeyFn = function (event) {
                if (event.keyCode === 13) {
                    $(".layui-layer-btn0").click();
                    return false; //阻止系统默认回车事件
                } else if (event.keyCode == 27) {
                    $(".layui-layer-btn1").click();
                    return false;
                }
            };
            $(document).on('keydown', layConfirmKeyFn); //监听键盘事件，关闭层
        }, end: function () {
            $(document).off('keydown', layConfirmKeyFn); //解除键盘关闭事件
        }
    }, function (index) {
        try {
            yesFn(true);
        }
        catch (err) {
            console.log(err);
        }
        if (!notClose) {
            layer.close(index);
        }
    }, function (index) {
        if (noFn) {
            noFn(false);
        }
        if (!notClose) {
            layer.close(index);
        }
    });
}

function InitialLayPage(paginId, count, limit, pageNum, fn) {
    //自定义首页、尾页、上一页、下一页文本
    if (count == 0) {
        $("#" + paginId).hide();
    } else {
        $("#" + paginId).show();
        layui.use(['laypage', 'layer'], function () {
            var laypage = layui.laypage, layer = layui.layer;
            laypage.render({
                elem: paginId
                , curr: pageNum
                , count: count
                , limit: limit
                , first: '首页'
                , last: '尾页'
                , prev: '<em>上一页</em>'
                , next: '<em>下一页</em>'
                , layout: ['count', 'prev', 'page', 'next', 'skip']
                , jump: function (obj, first) {
                    //obj包含了当前分页的所有参数，比如：
                    console.log(obj.curr); //得到当前页，以便向服务端请求对应页的数据。
                    console.log(obj.limit); //得到每页显示的条数
                    //首次不执行
                    if (!first) {
                        pageNum = obj.curr;
                        fn(obj, first);
                    }
                }
            });
        });
    }
}

///layui弹出页面层（弹出div）
///title：标题  elem：弹出的jq元素  w：宽  h：高 
///yesfn1: 点击 确定 关闭调用的方法 
///closefn: 点击 取消 关闭调用的方法
///closefn: 点击x关闭的方法
function layShowPage(title, elem, w, h, yesfn1, closefn1, closefn2) {
    var tempIndex = layer.open({
        title: title
        , content: elem
        , type: 1
        , btn: ['确定', '取消']
        , btnAlign: 'c'
        , area: [w + 'px', h + 'px']
        , yes: function (index, layero) {
            //按钮【按钮一】的回调
            if (yesfn1) {
                yesfn1();
            }

        }
        , btn2: function (index, layero) {
            //按钮【按钮二】的回调
            if (closefn1) {
                closefn1();
            }
            layer.close(index);
            //return false 开启该代码可禁止点击该按钮关闭
        }
        , cancel: function () {
            //右上角关闭回调
            if (closefn2) {
                closefn2();
            }
            //layer.close(tempIndex);
            //return false 开启该代码可禁止点击该按钮关闭
        }, end: function () {
            elem.hide();
        }
    });
    return tempIndex;
}

//关闭所有页面层
function ClosePage() {
    layer.closeAll('page'); //关闭所有页面层
}

/*弹出层*/
/*
    参数解释：
    title   标题
    url     请求的url
    id      需要操作的数据id
    w       弹出层宽度（缺省调默认值）
    h       弹出层高度（缺省调默认值）
*/
function layShowIframe(title, url, w, h, isfull, cancelMsg) {
    if (title == null || title == '') {
        title = false;
    };
    if (url == null || url == '') {
        url = "404.html";
    };
    if (url.indexOf("?") != -1) {
        var strUrl = url.split("?")[0];
        var strParameter = url.split("?")[1];
        url = strUrl + "?v=" + Math.random() + "&" + strParameter;
    } else {
        url = url + "?v=" + Math.random();
    }

    if (w == null || w == '') {
        w = ($(window).width() * 0.9);
    };
    if (h == null || h == '') {
        h = ($(window).height() - 50);
    };
    var tempIndex = layer.open({
        type: 2,
        area: [w + 'px', h + 'px'],
        fix: false, //不固定
        maxmin: false,
        shadeClose: false,
        shade: 0.4,
        title: title,
        content: url,
        cancel: function (index) {
            if (cancelMsg) {
                layConfirm("确定关闭吗?", function (res) {
                    if (res) {
                        layer.close(index);
                    } else {

                    }
                });
                return false;
            } else {
                return true;
            }
        }
        //end: function () {

        //}
    });
    if (isfull) {//弹出最大化
        layer.full(tempIndex);

    }
}

/*关闭弹出框口*/
function CloseLayIframe(ty) {
    if (ty == 1) {
        layConfirm("确定关闭吗?", function (res) {
            if (res) {
                var index = parent.layer.getFrameIndex(window.name);
                parent.layer.close(index);
            }
        });
    } else {
        var index = parent.layer.getFrameIndex(window.name);
        parent.layer.close(index);
    }
}

//去掉所有空格
function StrTrimAllSpace(str) {
    if (str == null || str == "") {
        return "";
    }
    return str.replace(/\s/g, "");
}

function getvl(name) {
    var reg = new RegExp("(^|\\?|&)" + name + "=([^&]*)(\\s|&|$)", "i");
    if (reg.test(location.href)) return unescape(RegExp.$2.replace(/\+/g, " "));
    return "";
};

// 判断字符串是否为空
function IsNull(value) {
    var result = false;
    if (value == "" || value == null || typeof (value) == "undefined") {
        result = true;
    } else {
        result = false;
    }
    return result;
}


//url:路径
//fn：回调函数
//data:请求数据
//type：请求类型 默认post
function ApiAjax(purl, pfn, pdata, ptype, pasync, pNoShow) {
    var type = "post";
    var data = {};
    var async = true;
    var noShow = false;
    if (pdata) {
        if (pdata != "") {
            data = pdata;
        }
    }
    if (ptype) {
        if (pdata != "") {
            type = ptype;
        }
    }
    if (pasync == false) {
        async = false;
    }
    if (pNoShow === true) {
        noShow = true;
    }
    $.ajax({
        url: purl,
        data: data,
        type: type,
        dataType: 'json',
        async: async,
        beforeSend: function (XMLHttpRequest) {
            XMLHttpRequest.setRequestHeader("Token", "abc123sfkj");
            if (noShow == false) {
                layLoading();
            }
        },
        success: function (res) {
            if (res == null) {
                if (noShow == false) {
                    layLoadEnd();
                }
            }
            if (pfn) {
                pfn(res);
            }
            if (noShow == false) {
                layLoadEnd();
            }
        },
        error: function (res) {
            //var a = res;
            console.error(purl);
            console.error(res);
            alert(res);
            if (noShow == false) {
                layLoadEnd();
            }
        }
    });
}

//没有登录返回登录页面
function GetUserModel() {
    var uModel = jQuery.parseJSON(sessionStorage.User);
    if (uModel == null || uModel == "") {
        alert("登录超时，请重新登录！");
        location.href = window.location.origin = "/DoDL.aspx";
    }
    return uModel;
}

/// <summary>
/// 限定输入框长度
/// </summary>
/// <param name="field">控件</param>
/// <param name="maxlimit">最大输入数</param>
function textMaxLength(field, maxlimit) {
    var charcnt = field.value.length;
    // trim the extra text
    if (charcnt > maxlimit) {
        field.value = field.value.substring(0, maxlimit);
    }
}