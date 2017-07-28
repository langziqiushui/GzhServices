<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="FrmSendMessage.aspx.cs" Inherits="GzhServices.FrmSendMessage" %>

<!DOCTYPE html>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
    <title>内容推送</title>
    <script src="js/jquery.js"></script>
    <script>
        function ajaxExec(prams, callback) {
            $.ajax({
                url: '/FrmSendMessage.aspx',
                type: 'POST',
                async: true,
                data: prams,
                dataType: 'text',
                success: callback
            });
        }

        function sendMsg() {
            ajaxExec({ action: "sendMsg", content: $("#txtContent").val() }, function (data) {
                alert(data);
            });
        }
    </script>
</head>
<body>
    <form id="form1" runat="server">
        <textarea id="txtContent" rows="5" cols="70"></textarea><br />
        <input type="button" value="发送消息" onclick="sendMsg()" />
    </form>
</body>
</html>
