package com.adams.cambook.views.mediators
{
	import com.adams.cambook.model.AbstractDAO;
	import com.adams.cambook.model.processor.PersonProcessor;
	import com.adams.cambook.model.vo.*;
	import com.adams.cambook.util.GetVOObjectUtil;
	import com.adams.cambook.util.RendererUtil;
	import com.adams.cambook.util.Utils;
	import com.adams.cambook.views.HomeSkinView;
	import com.adams.cambook.views.renderers.BuddyCard;
	import com.adams.cambook.views.renderers.Comment;
	import com.adams.cambook.views.renderers.UpdateCard;
	import com.adams.swizdao.dao.PagingDAO;
	import com.adams.swizdao.model.vo.*;
	import com.adams.swizdao.response.SignalSequence;
	import com.adams.swizdao.util.Action;
	import com.adams.swizdao.util.ArrayUtil;
	import com.adams.swizdao.util.Description;
	import com.adams.swizdao.util.ObjectUtils;
	import com.adams.swizdao.views.components.NativeList;
	import com.adams.swizdao.views.mediators.AbstractViewMediator;
	
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.utils.setTimeout;
	
	import mx.collections.ArrayCollection;
	import mx.collections.ArrayList;
	import mx.core.ClassFactory;
	import mx.core.FlexGlobals;
	import mx.core.IFactory;
	import mx.events.CloseEvent;
	import mx.events.FlexEvent;
	import mx.events.ItemClickEvent;
	import mx.events.ValidationResultEvent;
	import mx.managers.PopUpManager;
	import mx.validators.StringValidator;
	import mx.validators.Validator;
	
	import spark.components.TextInput;
	import spark.components.TitleWindow;
	import spark.events.IndexChangeEvent;
	import spark.skins.spark.DefaultItemRenderer;
	

	public class HomeViewMediator extends AbstractViewMediator
	{ 		 
		
		[Inject]
		public var currentInstance:CurrentInstance; 
		 
		[Inject("personDAO")]
		public var personDAO:AbstractDAO;
		
		[Inject("noteDAO")]
		public var noteDAO:AbstractDAO;
		
		[Inject]
		public var pagingDAO:PagingDAO;
		[Inject]
		public var personProcess:PersonProcessor;
		
		[Form(form="view.passwordForm")]
		public var personObj:Object;
		 
		protected var passWordNameValidator:StringValidator;
		private var _mainViewStackIndex:int
		public function get mainViewStackIndex():int {
			return _mainViewStackIndex;
		}
		public function set mainViewStackIndex( value:int ):void {
			_mainViewStackIndex = value;
		} 
		
		
		/**
		 * Create the form field validators for the login fields.
		 */
		protected function createFormValidators():void
		{ 
			
			// create the user name validator
			passWordNameValidator = new StringValidator();
			passWordNameValidator.requiredFieldError = "Please enter minimum 5 Characters";
			passWordNameValidator.minLength = 5;
			passWordNameValidator.property = "text";
		}
		/**
		 * Constructor.
		 */
		public function HomeViewMediator( viewType:Class=null )
		{
			super( HomeSkinView ); 
		}

		/**
		 * Since the AbstractViewMediator sets the view via Autowiring in Swiz,
		 * we need to create a local getter to access the underlying, expected view
		 * class type.
		 */
		public function get view():HomeSkinView 	{
			return _view as HomeSkinView;
		}
		
		[MediateView( "HomeSkinView" )]
		override public function setView( value:Object ):void { 
			super.setView(value);	
		}
		/**
		 * Handles text input changes to the username and password and validate them.
		 * Only enable the submit button if both the username and password fields 
		 * are valid.
		 * 
		 * @param evt    Change event from the targeted input field.
		 */
		protected function inputChgHandler(evt:Event):void
		{
			view.submitBtn.enabled = isTextInputFieldValid(view.personPassword1,passWordNameValidator) && isTextInputFieldValid(view.personPassword2,passWordNameValidator);
		}
		
		/**
		 * Determines if the username text input is valid.
		 * @return Boolean
		 */
		protected function isTextInputFieldValid(textInput:spark.components.TextInput, validator:Validator):Boolean
		{
			textInput.errorString = "";
			
			var resultEvent:ValidationResultEvent = validator.validate(textInput.text);
			if (resultEvent.type != ValidationResultEvent.VALID)
			{
				textInput.errorString = resultEvent.message;
			}
			return (resultEvent.type == ValidationResultEvent.VALID);
		}
		/**
		 * The <code>init()</code> method is fired off automatically by the 
		 * AbstractViewMediator when the creation complete event fires for the
		 * corresponding ViewMediator's view. This allows us to listen for events
		 * and set data bindings on the view with the confidence that our view
		 * and all of it's child views have been created and live on the stage.
		 */
		override protected function init():void {
			super.init();  
			viewState = Utils.HOME_INDEX;
			
			view.personQuestion.dataProvider = new ArrayList(["My Favorite Movie?","My Mother's Maiden Name?","My First Vehicle?","My Favorite Color?"]);
			view.personQuestion.selectedIndex = 0;
			
			createFormValidators();
			
			if(!int( currentInstance.mapConfig.currentPerson.personId) ) {
				var perAllsignal:SignalVO = new SignalVO( this, personDAO, Action.SQL_FINDALL );
				signalSeq.addSignal( perAllsignal ); 
				
				var persignal:SignalVO = new SignalVO( this, personDAO, Action.FINDBY_NAME );
				persignal.name = currentInstance.mapConfig.currentPerson.personEmail;
				signalSeq.addSignal( persignal ); 
			}
		}
		//load all persons
		protected function initRecords(person:Persons):void {
			currentInstance.mapConfig.currentPerson.connectionArr.push(person.personId)
			var persignal:SignalVO = new SignalVO( this, personDAO, Action.FINDBY_NAME );
			persignal.description = Description.FINISHED
			persignal.name = person.personEmail;
			signalSeq.addSignal( persignal ); 
		}
		protected function setDataProviders():void {	
			setDataProviderFilters('upd');
			view.myUpdateDG.dataProvider = currentInstance.mapConfig.currentPerson.notesSet;
			view.friendsListDG.dataProvider = currentInstance.mapConfig.currentPerson.connectionSet;
			setDataProviderFilters('suggest');
			view.suggestFriendsListDG.dataProvider = personDAO.collection.items;
			view.wallTab.selectedIndex = 0;
			view.wallTab.dispatchEvent(new IndexChangeEvent(IndexChangeEvent.CHANGE))
		} 
		protected function setDataProviderFilters(filterStr:String):void {	
			switch(filterStr){
				case 'wall':
					if(noteDAO.collection.items){
					(noteDAO.collection.items as ArrayCollection).filterFunction = wallFilter;
					(noteDAO.collection.items as ArrayCollection).refresh();
					}
					break;
				case 'msg':
					if(noteDAO.collection.items){
					(noteDAO.collection.items as ArrayCollection).filterFunction = msgFilter;
					(noteDAO.collection.items as ArrayCollection).refresh();
					}
					break;
				case 'suggest':
					if(personDAO.collection.items){
					(personDAO.collection.items as ArrayCollection).filterFunction = suggestFilter;
					(personDAO.collection.items as ArrayCollection).refresh();
					}
					break; 
				case 'upd':
					currentInstance.mapConfig.currentPerson.notesSet.filterFunction = updateFilter;
					currentInstance.mapConfig.currentPerson.notesSet.refresh();
					break; 
			}
		}
		
		protected function updateFilter(obj:Object):Boolean{
			if ( Notes(obj).personFK == 0 &&  Notes(obj).noteType ==0){
				return true;
			}
			return false;
		}
		protected function msgFilter(obj:Object):Boolean{
			if( Notes(obj).personFK > 0 ){
				if ( Notes(obj).personFK == currentInstance.mapConfig.currentPerson.personId || (Notes(obj).createdPersonFK == currentInstance.mapConfig.currentPerson.personId ) ){
						return true;
				}
			}
			return false;
		}
		protected function wallFilter(obj:Object):Boolean{
			if ( Notes(obj).createdPersonFK != currentInstance.mapConfig.currentPerson.personId && Notes(obj).personFK == 0){
				for each(var person:Persons in currentInstance.mapConfig.currentPerson.connectionSet){
					if(person.personId == Notes(obj).createdPersonFK){
						return true;
					}
				}
			}
			return false;
		}
		protected function suggestFilter(obj:Object):Boolean{
			if ( currentInstance.mapConfig.currentPerson.connectionArr.indexOf(Persons(obj).personId)==-1){ 
				if(Persons(obj).personId!= currentInstance.mapConfig.currentPerson.personId){
					return true;
				}
			}
			return false;
		}
		override protected function setRenderers():void {
			super.setRenderers(); 
			BuddyCard.personsArr = currentInstance.mapConfig.currentPerson.connectionArr;
			view.wallDG.itemRenderer = RendererUtil.getCustomRenderer(Utils.NOTEDAO);
			view.myUpdateDG.itemRenderer = RendererUtil.getCustomRenderer(Utils.NOTEDAO);
			view.messageDG.itemRenderer = RendererUtil.getCustomRenderer(Utils.NOTEDAO);
			view.friendsListDG.itemRenderer = RendererUtil.getCustomRenderer(Utils.PERSONDAO);
			view.suggestFriendsListDG.itemRenderer = RendererUtil.getCustomRenderer(Utils.PERSONDAO);
		} 
		private var passwordState:Boolean;
		
		protected function changeToPasswordView(evt:MouseEvent = null):void
		{
			passwordState = !passwordState;
			changeState(passwordState);
		}
		protected function changeState(register:Boolean):void
		{
			view.passwordForm.includeInLayout = register;
			view.passwordForm.visible = register;
			view.passwordBtn.includeInLayout =!register;
			view.passwordBtn.visible = !register;
		}
		override protected function serviceResultHandler( obj:Object,signal:SignalVO ):void {  
		 	 	if( signal.destination == personDAO.destination ) {
					if( signal.action == Action.FINDBY_NAME ){
						if(signal.description!=Description.FINISHED ){
	 						currentInstance.mapConfig.currentPerson =GetVOObjectUtil.getPersonObject( currentInstance.mapConfig.currentPerson.personEmail, currentInstance.mapConfig.currentPerson.personPassword, personDAO.collection.items as ArrayCollection );
							currentInstance.mapConfig.currentPerson.personAvailability = 1;
							view.personName.text = currentInstance.mapConfig.currentPerson.personFirstname;
							ObjectUtils.setUpForm(currentInstance.mapConfig.currentPerson,view.personForm); 
							ObjectUtils.setUpForm(currentInstance.mapConfig.currentPerson,view.passwordForm); 
							
							view.friendsCount.text ='Friends Count : '+ currentInstance.mapConfig.currentPerson.connectionArr.length;
							currentInstance.mapConfig.currentPerson.connectionArr.push(currentInstance.mapConfig.currentPerson.personId);
							if(currentInstance.mapConfig.currentPerson.personRelations == 0){
								changeToPasswordView();
								currentInstance.mapConfig.currentPerson.personRelations = 1;
							}
							
							view.wallDG.currentPersonId = currentInstance.mapConfig.currentPerson.personId;
							view.myUpdateDG.currentPersonId = currentInstance.mapConfig.currentPerson.personId;
							view.messageDG.currentPersonId = currentInstance.mapConfig.currentPerson.personId;
							var perAvailSignal:SignalVO = new SignalVO( this, personDAO, Action.UPDATE );
							perAvailSignal.valueObject = currentInstance.mapConfig.currentPerson;
							signalSeq.addSignal( perAvailSignal ); 
							
							var pushOnlineMessage:PushMessage = new PushMessage( Description.UPDATE, [],  currentInstance.mapConfig.currentPerson.personId );
							var pushOnlineSignal:SignalVO = new SignalVO( this, personDAO, Action.PUSH_MSG, pushOnlineMessage );
							signalSeq.addSignal( pushOnlineSignal );
						}else{
							personProcess.processVO(ArrayCollection(obj).getItemAt(0) as Persons);
						}
						setDataProviders();
					}
					if( signal.action == Action.SQL_FINDALL ){
						currentInstance.mapConfig.currentPersonsList = obj as ArrayCollection;
						UpdateCard.currentPersonsList = currentInstance.mapConfig.currentPersonsList;
	 					Comment.currentPersonsList = currentInstance.mapConfig.currentPersonsList;
						view.searchInput.dataProvider = currentInstance.mapConfig.currentPersonsList
						view.searchInput.labelField = 'personFirstname'	
					}
				}
				if( signal.destination == noteDAO.destination ) {
					if( signal.action == Action.CREATE ){
						if(Notes(obj).personFK ==0){
							currentInstance.mapConfig.currentPerson.notesSet.addItem(obj);
							view.myUpdateDG.dataProvider =	currentInstance.mapConfig.currentPerson.notesSet;
							view.updateTxt.text = '';
							if(parentUpdateNote!=null && Notes(obj).noteType != 0){
								var updateParentNoteSignal:SignalVO = new SignalVO( this, noteDAO, Action.UPDATE );
								parentUpdateNote.notesSet.addItem(Notes(obj));
								updateParentNoteSignal.valueObject = parentUpdateNote;
								signalSeq.addSignal( updateParentNoteSignal );
							}
						}
						 
					}
					if( signal.action == Action.UPDATE ){
						parentUpdateNote = null;
					}
				}
				if( signal.destination == pagingDAO.destination ) { 
					if(obj == Utils.TWEETSUCCESS){
						view.updateTxt.text = '';
					}else{
						currentInstance.config.statusText = obj as String
						setTimeout(	clearStatus,2000);
					}
				}
		}
		protected function clearStatus():void{ 
			currentInstance.config.statusText =''
		}
		protected function newTweetHandler(ev:Object):void{ 
		/*	var pushChatMessage:PushMessage = new PushMessage( 'Chat Message', [view.personid.value],  currentInstance.mapConfig.currentPerson.personId );
			var pushChatSignal:SignalVO = new SignalVO( this, personDAO, Action.PUSH_MSG, pushChatMessage );
			signalSeq.addSignal( pushChatSignal );*/
			
		}
		/**
		 * Create listeners for all of the view's children that dispatch events
		 * that we want to handle in this mediator.
		 */
		override protected function setViewListeners():void {
			super.setViewListeners(); 
			//view.tweet.clicked.add(chatPush);
			view.submitBtn.clicked.add(modifyPasswordHandler);
			view.personPassword1.addEventListener(Event.CHANGE, inputChgHandler);
			view.personPassword2.addEventListener(Event.CHANGE, inputChgHandler);
			view.wallTab.addEventListener(IndexChangeEvent.CHANGE,changeWallFilter);
			view.passwordBtn.clicked.add(changeToPasswordView);
			view.cancelBtn.clicked.add(changeToPasswordView);
			view.profilePanel.panelSignal.add(profilePanelHandler);
			view.searchPanel.panelSignal.add(searchPanelHandler);
			view.profileTxt.addEventListener(MouseEvent.CLICK,profilePanelHandler);
			view.findFriendsBtn.clicked.add(searchPanelHandler);
			view.update.clicked.add(newUpdateHandler);
			
			view.wallDG.renderSignal.add(wallHandler);
			view.myUpdateDG.renderSignal.add(myUpdateDGHandler);
			view.messageDG.renderSignal.add(messageDGHandler);
			view.friendsListDG.renderSignal.add(friendsListDGHandler);
			view.suggestFriendsListDG.renderSignal.add(suggestFriendsListDGHandler);
			ObjectUtils.buddySignal.add(addFriendsHandler);
		}
		private function changeWallFilter(ev:IndexChangeEvent=null,index:int = 1):void{
			if(ev) index = ev.newIndex
			if(index == 2){
				view.currentState = "MsgState";
				setDataProviderFilters('msg');
				view.messageDG.dataProvider = noteDAO.collection.items;
			}else if(index == 1){
				view.currentState ="WallState";
				setDataProviderFilters('wall');
				view.wallDG.dataProvider = noteDAO.collection.items;
			}else{
				view.currentState = "UpdateState";
			}
		} 
		private var parentUpdateNote:Notes
		private function wallHandler(str:String, note:Notes,parentNote:Notes):void{ 
			if(str==NativeList.REPLIEDUPDATE){
			var updateNoteSignal:SignalVO = new SignalVO( this, noteDAO, Action.CREATE );
			var updateParentNoteSignal:SignalVO = new SignalVO( this, noteDAO, Action.UPDATE );
			parentNote.notesSet.addItem(note);
			updateNoteSignal.valueObject = note;
			parentUpdateNote= parentNote;
			updateParentNoteSignal.valueObject = parentNote;
			signalSeq.addSignal( updateNoteSignal );
			signalSeq.addSignal( updateParentNoteSignal );
			}
		}
		private function myUpdateDGHandler(str:String, note:Notes,parentNote:Notes):void{
			if(str==NativeList.REPLIEDUPDATE){
			var updateNoteSignal:SignalVO = new SignalVO( this, noteDAO, Action.CREATE );
			updateNoteSignal.valueObject = note; 
			parentUpdateNote= parentNote;
			signalSeq.addSignal( updateNoteSignal ); 
			}
		}
		private function messageDGHandler(str:String, note:Notes,parentNote:Notes):void{
			if(str==NativeList.REPLIEDUPDATE){
			var updateNoteSignal:SignalVO = new SignalVO( this, noteDAO, Action.CREATE );
			updateNoteSignal.valueObject = note; 
			parentUpdateNote= parentNote;
			signalSeq.addSignal( updateNoteSignal );
			}
		}
		
		public var openedUser:Array = [];
		private function friendsListDGHandler(str:String, person:Persons):void{
			if(str==NativeList.OPENCHAT){
				if(openedUser.indexOf(person)==-1){  
				}	
			}
		}
		private function setPositions(event:Event):void{
			event.currentTarget.x = Math.random()*(this.width-event.currentTarget.width);
			event.currentTarget.y = Math.random()*(this.height-event.currentTarget.height);
		}
		private function closeChatWindow(event:Event):void{
			if(openedUser.indexOf(event.currentTarget.person)!= -1){
				openedUser.splice(openedUser.indexOf(event.currentTarget.person),1);
			};
		}
		private function suggestFriendsListDGHandler(str:String, person:Persons):void{
			
		} 
		private function addFriendsHandler(str:String,person:Persons,msgStr:String=''):void{
			if(str == NativeList.FOLLOWPERSON){
				currentInstance.mapConfig.currentPerson.connectionSet.addItem(person);
				var perFollowSignal:SignalVO = new SignalVO( this, personDAO, Action.UPDATE );
				perFollowSignal.valueObject = currentInstance.mapConfig.currentPerson;
				signalSeq.addSignal(perFollowSignal);
				initRecords(person)
			}else if(str == NativeList.REPLIEDUPDATE){
				var perMsgSignal:SignalVO = new SignalVO( this, noteDAO, Action.CREATE );
				var msg:Notes = new Notes();
				msg.createdPersonFK = currentInstance.mapConfig.currentPerson.personId;
				msg.description = msgStr;
				msg.personFK = person.personId;
				perMsgSignal.valueObject = msg;
				signalSeq.addSignal(perMsgSignal);
			}
		}
		
		private function newUpdateHandler(event:MouseEvent=null):void{
			var newNote:Notes = new Notes();
			newNote.description =  view.updateTxt.text;
			newNote.createdPersonFK = currentInstance.mapConfig.currentPerson.personId;
			newNote.creationDate = new Date();
			if(view.tweet.selected){
				var tweetSignal:SignalVO = new SignalVO( this, pagingDAO, Action.UPDATETWEET );
				tweetSignal.id = newNote.createdPersonFK; 
				tweetSignal.name =newNote.description 
				signalSeq.addSignal( tweetSignal );
			}
			var updateNoteSignal:SignalVO = new SignalVO( this, noteDAO, Action.CREATE );
			updateNoteSignal.valueObject = newNote;
			signalSeq.addSignal( updateNoteSignal );
		}
		private function searchPanelHandler(event:MouseEvent=null):void{
			view.searchPanel.includeInLayout = !view.searchPanel.includeInLayout;
			view.searchPanel.visible = !view.searchPanel.visible ;
		}
		private function profilePanelHandler(event:MouseEvent=null):void{
			view.profilePanel.includeInLayout = !view.profilePanel.includeInLayout ;
			view.profilePanel.visible = !view.profilePanel.visible;
		}
 
		protected function modifyPasswordHandler( event:MouseEvent): void {
			var perPasswdSignal:SignalVO = new SignalVO( this, personDAO, Action.UPDATE );
			var personVo:Persons= currentInstance.mapConfig.currentPerson;
			personVo = ObjectUtils.getCastObject(personObj,personVo) as Persons;
			personVo.personPassword = view.personPassword1.text;
			perPasswdSignal.valueObject = personVo;
			
			if(view.personPassword1.text == view.personPassword2.text && view.oldPersonPassword.text == currentInstance.mapConfig.currentPerson.personPassword){
				signalSeq.addSignal(perPasswdSignal);
				changeToPasswordView();
			}else{
				currentInstance.config.statusText ='Passwords should match'
				setTimeout(	clearStatus,2000);
			}
		}
		override protected function pushResultHandler( signal:SignalVO ): void { 
		} 
		/**
		 * Remove any listeners we've created.
		 */
		override protected function cleanup( event:Event ):void {
			super.cleanup( event ); 		
		}
		//@TODO

		/**
		 * initiates cleanup view, of this view. manages stage resize, minimize or maximize event 
		 * as removed from stage event should not be called on these system events
		 */		
		override protected function gcCleanup( event:Event ):void {
			if( viewState != Utils.HOME_INDEX ) {
				cleanup( event );	
			}
		}
	}
}