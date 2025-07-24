package biliopenlive.utils {
    import biliopenlive.events.*;
    import biliopenlive.pipe.*;

    /**
     * <p>
     * WSSDataHandler提供长链消息的简单输出。
     * </p>
     * @playerversion AIR 51.0
     */
    public class WSSDataHandler {
        /**
         * <p>构造新的WSSDataHandler实例。</p>
         */
        public function WSSDataHandler() {
            //noop
        }
        /**
         * <p>启动对长链消息事件的侦听。</p>
         */
        public function startListen(): void {
            BOpenlivePipe.bOpenlivePipe.addEventListener(BOpenliveWSSEvent.DM, onDM);
            BOpenlivePipe.bOpenlivePipe.addEventListener(BOpenliveWSSEvent.SEND_GIFT, onSendGift);
            BOpenlivePipe.bOpenlivePipe.addEventListener(BOpenliveWSSEvent.SUPER_CHAT, onSuperChat);
            BOpenlivePipe.bOpenlivePipe.addEventListener(BOpenliveWSSEvent.SUPER_CHAT_DEL, onSuperChatDelete);
            BOpenlivePipe.bOpenlivePipe.addEventListener(BOpenliveWSSEvent.GUARD, onGuard);
            BOpenlivePipe.bOpenlivePipe.addEventListener(BOpenliveWSSEvent.LIKE, onLike);
            BOpenlivePipe.bOpenlivePipe.addEventListener(BOpenliveWSSEvent.LIVE_ROOM_ENTER, onLiveRoomEnter);
            BOpenlivePipe.bOpenlivePipe.addEventListener(BOpenliveWSSEvent.LIVE_START, onLiveStart);
            BOpenlivePipe.bOpenlivePipe.addEventListener(BOpenliveWSSEvent.LIVE_END, onLiveEnd);
            BOpenlivePipe.bOpenlivePipe.addEventListener(BOpenliveWSSEvent.INTERACTION_END, onInteractionEnd);
        }
        /**
         * <p>结束对长链消息事件的侦听。</p>
         */
        public function endListen(): void {
            BOpenlivePipe.bOpenlivePipe.removeEventListener(BOpenliveWSSEvent.DM, onDM);
            BOpenlivePipe.bOpenlivePipe.removeEventListener(BOpenliveWSSEvent.SEND_GIFT, onSendGift);
            BOpenlivePipe.bOpenlivePipe.removeEventListener(BOpenliveWSSEvent.SUPER_CHAT, onSuperChat);
            BOpenlivePipe.bOpenlivePipe.removeEventListener(BOpenliveWSSEvent.SUPER_CHAT_DEL, onSuperChatDelete);
            BOpenlivePipe.bOpenlivePipe.removeEventListener(BOpenliveWSSEvent.GUARD, onGuard);
            BOpenlivePipe.bOpenlivePipe.removeEventListener(BOpenliveWSSEvent.LIKE, onLike);
            BOpenlivePipe.bOpenlivePipe.removeEventListener(BOpenliveWSSEvent.LIVE_ROOM_ENTER, onLiveRoomEnter);
            BOpenlivePipe.bOpenlivePipe.removeEventListener(BOpenliveWSSEvent.LIVE_START, onLiveStart);
            BOpenlivePipe.bOpenlivePipe.removeEventListener(BOpenliveWSSEvent.LIVE_END, onLiveEnd);
            BOpenlivePipe.bOpenlivePipe.removeEventListener(BOpenliveWSSEvent.INTERACTION_END, onInteractionEnd);
        }
        private function onDM(e: BOpenliveWSSEvent): void {
            var json: Object = e.data;
            var output: String = "";
            if (json.is_admin == 1) {
                output += "（房）";
            }
            if (json.glory_level > 0) {
                output += "（荣耀等级" + json.glory_level + "）";
            }
            if (json.fans_medal_level > 0) {
                output += "【" + json.fans_medal_name + json.fans_medal_level + "】";
            }
            output += json.uname + "：";
            if (json.reply_uname != "") {
                output += " @" + json.reply_uname + " ";
            }
            output += json.msg;
            Logger.message(output);
        }
        private function onSendGift(e: BOpenliveWSSEvent): void {
            var json: Object = e.data;
            var output: String = "";
            if (json.fans_medal_level > 0) {
                output += "【" + json.fans_medal_name + json.fans_medal_level + "】";
            }
            output += json.uname + " 投喂 " + json.gift_name;
            if (json.combo_gift) {
                output += "x" + json.combo_info?.combo_base_num + json.combo_info?.combo_count + "连击";
            } else {
                if (json.gift_num > 1) {
                    output += "x" + json.gift_num;
                }
            }
            Logger.message(output);
        }
        private function onSuperChat(e: BOpenliveWSSEvent): void {
            var json: Object = e.data;
            var output: String = "\n";
            output += json.uname + "                        " + "标签悬挂时长" + (json.end_time - json.start_time) + "秒\n";
            output += "￥" + json.rmb + "（" + (json.rmb * 1000) + "金瓜子）\n\n";
            output += json.message + "\n\n";
            Logger.message(output);
        }
        private function onSuperChatDelete(e: BOpenliveWSSEvent): void {
            var json: Object = e.data;
            var output: String = "";
            output += "以下ID的留言被撤回："
            for each(var messageId: Number in json.message_ids) {
                output += messageId;
                if (messageId != json.message_ids[json.message_ids.length - 1]) {
                    output += "、";
                }
            }
            Logger.warning(output);
        }
        private function onGuard(e: BOpenliveWSSEvent): void {
            var json: Object = e.data;
            var output: String = "";
            output += json.user_info.uname += "开通/续费了";
            if (json.guard_unit != "月") {
                output += json.guard_unit;
            } else {
                output += "*" + json.guard_num + json.guard_unit;
            }
            if (json.guard_level == 1) {
                output += "总督";
            } else if (json.guard_level == 2) {
                output += "提督";
            } else if (json.guard_level == 3) {
                output += "舰长";
            }
            output += "，花费" + (json.price / 100) + "电池";
            Logger.message(output);
        }
        private function onLike(e: BOpenliveWSSEvent): void {
            var json: Object = e.data;
            var output: String = "";
            output += json.uname + "给主播点赞了" + json.like_count + "次";
            Logger.message(output);
        }
        private function onLiveRoomEnter(e: BOpenliveWSSEvent): void {
            var json: Object = e.data;
            var output: String = "";
            output += json.uname + " 进入直播间";
            Logger.message(output);
        }
        private function onLiveStart(e: BOpenliveWSSEvent): void {
            var json: Object = e.data;
            var output: String = "";
            output += "主播开播了 " + json.title;
            Logger.message(output);
        }
        private function onLiveEnd(e: BOpenliveWSSEvent): void {
            var json: Object = e.data;
            var output: String = "";
            output += "主播下播了";
            Logger.message(output);
        }
        private function onInteractionEnd(e: BOpenliveWSSEvent): void {
            var json: Object = e.data;
            var output: String = "";
            output += "连接已断开，若非主动断开请检查程序逻辑！";
            Logger.warning(output);
        }
    }
}