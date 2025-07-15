package biliopenlive.events {
    import flash.events.*;

    /**
     * <p>
     * 当BOpenlive SDK接收到直播间相关消息响应时，触发BOpenliveWSSEvent。
     * </p>
     * <p>
     * 通过BOpenlivePipe类侦听相关事件。
     * </p>
     * @playerversion AIR 51.0
     */
    public class BOpenliveWSSEvent extends Event {
        public static const DM: String = "LIVE_OPEN_PLATFORM_DM";
        public static const SEND_GIFT: String = "LIVE_OPEN_PLATFORM_SEND_GIFT";
        public static const SUPER_CHAT: String = "LIVE_OPEN_PLATFORM_SUPER_CHAT";
        public static const SUPER_CHAT_DEL: String = "LIVE_OPEN_PLATFORM_SUPER_CHAT_DEL";
        public static const GUARD: String = "LIVE_OPEN_PLATFORM_GUARD";
        public static const LIKE: String = "LIVE_OPEN_PLATFORM_LIKE";
        public static const LIVE_ROOM_ENTER: String = "LIVE_OPEN_PLATFORM_LIVE_ROOM_ENTER";
        public static const LIVE_START: String = "LIVE_OPEN_PLATFORM_LIVE_START";
        public static const LIVE_END: String = "LIVE_OPEN_PLATFORM_LIVE_END";
        public static const INTERACTION_END: String = "LIVE_OPEN_PLATFORM_INTERACTION_END";
        private var _data: Object;
        private var _success: Boolean;
        /**
         * <p>服务器返回的JSON数据体。</p>
         */
        public function get data(): Object {
            return _data;
        }

        /**
         * <p>构造新的BOpenliveWSSEvent。</p>
         */
        public function BOpenliveWSSEvent(type: String, data: Object, bubbles: Boolean = false, cancelable: Boolean = false) {
            super(type, bubbles, cancelable);
            _data = data;
        }
    }
}