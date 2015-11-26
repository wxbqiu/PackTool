package com.frontdig.utils
{
	import com.frontdig.manager.FileManager;
	
	import flash.filesystem.File;
	import flash.utils.ByteArray;

	public class CodeTempUtil
	{
		public function CodeTempUtil()
		{
		}
		static public function onStart(file:File):void{
			var templeteFileStr:String = FileManager.getFileString(new File(File.applicationDirectory.nativePath+"/"+"codeTemplete/codeTemplete.txt"));
			var moduleName:String = file.parent.parent.name;//"{moduleName}";
			var fileName:String = file.name.replace("."+file.extension,"");
			var MediatorClass:String = fileName.charAt(0).toLocaleUpperCase()+ fileName.slice(1)+"Mediator"; //"{MediatorClass}";
			var plist:String = "res/module/"+moduleName+"/uiResource/"+moduleName+"_"+fileName+".plist"; //"{plist}";
			var mediatorConstant:String = toClassName(MediatorClass);//"{MediatorConstant}";
			var uiConfig:String = "src/module/view/"+moduleName+"/uiConfig/"+fileName+"Config.lua"//"{uiConfig}";
			var moduleCommand:String = "OPEN_"+toClassName(MediatorClass);//"{ModuleCommand}";
			var handler:String = "open"+MediatorClass//"{handler}";
			
			templeteFileStr = replaceAll(templeteFileStr,"{moduleName}",moduleName);
			templeteFileStr = replaceAll(templeteFileStr,"{MediatorClass}",MediatorClass);
			templeteFileStr = replaceAll(templeteFileStr,"{plist}",plist);
			templeteFileStr = replaceAll(templeteFileStr,"{MediatorConstant}","MediatorConstant."+mediatorConstant);
			templeteFileStr = replaceAll(templeteFileStr,"{uiConfig}",uiConfig);
			templeteFileStr = replaceAll(templeteFileStr,"{ModuleCommand}","ModuleCommand."+moduleCommand);
			templeteFileStr = replaceAll(templeteFileStr,"{handler}",handler);
			
			var byte:ByteArray = new ByteArray();
			byte.writeUTFBytes(templeteFileStr);
			FileManager.onSave(function():void{},byte,fileName+"代码模版.txt");
		}
		
		static private function toClassName(str:String):String
		{
			var index:int = 1;
			var tmpStr:String = "";
			tmpStr = str.charAt(0);
			while(str.charAt(index)!=""){
				if(check_uppercase(str.charAt(index))==true){
					tmpStr += "_"+str.charAt(index).toLocaleUpperCase();
				}else{
					tmpStr += str.charAt(index).toLocaleUpperCase();
				}
				index++;
			}
			
			function check_uppercase(obj)   
			{          
				if (/^[A-Z]+$/.test( obj ))    
				{   
					return true;   
				}
				return false;   
			}
			return tmpStr;
		}
		
		static private function replaceAll(str:String,p:String,rep:String):String{
			var str1:String = str;
			while(str1.indexOf(p)!=-1){
				str1 = str1.replace(p,rep);
			}
			return str1;
		}
	}
}