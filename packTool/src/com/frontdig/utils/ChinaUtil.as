package com.frontdig.utils
{
	import com.frontdig.manager.FileManager;
	
	import flash.filesystem.File;
	import flash.utils.Dictionary;

	public class ChinaUtil
	{
		public function ChinaUtil()
		{
		}
		
		public static function parse(f:File):String
		{
			ChinaDic.init();
			var list:Dictionary = ChinaDic.list;
			var prevChatIsChina:Boolean = false;
			var name:String = f.name.replace("."+f.extension,"");
			while(name.indexOf(" ")!=-1){
				name = name.replace(" ","");
			}
			var newName:String = "";
			for(var i:int = 0;i < name.length;i++){
				var orginNameIndex:String = name.charAt(i);
				var nameIndex:String = list[orginNameIndex];
				if(nameIndex == null){
					if(i > 0 && prevChatIsChina){
						newName += "_";
					}
					prevChatIsChina = false;
					newName += orginNameIndex;
				}else{
					if(i > 0){
						newName += "_";
					}
					prevChatIsChina = true;
					newName += nameIndex;
				}
			}
			return newName;
		}
		
		public static function onRename(file:File):void{
			var fileList:Array  = FileManager.getFiles(file,"");
			ChinaDic.init();
			var list:Dictionary = ChinaDic.list;
			for each(var f:File in fileList){
//				if(f.isDirectory)continue;
				var prevChatIsChina:Boolean = false;
				var name:String = f.name.replace("."+f.extension,"");
				while(name.indexOf(" ")!=-1){
					name = name.replace(" ","");
				}
				var newName:String = "";
				for(var i:int = 0;i < name.length;i++){
					var orginNameIndex:String = name.charAt(i);
					var nameIndex:String = list[orginNameIndex];
					if(nameIndex == null){
						if(i > 0 && prevChatIsChina){
							newName += "_";
						}
						prevChatIsChina = false;
						newName += orginNameIndex;
					}else{
						if(i > 0){
							newName += "_";
						}
						prevChatIsChina = true;
						newName += nameIndex;
					}
				}
//				trace(f.parent.nativePath+"\\"+newName+"."+f.extension);
				var file_ext:String = "";
				if(f.isDirectory == false){
					file_ext = "."+f.extension
				}
				var moveFile:File = new File(f.parent.nativePath+"\\"+newName+file_ext);
				if(moveFile.exists)continue;
				f.moveTo(moveFile,true);
			}
		}
	}
}