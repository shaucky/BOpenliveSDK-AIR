package biliopenlive.net {
    import biliopenlive.utils.*;
    import flash.net.*;

    /**
     * <p>
     * BOpenliveAPI类提供BOpenlive SDK对哔哩哔哩直播开放平台官方API的访问。通过传递相关权证，访问官方API，实现项目生命周期的交互。
     * </p>
     * <p>
     * 建议通过BOpenlivePipe类获取封装好的事件进行对请求结果的处理。
     * </p>
     * @playerversion AIR 51.0
     * @see https://open-live.bilibili.com/document/eba8e2e1-847d-e908-2e5c-7a1ec7d9266f
     */
    public final class BOpenliveAPI {
        public static var isTestEnv: Boolean;
        private static const APP_START: String = "/v2/app/start";
        private static const APP_END: String = "/v2/app/end";
        private static const APP_HEARTBEAT: String = "/v2/app/heartbeat";
        private static const APP_BATCH_HEARTBEAT: String = "/v2/app/batchHeartbeat";
        private static const POST: String = "POST";
        private static function get openLiveDomain(): String {
            return isTestEnv ? "http://test-live-open.biliapi.net" : "https://live-open.biliapi.com";
        }

        /**
         * <p>构建开始请求。</p>
         * @param code 主播的身份码
         * @param appId 应用ID
         */
        public static function startInteractivePlay(code: String, appId: String): URLLoader {
            var postUrl: String = openLiveDomain + APP_START;
            var param: String = JSON.stringify({
                code: code,
                app_id: Number(appId)
            });
            return requestWeb(postUrl, POST, param);
        }
        /**
         * <p>构建结束请求。</p>
         * @param appId 应用ID
         * @param gameId 场次ID
         */
        public static function endInteractivePlay(appId: String, gameId: String): URLLoader {
            var postUrl: String = openLiveDomain + APP_END;
            var param: String = JSON.stringify({
                app_id: Number(appId),
                game_id: gameId
            });
            return requestWeb(postUrl, POST, param);
        }
        /**
         * <p>构建心跳请求。</p>
         * @param gameId 场次ID
         */
        public static function heartbeatInteractivePlay(gameId: String): URLLoader {
            var postUrl: String = openLiveDomain + APP_HEARTBEAT;
            var param: String = JSON.stringify({
                game_id: gameId
            });
            return requestWeb(postUrl, POST, param);
        }
        /**
         * <p>构建批量心跳请求。</p>
         * @param gameIds 场次ID数组
         */
        public static function batchHeartbeatInteractivePlay(gameIds: Array): URLLoader {
            var postUrl: String = openLiveDomain + APP_BATCH_HEARTBEAT;
            var param: String = JSON.stringify({
                game_ids: gameIds
            });
            return requestWeb(postUrl, POST, param);
        }
        private static function requestWeb(url: String, method: String, param: String, cookie: String = null): URLLoader {
            var webRequest: URLRequest = new URLRequest(url);
            var loader: URLLoader;
            webRequest.method = method;
            if (param != null) {
                SignUtility.setRequestHeader(webRequest, param, cookie);
            }
            loader = new URLLoader();
            loader.dataFormat = URLLoaderDataFormat.TEXT;
            loader.load(webRequest);
            return loader;
        }
    }
}