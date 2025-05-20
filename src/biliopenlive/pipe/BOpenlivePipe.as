package biliopenlive.pipe {
    import biliopenlive.events.BOpenliveHTTPSEvent;
    import biliopenlive.net.BOpenliveAPI;
    import biliopenlive.utils.Logger;
    import biliopenlive.utils.HeartbeatTimer;
    import flash.events.EventDispatcher;
    import flash.events.Event;
    import flash.events.IOErrorEvent;
    import flash.events.TimerEvent;
    import flash.net.URLLoader;
    import biliopenlive.net.BOpenliveWebSocket;
    import biliopenlive.events.BOpenliveWSSEvent;

    /**
     * 向API发送开始请求且返回后派发。
     * @eventType biliopenlive.events.BOpenliveHTTPSEvent.START
     */
    [Event(name="start", type="biliopenlive.events.BOpenliveHTTPSEvent")]
    /**
     * 向API发送结束请求且返回后派发。
     * @eventType biliopenlive.events.BOpenliveHTTPSEvent.END
     */
    [Event(name="end", type="biliopenlive.events.BOpenliveHTTPSEvent")]
    /**
     * 向API发送心跳请求且返回后派发。
     * @eventType biliopenlive.events.BOpenliveHTTPSEvent.HEARTBEAT
     */
    [Event(name="heartbeat", type="biliopenlive.events.BOpenliveHTTPSEvent")]
    /**
     * 向API发送批量心跳请求且返回后派发。
     * @eventType biliopenlive.events.BOpenliveHTTPSEvent.BATCH_HEARTBEAT
     */
    [Event(name="batchHeartbeat", type="biliopenlive.events.BOpenliveHTTPSEvent")]
    /**
     * 接收到弹幕信息后派发。
     * @eventType biliopenlive.events.BOpenliveWSSEvent.DM
     */
    [Event(name="LIVE_OPEN_PLATFORM_DM", type="biliopenlive.events.BOpenliveWSSEvent")]
    /**
     * 接收到礼物信息后派发。
     * @eventType biliopenlive.events.BOpenliveWSSEvent.SEND_GIFT
     */
    [Event(name="LIVE_OPEN_PLATFORM_SEND_GIFT", type="biliopenlive.events.BOpenliveWSSEvent")]
    /**
     * 接收到SC信息后派发。
     * @eventType biliopenlive.events.BOpenliveWSSEvent.SUPER_CHAT
     */
    [Event(name="LIVE_OPEN_PLATFORM_SUPER_CHAT", type="biliopenlive.events.BOpenliveWSSEvent")]
    /**
     * 接收到SC屏蔽信息后派发。
     * @eventType biliopenlive.events.BOpenliveWSSEvent.SUPER_CHAT_DEL
     */
    [Event(name="LIVE_OPEN_PLATFORM_SUPER_CHAT_DEL", type="biliopenlive.events.BOpenliveWSSEvent")]
    /**
     * 接收到付费大航海信息后派发。
     * @eventType biliopenlive.events.BOpenliveWSSEvent.GUARD
     */
    [Event(name="LIVE_OPEN_PLATFORM_GUARD", type="biliopenlive.events.BOpenliveWSSEvent")]
    /**
     * 接收到点赞信息后派发。
     * @eventType biliopenlive.events.BOpenliveWSSEvent.LIKE
     */
    [Event(name="LIVE_OPEN_PLATFORM_LIKE", type="biliopenlive.events.BOpenliveWSSEvent")]
    /**
     * 接收到进房信息后派发。
     * @eventType biliopenlive.events.BOpenliveWSSEvent.LIVE_ROOM_ENTER
     */
    [Event(name="LIVE_OPEN_PLATFORM_LIVE_ROOM_ENTER", type="biliopenlive.events.BOpenliveWSSEvent")]
    /**
     * 接收到直播开始信息后派发。
     * @eventType biliopenlive.events.BOpenliveWSSEvent.LIVE_START
     */
    [Event(name="LIVE_OPEN_PLATFORM_LIVE_START", type="biliopenlive.events.BOpenliveWSSEvent")]
    /**
     * 接收到直播结束信息后派发。
     * @eventType biliopenlive.events.BOpenliveWSSEvent.LIVE_END
     */
    [Event(name="LIVE_OPEN_PLATFORM_LIVE_END", type="biliopenlive.events.BOpenliveWSSEvent")]
    /**
     * 接收到推送结束通知后派发。
     * @eventType biliopenlive.events.BOpenliveWSSEvent.INTERACTION_END
     */
    [Event(name="LIVE_OPEN_PLATFORM_INTERACTION_END", type="biliopenlive.events.BOpenliveWSSEvent")]
    /**
     * <p>
     * BOpenlivePipe类实现BOpenlive SDK的消息管道。
     * </p>
     * <p>
     * 订阅者通过对BOpenlivePipe相关事件进行订阅，从而实现对生命周期事件和直播间消息的响应。
     * </p>
     * <p>
     * 对于任意官方API请求，不论请求是否成功，都会触发相应的BOpenliveHTTPSEvent。
     * 开发者需要在回调函数中根据事件的success和data做进一步处理，如果请求成功与服务器通信，则success属性为true，否则为false；
     * 如果请求成功与服务器通信，则data为序列化的JSON数据，具体数据格式见开放平台文档，否则data可能为错误页面代码。
     * </p>
     * <p>
     * 对于消息长链命令，每次收到消息均会触发相应的BOpenliveWSSEvent。
     * 其中，事件的data是服务器返回数据中的data体，type是服务器返回数据的cmd值。请参考开放平台文档对不同命令做具体处理。
     * </p>
     * @playerversion AIR 51.0
     * @see https://open-live.bilibili.com/document/74eec767-e594-7ddd-6aba-257e8317c05d
     * @see https://open-live.bilibili.com/document/f9ce25be-312e-1f4a-85fd-fef21f1637f8
     */
    public class BOpenlivePipe extends EventDispatcher {
        private static var _instance: BOpenlivePipe;
        private var _code: String; //主播身份码
        private var _appId: String; //项目ID
        private var _gameId: String; //场次ID
        private var _heartbeat: HeartbeatTimer;
        private var _webSocket: BOpenliveWebSocket;
        /**
         * 返回BOpenlivePipe的单例。
         */
        public static function get bOpenlivePipe(): BOpenlivePipe {
            return _instance == null ? _instance = new BOpenlivePipe() : _instance;
        }
        public function get appId(): String {
            return _appId;
        }
        public function set appId(value: String): void {
            _appId = value;
        }
        public function get gameId(): String {
            return _gameId;
        }
        public function set gameId(value: String): void {
            _gameId = value;
        }

        /**
         * <p>
         * BOpenlivePipe类的构造函数。BOpenlivePipe是单例类型，请勿调用该构造函数。从第二次开始调用会引发ArgumentError。
         * </p>
         * <p>请直接使用bOpenlivePipe属性访问单例。</p>
         */
        public function BOpenlivePipe() {
            if (_instance != null) {
                throw(new ArgumentError("Error #2012: " + 
                (this as Object).constructor.toString()
                .replace("[class ", "").replace("]", "") + 
                "$ class cannot be instantiated.", 2012));
            }
        }
        /**
         * <p>
         * 发送开始请求。需要传递code并提前设置好appId，否则会抛出异常。
         * </p>
         * @param code 主播的身份码
         */
        public function linkStart(code: String): void {
            var startLoader: URLLoader;
            _code = code;
            if (_code == null || _appId == null) {
                Logger.error("HTTPS请求所需参数不得为空。");
                return;
            } else {
                startLoader = BOpenliveAPI.startInteractivePlay(_code, _appId);
            }
            startLoader.addEventListener(Event.COMPLETE, function(e: Event): void {
                var responseJSON: Object = JSON.parse(startLoader.data);
                if (responseJSON.code != 0) {
                    Logger.warning("HTTPS连接失败");
                    Logger.warning(responseJSON.code + ":" + responseJSON.message);
                } else {
                    Logger.message("HTTPS连接成功");
                    _gameId = responseJSON.data.game_info.game_id;
                    _heartbeat = new HeartbeatTimer(20000, _gameId);
                    _heartbeat.start();
                    _heartbeat.addEventListener(TimerEvent.TIMER, onHeartbeatTimer);
                    _webSocket = new BOpenliveWebSocket(responseJSON.data.websocket_info.wss_link, responseJSON.data.websocket_info.auth_body);
                    addWebSocketListener(_webSocket);
                }
                startLoader.removeEventListener(Event.COMPLETE, arguments.callee);
                dispatchEvent(new BOpenliveHTTPSEvent(BOpenliveHTTPSEvent.START, responseJSON, true));
            });
            startLoader.addEventListener(IOErrorEvent.IO_ERROR, function(e: IOErrorEvent): void {
                Logger.warning("HTTPS连接失败");
                startLoader.removeEventListener(IOErrorEvent.IO_ERROR, arguments.callee);
                dispatchEvent(new BOpenliveHTTPSEvent(BOpenliveHTTPSEvent.START, startLoader.data, false));
            });
        }
        /**
         * <p>
         * 发送结束请求。在调用该方法前，应当已经调用linkStart()方法且成功进行连接（服务器返回码为0），否则会抛出异常。
         * </p>
         */
        public function linkEnd(): void {
            var endLoader: URLLoader;
            if (_appId == null || _gameId == null) {
                Logger.error("HTTPS请求所需参数不得为空。");
                return;
            } else {
                endLoader = BOpenliveAPI.endInteractivePlay(_appId, _gameId);
            }
            endLoader.addEventListener(Event.COMPLETE, function(e: Event): void{
                var responseJSON: Object = JSON.parse(endLoader.data);
                if (responseJSON.code != 0) {
                    Logger.warning("HTTPS断连失败");
                    Logger.warning(responseJSON.code + ":" + responseJSON.message);
                } else {
                    Logger.message("HTTPS断连成功");
                    if (_heartbeat != null) {
                        _heartbeat.stop();
                        _heartbeat.removeEventListener(TimerEvent.TIMER, onHeartbeatTimer);
                        _heartbeat = null;
                    }
                }
                endLoader.removeEventListener(Event.COMPLETE, arguments.callee);
                dispatchEvent(new BOpenliveHTTPSEvent(BOpenliveHTTPSEvent.END, responseJSON, true));
            });
            endLoader.addEventListener(IOErrorEvent.IO_ERROR, function(e: IOErrorEvent): void{
                Logger.warning("HTTPS断连失败");
                endLoader.removeEventListener(IOErrorEvent.IO_ERROR, arguments.callee);
                dispatchEvent(new BOpenliveHTTPSEvent(BOpenliveHTTPSEvent.END, endLoader.data, false));
            });
        }
        private function onHeartbeatTimer(e: TimerEvent): void {
            var timerLoader: URLLoader = _heartbeat.loader;
            var ids: Array = _heartbeat.gameIds;
            timerLoader.addEventListener(Event.COMPLETE, function(e:Event): void {
                var responseJSON: Object = JSON.parse(timerLoader.data);
                if (responseJSON.code != 0) {
                    Logger.warning("HTTPS心跳失败");
                    Logger.warning(responseJSON.code + ":" + responseJSON.message);
                    if (responseJSON.data.failed_game_ids != null) {
                        Logger.warning("存在心跳失败的场次：" + responseJSON.data.failed_game_ids);
                    }
                } else {
                    Logger.message("HTTPS心跳成功");
                }
                timerLoader.removeEventListener(Event.COMPLETE, arguments.callee);
                if (ids.length == 1) {
                    dispatchEvent(new BOpenliveHTTPSEvent(BOpenliveHTTPSEvent.HEARTBEAT, responseJSON, true));
                } else if (ids.length > 1) {
                    dispatchEvent(new BOpenliveHTTPSEvent(BOpenliveHTTPSEvent.BATCH_HEARTBEAT, responseJSON, true));
                }
            });
            timerLoader.addEventListener(IOErrorEvent.IO_ERROR, function(e:Event): void {
                Logger.warning("HTTPS心跳失败");
                timerLoader.removeEventListener(IOErrorEvent.IO_ERROR, arguments.callee);
                if (ids.length == 1) {
                    dispatchEvent(new BOpenliveHTTPSEvent(BOpenliveHTTPSEvent.HEARTBEAT, timerLoader.data, false));
                } else if (ids.length > 1) {
                    dispatchEvent(new BOpenliveHTTPSEvent(BOpenliveHTTPSEvent.BATCH_HEARTBEAT, timerLoader.data, false));
                }
            });
        }
        private function addWebSocketListener(webSocket: BOpenliveWebSocket): void {
            if (webSocket == _webSocket) {
                _webSocket.connect();
                _webSocket.addEventListener(BOpenliveWSSEvent.DM, dispatchWebSocketEvent);
                _webSocket.addEventListener(BOpenliveWSSEvent.SEND_GIFT, dispatchWebSocketEvent);
                _webSocket.addEventListener(BOpenliveWSSEvent.SUPER_CHAT, dispatchWebSocketEvent);
                _webSocket.addEventListener(BOpenliveWSSEvent.SUPER_CHAT_DEL, dispatchWebSocketEvent);
                _webSocket.addEventListener(BOpenliveWSSEvent.GUARD, dispatchWebSocketEvent);
                _webSocket.addEventListener(BOpenliveWSSEvent.LIKE, dispatchWebSocketEvent);
                _webSocket.addEventListener(BOpenliveWSSEvent.LIVE_ROOM_ENTER, dispatchWebSocketEvent);
                _webSocket.addEventListener(BOpenliveWSSEvent.LIVE_START, dispatchWebSocketEvent);
                _webSocket.addEventListener(BOpenliveWSSEvent.LIVE_END, dispatchWebSocketEvent);
                _webSocket.addEventListener(BOpenliveWSSEvent.INTERACTION_END, dispatchWebSocketEvent);
            }
        }
        private function dispatchWebSocketEvent(e: BOpenliveWSSEvent): void {
            dispatchEvent(new BOpenliveWSSEvent(e.type, e.data));
        }
    }
}