package
{
	import epub.OpfPage;
	
	import flash.display.Sprite;
	import flash.text.TextField;
	import flash.text.engine.TextLine;
	
	import flashx.textLayout.container.ContainerController;
	import flashx.textLayout.elements.TextFlow;
	
	public class ViewPage extends Sprite
	{
		private var _opfPage:OpfPage;
		private var _opfPageIndex:int;
		public var isBig:Boolean=true;
		private var _index:int;//以单页面为基准
		public var sp:Sprite;
		public var ly:int;
		public var lineX:int=0;
		public var lineY:int=10;
		public var _lineIndex:int=0;
		public var _markWord:String="";
		
		public var control:ContainerController;
		public var txfl:TextFlow;
		public var txtNum:TextField=new TextField();
		
		public function ViewPage()
		{
			super();
		}
		
		public function addLine(line:TextLine):void{
			if(_lineIndex==0){
//				line.get
			}
			line.x=20;
			line.y=lineY+line.height;
			lineY=lineY+line.height+8;
			sp.addChild(line);
			ly=ly-line.height-8;
			_lineIndex++;
		}
		
		public function updateTF():void{
			txfl.flowComposer.updateAllControllers();
			txtNum.text="= "+_index+" =";
			txtNum.x=this.width/2-20;
			txtNum.y=this.height-25;
			this.addChild(txtNum);
		}
		
		public function resetSize(w:int,h:int):void{
			_lineIndex=0;
			_markWord="";
			lineX=0;
			lineY=20;
			ly=h-30;
			while(sp){
				sp=null;
			}
			sp=new Sprite();
//			this.width=w;
//			this.height=h;
			drawPage(w,h);
			control=new ContainerController(sp,this.width,this.height);
			txfl=new TextFlow();
			txfl.flowComposer.addController(control);
			addChild(sp);
		}
		
		public function drawPage(w:int,h:int):void{
			sp.graphics.beginFill(0xffffff);
			sp.graphics.drawRect(0,0,w,h);
			sp.graphics.endFill();
			
			sp.graphics.lineStyle(2,0x999999);
			sp.graphics.moveTo(1,1);
			sp.graphics.lineTo(w-1,1);
			sp.graphics.lineTo(w-1,h-1);
			sp.graphics.lineTo(1,h-1);
			sp.graphics.lineTo(1,1);
		}
		
		public function get opfPageIndex():int
		{
			return _opfPageIndex;
		}

		public function set opfPageIndex(value:int):void
		{
			_opfPageIndex = value;
		}

		public function get opfPage():OpfPage
		{
			return _opfPage;
		}

		public function set opfPage(value:OpfPage):void
		{
			_opfPage = value;
		}

		public function get index():int
		{
			return _index;
		}

		public function set index(value:int):void
		{
			_index = value;
		}

	}
}