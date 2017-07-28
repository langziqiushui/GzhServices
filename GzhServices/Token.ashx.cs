using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;

namespace GzhServices
{
    /// <summary>
    /// Token 的摘要说明
    /// </summary>
    public class Token : IHttpHandler
    {

        public void ProcessRequest(HttpContext context)
        {
            context.Response.ContentType = "text/plain";

            string signature = context.Request.QueryString["signature"] ?? "";

            string token = context.Request.QueryString["token"] ?? "";
            string timestamp = context.Request.QueryString["timestamp"] ?? "";
            string nonce = context.Request.QueryString["nonce"] ?? "";

            string echostr = context.Request.QueryString["echostr"] ?? "";


            /*System.Collections.Specialized.NameValueCollection collect = new System.Collections.Specialized.NameValueCollection();
            collect.Add("Action", "GetCdnLogList");
            string urlGet = "cdn.api.qcloud.com/v2/index.php?";
            foreach (string key in collect.Keys)
            {
                urlGet += key + "=" + collect[key] + "&";
            }
            urlGet = urlGet.TrimEnd('&');
            string SignatureGet = HttpUtility.UrlEncode(Util.HmacSha1Sign("Vjq0C8rJUUFo6FH4pa5RmrfDsUyGI5nh", "GET" + urlPost));*/

            context.Response.Write(echostr);
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