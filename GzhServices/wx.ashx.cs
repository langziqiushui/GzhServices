using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Text;
using System.Web;

namespace GzhServices
{
    /// <summary>
    /// Token 的摘要说明
    /// </summary>
    public class wx : IHttpHandler
    {

        private const string token = "qiushuizhijiagzhtoken";
        private const string _myOpenid = "wxa3da5fcaddf4c8b4";
        private static string postStr = "";
        public void ProcessRequest(HttpContext context)
        {
            context.Response.ContentType = "text/plain";

            if (context.Request.HttpMethod == "POST")
            {
                //消息处理
                ProccessMessage();
            }
            else
            {
                //验证
                if (CheckSignature())
                {
                    //处理消息
                    string echostr = context.Request.QueryString["echostr"] ?? "";
                    context.Response.Write(echostr);
                }
                else
                {
                    context.Response.Write("验证失败！");
                }
            }
        }

        public static void ProccessMessage()
        {
            Stream s = System.Web.HttpContext.Current.Request.InputStream;
            byte[] b = new byte[s.Length];
            s.Read(b, 0, (int)s.Length);
            postStr = Encoding.UTF8.GetString(b);
            if (!string.IsNullOrEmpty(postStr))
            {
                MessageServices.ResponseMsg(postStr);
            }
        }

        /// <summary>
        /// 验证微信签名
        /// </summary>
        /// * 将token、timestamp、nonce三个参数进行字典序排序
        /// * 将三个参数字符串拼接成一个字符串进行sha1加密
        /// * 开发者获得加密后的字符串可与signature对比，标识该请求来源于微信。
        /// <returns></returns>
        public static bool CheckSignature()
        {
            //HttpContext.Current.Response.Write(HttpContext.Current.Request.RawUrl);

            string signature = HttpContext.Current.Request.QueryString["signature"] ?? "";
            string timestamp = HttpContext.Current.Request.QueryString["timestamp"] ?? "";
            string nonce = HttpContext.Current.Request.QueryString["nonce"] ?? "";
            string[] ArrTmp = { token, timestamp, nonce };
            Array.Sort(ArrTmp);//字典排序
            string tmpStr = string.Join("", ArrTmp);
            tmpStr = Util.HashPasswordForStoringInConfigFile(tmpStr, "SHA1");
            tmpStr = tmpStr.ToLower();
            if (tmpStr == signature)
            {
                return true;
            }
            else
            {
                return false;
            }
        }

        public bool IsReusable
        {
            get
            {
                return false;
            }
        }
    }
}