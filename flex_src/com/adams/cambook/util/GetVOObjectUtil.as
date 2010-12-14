package com.adams.cambook.util
{
	import com.adams.swizdao.model.vo.IValueObject;
	import com.adams.swizdao.util.GetVOUtil;
	
	import mx.collections.ArrayCollection;

	public class GetVOObjectUtil extends GetVOUtil
	{
		import com.adams.cambook.model.vo.Persons; 
		public static function getPersonObject( username:String, password:String,arrc:ArrayCollection):Persons{
			var item:IValueObject = new Persons();
			Persons(item).personEmail= username;
			Persons(item).personPassword = password;
			arrc.sort = null;
			var returnPerson:Persons = getValueObject(item,'personEmail',arrc) as Persons;
			arrc.sort = null;
			return returnPerson; 
		}
	}
}