using System;
using System.Collections.Generic;
using System.Linq;
using System.Security.Cryptography;
using System.Text;
using System.Threading.Tasks;
using System.Web.Security;

namespace GzhServices
{
    public static class Util
    {
        /// <summary>
        /// HMAC-SHA1加密算法
        /// </summary>
        /// <param name="secret">密钥</param>
        /// <param name="strOrgData">源文</param>
        /// <returns></returns>
        public static string HmacSha1Sign(string secret, string strOrgData)
        {
            var hmacsha1 = new HMACSHA1(Encoding.UTF8.GetBytes(secret));
            var dataBuffer = Encoding.UTF8.GetBytes(strOrgData);
            var hashBytes = hmacsha1.ComputeHash(dataBuffer);
            return Convert.ToBase64String(hashBytes);
        }
        public static string HashPasswordForStoringInConfigFile(string str, string type)
        {
            return FormsAuthentication.HashPasswordForStoringInConfigFile(str, type);
        }
    }
}
