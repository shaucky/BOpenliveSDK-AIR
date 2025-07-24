package biliopenlive.utils {
    /**
     * Logger是BOpenlive SDK的调试输出工具，主要用于文本内容输出。
     * @playerversion AIR 51.0
     */
    public final class Logger {
        /**
         * <p>
         * Logger是不允许被实例化的类型，尝试调用该构造函数将抛出ArgumentError。
         * </p>
         * <p>
         * 请直接调用Logger的静态方法。
         * </p>
         */
        public function Logger() {
            throw(new ArgumentError("Error #2012: " + 
            (this as Object).constructor.toString()
            .replace("[class ", "").replace("]", "") + 
            "$ class cannot be instantiated.", 2012));
        }
        /**
         * <p>
         * 输出一段消息。
         * </p>
         * @param content 要输出的内容。
         */
        public static function message(content: Object): void {
            trace("〔Logger message: " + content?.toString() + "〕");
        }
        /**
         * <p>
         * 警告一段消息。
         * </p>
         * @param content 要警告的内容。
         */
        public static function warning(content: Object): void {
            trace("［Logger warning: " + content?.toString() + "］");
        }
        /**
         * <p>
         * 报错一段消息。调用该方法的同时会抛出Error。
         * </p>
         * @param content 要报错的内容。
         */
        public static function error(content: Object): void {
            trace("〈Logger error: " + content?.toString() + "〉");
            throw(new Error("Error #2044: Unhandled Error:.", 2044));
        }
    }
}