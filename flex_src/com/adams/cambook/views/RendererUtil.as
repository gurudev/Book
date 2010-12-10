package com.adams.cambook.views
{
	import com.adams.cambook.views.renderers.BuddyCard;
	import com.adams.cambook.views.renderers.Comment;
	import com.adams.cambook.views.renderers.UpdateCard;
	
	import mx.core.ClassFactory;
	
	import org.osflash.signals.Signal;

	public class RendererUtil
	{
		public static const PERSONDAO 	:String="personDAO"; 
		public static const NOTEDAO 	:String="noteDAO";  
		public static const FILEDAO 	:String="fileDAO";  
		public static const REPLY 	:String="reply";  
		public static function getCustomRenderer( type:String):ClassFactory{
			switch(type){
				case PERSONDAO:					
					return new ClassFactory(com.adams.cambook.views.renderers.BuddyCard);
					break; 
				case NOTEDAO:					
					return new ClassFactory(com.adams.cambook.views.renderers.UpdateCard);
					break; 
				case REPLY:					
					return new ClassFactory(com.adams.cambook.views.renderers.Comment);
					break; 
				
			}			
			return null; 
		}   		

	}
}