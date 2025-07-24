package biliopenlive.display {
	import flash.display.Shape;
	import flash.display.SimpleButton;
	import flash.display.Sprite;
	import flash.display.Stage;
	import flash.events.Event;
	import flash.events.FocusEvent;
	import flash.events.MouseEvent;
	import flash.text.TextField;
	import flash.utils.Timer;
	import flash.events.TimerEvent;

	[Event(name="change", type="flash.events.Event")]
	[Event(name="complete", type="flash.events.Event")]
	[Event(name="connect", type="flash.events.Event")]
	public class BOpenliveAuthPanel extends Sprite {
		private const HOLD_PLACE: String = "请输入身份码";
		private const _animationTimer: Timer = new Timer(16.6);
		private var _background: Shape;
		private var _title: TextField;
		private var _input: Sprite;
		private var _inputField: TextField;
		private var _buttonClear: SimpleButton;
		private var _button: SimpleButton;
		private var _toggle: Sprite;
		private var _checkmark: SimpleButton
		private var _buttonClose: SimpleButton;
		private var _animationForward: Boolean;
		private var _animationPercent: Number;
		private var _lastTime: Number;
		public function get checkmark(): Boolean {
			return _checkmark.visible;
		}
		public function set checkmark(value: Boolean): void {
			_checkmark.visible = value;
		}
		public function get code(): String {
			return _inputField.text;
		}
		public function set code(value: String): void {
			_inputField.text = value;
			_inputField.textColor = 0x323232;
		}

		public function BOpenliveAuthPanel() {
			if (parent is Stage) { //在Flash Player中单元测试用
				x = stage.stageWidth / 2;
				y = stage.stageHeight / 2;
			} else {
				visible = false;
			}
			_background = getChildAt(0) as Shape;
			_title = getChildAt(1) as TextField;
			_input = getChildAt(2) as Sprite;
			_inputField = _input.getChildAt(2) as TextField;
			_buttonClear = _input.getChildAt(3) as SimpleButton;
			_button = getChildAt(3) as SimpleButton;
			_toggle = getChildAt(5) as Sprite;
			_checkmark = _toggle.getChildAt(1) as SimpleButton;
			_buttonClose = getChildAt(6) as SimpleButton;
			addInputFieldListener();
			addButtonClearListener();
			addButtonListener();
			addToggleListener();
			addButtonCloseListener();
			_animationTimer.addEventListener(TimerEvent.TIMER, onTimer);
		}
		private function addInputFieldListener(): void {
			if (_inputField != null) {
				_inputField.text = HOLD_PLACE;
				_inputField.addEventListener(FocusEvent.FOCUS_IN, function(e: FocusEvent): void {
					if (_inputField.text == HOLD_PLACE) {
						_inputField.text = "";
						_inputField.textColor = 0x323232;
					}
				});
				_inputField.addEventListener(FocusEvent.FOCUS_OUT, function(e: FocusEvent): void {
					if (_inputField.text == "") {
						_inputField.text = HOLD_PLACE;
						_inputField.textColor = 0xC9CCD0;
					}
				});
			}
		}
		private function addButtonClearListener(): void {
			if (_buttonClear != null) {
				_buttonClear.addEventListener(MouseEvent.CLICK, function(e: MouseEvent): void {
					if (_inputField != null) {
						_inputField.text = HOLD_PLACE;
						_inputField.textColor = 0xC9CCD0;
					}
				});
			}
		}
		private function addButtonListener(): void {
			if (_button != null) {
				_button.addEventListener(MouseEvent.CLICK, function(e: MouseEvent): void{
					dispatchEvent(new Event(Event.CONNECT));
				});
			}
		}
		private function addToggleListener(): void {
			if (_toggle != null) {
				if (_checkmark != null) {
					_checkmark.visible = false;
				}
				_toggle.addEventListener(MouseEvent.CLICK, function(e: MouseEvent): void {
					_checkmark.visible = !_checkmark.visible;
					dispatchEvent(new Event(Event.CHANGE));
				});
			}
		}
		private function addButtonCloseListener(): void {
			if (_buttonClose != null) {
				_buttonClose.addEventListener(MouseEvent.CLICK, function(e: MouseEvent): void {
					hide();
				});
			}
		}
		private function onTimer(e: TimerEvent): void {
			var delta: Number = ((new Date()).valueOf() - _lastTime) / 1000 / 0.664;
			if (_animationForward) {
				if (_animationPercent >= 1) {
					_animationPercent = 1;
					scaleX = 1;
					scaleY = 1;
					_animationTimer.stop();
					dispatchEvent(new Event(Event.COMPLETE));
				} else if (_animationPercent >= 0.6) {
					scaleX = 1.1 - (_animationPercent - 0.6) * 0.25;
					scaleY = 1.1 - (_animationPercent - 0.6) * 0.25;
				} else {
					scaleX = _animationPercent * 1.83;
					scaleY = _animationPercent * 1.83;
				}
			} else {
				if (_animationPercent >= 1) {
					_animationPercent = 1;
					scaleX = 0;
					scaleY = 0;
					_animationTimer.stop();
					dispatchEvent(new Event(Event.COMPLETE));
				} else if (_animationPercent >= 0.4) {
					scaleX = 1.1 - (_animationPercent - 0.4) * 1.83;
					scaleY = 1.1 - (_animationPercent - 0.4) * 1.83;
				} else {
					scaleX = 1 + _animationPercent * 0.36;
					scaleY = 1 + _animationPercent * 0.36;
				}
			}
			_animationPercent += delta;
			_lastTime = (new Date()).valueOf();
		}
		public function show(): void {
			_lastTime = (new Date()).valueOf();
			_animationForward = true;
			_animationPercent = 0;
			_animationTimer.reset();
			_animationTimer.start();
			scaleX = 0;
			scaleY = 0;
			visible = true;
		}
		public function hide(): void {
			_lastTime = (new Date()).valueOf();
			_animationForward = false;
			_animationPercent = 0;
			_animationTimer.reset();
			_animationTimer.start();
			scaleX = 1;
			scaleY = 1;
			visible = true;
		}
	}
	
}
