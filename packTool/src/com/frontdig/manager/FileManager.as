package com.frontdig.manager {

	import flash.desktop.ClipboardFormats;
	import flash.display.DisplayObjectContainer;
	import flash.display.Stage;
	import flash.events.Event;
	import flash.events.NativeDragEvent;
	import flash.filesystem.File;
	import flash.filesystem.FileMode;
	import flash.filesystem.FileStream;
	import flash.utils.ByteArray;
	
	import mx.controls.Alert;
	import mx.events.FileEvent;

	public class FileManager {
		private static var init:Boolean = false;
		private static var _fun:Function;
		private static var saveFile:File = new File();
		private static var saveFileStream:FileStream = new FileStream();
		private static var prevCallBack:Function;

		public static function open(callBack:Function, isDirectory:Boolean = true, fileMask:Array = null):void {
			addListener(Event.SELECT, callBack);
			if (isDirectory) {
				saveFile.browseForDirectory("open file");
			} else {
				saveFile.browseForOpen("open", fileMask);
			}
		}

		public static function onSave(callBack:Function, data:ByteArray, defaultName:String = ""):void {
			addListener(Event.SELECT, callBack);
			saveFile.save(data, defaultName);
		}

		public static function getFiles(file:File, fileType:String, ignoreDic:Array=null):Array {
			var tmpArr:Array = [];

			function find(file:File):void {
				if (!file.isDirectory)return;
				if (ignoreDic && ignoreDic.indexOf(file.name) != -1)return;
				var files:Array = file.getDirectoryListing();
				for (var i:int = 0; i < files.length; i++) {
					if (files[i].isDirectory)find(files[i]);
					if ((files[i] as File).name.toLowerCase().indexOf(fileType) != -1) {
						tmpArr.push(files[i]);
					}
				}
			}

			find(file);
			return tmpArr;
		}

		public static function getFileNames(file:File, fileType:String, ignoreDic:Array=null):Array {
			var tmpArr:Array = [];
			
			function find(file:File):void {
				if (!file.isDirectory)return;
				if (ignoreDic && ignoreDic.indexOf(file.name) != -1)return;
				var files:Array = file.getDirectoryListing();
				for (var i:int = 0; i < files.length; i++) {
					if (files[i].isDirectory)find(files[i]);
					if ((files[i] as File).name.toLowerCase().indexOf(fileType) != -1) {
						tmpArr.push(files[i].name);
					}
				}
			}
			
			find(file);
			return tmpArr;
		}
		
		public static function save(data:Object, path:String = "", fileName:String = "", callBack:Function = null):void {
			reset();
			if (data is ByteArray) {
				if (path != "") {
					saveFile.nativePath = path + File.separator + fileName;
					saveFileStream.open(saveFile, FileMode.WRITE);
					saveFileStream.writeBytes(data as ByteArray);
					saveFileStream.close();
					if (callBack != null)callBack(saveFile);
				} else {
					open(function ():void {
						saveFile.nativePath = saveFile.nativePath + File.separator + fileName;
						saveFileStream.open(saveFile, FileMode.WRITE);
						saveFileStream.writeBytes(data as ByteArray);
						saveFileStream.close();
						if (callBack != null)callBack(saveFile);
					}, true)
				}
			} else if (data is Vector) {
				if (path == "") {
					open(function ():void {
						var tmpPath:String = saveFile.nativePath;
						for (var i:int = 0; i < data.length; i++) {
//              saveFile.nativePath = path+i;
							if (data[i].byte == null)continue;
							saveFile.nativePath = tmpPath;
							saveFile.nativePath = saveFile.nativePath + File.separator + data[i].name;
							saveFileStream.open(saveFile, FileMode.WRITE);
							saveFileStream.writeBytes(data[i].byte);
							saveFileStream.close();
						}
						if (callBack != null)callBack(saveFile);
					}, true)
				} else {
					var tmpPath:String = path;
					for (var i:int = 0; i < data.length; i++) {
						saveFile.nativePath = tmpPath;
						saveFile.nativePath = saveFile.nativePath + File.separator + data[i].name;
						saveFileStream.open(saveFile, FileMode.WRITE);
						saveFileStream.writeBytes(data[i].byte);
						saveFileStream.close();
					}
					if (callBack != null)callBack(saveFile);
				}
			}
		}

		public static function getFileString(file:File, pEncoding:String = "utf-8"):String {
			//var file:File = File.desktopDirectory.resolvePath(pPath);

			var stream:FileStream = new FileStream();

			stream.open(file, FileMode.READ);

			var str:String = stream.readMultiByte(stream.bytesAvailable, pEncoding);

			stream.close();

			return str;
		}
		
		public static function createFileFromString(pPath:String, pText:String, pEncoding:String = "utf-8"):File {
			var file:File = new File(pPath);
			writeTextInFile(file, pText, pEncoding);
			return file;
		}

		public static function createTmpFileFromString(pName:String, pText:String, pEncoding:String = "utf-8"):File {

			var file:File = File.createTempDirectory().resolvePath(pName);
			writeTextInFile(file, pText, pEncoding);
			return file;

		}

		public static function writeTextInFile(pFile:File, pText:String, pEncoding:String = "utf-8", isAppend:Boolean = false):void {
			// Replace line ending character with the appropriated one
//      var t:String = pText.replace(/[\r|\n]/g, File.lineEnding);
			var stream:FileStream = new FileStream();
			stream.open(pFile, isAppend ? FileMode.APPEND : FileMode.WRITE);
			stream.writeMultiByte(pText, pEncoding)
			stream.close();
		}

		public static function getOrMoveFile(pDirPath:String, pParentDir:File = null):File {

			if (pParentDir == null) pParentDir = File.applicationStorageDirectory;
		
			
			var f:File = pParentDir.resolvePath(pDirPath);

//			if (!f.exists) {
//
//				trace("Unable to find " + pDirPath + ", copying from applicationDirectory to " + pParentDir.nativePath);
//
//				var f2:File = File.applicationDirectory.resolvePath(pDirPath);
//
//				if (!f2.exists) return null;//Alert.show("Unable to find file or directory : "+ pDirPath, "File not found");
//
//				f2.copyTo(pParentDir.resolvePath(pDirPath));
//
//				return f2;
//			}
//			else 
			return f;

		}
		
		public static function copyFile(orginFilePath:String,targetFilePath:String,overwrite:Boolean=false):void{
			new File(orginFilePath).copyTo(new File(targetFilePath),overwrite);
		}

		public static function onDragFile(contain:Stage, fun:Function):void {
			contain.addEventListener(NativeDragEvent.NATIVE_DRAG_ENTER, eventHandler);
			contain.addEventListener(NativeDragEvent.NATIVE_DRAG_DROP, eventHandler);
			_fun = fun;
		}

		private static function reset():void {
			saveFileStream.close();
		}

		private static function addListener(EventName:String, callBack:Function):void {
			if (prevCallBack != null)saveFile.removeEventListener(EventName, prevCallBack);
			saveFile.addEventListener(EventName, callBack);
			prevCallBack = callBack;
		}

		public function FileManager() {

		}

		private static function eventHandler(e:NativeDragEvent):void {
			_fun(e, e.clipboard.getData(ClipboardFormats.FILE_LIST_FORMAT) as Array);
		}
		
		public static function operFile(item:Object, mode:int,alert:Boolean = true):Object
		{
			if(mode == 0)
			{
				var stream:FileStream = new FileStream();
				stream.open(item as File, FileMode.READ);
				var data:ByteArray = new ByteArray();
				stream.readBytes(data);
				stream.close();
				return data;
			}
			else if(mode == 1)
			{
				var file:File = item.file;
				if(file.exists && alert)
				{
					Alert.show("存在相同文件：" + file.nativePath,"警告");
				}
				stream = new FileStream();
				stream.open(item.file,FileMode.WRITE);
				stream.writeBytes(item.data);
				stream.close();
				return true;
			}
			
			return null;
		}
	}
}