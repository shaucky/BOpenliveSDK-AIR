package biliopenlive.utils {
    import biliopenlive.net.*;
    import flash.events.*;
    import flash.net.*;
    import flash.utils.*;

    /**
     * <p>HeartbeatTimer类用于管理BOpenlive SDK的心跳周期。</p>
     * <p>构造后需要调用继承的start()方法以开始计时。</p>
     * @playerversion AIR 51.0
     */
    public final class HeartbeatTimer extends Timer {
        /**
         * <p>心跳计时器负责的场次ID，可能存在1或多个值。</p>
         */
        public var gameIds: Array;
        /**
         * <p>对发出该心跳请求的URLLoader的引用。</p>
         */
        public var loader: URLLoader;

        /**
         * <p>构造新的心跳计时器。</p>
         * <p>构造后需要调用继承的start()方法以开始计时。</p>
         * @param delay 计时器的触发周期，以毫秒为单位。
         * @param gameIds 计时器负责的场次ID，应当提供至少1个。
         */
        public function HeartbeatTimer(delay: Number, ...gameIds) {
            super(delay, 0);
            this.gameIds = gameIds;
            addEventListener(TimerEvent.TIMER, onTimer);
        }
        private function onTimer(e: TimerEvent): void {
            if (loader != null) {
                //noop
            }
            if (gameIds != null) {
                if (gameIds.length == 1) {
                    loader = BOpenliveAPI.heartbeatInteractivePlay(gameIds[0]);
                } else {
                    loader = BOpenliveAPI.batchHeartbeatInteractivePlay(gameIds);
                }
            }
        }
    }
}