package biliopenlive.net {
    /**
     * <p>
     * BOpenliveWebSocketOperation类提供BOpenliveWebSocket所需的相关枚举值。
     * </p>
     * @playerversion AIR 51.0
     */
    public final class BOpenliveWebSocketOperation {
        public static const OP_HEARTBEAT: int = 2;
        public static const OP_HEARTBEAT_REPLY: int = 3;
        public static const OP_SEND_SMS_REPLY : int = 5;
        public static const OP_AUTH: int = 7;
        public static const OP_AUTH_REPLY: int = 8;
        /**
         * <p>BOpenliveWebSocketOperation是不允许被实例化的枚举类，尝试调用该构造函数将抛出ArgumentError。</p>
         */
        public function BOpenliveWebSocketOperation() {
            throw(new ArgumentError("Error #2012: " + 
            (this as Object).constructor.toString()
            .replace("[class ", "").replace("]", "") + 
            "$ class cannot be instantiated.", 2012));
        }
    }
}