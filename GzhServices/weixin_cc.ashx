<%@ WebHandler Language="C#" Class="weixin" %>

using System;
using System.Collections;
using System.Collections.Generic;
using System.Security.Cryptography;
using System.Text;
using System.Web;
using System.Xml;
//using ASP;
public class weixin : IHttpHandler
{


    protected HttpContext context;
    protected HttpRequest Request;
    protected HttpResponse Response;


    const string sToken = "weixin";
    const string sAppID = "wxa3da5fcaddf4c8b4";
    const string sEncodingAESKey = "IIOCANJ30sb1u2gRpwEWibJ8t4PHpgORaxq15jkGBJe";



    public void ProcessRequest(HttpContext context)
    {
        this.context = context;
        this.Request = context.Request;
        this.Response = context.Response;

        //公众平台上开发者设置的token, appID, EncodingAESKey
        CheckServer();

        var reqmsg = RequestMessage();
        if (reqmsg == null)
        {
            Response.Write("ERR: fail ");
            return;
        }

        string msgType = (reqmsg["MsgType"] as string ?? string.Empty);
        if (msgType == "")
        {
            msgType = "text";
        }
        if (!string.IsNullOrEmpty(msgType))
        {
            reqmsg["temp"] = reqmsg["ToUserName"];
            reqmsg["ToUserName"] = reqmsg["FromUserName"];
            reqmsg["FromUserName"] = reqmsg["temp"];
        }

        switch (msgType)
        {
            case "text":

                //ResponseTextMessage(textmsg);
                SearchKeywordsAndEchoMessages(reqmsg);
                break;

            case "event":
                ResponseEventMessage(reqmsg);

                break;
            default:
                break;
        }



    }


    void ResponseEventMessage(Hashtable hash)
    {
        try
        {
            string eve = (hash["Event"] as string ?? string.Empty).ToLower().Trim();

            switch (eve)
            {
                //用户未关注时，开始关注
                case "subscribe":

                    if (true)
                    {





                        //var str = "亲，欢迎终于等到你 ！\r\n"
                        //    + "<a href=\"http://www.guo15.com/api/opx.ashx/subscribe?uid=" + HttpUtility.UrlEncode(hash["ToUserName"] as string ?? string.Empty)
                        //    + "\">☞点我继续阅读</a>\r\n"
                        //    + "<a href=\"http://www.guo15.com\">☞进入书库</a>（万部内容随心看，亦可在页面中搜索想要的内容！）\r\n"
                        //    + "<a href=\"http://t.cn/R9HHesV\">☞免费TXT全本下载</a>\r\n"
                        //    + "<a href=\"http://t.cn/R9H8A7y\">☞免费VIP影视大片</a>\r\n"
                        //    + "<a href=\"http://t.cn/R9H8A7y\">☞不可描述的资源</a>\r\n";



                        string str = "直接搜索资源名获取资源！请注意错别字。\r\n"
                                + "1.回复“往期影评”可看经典影评\r\n"
                                + "2.由于此公众号暂未开通留言，粉丝活动暂时在“快手影讯”中开启。\r\n"
                                + "3.<a href=\"http://m.602.com/mobile/wx_login/?appid=100130&uid=fzq&suid=cd\">传奇来了</a>\r\n";


                        //+ "3.有些资源书库找不到，您可以尝试一下网页搜索\r\n"
                        //+ "<a href=\"http://weixin.sogou.com\">☞点我搜索</a>\r\n"
                        //+ "4.确实找不到资源？由于微信监管的十分的，非常的严格！我们也给大伙提供了QQ资源交流群（回复：qq进群），就劳烦哥哥姐姐们移步进群交流吧！\r\n";

                        hash["Content"] = str;

                        ResponseTextMessage(hash);
                    }



                    //微信关注时 调用微信素材
                    //ResponseWXNewsMessage(hash);
                    break;

                //取消关注
                case "unsubscribe":
                    //hash["Content"] = "欢迎您再次关注!";
                    //ResponseTextMessage(hash);
                    break;

                case "click":
                    //if (true)
                    //{
                    //    switch ((hash["EventKey"] as string ?? string.Empty).ToLower().Trim())
                    //    {
                    //        case "history":
                    //            hash["Content"] = "<a href=\"http://www.guo15.com/api/opx.ashx/history?uid="
                    //                    + HttpUtility.UrlEncode(hash["ToUserName"] as string ?? string.Empty)
                    //                    + "\">☞点我进入书架</a>";
                    //            ResponseTextMessage(hash);
                    //            break;

                    //        case "onlineshop":
                    //            hash["Content"] = "<a href=\"http://www.guo15.com/.m/system/booklist.aspx?uid="
                    //                    + HttpUtility.UrlEncode(hash["ToUserName"] as string ?? string.Empty)
                    //                    + "\">☞点击进入书城</a>";
                    //            ResponseTextMessage(hash);
                    //            break;
                    //    }
                    //}
                    break;
                //用户已关注 扫描二维码
                case "scan":
                    hash["Content"] = "今天是：" + DateTime.Now.ToString("yyyy-MM-dd") + " ";
                    ResponseTextMessage(hash);
                    break;

                //不允许回复
                case "location":
                    //hash["Content"] = "您的位置：" + hash["Location_X"] + " , " + hash["Location_Y"] + " , " + hash["Scale"] + " , " + hash["Label"];
                    //hash["Content"] = "您的位置";
                    //ResponseTextMessage(hash);
                    break;

                default:
                    break;
            }
        }
        catch (Exception ex)
        {

            //using (var file = File.CreateText(context.Server.MapPath("/runtime/" + DateTime.Now.Ticks.ToString() + ".err")))
            //{
            //    file.Write(ex);

            //    file.Close();

            //}
        }

    }


