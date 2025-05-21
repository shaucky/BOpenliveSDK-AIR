package  {
	import biliopenlive.events.BOpenliveHTTPSEvent;
	import biliopenlive.pipe.BOpenlivePipe;
	import biliopenlive.utils.SignUtility;
	import flash.desktop.NativeApplication;
	import flash.display.DisplayObject;
	import flash.display.Loader;
	import flash.display.MovieClip;
	import flash.display.NativeWindow;
	import flash.display.NativeWindowInitOptions;
	import flash.display.NativeWindowSystemChrome;
	import flash.display.NativeWindowRenderMode;
	import flash.display.Screen;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	import flash.events.Event;
	import flash.events.InvokeEvent;
	import flash.net.SharedObject;
	import flash.net.URLRequest;
	import flash.events.EventDispatcher;
	import biliopenlive.utils.WSSDataHandler;
	
	public class Main extends MovieClip {
		private var _authPanelLoader: Loader = new Loader();
		private var _authPanel: Object;
		private var _sharedObject: SharedObject = SharedObject.getLocal("bopenlivesdkdemo");
		private var _appId: String;
		private var _code: String;
		private var _invokeCode: Boolean = false;
		private var _access_key: String;
		private var _access_secret: String;
		
		public function Main() {
			_authPanelLoader.load(new URLRequest("bOpenliveAuthPanel.swf"));
			_authPanelLoader.contentLoaderInfo.addEventListener(Event.COMPLETE, onAuthPanelLoadComplete);
			NativeApplication.nativeApplication.addEventListener(InvokeEvent.INVOKE, onApplicationInvoke);
			(new WSSDataHandler()).startListen();
		}
		private function startLink(): void {
			if (_appId != null && _code != null && _access_key != null && _access_secret != null) {
				SignUtility.accessKeyId = _access_key;
				SignUtility.accessKeySecret = _access_secret;
				BOpenlivePipe.bOpenlivePipe.appId = _appId;
				BOpenlivePipe.bOpenlivePipe.linkStart(_code);
				BOpenlivePipe.bOpenlivePipe.addEventListener(BOpenliveHTTPSEvent.START, function(e :BOpenliveHTTPSEvent): void {
					if (e.data.code == 0) {
						if (_authPanel != null) {
							_authPanel.removeEventListener(Event.COMPLETE, exit);
							_authPanel.hide();
							_authPanel.addEventListener(Event.COMPLETE, function(e: Event): void {
								(_authPanel as DisplayObject).stage.nativeWindow.close();
								stage.nativeWindow.title = "项目初始窗口";
								stage.nativeWindow.activate();
								stage.nativeWindow.addEventListener(Event.CLOSING, onOriginalWindowClosing);
							});
						} else {
							stage.nativeWindow.title = "项目初始窗口";
							stage.nativeWindow.activate();
							stage.nativeWindow.addEventListener(Event.CLOSING, onOriginalWindowClosing);
						}
					} else {
						NativeApplication.nativeApplication.exit();
					}
				});
			}
		}
		private function onApplicationInvoke(e: InvokeEvent): void {
			var args: Array = e.arguments;
			for each(var param: String in args)
			{
				if (param.indexOf("code=") == 0) {
					_code = param.replace("code=", "");
					_invokeCode = true;
					break;
				}
			}
			if (_invokeCode) {
				startLink();
			}
		}
		private function onAuthPanelLoadComplete(e: Event): void {
			var window: NativeWindow;
			var options: NativeWindowInitOptions = new NativeWindowInitOptions();
			if (!_invokeCode) {
				_authPanel = _authPanelLoader.content;
				options.systemChrome = NativeWindowSystemChrome.NONE;
				options.renderMode = NativeWindowRenderMode.DIRECT;
				options.transparent = true;
				window = new NativeWindow(options);
				window.title = "认证身份后可开启玩法";
				window.stage.align = StageAlign.TOP_LEFT;
				window.stage.scaleMode = StageScaleMode.NO_SCALE;
				window.width = 404 * 1.1;
				window.height = 254 * 1.1;
				window.x = ((Screen.mainScreen.bounds.width / Screen.mainScreen.contentsScaleFactor) - window.width) / 2;
				window.y = ((Screen.mainScreen.bounds.height / Screen.mainScreen.contentsScaleFactor) - window.height) / 2;
				_authPanel.x = window.stage.stageWidth / 2;
				_authPanel.y = window.stage.stageHeight / 2;
				_authPanel.show();
				window.activate();
				window.stage.addChild(_authPanel as DisplayObject);
				if (_sharedObject.data.rememberCode) {
					_authPanel.code = _sharedObject.data.code;
					_authPanel.checkmark = true;
				}
				(_authPanel as EventDispatcher).addEventListener(Event.COMPLETE, function(e: Event): void {
					_authPanel.addEventListener(Event.COMPLETE, exit);
					_authPanel.addEventListener(Event.CONNECT, function(e: Event): void {
						_sharedObject.data.rememberCode = _authPanel.checkmark;
						if (_authPanel.checkmark) {
							_sharedObject.data.code = _authPanel.code;
						} else {
							_sharedObject.data.code = "";
						}
						_code = e.target.code;
						startLink();
					});
				});
			}
		}
		private function onOriginalWindowClosing(e: Event): void {
			e.preventDefault();
			BOpenlivePipe.bOpenlivePipe.linkEnd();
			stage.nativeWindow.removeEventListener(Event.CLOSING, onOriginalWindowClosing);
			BOpenlivePipe.bOpenlivePipe.addEventListener(BOpenliveHTTPSEvent.END, function(e: BOpenliveHTTPSEvent): void {
				stage.nativeWindow.close();
			});
		}
		private function exit(e: Event): void {
			NativeApplication.nativeApplication.exit();
		}
	}
	
}
