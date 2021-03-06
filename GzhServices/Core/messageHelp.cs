﻿using System;
using System.Collections.Generic;
using System.Web;
using System.IO;
using System.Text;
using System.Web.Security;
using System.Xml;

namespace GzhServices
{
    /// <summary>
    /// 接受/发送消息帮助类
    /// </summary>
    public class messageHelp
    {
        //返回消息
        public string ReturnMessage(string postStr)
        {
            string responseContent = "";
            XmlDocument xmldoc = new XmlDocument();
            xmldoc.Load(new System.IO.MemoryStream(System.Text.Encoding.GetEncoding("UTF-8").GetBytes(postStr)));
            XmlNode MsgType = xmldoc.SelectSingleNode("/xml/MsgType");
            if (MsgType != null)
            {
                switch (MsgType.InnerText)
                {
                    case "event":
                        responseContent = EventHandle(xmldoc);//事件处理
                        break;
                    case "text":
                        responseContent = TextHandle(xmldoc);//接受文本消息处理
                        break;
                    default:
                        break;
                }
            }
            return responseContent;
        }
        //事件
        public string EventHandle(XmlDocument xmldoc)
        {
            string responseContent = "";
            XmlNode Event = xmldoc.SelectSingleNode("/xml/Event");
            XmlNode EventKey = xmldoc.SelectSingleNode("/xml/EventKey");
            XmlNode ToUserName = xmldoc.SelectSingleNode("/xml/ToUserName");
            XmlNode FromUserName = xmldoc.SelectSingleNode("/xml/FromUserName");
            if (Event != null)
            {
                //菜单单击事件
                if (Event.InnerText.Equals("CLICK"))
                {
                    if (EventKey.InnerText.Equals("wather"))//天气
                    {
                        responseContent = string.Format(ReplyType.Message_Text,
                            FromUserName.InnerText,
                            ToUserName.InnerText,
                            DateTime.Now.Ticks,
                            "<a href=\"http://www.weather.com.cn/weather/101190404.shtml\">点击查看最近天气</a>");
                    }
                    else if (EventKey.InnerText.Equals("aboutus"))//关于我
                    {
                        responseContent = string.Format(ReplyType.Message_Text,
                            FromUserName.InnerText,
                            ToUserName.InnerText,
                            DateTime.Now.Ticks,
                            "我是陈有才，感谢关注");
                    }
                    else if (EventKey.InnerText.Equals("xiaohua"))//笑话
                    {
                        responseContent = string.Format(ReplyType.Message_Text,
                            FromUserName.InnerText,
                            ToUserName.InnerText,
                            DateTime.Now.Ticks,
                            "这个笑话真的不好笑");
                    }
                }
            }
            return responseContent;
        }

        //接受文本消息
        public string TextHandle(XmlDocument xmldoc)
        {
            try
            {
                string responseContent = "";
                XmlNode ToUserName = xmldoc.SelectSingleNode("/xml/ToUserName");
                XmlNode FromUserName = xmldoc.SelectSingleNode("/xml/FromUserName");
                XmlNode Content = xmldoc.SelectSingleNode("/xml/Content");
                string resultMessage = "欢迎使用微信公共账号。<a href=\"http://news.qq.com\">点击查看最近新闻</a>";
                if (Content != null)
                {
                    if (Content.InnerText.Contains("天气"))
                    {
                        resultMessage = "<a href=\"http://www.weather.com.cn/weather/101190404.shtml\">点击查看最近天气</a>";
                        responseContent = string.Format(ReplyType.Message_Text,
                            FromUserName.InnerText,
                            ToUserName.InnerText,
                            DateTime.Now.Ticks,
                            resultMessage);
                    }
                    else if (Content.InnerText.Contains("新闻"))
                    {
                        responseContent = string.Format(ReplyType.Message_News_Main,
                            FromUserName.InnerText,
                            ToUserName.InnerText,
                            DateTime.Now.Ticks,
                            "1", string.Format(ReplyType.Message_News_Item, "最新新闻", "了解最近的新闻",
                             "http://mat1.gtimg.com/news/news2017/img/logo.png",
                             "http://news.qq.com/"));
                    }
                    else
                    {
                        responseContent = string.Format(ReplyType.Message_Text,
                            FromUserName.InnerText,
                            ToUserName.InnerText,
                            DateTime.Now.Ticks,
                            resultMessage);
                    }
                }
                return responseContent;
            }
            catch (Exception ex)
            {
                WriteLog(ex.Message);
                return "error";
            }
        }

        //写入日志
        public void WriteLog(string text)
        {
            StreamWriter sw = new StreamWriter(HttpContext.Current.Server.MapPath(".") + "\\log\\log_" + DateTime.Now.ToString("yyyyMMdd") + ".txt", true);
            sw.WriteLine(text + "\r\n");
            sw.Close();//写入
        }
    }

    //回复类型
    public class ReplyType
    {
        /// <summary>
        /// 普通文本消息
        /// </summary>
        public static string Message_Text
        {
            get
            {
                return @"<xml>
                            <ToUserName><![CDATA[{0}]]></ToUserName>
                            <FromUserName><![CDATA[{1}]]></FromUserName>
                            <CreateTime>{2}</CreateTime>
                            <MsgType><![CDATA[text]]></MsgType>
                            <Content><![CDATA[{3}]]></Content>
                            </xml>";
            }
        }
        /// <summary>
        /// 图文消息主体
        /// </summary>
        public static string Message_News_Main
        {
            get
            {
                return @"<xml>
                            <ToUserName><![CDATA[{0}]]></ToUserName>
                            <FromUserName><![CDATA[{1}]]></FromUserName>
                            <CreateTime>{2}</CreateTime>
                            <MsgType><![CDATA[news]]></MsgType>
                            <ArticleCount>{3}</ArticleCount>
                            <Articles>
                            {4}
                            </Articles>
                            </xml> ";
            }
        }
        /// <summary>
        /// 图文消息项
        /// </summary>
        public static string Message_News_Item
        {
            get
            {
                return @"<item>
                            <Title><![CDATA[{0}]]></Title> 
                            <Description><![CDATA[{1}]]></Description>
                            <PicUrl><![CDATA[{2}]]></PicUrl>
                            <Url><![CDATA[{3}]]></Url>
                            </item>";
            }
        }
    }
}