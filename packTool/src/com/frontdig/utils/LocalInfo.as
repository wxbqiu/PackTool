package com.frontdig.utils
{
	import flash.filesystem.File;
	import flash.filesystem.FileMode;
	import flash.filesystem.FileStream;
	import flash.utils.ByteArray;

	public class LocalInfo
	{
		public var data:MyData;
		public function LocalInfo()
		{
		}
		public static function getLocal(name:String):LocalInfo
		{
			var file:File = searchFile(name);
			if(!file.exists){
				var path:String = File.applicationDirectory.nativePath+File.separator+"local"+File.separator+name;
				file = new File(path);
				var stream:FileStream = new FileStream();
				stream.open(file,FileMode.UPDATE);
				stream.close();
			}
			var localInfo:LocalInfo = new LocalInfo();
			localInfo.data = new MyData(file);
			return localInfo;
		}
		
		public function flush():void{
			data.flush();
		}
		
		private static function searchFile(name:String):File{
			return new File(File.applicationDirectory.nativePath+File.separator+"local"+File.separator+name);
		}
	}
}
import flash.filesystem.File;
import flash.filesystem.FileMode;
import flash.filesystem.FileStream;
import flash.utils.Proxy;
import flash.utils.flash_proxy;

dynamic class MyData extends Proxy {
	private var _openFile:File;
	
	private var _isChange:Boolean = true;
	private var _cacheObj:Object;
	public function MyData(file:File){
		_openFile = file;
	}
	private var _init:Boolean = false;
	private function init():void{
		if(_init==false){
			_init = true;
			var _stream:FileStream = new FileStream();
			_stream.open(_openFile,FileMode.WRITE);
			_stream.close();
		}
	}
	private function writeData(obj:Object):void{
		if(obj != null){
			var _stream:FileStream = new FileStream();
			_stream.open(_openFile,FileMode.WRITE);
			_stream.writeObject(obj);
			_stream.close();
			_isChange = true;
		}
	}
	private function readData():Object{
		if(!_isChange){
			return _cacheObj;
		}
		var _stream:FileStream = new FileStream();
		_stream.open(_openFile,FileMode.READ);
		if(_stream.bytesAvailable <= 0){
			return null;
		}
		var obj:Object = _stream.readObject() as Object;
		_stream.close();
		_cacheObj = obj;
		_isChange = false;
		return obj;
	}
	public function flush():void{
		writeData(_cacheObj);
	}
	flash_proxy override function setProperty(name:*, value:*):void{
		init();
		var obj:Object = readData();
		obj[name.localName] = value;
		writeData(obj);
	}
	
	flash_proxy override function getProperty(name:*):*{
		var obj:Object = readData();
		return obj[name.localName];
	}
	
	flash_proxy override function deleteProperty(name:*):Boolean{
		init();
		var obj:Object = readData();
		if(obj == null)return;
		delete obj[name.localName];
//		writeData(obj);
		return false;
	}
}