    Hashtable RequestMessage()
    {



        Hashtable hash = null;
        //Tencent.WXBizMsgCrypt wxcpt = new Tencent.WXBizMsgCrypt(sToken, sEncodingAESKey, sAppID);


        string sReqMsgSig = Request.QueryString["msg_signature"] ?? string.Empty;
        string sReqTimeStamp = Request.QueryString["timestamp"] ?? string.Empty;
        string sReqNonce = Request.QueryString["nonce"] ?? string.Empty;
        string sReqData = null;

        using (var stream = Request.InputStream)
        {
            long len = stream.Length;

            byte[] bytes = new byte[len];

            stream.Read(bytes, 0, Convert.ToInt32(len));

            sReqData = Encoding.UTF8.GetString(bytes);
        }



        if (string.IsNullOrEmpty(sReqData))
        {
            return null;
        }

        //using (var file = System.IO.File.CreateText(context.Server.MapPath("/runtime/" + DateTime.Now.Ticks.ToString() + ".log")))
        //{
        //    file.Write(sReqData);
        //    file.Close();
        //}


        string sMsg = sReqData;  //解析之后的明文
        int ret = 0;
        //ret = wxcpt.DecryptMsg(sReqMsgSig, sReqTimeStamp, sReqNonce, sReqData, ref sMsg);
        if (ret != 0)
        {
            Response.Write("ERR: Decrypt fail, ret: " + ret);
            return null;
        }


        if (string.IsNullOrEmpty(sMsg))
        {
            return null;
        }

        try
        {
            XmlDocument doc = new XmlDocument();
            doc.LoadXml(sMsg);

            hash = new Hashtable();

            if (doc != null)
            {
                if (doc.DocumentElement != null)
                {
                    var list = doc.DocumentElement.ChildNodes;

                    if (list != null)
                    {
                        for (int i = 0; i < list.Count; i++)
                        {
                            var node = list[i];

                            hash[node.Name] = node.InnerText;
                        }
                    }
                }
            }
        }
        catch (Exception ex)
        {


        }


        return hash;
    }

    //写入日志
    public void WriteLog(string text)
    {
        System.IO.StreamWriter sw = new System.IO.StreamWriter(@"D:\Hosts\www.qqxzb.com\log\log_" + DateTime.Now.ToString("yyyyMMdd") + ".txt", true);
        sw.WriteLine(text + "\r\n");
        sw.Close();//写入
    }

