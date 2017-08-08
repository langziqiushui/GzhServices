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
        private const string strAppSecret = "8ed6222d87d706ed872e5b2d1e8b89d5";
        private static string postString = "";
        private messageHelp help = new messageHelp();

        public void ProcessRequest(HttpContext context)
        {
            context.Response.ContentType = "text/plain";

            if (context.Request.HttpMethod.ToUpper() == "POST")
            {
                //消息处理 
                using (Stream stream = HttpContext.Current.Request.InputStream)
                {
                    Byte[] postBytes = new Byte[stream.Length];
                    stream.Read(postBytes, 0, (Int32)stream.Length);
                    postString = Encoding.UTF8.GetString(postBytes);
                    Handle(postString);
                }
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

        /// <summary>
        /// 处理信息并应答
        /// </summary>
        private void Handle(string postStr)
        {
            //help.WriteLog(postStr);
            string responseContent = help.ReturnMessage(postStr);
            HttpContext.Current.Response.ContentEncoding = Encoding.UTF8;
            HttpContext.Current.Response.Write(responseContent);
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