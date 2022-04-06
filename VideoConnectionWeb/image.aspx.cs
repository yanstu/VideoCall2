﻿using System;
using System.Collections.Generic;
using System.Drawing;
using System.IO;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace VideoConnectionWeb
{
    public partial class image : System.Web.UI.Page
    {
        Random ran = new Random();
        protected void Page_Load(object sender, EventArgs e)
        {
            string str = getRandomValidate(4);
            Session["myCheckCode"] = str; //验证码写入Session
            getImageValidate(str);
        }

        //得到随机字符串,长度自己定义
        private string getRandomValidate(int len)
        {
            //int num;
            //int tem;
            string rtuStr = "";

            Random rad = new Random();//实例化随机数产生器rad；

            int value = rad.Next(1000, 10000);//用rad生成大于等于1000，小于等于9999的随机数；

            rtuStr = value.ToString();
            //for (int i = 0; i < len; i++)
            //{
            //    num = ran.Next();
            //    /*
            //     * 这里可以选择生成字符和数字组合的验证码
            //     */
            //    //if (i % 2 == 1)
            //    //    tem = num % 10 + '0';//生成数字
            //    //else
            //    tem = num % 26 + 'A';//生成字符
            //    rtuStr += Convert.ToChar(tem).ToString();
            //}
            return rtuStr;
        }
        //生成图像
        private void getImageValidate(string strValue)
        {
            //string str = "OO00"; //前两个为字母O，后两个为数字0
            int width = Convert.ToInt32(strValue.Length * 25);    //计算图像宽度
            Bitmap img = new Bitmap(width, 37);
            Graphics gfc = Graphics.FromImage(img);           //产生Graphics对象，进行画图
            gfc.Clear(Color.White);
            drawLine(gfc, img);
            //写验证码，需要定义Font
            Font font = new Font("arial", 18, FontStyle.Regular);
            System.Drawing.Drawing2D.LinearGradientBrush brush =
                new System.Drawing.Drawing2D.LinearGradientBrush(new Rectangle(0, 0, img.Width, img.Height), Color.Black, Color.Black, 2.5f, true);
            gfc.DrawString(strValue, font, brush, 15, 5);
            drawPoint(img);
            //gfc.DrawRectangle(new Pen(Color.DarkBlue), 0, 0, img.Width - 1, img.Height - 1); 不要边框
            //将图像添加到页面
            MemoryStream ms = new MemoryStream();
            img.Save(ms, System.Drawing.Imaging.ImageFormat.Gif);
            //更改Http头
            Response.ClearContent();
            Response.ContentType = "image/gif";
            Response.BinaryWrite(ms.ToArray());
            //Dispose
            gfc.Dispose();
            img.Dispose();
            Response.End();
        }

        private void drawLine(Graphics gfc, Bitmap img)
        {
            //选择画10条线,也可以增加，也可以不要线，只要随机杂点即可
            for (int i = 0; i < 10; i++)
            {
                int x1 = ran.Next(img.Width);
                int y1 = ran.Next(img.Height);
                int x2 = ran.Next(img.Width);
                int y2 = ran.Next(img.Height);
                gfc.DrawLine(new Pen(Color.RosyBrown), x1, y1, x2, y2);      //注意画笔一定要浅颜色，否则验证码看不清楚
            }
        }
        private void drawPoint(Bitmap img)
        {
            /*
            //选择画100个点,可以根据实际情况改变
            for (int i = 0; i < 100; i++)
            {
                int x = ran.Next(img.Width);
                int y = ran.Next(img.Height);
                img.SetPixel(x,y,Color.FromArgb(ran.Next()));//杂点颜色随机
            }
             */
            int col = ran.Next();//在一次的图片中杂店颜色相同
            for (int i = 0; i < 100; i++)
            {
                int x = ran.Next(img.Width);
                int y = ran.Next(img.Height);
                img.SetPixel(x, y, Color.FromArgb(col));
            }


        }
    }
}