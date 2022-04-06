$(function () {
    var element = "";
    var layer = "";
    layui.use(['form', 'element'], function () {  //如果只加载一个模块，可以不填数组。如：layui.use('form')
        layer = layui.layer;
        element = layui.element;

        element.on('tab', function (data) {
            //console.log(this); //当前Tab标题所在的原始DOM元素
            //console.log(data.index); //得到当前Tab的所在下标
            //console.log(data.elem); //得到当前的Tab大容器
            $("#ulMenu .layui-this").removeClass("layui-this");
            $("#" + $(this).attr("lay-id") + "").addClass("layui-this");
        });
        LoadShowPage();
    });

    //触发事件
    var tab = {
        tabAdd: function (title, url, id) {
            var H = getSetIframeH();
            //新增一个Tab项
            element.tabAdd('xbs_tab', {
                //title: title
                title: '<i class="layui-icon"></i>&nbsp;<cite>' + title + '</cite>'
              , content: '<iframe tab-id="' + id + '" style="overflow-x: auto;height:' + H + 'px;" frameborder="0" src="' + url + '" scrolling="yes" class="x-iframe"></iframe>'
              , id: id
            })
        }
          , tabDelete: function (othis) {
              //删除指定Tab项
              element.tabDelete('xbs_tab', '44'); //删除：“商品管理”


              othis.addClass('layui-btn-disabled');
          }
          , tabChange: function (id) {
              //切换到指定Tab项
              element.tabChange('xbs_tab', id); //切换到：用户管理

          }
    };

    $('.container .left_open i').click(function (event) {
        if ($('.left-nav').css('left') == '0px') {
            $('.left-nav').animate({ left: '-221px' }, 100);
            $('.page-content').animate({ left: '0px' }, 100);
            $('.page-content-bg').hide();
        } else {
            $('.left-nav').animate({ left: '0px' }, 100);
            $('.page-content').animate({ left: '221px' }, 100);
            if ($(window).width() < 768) {
                $('.page-content-bg').show();
            }
        }

    });

    $('.page-content-bg').click(function (event) {
        $('.left-nav').animate({ left: '-221px' }, 100);
        $('.page-content').animate({ left: '0px' }, 100);
        $(this).hide();
    });

    $('.layui-tab-close').click(function (event) {
        $('.layui-tab-title li').eq(0).find('i').remove();
    });

    $("tbody.x-cate tr[fid!='0']").hide();
    // 栏目多级显示效果
    $('.x-show').click(function () {
        if ($(this).attr('status') == 'true') {
            $(this).html('&#xe625;');
            $(this).attr('status', 'false');
            cateId = $(this).parents('tr').attr('cate-id');
            $("tbody tr[fid=" + cateId + "]").show();
        } else {
            cateIds = [];
            $(this).html('&#xe623;');
            $(this).attr('status', 'true');
            cateId = $(this).parents('tr').attr('cate-id');
            getCateId(cateId);
            for (var i in cateIds) {
                $("tbody tr[cate-id=" + cateIds[i] + "]").hide().find('.x-show').html('&#xe623;').attr('status', 'true');
            }
        }
    })

    //左侧菜单效果
    // $('#content').bind("click",function(event){
    $('.left-nav #nav li').click(function (event) {

        if ($(this).children('.sub-menu').length) {
            if ($(this).hasClass('open')) {
                $(this).removeClass('open');
                $(this).find('.nav_right').html('&#xe697;');
                $(this).children('.sub-menu').stop().slideUp();
                $(this).siblings().children('.sub-menu').slideUp();
            } else {
                $(this).addClass('open');
                $(this).children('a').find('.nav_right').html('&#xe6a6;');
                $(this).children('.sub-menu').stop().slideDown();
                $(this).siblings().children('.sub-menu').stop().slideUp();
                $(this).siblings().find('.nav_right').html('&#xe697;');
                $(this).siblings().removeClass('open');
            }
        } else {

            var url = $(this).children('a').attr('_href');
            var title = $(this).find('cite').html();
            var index = $('.left-nav #nav li').index($(this));

            for (var i = 0; i < $('.x-iframe').length; i++) {
                if ($('.x-iframe').eq(i).attr('tab-id') == index + 1) {
                    tab.tabChange(index + 1);
                    event.stopPropagation();
                    return;
                }
            };

            tab.tabAdd(title, url, index + 1);
            tab.tabChange(index + 1);
        }
        event.stopPropagation();

    })


    //重写左侧菜单效果
    // $('#content').bind("click",function(event){
    $('#ulMenu.layui-nav-tree li').click(function (event) {

        if ($(this).children('.sub-menu').length) {
            if ($(this).hasClass('open')) {
                $(this).removeClass('open');
                $(this).find('.nav_right').html('&#xe697;');
                $(this).children('.sub-menu').stop().slideUp();
                $(this).siblings().children('.sub-menu').slideUp();
                $(this).children('.sub-menu').hide();
            } else {
                $(this).addClass('open');
                $(this).children('a').find('.nav_right').html('&#xe6a6;');
                $(this).children('.sub-menu').stop().slideDown();
                $(this).siblings().children('.sub-menu').stop().slideUp();
                $(this).siblings().find('.nav_right').html('&#xe697;');
                $(this).siblings().removeClass('open');
                $(this).children('.sub-menu').children("li").show();

            }
            $(this).removeClass("layui-this");
        } else {

            var url = $(this).children('a').attr('data-url');
            var id = $(this).attr('id');
            var title = $(this).find('cite').html();
            var index = $('#ulMenu.layui-nav-tree li').index($(this));

            for (var i = 0; i < $('.x-iframe').length; i++) {
                if ($('.x-iframe').eq(i).attr('tab-id') == id) {
                    tab.tabChange(id);
                    event.stopPropagation();
                    return;
                }
            };

            if (url.indexOf("?") != -1) {
                var strUrl = url.split("?")[0];
                var strParameter = url.split("?")[1];
                url = strUrl + "?v=" + Math.random() + "&" + strParameter;
            } else {
                url = url + "?v=" + Math.random();
            }
            tab.tabAdd(title, url, id);
            tab.tabChange(id);
        }

        event.stopPropagation();

    })


})
var cateIds = [];
function getCateId(cateId) {
    $("tbody tr[fid=" + cateId + "]").each(function (index, el) {
        id = $(el).attr('cate-id');
        cateIds.push(id);
        getCateId(id);
    });
}

function getSetIframeH() {
    var h = $(window).height() - 108;
    $(".x-iframe").height(h);
    return h;
}

function LoadShowPage() {
    $("#ulMenu .layui-nav-item:visible").first().click();//要加载列表的第一个
}