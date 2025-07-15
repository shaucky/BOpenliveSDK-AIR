package biliopenlive.net {
    import air.net.*;
    import biliopenlive.events.*;
    import biliopenlive.utils.*;
    import flash.events.*;
    import flash.utils.*;

    /**
     * <p>
     * BOpenliveWebSocket类负责维护与哔哩哔哩直播开放平台的消息长链。通过保持与服务器的连接，即时获取直播间的相关数据，如弹幕消息、礼物信息等。
     * </p>
     * <p>
     * 建议通过BOpenlivePipe类获取封装好的事件进行对请求结果的处理。
     * </p>
     * @playerversion AIR 51.0
     * @see https://open-live.bilibili.com/document/657d8e34-f926-a133-16c0-300c1afc6e6b
     */
    public final class BOpenliveWebSocket extends EventDispatcher {
        private var _timer: Timer;
        private var _webSocket: WebSocket;
        private var _links: Array;
        private var _authBody: String;
        private var _linkIndex: int;
        private var _retryTimes: int = 0;
        private var _retryMaxinum: int;

        /**
         * <p>构造BOpenliveWebSocket的实例。</p>
         * @param links 服务器返回的长连地址数组
         * @param authBody 服务器返回的认证结构
         * @param retryTimes 允许的尝试连接次数，默认为5。
         */
        public function BOpenliveWebSocket(links: Array, authBody: String, retryTimes: int = 5) {
            _links = links;
            _authBody = authBody;
            _linkIndex = 0;
            _retryMaxinum = retryTimes;
        }
        /**
         * <p>尝试与长连地址进行通信。</p>
         * <p>每次尝试连接会选择长连地址数组的下一候选地址（如果适用），全部尝试过后则重新尝试首个地址。</p>
         * <p>尝试连接次数达到构造时设置的最大次数后，再次尝试连接会抛出异常。</p>
         */
        public function connect(): void {
            if (_retryTimes >= _retryMaxinum) {
                Logger.error("重连次数达到上限。");
                return;
            }
            _retryTimes++;
            if (_webSocket != null) {
                _webSocket.close();
                removeAllEventListsner(_webSocket);
            }
            if (_timer != null) {
                _timer.stop();
                _timer.removeEventListener(TimerEvent.TIMER, onTimer);
                _timer = null;
            }
            _webSocket = new WebSocket();
            if (_linkIndex >= _links.length) {
                _linkIndex = 0;
            }
            _webSocket.connect(_links[_linkIndex++]);
            _webSocket.addEventListener(Event.CONNECT, onConnect);
        }
        private function send(message: ByteArray): void {
            _webSocket.sendMessage(WebSocket.fmtBINARY, message);
        }
        private function authToBytes(): ByteArray {
            var authBody: ByteArray = new ByteArray();
            authBody.writeUTFBytes(_authBody);
            return pack(authBody, 1, BOpenliveWebSocketOperation.OP_AUTH);
        }
        private function heartbeatToBytes(): ByteArray {
            var heartbeat: ByteArray = new ByteArray();
            return pack(heartbeat, 1, BOpenliveWebSocketOperation.OP_HEARTBEAT);
        }
        private function pack(body: ByteArray, version: int, operation: int, sequence: int = 1): ByteArray {
            var bytes: ByteArray = new ByteArray();
            bytes.endian = Endian.BIG_ENDIAN;
            bytes.writeInt(body.length + 16);
            bytes.writeShort(16);
            bytes.writeShort(version);
            bytes.writeInt(operation);
            bytes.writeInt(sequence);
            bytes.writeBytes(body);
            bytes.position = 0;
            return bytes;
        }
        private function zlibUncompress(bytes: ByteArray): ByteArray {
            var out: ByteArray = new ByteArray();
            bytes.position = 0;
            bytes.readBytes(out);
            out.uncompress();
            return out;
        }
        private function onConnect(e:Event): void {
            Logger.message("WSS长连建立");
            send(authToBytes());
            _timer = new Timer(20000);
            _timer.addEventListener(TimerEvent.TIMER, onTimer);
            _timer.start();
            _webSocket.removeEventListener(Event.CONNECT, onConnect);
            _webSocket.addEventListener(WebSocketEvent.DATA, onWebSocketData);
            _webSocket.addEventListener(Event.CLOSE, onClose);
            _webSocket.addEventListener(IOErrorEvent.IO_ERROR, onIOError);
        }
        private function onWebSocketData(e: WebSocketEvent): void {
            var data: ByteArray = e.data as ByteArray;
            data.endian = Endian.BIG_ENDIAN;
            while (data.bytesAvailable >= 16) {
                var packLen: int = data.readInt();
                var headLen: int = data.readShort();
                var version: int = data.readShort();
                var operation: int = data.readInt();
                var seq: int = data.readInt();
                var bodyLen: int = packLen - headLen;
                var bodyBytes: ByteArray = new ByteArray();
                var authReply: Object;
                var unzlib: ByteArray;
                var msg: Object;
                if (bodyLen > 0 && data.bytesAvailable >= bodyLen) {
                    data.readBytes(bodyBytes, 0, bodyLen);
                }
                if (operation == BOpenliveWebSocketOperation.OP_HEARTBEAT_REPLY) {
                    Logger.message("WSS对向心跳");
                } else if (operation == BOpenliveWebSocketOperation.OP_AUTH_REPLY) {
                    authReply = JSON.parse(bodyBytes.readUTFBytes(bodyBytes.length));
                    if (authReply.code == 0) {
                        Logger.message("WSS鉴权成功");
                    } else {
                        Logger.error("WSS鉴权失败");
                    }
                } else if (operation == BOpenliveWebSocketOperation.OP_SEND_SMS_REPLY) {
                    if (version == 2) {
                        unzlib = zlibUncompress(bodyBytes);
                        onWebSocketData(new WebSocketEvent(WebSocketEvent.DATA, WebSocket.fmtBINARY, unzlib));
                    } else if (version == 0) {
                        msg = JSON.parse(bodyBytes.readUTFBytes(bodyBytes.length));
                        dispatchEvent(new BOpenliveWSSEvent(msg.cmd, msg.data));
                    }
                }
                if (data.bytesAvailable < 16) {
                    break;
                }
            }
        }
        private function onClose(e: Event): void {
            Logger.error("WSS长连被对方关闭，建议调用connect()尝试重连。");
            removeAllEventListsner(e.target as WebSocket);
        }
        private function onIOError(e: IOErrorEvent): void {
            Logger.error("WSS长连发生出入流错误，建议调用connect()尝试重连。");
            removeAllEventListsner(e.target as WebSocket);
        }
        private function onTimer(e:TimerEvent): void {
            Logger.message("WSS长连心跳");
            send(heartbeatToBytes());
        }
        private function removeAllEventListsner(webSocket: WebSocket): void {
            webSocket.removeEventListener(Event.CONNECT, onConnect);
            webSocket.removeEventListener(WebSocketEvent.DATA, onWebSocketData);
            webSocket.removeEventListener(Event.CLOSE, onClose);
            webSocket.removeEventListener(IOErrorEvent.IO_ERROR, onIOError);
        }
    }
}