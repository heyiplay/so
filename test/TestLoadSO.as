package 
{
	import com.tudou.net.SWFLoader;
	import com.tudou.utils.Debug;
	import com.tudou.utils.Utils;
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import flash.events.ErrorEvent;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.MouseEvent;
	import flash.events.NetStatusEvent;
	import flash.events.SecurityErrorEvent;
	import flash.text.TextField;
	import flash.text.TextFieldType;
	import flash.text.TextFormat;
	/**
	 * ...
	 * @author 8088
	 */
	public class TestLoadSO extends Sprite
	{
		
		public function TestLoadSO() 
		{
			if (stage) onStage();
			else addEventListener(Event.ADDED_TO_STAGE, onStage);
		}
		
		private function onStage(evt:Event=null):void
		{
			removeEventListener(Event.ADDED_TO_STAGE, onStage);
			
			loadModule();
			
			initUI();
		}
		
		private var name_txt:TextField;
		private var path_txt:TextField;
		private var view_txt:TextField;
		private var get_txt:TextField;
		private var key_txt:TextField;
		private var value_txt:TextField;
		private var delete_txt:TextField;
		
		
		private var name_btn:Button;
		private var read_btn:Button;
		private var clear_btn:Button;
		private var save_btn:Button;
		private var get_btn:Button;
		private var set_btn:Button;
		private var delete_btn:Button;
		private function initUI():void
		{
			var namespace_txt:TextField = creatTxt(10, 10, 100, 20, false, TextFieldType.DYNAMIC);
			namespace_txt.text = "名字：player.store.";
			addChild(namespace_txt);
			
			name_txt = creatTxt(110, 10, 60, 20, true, TextFieldType.INPUT);
			addChild(name_txt);
			
			var root_txt:TextField = creatTxt(180, 10, 60, 20, false, TextFieldType.DYNAMIC);
			root_txt.text = "路径：";
			addChild(root_txt);
			
			path_txt = creatTxt(215, 10, 135, 20, true, TextFieldType.INPUT);
			path_txt.text = "/";
			addChild(path_txt);
			
			var log_txt:TextField = creatTxt(10, 30, 60, 20, false, TextFieldType.DYNAMIC);
			log_txt.text = "显示结果：";
			addChild(log_txt);
			
			view_txt = creatTxt(10, 50, 230, 300, true, TextFieldType.DYNAMIC);
			view_txt.multiline = true;
			view_txt.wordWrap = true;
			addChild(view_txt);
			
			name_btn = new Button(110, 22, "改变文件名或路径");
			name_btn.x = 360;
			name_btn.y = 9;
			name_btn.addEventListener(MouseEvent.CLICK, setSoNameOrPath);
			addChild(name_btn);
			
			read_btn = new Button(66, 22, "取出所有");
			read_btn.x = 9;
			read_btn.y = 355;
			read_btn.addEventListener(MouseEvent.CLICK, getAll);
			addChild(read_btn);
			
			clear_btn = new Button(66, 22, "清空所有");
			clear_btn.x = 80;
			clear_btn.y = 355;
			clear_btn.addEventListener(MouseEvent.CLICK, onClear);
			addChild(clear_btn);
			
			save_btn = new Button(92, 22, "保存一默认对象");
			save_btn.x = 150;
			save_btn.y = 355;
			save_btn.addEventListener(MouseEvent.CLICK, onSave);
			addChild(save_btn);
			
			get_txt = creatTxt(250, 50, 60, 20, true, TextFieldType.INPUT);
			addChild(get_txt);
			get_btn= new Button(30, 22, "get");
			get_btn.x = 315;
			get_btn.y = 49;
			get_btn.addEventListener(MouseEvent.CLICK, onGet);
			addChild(get_btn);
			
			var key:TextField = creatTxt(248, 80, 40, 20, false, TextFieldType.DYNAMIC);
			key.text = "key："
			addChild(key);
			var value:TextField = creatTxt(333, 80, 40, 20, false, TextFieldType.DYNAMIC);
			value.text = "-value："
			addChild(value);
			
			key_txt = creatTxt(275, 80, 55, 20, true, TextFieldType.INPUT);
			addChild(key_txt);
			value_txt = creatTxt(375, 80, 60, 20, true, TextFieldType.INPUT);
			addChild(value_txt);
			set_btn= new Button(30, 22, "set");
			set_btn.x = 440;
			set_btn.y = 79;
			set_btn.addEventListener(MouseEvent.CLICK, onSet);
			addChild(set_btn);
			
			delete_txt = creatTxt(355, 50, 60, 20, true, TextFieldType.INPUT);
			addChild(delete_txt);
			delete_btn= new Button(50, 22, "delete");
			delete_btn.x = 420;
			delete_btn.y = 49;
			delete_btn.addEventListener(MouseEvent.CLICK, onDelete);
			addChild(delete_btn);
		}
		
		private function setSoNameOrPath(evt:MouseEvent):void
		{
			if (_so)
			{
				_so.name = name_txt.text;
				_so.path = path_txt.text;
			}
		}
		
		private function getAll(evt:MouseEvent):void
		{
			if (_so)
			{
				var data:Object = _so.read();
				
				/*var str:String = "";
				for (var key:* in data)
				{
					str += key + ": " + data[key] + "\n";
				}*/
				
				view_txt.text = Utils.serialize(data);
				
			}
		}
		
		private function onClear(evt:MouseEvent):void
		{
			if (_so)
			{
				_so.clear();
				view_txt.text = "";
			}
		}
		
		private function onSave(evt:MouseEvent):void
		{
			if (_so)
			{
				var obj:Object = { loopPlay:true, autoPlay:true, volume:0.3, id:"test", handler:"swf"};
				_so.save(obj);
			}
		}
		
		private function onGet(evt:MouseEvent):void
		{
			if (get_txt.text == "") return;
			if (_so)
			{
				view_txt.text = String(_so.getValue(get_txt.text));
			}
		}
		
		private function onDelete(evt:MouseEvent):void
		{
			if (delete_txt.text == "") return;
			if (_so)
			{
				_so.clear(delete_txt.text);
			}
		}
		
		private function onSet(evt:MouseEvent):void
		{
			if (key_txt.text == "" || value_txt.text=="") return;
			if (_so)
			{
				_so.setValue(key_txt.text, value_txt.text);
			}
		}
		
		private function creatTxt(_x:Number, _y:Number, _w:Number, _h:Number, _b:Boolean, _type:String):TextField
		{
			var format:TextFormat = new TextFormat();
			format.font = "Arial"
			format.size = 12;
			format.color = 0x999999;
			
			var txt:TextField = new TextField();
			txt.border = _b;
			if(_b) txt.borderColor = 0xCCCCCC;
			txt.x = _x;
			txt.y = _y;
			txt.height = _h;
			txt.width = _w;
			txt.type = _type;
			txt.defaultTextFormat = format;
			
			return txt;
		}
		
		
		/**
		 * 加载核心模块
		 */
		private function loadModule():void
		{
			var loader:SWFLoader = new SWFLoader();
			loader.addEventListener(IOErrorEvent.IO_ERROR, onLoadFailed);
			loader.addEventListener(SecurityErrorEvent.SECURITY_ERROR, onLoadFailed);
			loader.addEventListener(Event.COMPLETE, onLoaded);
			
			try {
				loader.load("so.swf");
			}
			catch (_:Error) {
				// ignore..
			};
		}
		
		private function onLoadFailed(evt:ErrorEvent):void
		{
			trace(evt)
		}
		
		private function onLoaded(evt:Event):void
		{
			var loader:SWFLoader = evt.target as SWFLoader;
			
			if (loader)
			{
				loader.removeEventListener(IOErrorEvent.IO_ERROR, onLoadFailed);
				loader.removeEventListener(SecurityErrorEvent.SECURITY_ERROR, onLoadFailed);
				loader.removeEventListener(Event.COMPLETE, onLoaded);
				
				_so = loader.content;
				_so.addEventListener(NetStatusEvent.NET_STATUS, onSoNetStatus);
				addChild(_so as DisplayObject);
				
				
			}
		}
		
		private function onSoNetStatus(evt:NetStatusEvent):void
		{
			Debug.log(Utils.serialize(evt.info));
			switch(evt.info.code)
			{
				case "SharedObject.Is.Ready":
					startTest();
					break;
			}
		}
		
		private function startTest():void
		{
			name_txt.text = _so.name;
			path_txt.text = _so.path;
		}
		
		private var _so:Object;
	}

}



