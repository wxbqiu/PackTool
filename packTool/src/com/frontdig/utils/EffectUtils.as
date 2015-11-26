package com.frontdig.utils
{
	import com.frontdig.manager.FileManager;
	
	import flash.filesystem.File;
	
	import mx.controls.Alert;

	public class EffectUtils
	{
		public function EffectUtils()
		{
		}
		public static function build(orginPath:String,hightQuilty:Boolean):void{
			var orginFile:File = new File(orginPath);
			if(orginFile.exists == false){
				Alert.show("文件夹不能为空");
				return;
			}
			
			//创建两层文件
			var packFile:File = new File(orginFile.parent.nativePath+File.separator+orginFile.name+"_temp"+File.separator);
			var tempFile:File = new File(packFile.nativePath+File.separator+ChinaUtil.parse(orginFile)+File.separator+ChinaUtil.parse(orginFile)+File.separator);
			if(packFile.exists){
				packFile.deleteDirectory(true);
			}else{
				tempFile.createDirectory();
			}
			
			FileManager.copyFile(orginFile.nativePath,tempFile.nativePath,true);
			ChinaUtil.onRename(tempFile);
			
			BuildUtils.build(tempFile.parent,packFile,hightQuilty);
		}
	}
}