    void SearchKeywordsAndEchoMessages(Hashtable hash)
    {
        var dbh = Common.DB.Factory.CreateDBHelper("default");

        string content = hash["Content"] as string;


        if (!string.IsNullOrWhiteSpace(content))
        {



            content = content.Trim();


            if (content.Length > 0)
            {
                WriteLog(content);
                switch (content)
                {
                    case "往期影评":
                        if (true)
                        {
                            string url = "https://mp.weixin.qq.com/mp/profile_ext?action=home&__biz=MzU2NjA0Mzg2NQ==&scene=123#wechat_redirect";
                            hash["Content"] = "<a href=\"" + url + "\">" + content + "</a>";
                            ResponseTextMessage(hash);
                        }
                        break;

                    case "粉丝福利":
                        if (true)
                        {
                            string url = "http://mp.weixin.qq.com/mp/homepage?__biz=MzU2NjA0Mzg2NQ==&hid=4&sn=d0aa6b3d299a34b4d376e68e4a04c49d#wechat_redirect";
                            hash["Content"] = "<a href=\"" + url + "\">" + content + "</a>";
                            ResponseTextMessage(hash);
                        }
                        break;



                    default:
                        if (true)
                        {
                            List<NewsMessage> list = new List<NewsMessage>();


                            var contsb = new StringBuilder();

                            //using (var reader = dbh.ExecuteReader("select top 8 id,name,url,type,date from data_video where charIndex(@0,name)>0  order by id desc", content))
                            //{



                            //    while (reader.Read())
                            //    {
                            //        var ent = new NewsMessage();

                            //        ent.Title = reader.GetString(1);
                            //        //ent.Description = reader.GetString(2);
                            //        //ent.PicUrl = reader.GetString(3);
                            //        string url = reader.GetString(2);


                            //        //using (var file = System.IO.File.CreateText(context.Server.MapPath("/runtime/" + DateTime.Now.Ticks.ToString() + ".log")))
                            //        //{
                            //        //    file.Write(url);
                            //        //    file.Close();
                            //        //}

                            //        if (url.IndexOf("://") >= 0)
                            //        {
                            //            ent.Url = url;
                            //        }
                            //        else
                            //        {
                            //            //ent.Url = "http://m.yxdown.com/weixin/content?id=" + reader.GetInt32(0);
                            //        }
                            //        int sid = reader.GetInt32(0);

                            //        list.Add(ent);

                            //        contsb.AppendLine("<a href=\"" + url + "\">《" + ent.Title + "》</a>");

                            //        //contsb.AppendLine("<a href=\"http://www.guo15.com/api/opx.ashx/read?uid=" + HttpUtility.UrlEncode(hash["ToUserName"] as string ?? string.Empty)
                            //        //    + "&sid=" + sid + "&url=" + HttpUtility.UrlEncode(url) + "\">《" + ent.Title + "》</a>");
                            //    }
                            //    reader.Close();
                            //}

                            if (list.Count == 0)
                            {
                                hash["Content"] = "抱歉，没有搜到相关内容，请核对关键词正确性，减少关键字试试~~";


                                //微信关注时 调用微信素材
                                //ResponseWXNewsMessage(hash);
                                ResponseTextMessage(hash);
                            }
                            else
                            {

                                hash["Content"] = contsb.ToString() + "点击上方影视名即可观看~"
                                + "<a href=\"http://m.602.com/mobile/wx_login/?appid=100130&uid=fzq&suid=cd\">传奇来了</a>\r\n";


                                //微信关注时 调用微信素材
                                //ResponseWXNewsMessage(hash);
                                ResponseTextMessage(hash);
                                //ResponseNewsMessage(hash, list);

                            }
                        }

                        break;
                }



            }




        }
    }