import flash.display.GradientType;
import flash.display.Graphics;
import flash.display.Shape;
import flash.display.SimpleButton;
import flash.display.Sprite;
import flash.geom.Matrix;
import flash.text.TextField;
import flash.text.TextFormat;
import flash.text.TextFormatAlign;
class Button extends Sprite
{
		
	public function Button(width:uint, height:uint, label:String)
	{
		var btn:SimpleButton = new SimpleButton();
		btn.downState      = DrawButton(width, height, [0.1,0.0], [0.08,0.03]);
		btn.overState      = DrawButton(width, height, [0.35,0.05], [0.08,0.03]);
		btn.upState        = DrawButton(width, height, [0.1,0.0], [0.08,0.03]);
		btn.hitTestState   = DrawButton(width, height, [0.1,0.0], [0.08,0.03]);
		btn.useHandCursor  = true;
		//
		var btnLabel:TextField = appendText(width, height, label);
		btnLabel.x = 0;
		btnLabel.y = 2;
		//
		addChild(btnLabel);
		addChild(btn);
	}
	
	private function appendText(w:uint, h:uint, text:String):TextField
	{
		//
		var newFormat:TextFormat = new TextFormat();
		newFormat.color = 0xFFFFFF;
		newFormat.font = "Verdana";
		newFormat.align = TextFormatAlign.CENTER;
		newFormat.size = 12;
		//
		var label:TextField = new TextField();
		label.selectable = false;
		label.width = w;
		label.height = h;
		label.text = text;
		label.setTextFormat(newFormat);
		return label;
	}
	
	private function DrawButton(w:uint,h:uint,innerFrameAlphas:Array,innerHighlightAlphas:Array):Shape
	{
		var s:Shape = new Shape();
		var g:Graphics = s.graphics;
		g.clear();
		var gradientBoxMatrix:Matrix = new Matrix();   
		g.lineStyle(1, 0xFFFFFF, 0.1);
		g.drawRect(0, 0, w, h);
		//
		g.lineStyle(1, 0xff6600, 0.6);
		gradientBoxMatrix.createGradientBox(w, h, Math.PI/2, 0, 0);
		g.beginGradientFill(GradientType.LINEAR,[0xFFFFFF, 0xFFFFFF],innerFrameAlphas,null,gradientBoxMatrix);
		g.drawRect(1, 1, w-2, h-2);
		g.endFill();
		//
		g.lineGradientStyle(GradientType.LINEAR,[0xFFFFFF, 0xFFFFFF],innerHighlightAlphas,null,gradientBoxMatrix);
		g.drawRect(2, 2, w-4, h-4);
		return s;
	}
}