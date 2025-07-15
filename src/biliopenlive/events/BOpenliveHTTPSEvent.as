package biliopenlive.events {
    import flash.events.*;

    /**
     * <p>
     * 当BOpenlive SDK接收到哔哩哔哩直播开放平台的官方API响应时，触发BOpenliveHTTPSEvent。
     * </p>
     * <p>
     * 通过BOpenlivePipe类侦听相关事件。
     * </p>
     * @playerversion AIR 51.0
     */
    public class BOpenliveHTTPSEvent extends Event {
        public static const START: String = "start";
        public static const END: String = "end";
        public static const HEARTBEAT: String = "heartbeat";
        public static const BATCH_HEARTBEAT: String = "batchHeartbeat";
        private var _data: Object;
        private var _success: Boolean;
        /**
         * <p>success为true时，data是序列化的JSON数据。</p>
         * <p>success为false时，data可能是服务器返回的错误页面代码。</p>
         */
        public function get data(): Object {
            return _data;
        }
        /**
         * 表示请求是否成功。
         */
        public function get success(): Boolean {
            return _success;
        }

        /**
         * <p>构造新的BOpenliveHTTPSEvent。</p>
         */
        public function BOpenliveHTTPSEvent(type: String, data: Object, success: Boolean, bubbles: Boolean = false, cancelable: Boolean = false) {
            super(type, bubbles, cancelable);
            _data = data;
            _success = success;
        }
    }
}