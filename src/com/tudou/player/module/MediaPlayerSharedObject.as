/*****************************************************
*  
*  Copyright (c) 2015 Youku Tudou, Inc.  All Rights Reserved.
*  
*****************************************************
*  Permission is hereby granted, free of charge, to any person obtaining a copy
*  of this software and associated documentation files (the "Software"), to deal
*  in the Software without restriction, including without limitation the rights
*  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
*  copies of the Software, and to permit persons to whom the Software is
*  furnished to do so, subject to the following conditions:

*  The above copyright notice and this permission notice shall be included in
*  all copies or substantial portions of the Software.
*  
*  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
*  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
*  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
*  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
*  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
*  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
*  THE SOFTWARE.
*  
*  
*  The Initial Developer of the Original Code is Youku Tudou, Inc.
*  Portions created by Youku Tudou, Inc. are Copyright (C) 2015 Youku Tudou, Inc. 
*  All Rights Reserved. 
*  
*****************************************************/
package com.tudou.player.module 
{
	import com.tudou.player.config.AccessDomain;
	import com.tudou.utils.Debug;
	import com.tudou.utils.Utils;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.NetStatusEvent;
	import flash.external.ExternalInterface;
	import flash.net.LocalConnection;
	import flash.net.SharedObject;
	import flash.net.SharedObjectFlushStatus;
	import flash.system.Security;
	/**
	 * Media Player SharedObject
	 * 
	 * @author 8088
	 */
	public class MediaPlayerSharedObject extends Sprite
	{
		
		public function MediaPlayerSharedObject() 
		{
			Security.allowDomain("*");
			Security.allowInsecureDomain("*");
			
			if (stage) onStage();
			else addEventListener(Event.ADDED_TO_STAGE, onStage);
		}
		
		public function getValue(key:String):*
		{
			try
			{
				var so:SharedObject = SharedObject.getLocal(NAMESPACE+_name, _path);
				
				var value:* = so.data[key];
				
				log("get " + key);
				
				return value;
			}
			catch (err:Error) {
				onError("unable to get data - " + err.message);
			}
			return null;
		}
		
		public function setValue(key:String, value:*):void
		{
			if (value == null) return;
			
			try
			{
				var so:SharedObject = SharedObject.getLocal(NAMESPACE+_name, _path);
				
				so.data[key] = value;
				
				flush(so);
				
				if(key != FOR_FIX_BUG) log("set " + key + ": " + value);
			}
			catch (err:Error) {
				onError("unable to set data - " + err.message);
			}
		}
		
		public function clear(key:String=null):void
		{
			try
			{
				var so:SharedObject = SharedObject.getLocal(NAMESPACE+_name, _path);
				
				if (key != null)
				{
					delete so.data[key];
					
					flush(so);
					
					log("delete " + key);
				}
				else {
					so.removeEventListener(NetStatusEvent.NET_STATUS, onNetStatus);
					
					so.clear();
					
					log("clear shared object: " + NAMESPACE+_name);
				}
			}
			catch (err:Error) {
				onError("error delete key - " + err.message);
			}
		}
		
		public function read():Object
		{
			try
			{
				var so:SharedObject = SharedObject.getLocal(NAMESPACE+_name, _path);
				
				var obj:Object = { };
				for (var key:* in so.data)
				{
					if(key!= FOR_FIX_BUG) obj[key] = so.data[key];
				}
				
				log("read " + Utils.serialize(obj));
				
				return obj;
			}
			catch (err:Error) {
				onError("unable to read data - " + err.message);
			}
			return null;
		}
		
		public function save(data:Object):void
		{
			if (data == null) return;
			
			try
			{
				var so:SharedObject = SharedObject.getLocal(NAMESPACE+_name, _path);
				
				for (var key:* in data)
				{
					so.data[key] = data[key];
				}
				
				flush(so);
				
				log("save " + Utils.serialize(data));
			}
			catch (err:Error) {
				onError("unable to save data - " + err.message);
			}
		}
		
		override public function get name():String
		{
			return _name;
		}
		
		override public function set name(value:String):void
		{
			if (value && LEGAL_NAME.test(value))
			{
				_name = value;
			}
			else {
				onError("invalid name: "+ value +", disabling!");
			}
		}
		
		public function get path():String
		{
			return _path;
		}
		
		public function set path(value:String):void
		{
			if (value && LEGAL_NAME.test(value) && loaderInfo.url.indexOf(value)!=-1)
			{
				_path = value;
			}
			else {
				onError("invalid path: "+ value +", disabling!");
			}
		}
		
		
		// Internal..
		//
		
		private function onStage(evt:Event = null):void
		{
			removeEventListener(Event.ADDED_TO_STAGE, onStage);
			
			if (AccessDomain.isIllegal()) return;
			else initialize();
			
		}
		
		private function initialize():void
		{
			log("initializing...");
			
			try
			{
				var so:SharedObject = SharedObject.getLocal(NAMESPACE+_name, _path);
			}
			catch (err:Error) {
				dispatchEvent(new NetStatusEvent
					( NetStatusEvent.NET_STATUS
					, false
					, false
					, 	{ code:"SharedObject.Unable.Creat"
						, level:"error"
						, error: { code:"E2134", desc:err.message, id:"MediaPlayerSharedObject" }
						}
					)
				);
				return;
			}
			
			this.setValue(FOR_FIX_BUG, '8088');
			
			if (ExternalInterface.available)
			{
				try
				{
					ExternalInterface.addCallback("get", getValue);
					ExternalInterface.addCallback("set", setValue);
					ExternalInterface.addCallback("read", read);
					ExternalInterface.addCallback("save", save);
					ExternalInterface.addCallback("clear", clear);
					
					ExternalInterface.call(NAMESPACE + "onload");
				}
				catch (err:Error) {
					onError(err.message);
				}
			}
			
			if (_has_error) return;
			
			log("it's works!");
			
			dispatchEvent( new NetStatusEvent
				( NetStatusEvent.NET_STATUS
				, false
				, false
				, { code:"SharedObject.Is.Ready", level:"status"}
				)
			);
		}
		
		private function flush(so:SharedObject):void
		{
			var state:String = null;
			try
			{
				state = so.flush(10000);
			}
			catch (err:Error) {
				onError("could not write shared object to disk - " + err.message);
			}
			
			if (state == null) return;
			
			switch (state)
			{
				case SharedObjectFlushStatus.PENDING:
					so.addEventListener(NetStatusEvent.NET_STATUS, onNetStatus);
					break;
				case SharedObjectFlushStatus.FLUSHED:
					// ignore..
					break;
			}
		}
		
		private function onNetStatus(evt:NetStatusEvent):void
		{
			dispatchEvent(evt);
			
			var so:SharedObject = evt.target as SharedObject;
			so.removeEventListener(NetStatusEvent.NET_STATUS, onNetStatus);
		}
		
		private function onError(msg:String):void
		{
			log(msg, Debug.RED);
			_has_error = true;
			
			dispatchEvent(new NetStatusEvent
				( NetStatusEvent.NET_STATUS
				, false
				, false
				, 	{ code:"SharedObject.Store.Failed"
					, level:"error"
					, error: { code:"E2130", desc:msg, id:"MediaPlayerSharedObject" }
					}
				)
			);
			try
			{
				if (ExternalInterface.available)
				{
					ExternalInterface.call(NAMESPACE + "onerror", msg);
				}
			}
			catch (err:Error) {
				log('attempting to fire external onerror callback - ' + err.message, Debug.RED);
			}
		}
		
		private function log(...args):void
		{
			Debug.log(args, "SO");
		}
		
		private var _name:String = "info";
		private var _path:String = "/";
		private var _url:String;
		private var _has_error:Boolean;
		
		//The container callback methods must in the default namespace.
		private static const NAMESPACE:String = "player.store.";
		private static const FOR_FIX_BUG:String = "__for_fix_bug";
		private static const LEGAL_NAME:RegExp = /^[a-zA-Z0-9_.$\/]+$/;
	}

}