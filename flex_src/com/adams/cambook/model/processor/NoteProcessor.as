package com.adams.cambook.model.processor
{
	import com.adams.cambook.model.AbstractDAO;
	import com.adams.swizdao.model.vo.IValueObject;
	import com.adams.cambook.model.vo.Notes;
	import com.adams.cambook.model.vo.Persons;
	import com.adams.swizdao.model.processor.AbstractProcessor;

	public class NoteProcessor extends AbstractProcessor
	{  
		[Inject("noteDAO")]
		public var noteDAO:AbstractDAO;

		public function NoteProcessor()
		{
			super();
		}
		//@TODO
		override public function processVO(vo:IValueObject):void
		{
			if(!vo.processed){
				super.processVO(vo);
				var notevo:Notes = vo as Notes;
				if(!noteDAO.collection.containsItem(notevo)){
					noteDAO.collection.addItem(notevo);
				}
				for each(var repliedNote:Notes in notevo.notesSet){
					processVO(repliedNote);
					if(!noteDAO.collection.containsItem(repliedNote)){
						noteDAO.collection.addItem(repliedNote);
					}
				}
			}
		}
	}
}