package com.frontdig.utils
{
	import com.frontdig.manager.FileManager;
	
	import flash.desktop.NativeProcess;
	import flash.desktop.NativeProcessStartupInfo;
	import flash.events.IOErrorEvent;
	import flash.events.NativeProcessExitEvent;
	import flash.events.ProgressEvent;
	import flash.filesystem.File;
	import flash.filesystem.FileMode;
	import flash.filesystem.FileStream;
	import flash.utils.ByteArray;
	import flash.utils.Dictionary;
	
	import mx.controls.Alert;
	import mx.utils.StringUtil;

	public class BuildUtils
	{
		public static var packPath:String;
		public function BuildUtils()
		{
		}
		private static var progressArgs:Vector.<String>;
		private static var nativeTarget:String;
		
		public static function build(packFile:File,target:File,bHighQuality:Boolean):void{
			var exeFile:File = new File(GameTools.GLOBAL_PACK_PATH);
			if(!exeFile.exists){
				return;
			}
			var txtFile:File = new File(packFile.nativePath+File.separator+"packConfig.xml");
			if(txtFile.exists){
				var temp_baseFile:File = new File(File.desktopDirectory.nativePath+"/temp_base(ignore)");
				if(temp_baseFile.exists)temp_baseFile.deleteDirectory(true);
				packFile.copyTo(temp_baseFile);
				packFile.nativePath = temp_baseFile.nativePath;
				var xml:XML = XML(FileManager.getFileString(txtFile));
				for each(var it:XML in xml.item){
					var temp_filePath:String = it.@orgin;
					var temp_fileName:String = it.@target;
					var isHighQuality:Boolean =  it.@quality == "hight";
					var file:File = new File(packFile.nativePath+File.separator+temp_filePath);
					var _packFilePath:String = packFile.nativePath+File.separator+temp_fileName+File.separator+temp_filePath;
					var _packFile:File = new File(_packFilePath);
					file.moveTo(_packFile);
					onPackResource(new File(packFile.nativePath+File.separator+temp_fileName),target,isHighQuality);
				}
//				var configArr:Array = FileManager.getFileString(txtFile).split("\n");
//				for(var f:int = 0;f < configArr.length;f++){
//					if(configArr[f]=="")continue;
//					while(configArr[f].indexOf("\r")!=-1){
//						configArr[f] = configArr[f].replace("\r","");
//					}
//					var temp_filePath:String = configArr[f].split("|")[0];
//					var temp_fileName:String = configArr[f].split("|")[1];
//					var isHighQuality:Boolean =  configArr[f].split("|")[2] == "hight"
//					var file:File = new File(packFile.nativePath+File.separator+temp_filePath);
//					var _packFilePath:String = packFile.nativePath+File.separator+temp_fileName+File.separator+temp_filePath;
//					var _packFile:File = new File(_packFilePath);
//					file.moveTo(_packFile);
//					onPackResource(new File(packFile.nativePath+File.separator+temp_fileName),target,isHighQuality);
//	//				onPackResource(_packFile,target,bHighQuality);
//				}			
			}else{
				onPackResource(packFile,target,bHighQuality);
			}
//			if(temp_baseFile.exists)temp_baseFile.deleteDirectory(true);
		}
		
		
		private static function encodeModuleResource(exe:File,resource:File,result:File,name:String,bHighQuality:Boolean=false):void
		{
			var dstSource:File = new File(result.nativePath + File.separator + "resultResource" + File.separator + resource.parent.name);
			dstSource.createDirectory();
			copyResource(resource,dstSource);
//			var resultResource:File = result;
			var resultResource:File = new File(result.nativePath + File.separator + "resultResource");
			var progress:Array = buildNativeProgress(exe,0);
			var resultItem:File = new File(result.nativePath + "/" + name + ".plist");
			var resultPVRCCZItem:File = new File(result.nativePath + "/" + name + ".pvr.ccz");
			progress[2].push("--sheet");
			progress[2].push(resultPVRCCZItem.nativePath);
			progress[2].push("--data");
			progress[2].push(resultItem.nativePath);
			progress[2].push("--format");
			progress[2].push("cocos2d");
			progress[2].push("--content-protection");
			progress[2].push(GameTools.SECRET_KEY);
			progress[2].push("--algorithm");
			progress[2].push("MaxRects");
			progress[2].push("--max-size");
			progress[2].push("2048");
			progress[2].push("--size-constraints");
			progress[2].push("POT");
			progress[2].push("--trim-mode");
			progress[2].push("Trim");
			progress[2].push("--maxrects-heuristics");
			progress[2].push("Best");
			progress[2].push("--pack-mode");
			progress[2].push("Best");
			progress[2].push("--reduce-border-artifacts");
			progress[2].push("--opt");
			if (bHighQuality == false)
			{
				progress[2].push("RGBA4444");
			}
			else
			{
				progress[2].push("RGBA8888");
			}
			var string:String = "";
			string += exe.nativePath+" ";
			for each(var str:String in progress[2]) {
				string += str + " "
			}
			trace(string);
			
			progress[2].push(resultResource.nativePath);
			progress[1].arguments = progress[2];
			progress[0].start(progress[1]);
		}
		
		public static function onPackResource(packFile:File,target:File,bHighQuality:Boolean):void{
			var exeFile:File = new File(GameTools.GLOBAL_PACK_PATH);
			if(!exeFile.exists){
				return;
			}
			
			var progress:Array = buildNativeProgress(exeFile,0);
			var resultItem:File = new File(target.nativePath + "//" + packFile.name + ".plist");
			var resultPVRCCZItem:File = new File(target.nativePath + "//" + packFile.name + ".pvr.ccz");
			if(resultItem.exists)resultItem.deleteFile();
			if(resultPVRCCZItem.exists)resultPVRCCZItem.deleteFile();
			progress[2].push("--sheet");
			progress[2].push(resultPVRCCZItem.nativePath);
			progress[2].push("--data");
			progress[2].push(resultItem.nativePath);
			progress[2].push("--format");
			progress[2].push("cocos2d");
			progress[2].push("--content-protection");
			progress[2].push(GameTools.SECRET_KEY);
			progress[2].push("--algorithm");
			progress[2].push("MaxRects");
			progress[2].push("--max-size");
			progress[2].push("2048");
			progress[2].push("--size-constraints");
			progress[2].push("POT");
			progress[2].push("--trim-mode");
			progress[2].push("Trim");
			progress[2].push("--maxrects-heuristics");
			progress[2].push("Best");
			progress[2].push("--pack-mode");
			progress[2].push("Best");
			progress[2].push("--reduce-border-artifacts");
			progress[2].push("--opt");
			if (bHighQuality == false)
			{
				progress[2].push("RGBA4444");
			}
			else
			{
				progress[2].push("RGBA8888");
			}
			progressArgs= progress[2].concat();
			nativeTarget = packFile.nativePath;
			progress[2].push(packFile.nativePath);
			progress[1].arguments = progress[2];
			progress[0].start(progress[1]);
			return;
		}
		private static function onLog(...arg):void{
			
//			GameTools.logTF_UI.text = GameTools.logTF_UI.text + arg.join("");
		}
		private static function buildNativeProgress(exe:File,arg:Object,errorCallback:Function = null):Array
		{
			var info:NativeProcessStartupInfo = new NativeProcessStartupInfo();
			info.executable = exe;
			
			var progress:NativeProcess = new NativeProcess();
			progress.addEventListener(ProgressEvent.STANDARD_OUTPUT_DATA,function(e:ProgressEvent):void
			{
				onLog(arg,"Got:",progress.standardOutput.readUTFBytes(progress.standardOutput.bytesAvailable));
				//Alert.show(arg + "Got:" + progress.standardOutput.readUTFBytes(progress.standardOutput.bytesAvailable));
			});
			progress.addEventListener(ProgressEvent.STANDARD_ERROR_DATA,function(e:ProgressEvent):void
			{
				var err:String = progress.standardError.readUTFBytes(progress.standardError.bytesAvailable);
				onLog(arg,"Error:", err);
				if(err.indexOf("all sprites") != -1 || err.indexOf("too small") != -1)
				{
					if(errorCallback != null)
						errorCallback();
					else
						e.target.exit();
					errorCallback = null;
				}
				//Alert.show(arg + "Error:" + progress.standardError.readUTFBytes(progress.standardError.bytesAvailable));
			});
			progress.addEventListener(NativeProcessExitEvent.EXIT,function(event:NativeProcessExitEvent):void
			{
				onLog(arg,"Process exited with ",event.exitCode);
			});
			progress.addEventListener(IOErrorEvent.STANDARD_OUTPUT_IO_ERROR,function(e:IOErrorEvent):void
			{
				onLog(arg,"Progress Standard output io error :",e.toString());
				//Alert.show(arg + "Error2:" + progress.standardError.readUTFBytes(progress.standardError.bytesAvailable));
			});
			progress.addEventListener(IOErrorEvent.STANDARD_ERROR_IO_ERROR,function(e:IOErrorEvent):void
			{
				onLog(arg,"Progress Standard error io error :",e.toString());
				//Alert.show(arg + "Error3:" + progress.standardError.readUTFBytes(progress.standardError.bytesAvailable));
			});
			var params:Vector.<String> = new Vector.<String>();
			return [progress,info,params];
		}
		private static var sepArr:Array = ["tip"];
		
		public static function checkJsons(files:Array):Array{
			var paths:Array = [];
			function pushPath(array:Array,pathStr:String):void{
				if(array.indexOf(pathStr)==-1){
					if(pathStr.slice(0,4)!="base" && pathStr.indexOf("EditorDefaultRes")==-1){
						array.push(pathStr);
					}
				}
			}
			function findPath(array:Array):void{
				for(var i:int = 0;i < array.length;i++){
					if(array[i].options){
						if(array[i].options["fileNameData"]!=null && array[i].options["fileNameData"]["path"]!=null){
							pushPath(paths,array[i].options["fileNameData"]["path"]);
						}
						if(array[i].options["pressedData"]!=null && array[i].options["pressedData"]["path"]!=null){
							pushPath(paths,array[i].options["pressedData"]["path"]);
						}
						if(array[i].options["backGroundImageData"]!=null && array[i].options["backGroundImageData"]["path"]!=null){
							pushPath(paths,array[i].options["backGroundImageData"]["path"]);
						}
						if(array[i].options["disabledData"]!=null && array[i].options["disabledData"]["path"]!=null){
							pushPath(paths,array[i].options["disabledData"]["path"]);
						}
						if(array[i].options["normalData"]!=null && array[i].options["normalData"]["path"]!=null){
							pushPath(paths,array[i].options["normalData"]["path"]);
						}
						if(array[i].options["textureData"]!=null && array[i].options["textureData"]["path"]!=null){
							pushPath(paths,array[i].options["textureData"]["path"]);
						}
					}
					if(array[i].children.length > 0){
						findPath(array[i].children);
					}
				}
			}
			for(var f:int = 0;f < files.length;f++ ){
				var file:File = files[f];
				var content:String = FileManager.getFileString(file);
//				onLog(content);
				var obj:Object = JSON.parse(content);
//				onLog(obj);
				findPath(obj.widgetTree.children);
				
			}
			return paths;
		}
		
		public static function findNotUse(file:File,moduleName:String=""):void{
			var target:File = file;
			var resource:File = new File(file.nativePath + "/Resources");
			var arrJson:Array = new File(file.nativePath + "/Json").getDirectoryListing();
			var result:File = new File(file.nativePath + "/Result");
			var paths:Array = checkJsons(arrJson);
			var moduleRes:Array = new File(file.nativePath + "/Resources/"+moduleName).getDirectoryListing();
			var moduleTempFile:File = new File(File.desktopDirectory.nativePath + "/"+moduleName+"(模块资源使用情况)");
			if(moduleTempFile.exists){
				moduleTempFile.deleteDirectory(true);
			}
			moduleTempFile.createDirectory();
			for(var r:int = 0; r < moduleRes.length;r++){
				//				onLog(moduleRes[r]);
				var tempFile:File = moduleRes[r];
				if(paths.indexOf(moduleName+"/"+tempFile.name)!=-1){
					tempFile.copyTo(new File(moduleTempFile.nativePath+"/模块使用/"+tempFile.name));
				}else{
					tempFile.copyTo(new File(moduleTempFile.nativePath+"/可能没有使用/"+tempFile.name));
				}
			}
			moduleTempFile.openWithDefaultApplication();
		}
		
		public static function buildModule(file:File,moduleName:String="",bHighQuality:Boolean=false):void{
			var result:File = new File(file.nativePath + "/Result");
			if(result.exists == true) result.deleteDirectory(true);
			result.createDirectory();
			var fileArray:Array = file.getDirectoryListing();
			var fileList:Array = new Array();
			for each(var csdFile:File in fileArray) {
				if(!csdFile.isDirectory) {
					var fileName:String = csdFile.name
					var suffix:String = fileName.substring(fileName.lastIndexOf("."));
					if(suffix == ".csd") {
						fileList.push(csdFile);
					}
				} else if(csdFile.name != "Result" && csdFile.name != "Resources" ) {
					var resource:File = csdFile;
				}
			}
			
			for each(var f:File in fileList) {
				var xmlStr:String = FileManager.getFileString(f);
				var xmlDoc:XML = new XML(xmlStr);
				for(var parname:String in xmlDoc.PropertyGroup.attributes()) {
				    var pStr:String = "return " + parseXML(xmlDoc);
					var resultConfig:File = new File(result.nativePath + "/" + f.name.replace(".csd","Config.lua"));
					var stream:FileStream = new FileStream();
					stream.open(resultConfig, FileMode.WRITE);
					stream.writeUTFBytes(pStr)
					stream.close();
				}
			}
			
			//			var target:File = e.target as File;
//			var target:File = file;
//			var resource:File = new File(file.nativePath + "/Resources");
//			var arrJson:Array = new File(file.nativePath + "/Json").getDirectoryListing();
//			var result:File = new File(file.nativePath + "/Result");
//			if(result.exists == true) result.deleteDirectory(true);
//			result.createDirectory();
//
//			//检测tag的唯一性
//			var tagDic:Dictionary = new Dictionary();
//			var isChange:Boolean = false;
//			var isSeparated:Boolean = false;
//			//对于有些工程每个画布是不同panel，每次检查tag重复使用新的Dictionary
//			var index:int = file.nativePath.lastIndexOf("\\");
//			if(index > 0)
//			{
//				var projectName:String = file.nativePath.substring(index+1);
//				for each(var str:String in sepArr)
//				{
//					if (str == projectName)
//					{
//						isSeparated = true;
//						break;
//					}
//				}
//			}
//			for each(var json:File in arrJson)d
//			{
//				if(json.name == ".svn")continue;
//				if (genConfig(json,result,!isSeparated ? tagDic : new Dictionary()))
//				{
//					isChange =true;
//				}
//			}
//			if (isChange)
//			{
//				Alert.show("有一样的tag，程序已经自动修改tag,请重新打开cocostudio项目","提示");
//			}
			//打包Resouces文件
			var exeFile:File = new File(GameTools.GLOBAL_PACK_PATH);
			if(exeFile != null)
			{
				encodeModuleResource(exeFile,resource,result,file.name,bHighQuality);
				return;
			}
			
		}
		
		private static function parseXML(xml:XML):String {
			var str:String = "{";
			var ls:XMLList = xml.children();
			var atts:XMLList = xml.attributes();
			
			var attNum:int = 0;
			for each (var att:XML  in atts)
			{
				attNum++;
				str += att.name().toString() + "=\"" + att.toString() + "\",";
			}
			
			if(ls.length() > 0)
			{
				for each(var node:XML in ls) 
				{
//					str += node.name().toString() + "=";
//					var strSub:String = parseXML(node);
//					str += strSub + ",";
					var strSub:String = parseXML(node);
					if(strSub != "{}") {
						if(node.name().toString() != "AbstractNodeData")
							str += node.name().toString() + "=" + strSub + ",";
						else
							str += strSub + ",";
					}
				}
				str = str.substring(0, str.length-1)
				
			} else {
				if (attNum != 0) {
					str = str.substring(0, str.length-1)
				}
			}
			str += "}";
			return str;
		}
		
		private static function copyResource(source:File,result:File):void
		{
			var lists:Array = source.getDirectoryListing();
			var moduleFile:File = source;
//			for each(var item:File in lists)
//			{
//				if(item.name!="bitmap_font" && item.name != "base" && item.name != ".svn")
//				{
//					moduleFile = item;
//					break;
//				}
//			}
			var item:File = source;
			result = new File(result.nativePath + "/" + moduleFile.name);
			result.createDirectory();
			
			//复制original文件夹进result
			var original:File = new File(item.nativePath /*+ "/" + "Original"*/);
			lists = original.getDirectoryListing();
			
			for each(var file:File in lists)
			{
				//        if(file.name.search(reg)!=-1) continue;
				var fileResult:File = new File(result.nativePath + "/" + file.name);
				file.copyTo(fileResult,true);
			}
			
		}

		private static function genConfig(json:File, result:File, tagDic:Dictionary): Boolean
		{
			//改变json格式
			var jsonTempData:Object = FileManager.operFile(json,0);
			var jsonString:String = jsonTempData.toString();
			var index3:int = -1;
			var isChange:Boolean = false;
			while(1)
			{
				index3 = jsonString.indexOf("\"tag",index3+1);
				if(index3==-1) break;
				var index4:int = jsonString.indexOf(",",index3);
				var value:int = int(jsonString.substring(index3+7,index4));
				// 999999作为ToolTip面板的退出按钮tag，不要排重
				while(tagDic.hasOwnProperty(value) && value!=999999)
				{
					value += 100;
					isChange = true;
				}
				tagDic[value] = true;
				var str1:String = jsonString.substring(0,index3+7);
				var str2:String = jsonString.substring(index4,jsonString.length);
				jsonString = str1+ value +str2;
			}
			
			var data:ByteArray = new ByteArray();
			data.writeUTFBytes(jsonString);
			var obj:Object = new Object();
			obj.data = data;
			obj.file = json;
			FileManager.operFile(obj,1,false);
			obj = null;
			data = null;
			
			var jsonResult:String = jsonString.split("[").join("{").split("]").join("}");
			jsonResult = jsonResult.replace(/:#/g,"##");
			var arr:Array = jsonResult.split(":");
			var length:int = arr.length;
			for(var i:int=0;i<length;i++)
			{
				var n:Number = i*0.5;
				var arr2:Array = (arr[i] as String).match(/".*"/g);
				if(arr2)
				{
					if(arr2[1])
						arr[i] = (arr[i] as String).replace(arr2[1],"["+arr2[1]+"]");
					else if(arr2[0])
						arr[i] = (arr[i] as String).replace(arr2[0],"["+arr2[0]+"]");
				}
			}
			jsonResult = arr.join("=").replace(/##/g,":#");
			jsonResult = jsonResult.replace(/\"capInsetsHeight\": [\d.]+/g,"\"capInsetsHeight\":1");
			jsonResult = jsonResult.replace(/\"capInsetsWidth\": [\d.]+/g,"\"capInsetsWidth\":1");
			var indexEnter:int = jsonResult.indexOf("\\\\n", 0);    //支持换行符
			while(indexEnter != -1)
			{
				jsonResult = jsonResult.replace("\\\\n","\\n");
				indexEnter = jsonResult.indexOf("\\\\n", indexEnter);
			}
			jsonResult = jsonResult.replace(/([^\]])=/g, function():String {
				return arguments[1] + ":";
			});
			jsonResult = cuttingJson("return " + jsonResult);
//			cuttingJson(jsonResult);
			var resultConfig:File = new File(result.nativePath + "/" + json.name.replace(".json","Config.lua"));
			var jsonResultByteArray:ByteArray = new ByteArray();
			jsonResultByteArray.writeUTFBytes(jsonResult);
			FileManager.operFile({file:resultConfig,data:jsonResultByteArray},1);
			
			return isChange;
		}
//		private static var cuttingTag:Array = []
		private static function cuttingJson(jsonContent:String):String{
			var arr:Array = jsonContent.split("\n");
			var handler:Function = StringUtil.trim;
			for(var i:int = 0;i < arr.length;i++){
				arr[i] = handler(arr[i]);
			}
			var result:String = arr.join("");
			return result;
		}
	}
}