    void ResponseTextMessage(Hashtable hash)
    {

        string sReqTimeStamp = Request.QueryString["timestamp"] ?? string.Empty;
        string sReqNonce = Request.QueryString["nonce"] ?? string.Empty;

        string ts = GetTimeStamp();

        //Tencent.WXBizMsgCrypt wxcpt = new Tencent.WXBizMsgCrypt(sToken, sEncodingAESKey, sAppID);

        string sRespData = "<xml><ToUserName><![CDATA[" + hash["ToUserName"] + "]]></ToUserName><FromUserName><![CDATA[" + hash["FromUserName"] + "]]></FromUserName><CreateTime>" + ts + "</CreateTime><MsgType><![CDATA[text]]></MsgType><Content><![CDATA[" + hash["Content"] + "]]></Content><MsgId>" + hash["ToUserName"] + ts + "</MsgId></xml>";


        string sEncryptMsg = sRespData; //xml格式的密文
        //int ret = wxcpt.EncryptMsg(sRespData, sReqTimeStamp, sReqNonce, ref sEncryptMsg);
        if (!string.IsNullOrEmpty(sEncryptMsg))
        {
            Response.Write(sEncryptMsg);
        }
        else
        {
            Response.Write("ERR: Encrypt fail, ret: ");
        }

    }


    public class NewsMessage
    {
        public string Title { get; set; }
        public string Description { get; set; }
        public string PicUrl { get; set; }
        public string Url { get; set; }
    }

    void ResponseNewsMessage(Hashtable hash, IList<NewsMessage> list)
    {

        if (list == null)
        {
            return;
        }

        if (list.Count == 0)
        {
            return;
        }

        string sReqTimeStamp = Request.QueryString["timestamp"] ?? string.Empty;
        string sReqNonce = Request.QueryString["nonce"] ?? string.Empty;

        string ts = GetTimeStamp();

        //Tencent.WXBizMsgCrypt wxcpt = new Tencent.WXBizMsgCrypt(sToken, sEncodingAESKey, sAppID);

        StringBuilder msgsb = new StringBuilder();


        msgsb.Append("<xml>");
        msgsb.Append("<ToUserName><![CDATA[" + hash["ToUserName"] + "]]></ToUserName>");
        msgsb.Append("<FromUserName><![CDATA[" + hash["FromUserName"] + "]]></FromUserName>");
        msgsb.Append("<CreateTime>" + ts + "</CreateTime>");
        msgsb.Append("<MsgType><![CDATA[news]]></MsgType>");


        msgsb.Append("<ArticleCount>" + list.Count + "</ArticleCount>");
        msgsb.Append("<Articles>");

        for (int i = 0; i < list.Count; i++)
        {
            var ent = list[i];

            msgsb.Append("<item>");
            msgsb.Append("<Title><![CDATA[" + ent.Title + "]]></Title> ");
            msgsb.Append("<Description><![CDATA[" + ent.Description + "]]></Description>");
            msgsb.Append("<PicUrl><![CDATA[" + ent.PicUrl + "]]></PicUrl>");
            msgsb.Append("<Url><![CDATA[" + ent.Url + "]]></Url>");
            msgsb.Append("</item>");
        }


        msgsb.Append("</Articles>");
        msgsb.Append("</xml>");

        string sRespData = msgsb.ToString();

        string sEncryptMsg = sRespData; //xml格式的密文
        //int ret = wxcpt.EncryptMsg(sRespData, sReqTimeStamp, sReqNonce, ref sEncryptMsg);
        if (!string.IsNullOrEmpty(sEncryptMsg))
        {
            Response.Write(sEncryptMsg);
        }
        else
        {
            Response.Write("ERR: Encrypt fail, ret: ");
        }

    }

