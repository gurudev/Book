/*
* Copyright 2010 @nsdevaraj
* 
* Licensed under the Apache License, Version 2.0 (the "License"); you may not
* use this file except in compliance with the License. You may obtain a copy of
* the License. You may obtain a copy of the License at
* 
* http://www.apache.org/licenses/LICENSE-2.0
* 
* Unless required by applicable law or agreed to in writing, software
* distributed under the License is distributed on an "AS IS" BASIS, WITHOUT
* WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the
* License for the specific language governing permissions and limitations under
* the License.
*/
package com.adams.cambook.util
{  
	import com.adams.cambook.model.AbstractDAO;
	public class Utils
	{  	 
		public static const LOGIN_INDEX:String='login'; 
		public static const HOME_INDEX:String='home';  
		
		public static const SQL_TYPE:String="type";  
		public static const ALERTHEADER:String='CamBook';
		public static const TWEETSUCCESS:String='Success';
		public static const DELETEITEMALERT:String="Are you sure you want to delete this item?";
		
		
		public static var FileSeparator:String='//';
		public static const VIEW_INDEX_ARR:Array = ['com'+FileSeparator+'adams'+FileSeparator+'cambook'+FileSeparator+'views'+FileSeparator+'modules'+FileSeparator+'LoginModule.swf',
			'com'+FileSeparator+'adams'+FileSeparator+'cambook'+FileSeparator+'views'+FileSeparator+'modules'+FileSeparator+'HomeViewModule.swf'];
		
		public static const PERSONKEY 	:String="personId"; 
		public static const NOTEKEY 	:String="noteId";  
		public static const FILEKEY 	:String="fileID";  
		
		public static const PERSONDAO 	:String="personDAO"; 
		public static const NOTEDAO 	:String="noteDAO";  
		public static const REPLY 	:String="reply";  
		
	}
}