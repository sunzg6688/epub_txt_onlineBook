package
{
	import epub.OpfPage;
	
	import flash.events.MouseEvent;
	
	import mx.core.UIComponent;
	
	import spark.components.Label;
	import spark.components.TextArea;
	
	public class MarkPage extends UIComponent
	{
		protected var _page:OpfPage;
		
		public function MarkPage()
		{
			super();
			this.addEventListener(MouseEvent.CLICK,pageClick);
			this.addEventListener(MouseEvent.ROLL_OVER,pageOver);
			this.addEventListener(MouseEvent.ROLL_OUT,pageOut);
		}
		
		public function get page():OpfPage
		{
			return _page;
		}

		public function set page(value:OpfPage):void
		{
			_page = value;
			init();
		}
		
		public function pageClick(event:MouseEvent):void{
			
		}
		
		public function pageOver(event:MouseEvent):void{
			this.graphics.beginFill(0xff0000,0.2);
			this.graphics.drawRect(0,0,200,400);
			this.graphics.endFill();
		}
		
		public function pageOut(event:MouseEvent):void{
			this.graphics.beginFill(0,0.2);
			this.graphics.drawRect(0,0,200,400);
			this.graphics.endFill();
		}
		
		public function init():void{
			this.graphics.beginFill(0x666666);
			this.graphics.drawRect(0,0,200,400);
			this.graphics.endFill();
			var _label:Label=new Label();
			_label.text="第"+_page.index+"页";
			_label.width=196;
			_label.height=24;
			_label.x=2;
			_label.y=2;
			this.addChild(_label);
			var txt:TextArea=new TextArea();
			txt.width=196;
			txt.height=376;
			txt.y=26;
			txt.x=2;
			txt.textFlow=_page.textFlow;
			this.addChild(txt);
		}
	}
}