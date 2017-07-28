using System;
using System.Collections.Generic;
using System.Linq;
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
                    messageHelp help = new messageHelp();
                    string resultMessage = string.Format(ReplyType.Message_Text,
                           "orUkWxBlHNfkBHJpBh61YHnyykTY",
                           "gh_0836efd869eb",
                           DateTime.Now.Ticks,
                           content);

                    //HttpContext.Current.Response.ContentEncoding = Encoding.UTF8;
                    //HttpContext.Current.Response.Write(resultMessage);

                    Response.Write("发送成功");
                }
            }
        }
    }
}