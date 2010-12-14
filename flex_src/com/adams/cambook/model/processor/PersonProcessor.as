package com.adams.cambook.model.processor
{
	import com.adams.cambook.model.AbstractDAO;
	import com.adams.swizdao.model.vo.IValueObject;
	import com.adams.cambook.model.vo.Notes;
	import com.adams.cambook.model.vo.Persons;
	import com.adams.swizdao.model.vo.SignalVO;
	import com.adams.swizdao.model.processor.AbstractProcessor;

	public class PersonProcessor extends AbstractProcessor
	{  		
		
		[Inject]
		public var noteProcessor:NoteProcessor;
		
		[Inject("personDAO")]
		public var personDAO:AbstractDAO;
		
		public function PersonProcessor()
		{
			super();
		} 	
		override public function processVO(vo:IValueObject):void
		{
			if(!vo.processed){
				
				super.processVO(vo);
				var person:Persons = vo as Persons;
				for each(var connectedPerson:Persons in person.connectionSet){
						person.connectionArr.push(connectedPerson.personId);
						
						processVO(connectedPerson);
						if(!personDAO.collection.containsItem(connectedPerson)){
							personDAO.collection.addItem(connectedPerson);
						}
			
				}
				for each(var note:Notes in person.notesSet){
					noteProcessor.processVO(note);
				}
				
			}
		}
	}
}