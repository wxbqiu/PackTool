package com.frontdig.utils
{
	import com.frontdig.manager.FileManager;
	import com.lipi.excel.Excel;
	
	import flash.filesystem.File;
	import flash.filesystem.FileMode;
	import flash.filesystem.FileStream;
	import flash.utils.ByteArray;
	
	import mx.controls.Alert;

	public class ExcelUtils
	{
		public function ExcelUtils()
		{
		}
		
		public static function onConfig(fromFilePath:String,toFilePath:String):void{
			var fromFile:File = new File(fromFilePath);
			var toFile:File = new File(toFilePath);
			if(!fromFile.exists){
				Alert.show("Excel目录不存在","错误");
				return;
			}
			if(!toFile.exists){
				Alert.show("生成目录不能为空","错误");
				return;
			}
			
			var files:Array = FileManager.getFiles(fromFile,").xls");
			var isSuccess:Boolean = true;
			var cnt:int = 0;
			for each(var f:File in files){
				if(f.name.slice(0,2)=='~$')continue;
				var saveFile:File;
				var isExport:Boolean = true;
				try
				{
					var byte:ByteArray = parseExcel2LuaByte(f);
					var fileName:String = f.name.split("(").pop().replace(")","").split(".")[0]+"_temp.lua";
					saveFile = new File(toFilePath+"/"+fileName);
				} 
				catch(error:Error) 
				{
					Alert.show(f.name+"导出配置失败,请修改之后再导出","错误");
					if(saveFile && saveFile.exists)saveFile.deleteFile();
					isExport = false;
					return;;
				}
				
				if(byte==null){
					Alert.show(f.name+"导出配置失败,请修改之后再导出","错误");
					if(saveFile && saveFile.exists)saveFile.deleteFile();
					isExport = false;
					return;
				}
				var fs:FileStream = new FileStream();
				fs.open(saveFile,FileMode.WRITE);
				fs.writeBytes(byte);
				fs.close();
			}
			Alert.show("配置导出成功");
		}
		
		public static function parseExcel2LuaByte(file:File):ByteArray
		{
			var data:ByteArray;
			var fileStream:FileStream = new FileStream();
			fileStream.open(file, FileMode.READ);
			data = new ByteArray();
			fileStream.readBytes(data);
			fileStream.close();
			
			var sheet:Array = new Excel(data).getSheetArray();
			if(sheet.length < 2){
				Alert.show(file.name+"配置表不得少于2行","错误");
				return null;
			}
			//第一行
			//				dg.requestedColumnCount = sheet.length;
			var headRows:Array = sheet[0];
			var headColumnsArray:Array = [];
			for(var i:int = 0;i < headRows.length;i++){
				if((headRows[i])==null){
					Alert.show(file.name+"第1行,第"+(i+1)+"列没有设置描述名称，程序退出","错误");
					return null;
				}
			}
			//取出第二行用来替换
			var codeRow:Array = sheet[1];
			var codeFlags:Array = [];
			for(var k:int = 0;k < headRows.length;k++){
				var type:String = "";
				var tempArr:Array = [];
				if(codeRow[k]==null){
					Alert.show(file.name+"第2行,第"+(k+1)+"列没有设置变量名，程序退出","错误");
					return null;
				}
				var splitArr:Array = codeRow[k].split("(");
				tempArr.push(splitArr[0]);
				if(splitArr.length > 1){
					type = splitArr[1].replace(")","");
					type = String(type).toLocaleLowerCase();
					var tableSplit:String = "";
					if(type.indexOf("table")!=-1){
						//							type = "table";
						tableSplit = type.replace("table|","");
						type = "table"
					}
					tempArr.push(type);
					if(tableSplit!=""){
						tempArr.push(tableSplit);
					}
				}
				codeFlags.push(tempArr);
				//trace(codeRow[k]);
			}
			//取出第三行数据推导数据
			var guessRow:Array = null;
			if(sheet.length >= 4){
				guessRow= sheet[4];
			}
			if(guessRow == null)guessRow =[];
			for(var m:int = 0;m < headRows.length;m++){
				if(codeFlags[m].length <=1){//如果是没有提供类型，就自动推导
					if((m in guessRow)==false ||guessRow[m]=="" || /^[\d,\.]+$/gi.test(guessRow[m])==true){//num
						codeFlags[m].push("num");
					}else{
						codeFlags[m].push("string");
					}
				}
			}
			

			var luaData:Array = [];
			for(var j:int = 3;j < sheet.length;j++){
				var row:Array = sheet[j];
				if(row == null || row[0]== null || row[0]==""){
//					Alert.show(file.name+"Excel表第"+j+"行，数据缺失，自动跳过","提示");
					continue;
				}
				var line:Array = [];
				line.push("[");
				line.push(row[0]);
				line.push("]={");
				for(var n:int = 0;n < headRows.length;n++){
					if(codeFlags[n][1]=="none")continue;
					line.push(codeFlags[n][0]);
					line.push("=");
					if(codeFlags[n][1]=="string"){
						if(row[n] == undefined)row[n] = "";
						line.push("[==["+row[n]+"]==]");
					}else if(codeFlags[n][1]=="table"){
						if(row[n] == undefined){
							row[n] = "";
						}else{
							var splitFlag:String = codeFlags[n][2];
							if(splitFlag!=""){
								row[n] = row[n].split(splitFlag);
								var result:Array = [];
								for(var ii:int = 0;ii < row[n].length;ii++){
									if(row[n][ii]=="" || /^[\d,\.]+$/gi.test(row[n][ii])==false){
										result.push("[==["+row[n][ii]+"]==]");
									}else{
										result.push(row[n][ii]);
									}
								}
								row[n]= result.join(",");
							}
							line.push("{");
							line.push(row[n]);
							line.push("}");
						}
					}else{
						if(row[n] == undefined)row[n] = 0;
						line.push(row[n]);
					}
					if(n != headRows.length-1){
						line.push(",");						
					}
				}
//				if(j != sheet.length-1){
					line.push("},\n");
//				}
				luaData.push(line.join(""));
			}
			
			var time:Date = new Date();
			var timeStr:String = time.fullYear+"-"+time.month+"-"+time.date+" "+time.hours+":"+time.minutes+":"+time.milliseconds;
			var luaStr:String = "--源文件:"+file.name+"\n--导出时间:"+timeStr+"\nreturn {\n"+luaData.join("")+"\n}";
			var byte:ByteArray = new ByteArray();
			byte.writeUTFBytes(luaStr);
			return byte;
		}
	}
}