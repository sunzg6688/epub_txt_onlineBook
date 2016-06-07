package epub
{
	
	import xhtml.XhtmlToTextFlow;
	
	import flashx.textLayout.elements.TextFlow;
	
	public class OpfPage
	{
		protected var _id:String;
		protected var _path:String;
		protected var _pageXML:XML;
		protected var _textFlow:TextFlow;
		protected var _index:int;
		
		public function OpfPage()
		{
		}
		
		public function get index():int{
			return _index;
		}
		
		public function set index(_index:int):void{
			this._index=_index;
		}

		public function get id():String { return _id; }
		public function set id(pId:String):void { _id = pId; }
		

		public function get pageString():String { 
			return _pageXML.toString(); 
		}
			
		public function set pageString(pS:String):void { 
			_pageXML = new XML(pS);
			_textFlow = null;
		}
		
		public function get path():String { return _path; }
		public function set path(pPath: String):void { _path = pPath; }
		
		public function set pageXML(p:XML):void {
			_pageXML = p;
			_textFlow = null;
		}
		
		public function get pageXML():XML {
			return _pageXML;
		}
		
		public function get textFlow():TextFlow {
			if (!_textFlow) {
				parseTextFlow();
			}
			return _textFlow;
		}
		
		public function parseTextFlow():void {
			_textFlow = XhtmlToTextFlow.convert( _pageXML );
		}

	}
}