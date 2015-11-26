package com.frontdig.utils
{
	import by.blooddy.crypto.MD5;
	
	import com.frontdig.manager.FileManager;
	
	import flash.filesystem.File;
	import flash.filesystem.FileMode;
	import flash.filesystem.FileStream;
	import flash.utils.ByteArray;
	import flash.utils.Dictionary;
	import flash.utils.getTimer;
	
	public class DiffUtils
	{
		public function DiffUtils()
		{
		}
		private static const FIND_DUP_FILE_TEMPLETE:String = 
			'<!DOCTYPE html>\n'+
			'<html lang="en">\n'+
			'<head>\n'+
			'	<meta charset="UTF-8">\n'+
			'	<title>Document</title>\n'+
			'</head>\n'+
			'<body>\n'+
			'<table border="1px solid black" style="text-align:center">\n'+
			'	<tr>\n'+
			'		<tr>\n'+
			'			<td>索引</td>\n'+
			'			<td>差异文件1</td>\n'+
			'			<td>差异文件2</td>\n'+
			'		</tr>\n'+
			'		%rep%\n'
			'	</tr>\n'+
			'</table>\n'+
			'</body>\n'+
			'</html>'
		private static const REPLACE_PART:String = 
			'		<tr>\n'+
			'			<td>%index%</td>\n'+
			'			<td>\n'+
			'				<img src="%url1%"/>\n'+
			'				</br>\n'+
			'				<a href="%url1%" target="blank">%url1%</a>\n'+
			'			</td>\n'+
			'			<td>\n'+
			'				<img src="%url2%"/>\n'+
			'				</br>\n'+
			'				<a href="%url2%" target="blank">%url2%</a>\n'+
			'			</td>\n'+
			'		</tr>'
		
		private static function onFileToMd5Str(file:File):String{
			var fileStream:FileStream = new FileStream();
			fileStream.open(file,FileMode.READ);
			var data:ByteArray = new ByteArray();
			fileStream.readBytes(data);
			fileStream.close();
			return MD5.hashBytes(data);
		}
		public static function checkSameRes(tergetFile:File):void{
			var hash:Dictionary = new Dictionary();
			var sameResVec:Vector.<Array> = new Vector.<Array>();
			if(tergetFile.exists && tergetFile.isDirectory){
				var fileList:Array = FileManager.getFiles(tergetFile,"");
				for(var j:int = 0; j < fileList.length;j++){
					var file:File = fileList[j];
					if(file.exists && file.isDirectory==false){
						var md5Str:String = onFileToMd5Str(file);
						if(hash[md5Str]==null){
							hash[md5Str] = file;
						}else{
							var filePath_1:String = file.nativePath.replace(tergetFile.nativePath,".");
							var filePath_2:String = (hash[md5Str] as File).nativePath.replace(tergetFile.nativePath,".");
							sameResVec.push([filePath_1,filePath_2]);
						}
					}
				}
			}
			var html_tr:Array = [];
			for(var i:int = 0;i < sameResVec.length;i++){
				var str:String = REPLACE_PART
					.replace("%index%",(i+1))
					.replace("%url1%",(sameResVec[i][0]))
					.replace("%url1%",(sameResVec[i][0]))
					.replace("%url1%",(sameResVec[i][0]))
					.replace("%url2%",(sameResVec[i][1]))
					.replace("%url2%",(sameResVec[i][1]))
					.replace("%url2%",(sameResVec[i][1]));
				html_tr.push(str);
			}
			var htmlContent:String = FIND_DUP_FILE_TEMPLETE.replace("%rep%",html_tr.join("\n"));
//			trace(htmlContent);
			var byte:ByteArray= new ByteArray();
			byte.writeUTFBytes(htmlContent);
			FileManager.save(byte,tergetFile.nativePath,"findDupFile.html");
		}
		public static function diffWithBase(targetFile:File,baseFile:File):void{
			if(targetFile.exists && targetFile.isDirectory && baseFile.exists && baseFile.isDirectory){
				var targetFileList:Array = FileManager.getFiles(targetFile,"");
				var baseFileList:Array = FileManager.getFiles(baseFile,"");
				
				var mosuleResVec:Vector.<String> = new Vector.<String>();
				var diffFile:Vector.<String> = new Vector.<String>();
				var diffFileWidthBase:Vector.<String> = new Vector.<String>();
				var baseResHash:Dictionary = new Dictionary();
				var moduleResHash:Dictionary = new Dictionary();
				
				for(var j:int = 0; j < baseFileList.length;j++){
					var file:File = baseFileList[i] as File;
					if(file.exists && file.isDirectory == false){
						var md5Str:String = onFileToMd5Str(file);
						baseResHash[md5Str] = file;
					}
				}
				
				for(var i:int = 0;i < targetFileList.length;i++){
					file = targetFileList[i] as File;
					if(file.exists && file.isDirectory == false){
						md5Str = onFileToMd5Str(file);
						moduleResHash[md5Str] = file;
						if(mosuleResVec.indexOf(md5Str) == -1 && baseResHash[md5Str]==null){
							mosuleResVec.push(md5Str);
						}else{
							if(baseResHash[md5Str]){
								diffFileWidthBase.push([file.nativePath,baseResHash[md5Str].nativePath]);
							}else{
								diffFile.push([file.nativePath,moduleResHash[md5Str].nativePath]);
							}
						}
					}
				}
				trace(diffFile);
				trace(diffFileWidthBase);
				//				trace((getTimer()-startTime));
			}
		}
	}
}