    //调取微信素材内页链接
    void ResponseWXNewsMessage(Hashtable hash)
    {
        var title = "2016 Chinajoy 门票免费领！";
        var description = "快来关注“游讯网”公众号参与活动吧！Chinajoy门票免费领哦！";
        var picUrl = "https://mmbiz.qlogo.cn/mmbiz/yhneKwnCAf3qZRpngYAq66ZR9VFUAdiaPow0eYib1XeyuqCFRHXLvjqQlcvKiaCpDG3gTM1ZmVZiaO4KknDNgZibF7g/0?wx_fmt=jpeg";
        var turl = "http://mp.weixin.qq.com/s?__biz=MjM5MjMyMDA4MQ==&mid=504804070&idx=1&sn=4388f8a2922af74c941522c54fa04418&scene=0#wechat_redirect";
        turl = "http://mp.weixin.qq.com/s?__biz=MjM5MjMyMDA4MQ==&mid=2652287742&idx=1&sn=c7593a5c94c11e037a54cbbbb345a871&scene=1&srcid=07127ml7lg3jDgK3IXCnBRcs#rd";
        string sReqTimeStamp = Request.QueryString["timestamp"] ?? string.Empty;
        string sReqNonce = Request.QueryString["nonce"] ?? string.Empty;

        string ts = GetTimeStamp();

        //Tencent.WXBizMsgCrypt wxcpt = new Tencent.WXBizMsgCrypt(sToken, sEncodingAESKey, sAppID);

        StringBuilder msgsb = new StringBuilder();


        msgsb.Append("<xml>");
        msgsb.Append("<ToUserName><![CDATA[" + hash["ToUserName"] + "]]></ToUserName>");
        msgsb.Append("<FromUserName><![CDATA[" + hash["FromUserName"] + "]]></FromUserName>");
        msgsb.Append("<CreateTime>" + ts + "</CreateTime>");
        msgsb.Append("<MsgType><![CDATA[news]]></MsgType>");

        //1篇文章
        msgsb.Append("<ArticleCount>1</ArticleCount>");
        msgsb.Append("<Articles>");

        msgsb.Append("<item>");
        msgsb.Append("<Title><![CDATA[" + title + "]]></Title> ");
        msgsb.Append("<Description><![CDATA[" + description + "]]></Description>");
        msgsb.Append("<PicUrl><![CDATA[" + picUrl + "]]></PicUrl>");
        msgsb.Append("<Url><![CDATA[" + turl + "]]></Url>");
        msgsb.Append("</item>");


        msgsb.Append("</Articles>");
        msgsb.Append("</xml>");

        string sRespData = msgsb.ToString();

        string sEncryptMsg = sRespData; //xml格式的密文
        //int ret = wxcpt.EncryptMsg(sRespData, sReqTimeStamp, sReqNonce, ref sEncryptMsg);
        if (!string.IsNullOrEmpty(sEncryptMsg))
        {
            Response.Write(sEncryptMsg);
        }
        else
        {
            Response.Write("ERR: Encrypt fail, ret: ");
        }
    }


    public static string GetTimeStamp()
    {
        TimeSpan ts = DateTime.UtcNow - new DateTime(1970, 1, 1, 0, 0, 0, 0);
        return Convert.ToInt64(ts.TotalSeconds).ToString();
    }







    public void CheckServer()
    {
        string _token = "weixin";
        string _timestamp = HttpContext.Current.Request["timestamp"];
        string _nonce = HttpContext.Current.Request["nonce"];
        string _singature = HttpContext.Current.Request["signature"];
        string _echostr = HttpContext.Current.Request["echostr"];
        if (CheckSignAture(_token, _timestamp, _nonce, _singature))
        {
            if (!string.IsNullOrEmpty(_echostr))
            {
                HttpContext.Current.Response.Write(_echostr);


                HttpContext.Current.Response.End();
            }
        }
    }




    /// <summary>
    /// 验证签名是否一致
    /// </summary>
    /// <param name="token">微信平台设置的口令</param>
    /// <param name="timestamp">时间戳</param>
    /// <param name="nonce">随机数</param>
    /// <param name="signature">微信加密签名</param>
    /// <returns></returns>
    public bool CheckSignAture(string token, string timestamp, string nonce, string signature)
    {
        string[] strs = new string[] { token, timestamp, nonce };//把参数放到数组
        Array.Sort(strs);//加密/校验流程1、数组排序
        string sign = string.Join("", strs);
        sign = GetSHA1Str(sign);
        if (sign == signature)
        {
            return true;
        }
        else
        {
            return false;
        }


    }




    /// <summary>
    /// SHA1加密方法
    /// </summary>
    /// <param name="str">需要加密的字符串</param>
    /// <returns></returns>
    public string GetSHA1Str(string str)
    {
        byte[] _byte = Encoding.Default.GetBytes(str);
        HashAlgorithm ha = new SHA1CryptoServiceProvider();
        _byte = ha.ComputeHash(_byte);
        StringBuilder sha1Str = new StringBuilder();
        foreach (byte b in _byte)
        {
            sha1Str.AppendFormat("{0:x2}", b);
        }
        return sha1Str.ToString();
    }

    public bool IsReusable
    {
        get
        {
            return false;
        }
    }

}

