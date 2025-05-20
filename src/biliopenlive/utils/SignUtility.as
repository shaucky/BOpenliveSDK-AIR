package biliopenlive.utils {
    import air.security.Digest;
    import flash.net.URLRequest;
    import flash.net.URLVariables;
    import flash.net.URLRequestHeader;
    import flash.utils.ByteArray;

    /**
     * <p>
     * BOpenlive SDK的签名工具，为官方API请求提供鉴权签名标头。
     * </p>
     * <p>
     * 确保在调用setRequestHeader()之前，已经为accessKeyId和accessKeySecret赋值。
     * </p>
     * @playerversion AIR 51.0
     * @see https://open-live.bilibili.com/document/74eec767-e594-7ddd-6aba-257e8317c05d
     */
    public class SignUtility {
        /**
         * <p>开发者从哔哩哔哩直播开放平台申请的开发密钥之一。</p>
         */
        public static var accessKeySecret: String;
        /**
         * <p>开发者从哔哩哔哩直播开放平台申请的开发密钥之一。</p>
         */
        public static var accessKeyId: String;

        /**
         * <p>
         * 按哔哩哔哩直播开放平台文档说明的规则添加请求标头。确保在调用该方法之前，已经为accessKeyId和accessKeySecret赋值。
         * </p>
         * @param request 需要添加标头的请求
         * @param jsonParam 要写入请求体的JSON数据
         * @param cookie 可选Cookie
         * @see https://open-live.bilibili.com/document/74eec767-e594-7ddd-6aba-257e8317c05d
         */
        public static function setRequestHeader(request: URLRequest, jsonParam: String, cookie: String): void {
            var sortedArray: Array = orderAndMD5(jsonParam);
            var authen: String = calcuSignature(sortedArray);
            var varibales: URLVariables = new URLVariables();
            var byteArray: ByteArray = new ByteArray();
            request.requestHeaders = new Array();
            for each(var kvp: Object in sortedArray)
            {
                request.requestHeaders.push(new URLRequestHeader(kvp.key, kvp.value));
            }
            request.requestHeaders.push(new URLRequestHeader("Authorization", authen));
            request.requestHeaders.push(new URLRequestHeader("Accept", "application/json"));
            request.requestHeaders.push(new URLRequestHeader("Content-Type", "application/json"));
            if (cookie != null) {
                request.requestHeaders.push(new URLRequestHeader("Cookie", cookie));
            }
            request.requestHeaders.removeAt(request.requestHeaders.push(new URLRequestHeader("Referer", "https://www.bilibili.com"))); //!important
            byteArray.writeUTFBytes(jsonParam);
            byteArray.position = 0;
            request.data = byteArray;
        }
        private static function orderAndMD5(jsonParam: String): Array {
            var kvps: Array = new Array(
                {key: "x-bili-content-md5", value: MD5(jsonParam)},
                {key: "x-bili-timestamp", value: Math.floor((new Date()).time / 1000).toString()},
                {key: "x-bili-signature-method", value: "HMAC-SHA256"},
                {key: "x-bili-signature-nonce", value: createGuid()},
                {key: "x-bili-accesskeyid", value: accessKeyId},
                {key: "x-bili-signature-version", value: "1.0"}
            );
            kvps.sortOn("key", Array.CASEINSENSITIVE);
            return kvps;
        }
        private static function MD5(jsonParam: String): String {
            var buffer: ByteArray = new ByteArray();
            var md5Buffer: ByteArray;
            var hex: String = "";
            var hexByte: String;
            var b: int;
            buffer.writeUTFBytes(jsonParam);
            md5Buffer = Digest.hash(Digest.MD5, buffer);
            md5Buffer.position = 0;
            while (md5Buffer.bytesAvailable > 0) {
                b = md5Buffer.readUnsignedByte();
                hexByte = b.toString(16);
                if (hexByte.length < 2) {
                    hexByte = "0" + hexByte;
                }
                hex += hexByte;
            }
            return hex;
        }
        private static function calcuSignature(array: Array): String {
            var signature: String = "";
            for each(var kvp: Object in array)
            {
                if (signature == "") {
                    signature += kvp.key + ":" + kvp.value;
                }
                else {
                    signature += "\n" + kvp.key + ":" + kvp.value;
                }
            }
            return hmacSHA256(signature, accessKeySecret);
        }
        private static function hmacSHA256(message: String, secret: String): String {
            var b: uint;
            var s: String;
            var messageBytes: ByteArray = new ByteArray();
            var secretBytes: ByteArray = new ByteArray();
            const blockSize: int = 64;
            var paddedKey: ByteArray;
            var o_key_pad: ByteArray;
            var i_key_pad: ByteArray;
            var innerMessage: ByteArray;
            var innerHash: ByteArray;
            var outerMessage: ByteArray;
            var ba: ByteArray;
            messageBytes.writeUTFBytes(message);
            secretBytes.writeUTFBytes(secret);
            if (secretBytes.length > blockSize) {
                secretBytes = Digest.hash(Digest.SHA256, secretBytes);
            }
            paddedKey = new ByteArray();
            paddedKey.writeBytes(secretBytes);
            while (paddedKey.length < blockSize) {
                paddedKey.writeByte(0x00);
            }
            o_key_pad = new ByteArray();
            i_key_pad = new ByteArray();
            paddedKey.position = 0;
            for (var i:int = 0; i < blockSize; i++) {
                b = paddedKey.readUnsignedByte();
                o_key_pad.writeByte(b ^ 0x5c);
                i_key_pad.writeByte(b ^ 0x36);
            }
            innerMessage = new ByteArray();
            innerMessage.writeBytes(i_key_pad);
            innerMessage.writeBytes(messageBytes);
            innerHash = Digest.hash(Digest.SHA256, innerMessage);
            outerMessage = new ByteArray();
            outerMessage.writeBytes(o_key_pad);
            outerMessage.writeBytes(innerHash);
            ba = Digest.hash(Digest.SHA256, outerMessage);
            ba.position = 0;
            s = "";
            while (ba.bytesAvailable > 0) {
                b = ba.readUnsignedByte();
                s += ("0" + b.toString(16)).substr(-2);
            }
            return s;
        }
        private static function createGuid(): String {
            var chars: String = "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx";
            return chars.replace(/[xy]/g, function(c:*, ...arguments): String {
                var r: int = Math.random()*16|0, v:int = c == "x" ? r : (r & 0x3 | 0x8);
                return v.toString(16);
            });
        }
    }
}