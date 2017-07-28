using System;
using System.Collections.Generic;
using System.Linq;
using System.Net;
using System.Text;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace GzhServices
{
    public partial class FrmSendMessage : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            if (Request["action"] == "sendMsg")
            {
                string content = Request["content"] ?? "";
                if (content != "")
                {
                    string json = "{'touser':'orUkWxBlHNfkBHJpBh61YHnyykTY','msgtype':'text','text':{'content':'" + content + "'}}";
                    WebClient webClient = new WebClient();
                    string uriString = "https://api.weixin.qq.com/cgi-bin/message/custom/send?access_token=1NB35ThVQAWgUzcNwHN4W8s68x2ZubFaqLNck52WuHxTRkYGMjH5fVzu06VKr4eCDz54_XfnxEVKbuKGFkuIuW1CT13MeAPLbJ2ggyAIctPtv9orFLBhWQATVbpIycQ2HAKeAIAATD";
                    WebClient myWebClient = new WebClient();
                    byte[] byteArray = Encoding.UTF8.GetBytes(json);
                    byte[] pageData = webClient.UploadData(uriString, "POST", byteArray);
                    Response.Write(Encoding.UTF8.GetString(pageData));
                    Response.End();
                }
            }
        }
    }
}