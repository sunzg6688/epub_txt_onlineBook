package xhtml
{
	import epub.EPub;
	
	import flash.display.DisplayObject;
	import flash.utils.getQualifiedClassName;
	
	import mx.core.FlexGlobals;
	
	import flashx.textLayout.conversion.ConversionType;
	import flashx.textLayout.conversion.TextConverter;
	import flashx.textLayout.elements.DivElement;
	import flashx.textLayout.elements.FlowElement;
	import flashx.textLayout.elements.FlowGroupElement;
	import flashx.textLayout.elements.FlowLeafElement;
	import flashx.textLayout.elements.InlineGraphicElement;
	import flashx.textLayout.elements.LinkElement;
	import flashx.textLayout.elements.ParagraphElement;
	import flashx.textLayout.elements.SpanElement;
	import flashx.textLayout.elements.TextFlow;
	import flashx.textLayout.events.FlowElementMouseEvent;
	
	public class XhtmlToTextFlow
	{
		
		public static var flow:Namespace = new Namespace("flow", "http://ns.adobe.com/textLayout/2008");
	
		
		// Character limits for section splitting
		public static const SECTION_MIN:Number = 400;
		public static const MAJOR_SECTION_MAX:Number = 20000;//20000
		public static const MAXIMUM_SECTION:Number = 40000; //40000
		
		public function XhtmlToTextFlow()
		{
			XML.ignoreComments = true;
			XML.ignoreWhitespace = true;
		}
		
		/*
		 * Normalizes an xmlhtml file by flattening out all the divs that are just used for styles
		 * The result file will be a sequence of headings, paragraphs, and inline html elements
		 */
		public static var styleIndex:int=0;
		public static function flattenElements(doc:XML, flatPage:XML, styleStack:String = ""):void {
			var nodes:XMLList = doc.children();
			var thisStack:String;
			for (var i:int=0; i < nodes.length(); i++) {
				if (nodes[i].localName() == 'div' ) {
					// Pull the div's styles and flatten
					var htmlClass:String = nodes[i].attribute('class').toString();
					var htmlId:String = nodes[i].attribute('id').toString();
					thisStack = styleStack;
					if (htmlClass != "") {
						thisStack = XhtmlToTextFlow.joinStyles(styleStack, 'div.' + htmlClass);
					}
					if (htmlId != "") {
						thisStack = XhtmlToTextFlow.joinStyles(styleStack, 'div#' + htmlId);
					}
					flattenElements(nodes[i], flatPage, thisStack);
				} else {
					// Assign the styles and add
					var styleName:String = nodes[i].@styleName.toString();
					if (styleStack != "") {
						nodes[i].@styleName = styleStack;
					} 
					styleIndex++;
					flatPage.appendChild(nodes[i]);
				}
			}
		}
		
		/*
		 * Divides a long xhtml file into manageable chunks
		 * Each h1, h2, or h3 heading creates a new section document
		 * Returns an array of new XHTML files
		 */
		public static var sssI:int=0;
		public static var sectionLg:int=0;
		
		public static var isGo:Boolean=false;
		
		public static function splitIntoSection3():Array{
			i--;
			sectionLg=0;
			sections=[];
			s=-1;
			for(i; i<children.length(); i++){
				if(sectionLg>=20){//每一页大约需要2秒钟
//					s++;
//					splitIntoSection4(i--);
					isGo=true;
					break;
//					return;
				}
				var tag:String= children[i].localName();
				var newSection:Boolean = false;
				if ( sections.length == 0) {
					newSection = true;
				} else {
					var thisSectionLength:Number = sections[s].toString().length;
					if (tag == "h1" || tag == "h2" || tag == "h3") {
						newSection = true;
						if (thisSectionLength < SECTION_MIN ) {
							newSection = false;
						}
					}else if(thisSectionLength > MAJOR_SECTION_MAX){
						if ( tag == "h4" || tag == "h5" || tag == "h6") {
							newSection = true;
						}
					}
					if (thisSectionLength > MAXIMUM_SECTION) {
						newSection = true;
					}
				}
				if (newSection) {
					// put content into a new section
					sectionLg++
					s++;
					sections[s] = <body/>;
					sections[s].appendChild( children[i] );
				} else {
					// Append to the current section
					sections[s].appendChild( children[i] );
				}
				isGo=false;
			}
			
			if(sections.length==0){ //空白页
				sections[0] = <body/>
				var _kb:XML=<body>
							  <p></p>
							</body>;
				var chl:XMLList = _kb.children();
				
				sections[0].appendChild(chl[0]);
			}
			return sections;
		}
		
		public static var sections:Array=[];
		public static var s:int=-1;
		public static var children:XMLList;
		public static var i:int=0;
		
		public static function splitIntoSections2(doc:XML):Array{
			isGo=false;
			sectionLg=0;
			sections=[];
			s=-1;
			i=0;
			children = doc.children();
			trace("children:::::::",children.length());
			for(i=0; i<children.length(); i++){
				if(sectionLg>=20){//每一页大约需要2秒钟
//					s++;
//					splitIntoSection3(i--);
					isGo=true;
					break;
//					return;
				}
				var tag:String= children[i].localName();
				var newSection:Boolean = false;
				if ( sections.length == 0) {
					newSection = true;
				} else {
					var thisSectionLength:Number = sections[s].toString().length;
					if (tag == "h1" || tag == "h2" || tag == "h3") {
						newSection = true;
						if (thisSectionLength < SECTION_MIN ) {
							newSection = false;
						}
					}else if(thisSectionLength > MAJOR_SECTION_MAX){
						if ( tag == "h4" || tag == "h5" || tag == "h6") {
							newSection = true;
						}
					}
					if (thisSectionLength > MAXIMUM_SECTION) {
						newSection = true;
					}
				}
				if (newSection) {
					// put content into a new section
					sectionLg++
					s++;
					sections[s] = <body/>;
					sections[s].appendChild( children[i] );
				} else {
					// Append to the current section
					sections[s].appendChild( children[i] );
				}
				isGo=false;
			}
			
			if(sections.length==0){ //空白页
				sections[0] = <body/>
				var _kb:XML=<body>
							  <p></p>
							</body>;
				var chl:XMLList = _kb.children();
				
				sections[0].appendChild(chl[0]);
			}
			return sections;
		}
		
		
		public static function splitIntoSections(doc:XML):Array {
//			if(sssI==0)trace("splitIntoSections doc",doc.toString());
			var sections:Array = new Array();
			var i:int; // counter
			var s:int=-1; // num of scurrent ection
			var children:XMLList = doc.children();
			
			for (i=0; i<children.length(); i++) {
				if(sectionLg>=20){//每一页大约需要2秒钟
					break;
				}
				var tag:String = children[i].localName();
				var newSection:Boolean = false;
				if ( sections.length == 0) {
					// We need at least one section!
					newSection = true;
				} else {
					var thisSectionLength:Number = sections[s].toString().length; 
//					trace("thisSectionLength==============",thisSectionLength);
					if (tag == "h1" || tag == "h2" || tag == "h3") {
						// Make new sections on heads
						newSection = true;
						
//						public static const SECTION_MIN:Number = 400;
//						public static const MAJOR_SECTION_MAX:Number = 20000;
//						public static const MAXIMUM_SECTION:Number =   40000; 
						
						
						// Unless the current section is really tiny!
						if (thisSectionLength < SECTION_MIN ) {
							newSection = false;
						}
					} else if (thisSectionLength > MAJOR_SECTION_MAX) {
						// If this one has just gotten huge, break anyway at another head
						if ( tag == "h4" || tag == "h5" || tag == "h6") {
							newSection = true;
						}
					}
					if (thisSectionLength > MAXIMUM_SECTION) {
						// Too big. BREAK!
//						trace("TTTTTTTTTTTTTt000 big ");
						newSection = true;
					}
				}
				
				
				if (newSection) {
					// put content into a new section
					sectionLg++
					s++;
					sections[s] = <body/>;
					sections[s].appendChild( children[i] );
				} else {
					// Append to the current section
					sections[s].appendChild( children[i] );
				}
			}
			
			if(sections.length==0){ //空白页
				sections[0] = <body/>
				var _kb:XML=<body>
                              <p></p>
                            </body>;
				var chl:XMLList = _kb.children();
				
				sections[0].appendChild(chl[0]);
			}
			return sections;
		}
		public static var textOut:int=0;
		public static function convert(xmlhtml:XML):TextFlow
		{
			var textFlow:TextFlow = new TextFlow();
			XhtmlToTextFlow.parseElement(xmlhtml, textFlow);
			
			if(textOut==5){
				XhtmlToTextFlow.testOutput(textFlow);
			}
			
			textOut++;
			return textFlow;
		}
		
		public static function testOutput(tf:TextFlow):void 
		{
//			trace ( TextConverter.export(tf, TextConverter.TEXT_LAYOUT_FORMAT, ConversionType.XML_TYPE) );
			systemOut();
//			trace(TextConverter.export(tf,TextConverter.TEXT_FIELD_HTML_FORMAT,ConversionType.STRING_TYPE));
		}
		
		public static function systemOut():void{
			trace("========================================");
		}
		public static function parseElement(xmlhtml:XML, flow:*, styleStack:String = "", pre:Boolean = false):void 
		{
			var tag:String = xmlhtml.localName();
//			if(textOut==0)trace("tage::::::::",tag);
			switch (tag) {
				case 'html':
					XhtmlToTextFlow.parseDivElement(xmlhtml, flow, "html", styleStack); break;
				case 'body':
					XhtmlToTextFlow.parseDivElement(xmlhtml, flow, "body", styleStack); break;
				case 'blockquote':
					XhtmlToTextFlow.parseDivElement(xmlhtml, flow, "blockquote", styleStack); break;
				case 'ul':
					XhtmlToTextFlow.parseDivElement(xmlhtml, flow, "ul", styleStack); break;
				case 'ol':
					XhtmlToTextFlow.parseDivElement(xmlhtml, flow, "ol", styleStack); break;
				case 'div': 
					XhtmlToTextFlow.parseDivElement(xmlhtml, flow, "div", styleStack); break;
				case 'p':
					XhtmlToTextFlow.parseParagraphElement(xmlhtml, flow, "p", styleStack); break;
				case 'h1':
					XhtmlToTextFlow.parseParagraphElement(xmlhtml, flow, "h1", styleStack); break;
				case 'h2':
					XhtmlToTextFlow.parseParagraphElement(xmlhtml, flow, "h2", styleStack); break;
				case 'h3':
					XhtmlToTextFlow.parseParagraphElement(xmlhtml, flow, "h3", styleStack); break;
				case 'h4':
					XhtmlToTextFlow.parseParagraphElement(xmlhtml, flow, "h4", styleStack); break;
				case 'h5':
					XhtmlToTextFlow.parseParagraphElement(xmlhtml, flow, "h5", styleStack); break;
				case 'h6':
					XhtmlToTextFlow.parseParagraphElement(xmlhtml, flow, "h6", styleStack); break;
				case 'li':
					XhtmlToTextFlow.parseParagraphElement(xmlhtml, flow, "li", styleStack); break;
				case 'span':
					XhtmlToTextFlow.parseSpanElement(xmlhtml, flow, "span", styleStack); break;
				case 'i':
					XhtmlToTextFlow.parseSpanElement(xmlhtml, flow, "i", styleStack); break;
				case 'b':
					XhtmlToTextFlow.parseSpanElement(xmlhtml, flow, "b", styleStack); break;
				case 'em':
					XhtmlToTextFlow.parseSpanElement(xmlhtml, flow, "em", styleStack); break;
				case 'strong':
					XhtmlToTextFlow.parseSpanElement(xmlhtml, flow, "strong", styleStack); break;
				case 'code':
					XhtmlToTextFlow.parseSpanElement(xmlhtml, flow, "code", styleStack); break;
				case 'cite':
					XhtmlToTextFlow.parseSpanElement(xmlhtml, flow, "cite", styleStack); break;
				case 'kbd':
					XhtmlToTextFlow.parseSpanElement(xmlhtml, flow, "kbd", styleStack); break;
				case 'a':
					XhtmlToTextFlow.parseLinkElement(xmlhtml, flow, styleStack); break;
				case 'pre':
					XhtmlToTextFlow.parsePreformatted(xmlhtml, flow, styleStack); break;
				case 'table':
					XhtmlToTextFlow.parseTable(xmlhtml, flow); break;
				case 'tr':
					XhtmlToTextFlow.parseParagraphElement(xmlhtml, flow, "tr", styleStack); break;
				case 'td':
					XhtmlToTextFlow.parseSpanElement(xmlhtml, flow, "td", styleStack); break;
				case 'img':
					XhtmlToTextFlow.parseImage(xmlhtml, flow); break;
				case 'hr':
					break; // ignore horizontal rules. they're stupid.
				case 'br':
					XhtmlToTextFlow.parseBrElement(xmlhtml, flow); break;
				case null:
					// Simple content 
					XhtmlToTextFlow.parseSimpleContent(xmlhtml, flow, styleStack, pre); break;
				default:
					XhtmlToTextFlow.parseUnknownElement(xmlhtml, flow); break;
			}
		}

		public static var imgxml:XML;
		public static function parseChildren(xmlhtml:XML, flow:FlowElement, styleStack:String = "", pre:Boolean = false):void {
			if ( xmlhtml.hasSimpleContent() ) {
				XhtmlToTextFlow.parseSimpleContent(xmlhtml, flow, styleStack, pre); 
			} else {
				var children:XMLList = xmlhtml.children();
				for (var i:int=0; i<children.length(); i++) {
					XhtmlToTextFlow.parseElement(children[i], flow, styleStack, pre);
				}
			}
		}
		
		public static function joinStyles(styleStack:String, newStyle:String):String {
			var rslt:String = styleStack;
			if (newStyle.length > 0) {
				if (rslt.length > 0 ) {
					rslt += ',';
				}
				rslt += newStyle;
			}
			return rslt;
		}

		public static function parseDivElement(xmlhtml:XML, flow:*, tag:String, styleStack:String = ""):void {
			var htmlId:String = xmlhtml.attribute('id').toString();
			var htmlClass:String = xmlhtml.attribute('class').toString();
			if ( isFlowGroup(flow) ) {
				var divElement:DivElement = new DivElement();
				divElement.styleName = styleStack; 	// It's possible there is a styleStack but unlikely
				divElement.styleName = XhtmlToTextFlow.joinStyles(divElement.styleName, xmlhtml.@styleName.toString() ); // add from xhtml
				divElement.styleName = XhtmlToTextFlow.joinStyles(divElement.styleName, tag); // add tag
				styleStack = ""; // it's applied, so clear it
				if (htmlClass != "") { 
					divElement.styleName = XhtmlToTextFlow.joinStyles(divElement.styleName, tag + '.' + htmlClass); // add class
				}
				if (htmlId != "") { 
					divElement.styleName = XhtmlToTextFlow.joinStyles(divElement.styleName, tag + '#' + htmlId); // add id
					divElement.id = htmlId;
				}
				flow.addChild(divElement);
				XhtmlToTextFlow.parseChildren(xmlhtml, divElement, styleStack);
			} else {
				// This is a bad case, but we can potentially use the style stack to add div styling to
				//   things poorly nested, for example, a <div> inside a <p> Ug!
				trace("Badly formed xmlhtml. Ignoring for now.");
			}
		}
		
		public static function parseParagraphElement(xmlhtml:XML, flow:FlowGroupElement, tag:String, styleStack:String = ""):void 
		{	
			var htmlId:String = xmlhtml.attribute('id').toString();
			var htmlClass:String = xmlhtml.attribute('class').toString();
			if ( isFlowGroup(flow) && xmlhtml.children().length() > 0) { 
				var paraElement:ParagraphElement = new ParagraphElement();
				paraElement.styleName = styleStack;
				paraElement.styleName = XhtmlToTextFlow.joinStyles(paraElement.styleName, xmlhtml.@styleName.toString() );
				paraElement.styleName = XhtmlToTextFlow.joinStyles(paraElement.styleName, tag);
				styleStack = ""; 
				if (htmlClass != "") { 
					paraElement.styleName = XhtmlToTextFlow.joinStyles(paraElement.styleName, tag + '.' + htmlClass);
				}
				if (htmlId != "") { 
					paraElement.styleName = XhtmlToTextFlow.joinStyles(paraElement.styleName, tag + '#' + htmlId); 
					paraElement.id = htmlId; 
				}
				flow.addChild(paraElement);
				XhtmlToTextFlow.parseChildren(xmlhtml, paraElement, styleStack);
			} else {
				// badly formed html again
//				trace("Ignoring badly formed xhtml");
			}
		}
		
		public static function setStyleForElement(_element:*):void{
			
		}
		
		public static function parseSpanElement(xmlhtml:XML, flow:*, tag:String, styleStack:String = ""):void {
			var htmlId:String = xmlhtml.attribute('id').toString();
			var htmlClass:String = xmlhtml.attribute('class').toString();
			if ( isDiv(flow) ) {
				// This span will need a new paragraph
				// Create a new paragraph, apply the style stack if it exists
				// Create a new styleStack for this tag
				// Parse children
				var para:ParagraphElement = new ParagraphElement();
				para.styleName = styleStack;
				para.styleName = XhtmlToTextFlow.joinStyles(para.styleName, 'p');
				styleStack = tag;
				if (htmlClass != "") { 
					styleStack = XhtmlToTextFlow.joinStyles(styleStack, tag + '.' + htmlClass);
				}
				if (htmlId != "") { 
					styleStack = XhtmlToTextFlow.joinStyles(styleStack, tag + '#' + htmlId); 
				}
				DivElement(flow).addChild(para);
				XhtmlToTextFlow.parseChildren(xmlhtml, para, styleStack);
			} else if (isLink(flow) || isParagraph(flow) ) {
				// The children can be added here.
				// Apply to the styleStack and parse children
				styleStack = XhtmlToTextFlow.joinStyles(styleStack, tag);
				if (htmlClass != "") { 
					styleStack = XhtmlToTextFlow.joinStyles(styleStack, tag + '.' + htmlClass);
				}
				if (htmlId != "") { 
					styleStack = XhtmlToTextFlow.joinStyles(styleStack, tag + '#' + htmlId); 
				}
				XhtmlToTextFlow.parseChildren(xmlhtml, flow, styleStack);
			} else if ( isSpan(flow) ) {
				// Nested spans should no longer exist, as spans are only created around simple content
				trace("Metaphysical fail!");
			}
		}
		
		public static function parseSimpleContent(xmlhtml:XML, flow:FlowElement, styleStack:String = "", pre:Boolean = false):void {
			if (xmlhtml == null) { return; } // Sometimes bad things happen to good code
			var spanElement:SpanElement = new SpanElement();
			if ( isSpan(flow) ) {
				// This should no longer happen, since this is the only function making span elements
				trace("Metaphysical fail.");
			} else if (isLink(flow)) { 
				// Here's simple content link text, to be added to the link leaf group
				// Apply the styleStack and add the element
				spanElement.styleName = styleStack; 
				LinkElement(flow).addChild(spanElement);
			} else if ( isParagraph(flow) ) {
				// Most common scenario. Apply the style stack to the span and add content
				spanElement.styleName = styleStack;
				ParagraphElement(flow).addChild(spanElement);
			} else if ( isDiv(flow) ) {
				// Some html monstrosities may be missing paragraphs
				// Create the para, and add the styleStack to the p instead
				var para:ParagraphElement = new ParagraphElement();
				para.styleName = XhtmlToTextFlow.joinStyles(styleStack, 'p');
				spanElement.styleName = 'span';
				DivElement(flow).addChild(para);
				para.addChild(spanElement);
			} 
			if (spanElement.styleName.indexOf('span') == -1) {
				// Make sure it's a span, but try not to duplicate
				spanElement.styleName = XhtmlToTextFlow.joinStyles(spanElement.styleName, 'span');
			}
			if (pre) {
				// Add text to span with all whitespace and everything
				spanElement.text = xmlhtml.children()[0].toXMLString();
			} else {
				// Strip space and add the text to the span
				spanElement.text = XhtmlToTextFlow.stripSpace(xmlhtml.toString());
				XhtmlToTextFlow.addSpaceIfNeeded(spanElement);
			}
		}
		
		// This might not be working right
		public static function addSpaceIfNeeded(spanElement:SpanElement): void {
			// adds space in front of this span if it would be needed
			var prevLeaf:FlowLeafElement = spanElement.getPreviousLeaf(spanElement.getParagraph());
			if (prevLeaf) {
				var prevSpan:SpanElement = SpanElement(prevLeaf);
				var lastChar:String = prevSpan.text.charAt(prevSpan.text.length-1);
				if  (lastChar != " ") {
					spanElement.text = " " + spanElement.text;
				}
			}
		}
		
		public static function stripSpace(s:String):String {
			var whitespace:RegExp = /(\t|\n|\s{2,})/g;  
			var nbsp:RegExp = /\u00A0/g;
			s = s.replace(nbsp, ' ');
			s = s.replace(whitespace, ' ');
			return s;
		}
		
		
		
		public static function parseLinkElement(xmlhtml:XML, flow:*, styleStack:String = ""):void {
			var aName:String = xmlhtml.@name.toString();
			var htmlId:String = xmlhtml.attribute('id').toString();
			if (aName == "") {
				aName = htmlId; // I guess anchors can be @name or @id
			}
			var htmlClass:String = xmlhtml.attribute('class').toString();
			var href:String = xmlhtml.@href.toString();
			var para:ParagraphElement;
			// An <a> tag can be a hyperlink or a named anchor
			//  if it's a link, make a LinkElement tag, else make a named span
			if (href) {
				// Make a hyperlink, a LinkElement 
				var linkElement:LinkElement = new LinkElement();
				linkElement.target="_blank";
				linkElement.href = href; // can be an internal or external link
				if ( isSpan(flow) || isLink(flow) ) {
					// If a span is being added to a span or another link... we're hosed
					// Just add its body as simple content for now
					trace("Cannot add this link here.");
					XhtmlToTextFlow.parseChildren(xmlhtml, flow);
					return;
				} else if ( isDiv(flow) ) {
					// Wrap the link in a new paragraph, and assign the styleStack
					para = new ParagraphElement();
					para.styleName = styleStack;
					para.styleName = XhtmlToTextFlow.joinStyles(para.styleName, 'p');
					styleStack = "";
					linkElement.styleName = 'a';
					para.addChild(linkElement);
					DivElement(flow).addChild(para);					
				} else if ( isParagraph(flow) ) {
					ParagraphElement(flow).addChild(linkElement);
					linkElement.styleName = styleStack;
					linkElement.styleName = XhtmlToTextFlow.joinStyles(linkElement.styleName, 'a');
					styleStack = "";
				}
				// And continue for divs and paras 
				if (htmlClass != "") {
					linkElement.styleName = XhtmlToTextFlow.joinStyles(linkElement.styleName, 'a.' + htmlClass);
				}
				if (htmlId != "") {
					linkElement.styleName = XhtmlToTextFlow.joinStyles(linkElement.styleName, 'a#' + htmlId);
				}
				// There are no mouse handlers for links at the moment, but you could ad them here ie
				// linkElement.addEventListener(flashx.textLayout.events.FlowElementMouseEvent.CLICK, mylinkHandler);
				// And now parse link children, usually simple content
				XhtmlToTextFlow.parseChildren(xmlhtml, linkElement, styleStack);
			} else {
				// Make a named span as an internal anchor right here.
				var spanElement:SpanElement = new SpanElement();
				spanElement.id = aName;
				spanElement.styleName = "anchor";
				spanElement.text = " "; // add a space to hold the anchor
				if ( isDiv(flow) ) {
					// Wrap the span in a new paragraph
					para = new ParagraphElement();
					para.styleName = "p";
					para.addChild(spanElement);
					DivElement(flow).addChild(para);
					// Add children to the parent element, in case it's nested deep
					XhtmlToTextFlow.parseChildren(xmlhtml, flow, styleStack);
				} else if ( isParagraph(flow) ) {
					ParagraphElement(flow).addChild(spanElement);
					XhtmlToTextFlow.parseChildren(xmlhtml, flow);
				} else if ( isSpan(flow) ) {
					// If a span is being added to a span... we have a mess
					// Add the anchor name to the element so we can link to it and forget everything else   
					flow.id = aName;
				}
			} 

		}
		
		public static function parseBrElement(xmlhtml:XML, flow:FlowElement):void {
			var spanElement:SpanElement;
			if ( isSpan(flow) ) {
				// Line breaks can be added to a span
				SpanElement(flow).text += '\n';
			} else if ( isParagraph(flow) ) {
				// Breaks must be added to a span
				spanElement = new SpanElement();
				spanElement.styleName = "span";
				spanElement.text = " \n";
				ParagraphElement(flow).addChild(spanElement);
			} else if ( isDiv(flow) ) {
				// Simple content must be wrapped with a paragraph and a span to be added to a div
				spanElement = new SpanElement();
				spanElement.text = " \n";
				spanElement.styleName = "span";
				var paraElement:ParagraphElement = new ParagraphElement();
				paraElement.styleName = "p";
				paraElement.addChild(spanElement);
				DivElement(flow).addChild(paraElement);
			} else {
				trace("Don't know how to add a line break here");
			}
		}
		
		private static function parsePreformatted(xmlhtml:XML, flow:FlowElement, styleStack:String = ""):void {
			var divElement:DivElement = new DivElement();
			var spanElement:SpanElement;
			var paraElement:ParagraphElement = new ParagraphElement();
			var i:int;
			divElement.styleName = "pre";
			var children:XMLList = xmlhtml.children();
			//
			if ( isDiv(flow) ) {
				DivElement(flow).addChild(divElement);
				XhtmlToTextFlow.parseChildren(xmlhtml, divElement, styleStack, true);
			} 
			else if ( isParagraph(flow)) {
				// Add each child to the paragraph, maintaining its spaces and such
				XhtmlToTextFlow.parseChildren(xmlhtml, flow, styleStack, true);
			}
			if (isSpan(flow)) {
				// Why the hell did you put a <pre> block inside a span element?
				// ... are you trying to drive me crazy? Just adding it as simple content.
				for (i=0; i<children.length(); i++) {
					SpanElement(flow).text += children[i].toXMLString();
				}
			}
		}
		
		public static function parseTable(xmlhtml:XML, flow:FlowElement):void {
			// parameterize IGNORE_TABLES
			var IGNORE_TABLES:Boolean = true;
			if ( IGNORE_TABLES ) {
				var spanElement:SpanElement = new SpanElement();
				spanElement.text = "[HTML table omitted]";
				var paraElement:ParagraphElement = new ParagraphElement();
				paraElement.styleName = "table";
				paraElement.addChild(spanElement);
				FlowGroupElement(flow).addChild(paraElement);
			} else if ( isDiv(flow) ) {
				var divElement:DivElement = new DivElement();
				divElement.styleName = "table";
				DivElement(flow).addChild(divElement);
				XhtmlToTextFlow.parseChildren(xmlhtml, flow);
			}  
			
		}
		
		public static function parseImage(xmlhtml:XML, flow:FlowElement):void {
			var ige:InlineGraphicElement;
//			if(textOut==0)trace("textOut====000::::::",xmlhtml.toXMLString());
			if ( isSpan(flow) ) {
				// FOOL! Why you try to add an image to a span? 
				// You want to open a wormhole to another dimension of suck?
				SpanElement(flow).text += " [Image omitted] ";
				return;
			} else if ( isLink(flow)) {
				// Not sure about adding images to links right now
				trace("Not adding an image to a link");
			}if ( isParagraph(flow) ) {
				// Add the inline to the p
				ige = new InlineGraphicElement();
				ParagraphElement(flow).addChild(ige);
			} else if ( isDiv(flow) ) {
				// Add the inline to a new p and a new div
				// Maybe that'll help it flow?
				ige = new InlineGraphicElement();
				var p:ParagraphElement = new ParagraphElement();
				var d:DivElement = new DivElement();
				d.styleName="image";
				d.addChild(p);
				p.addChild(ige);
				DivElement(flow).addChild(p);
			}
			ige.styleName = "img";
//			ige.setStyle("src", xmlhtml.@src.toString());
            // htmlWidth and height is the suggested values from the html, 
            // .. but the StyleFactory might chart it's own course later
            // The style factory also receives the asset manifest and matches up the DisplayObjects with their FLowELements
//			ige.setStyle("htmlWidth", xmlhtml.@width.toString()); 
//			ige.setStyle("htmlHeight", xmlhtml.@height.toString());
			
			var sourcePath:String=xmlhtml.@src.toString();
//			ige.source=xmlhtml.@src.toString();
			if(EPub._images[sourcePath])ige.source=EPub._images[sourcePath].loader;
//			if(ige.parent&&isTextFlow(ige.parent)){
//				trace("ige.parent:::::",ige.parent);
//				TextFlow(ige.parent).flowComposer.updateAllControllers();
//			}else if(ige.parent.parent&&isTextFlow(ige.parent.parent)){
//				trace("ige.parent.parent:::::",ige.parent.parent);
//				TextFlow(ige.parent.parent).flowComposer.updateAllControllers();
//			}else if(ige.parent.parent.parent&&isTextFlow(ige.parent.parent.parent)){
//				trace("ige.parent.parent.parent:::::",ige.parent.parent.parent);
//				TextFlow(ige.parent.parent.parent).flowComposer.updateAllControllers();
//			}
//			var imgObj:DisplayObject;
//			trace("out   EPub._images[i]::::",EPub._images[sourcePath]);
			
//			ige.setStyle("htmlWidth", "50"); 
//			ige.setStyle("htmlHeight", "50");
			
			
		}
		
		public static function parseUnknownElement(xmlhtml:XML, flow:FlowElement):void {
			var spanElement:SpanElement;
			if ( isSpan(flow)  ) {
				SpanElement(flow).text += " [Unrecognized content] ";
				SpanElement(flow).text += xmlhtml.toString();
				SpanElement(flow).text += " [end] ";
			} else if ( isLink(flow) ) {
				spanElement = new SpanElement();
				spanElement.styleName = "code";
				spanElement.text = " [Unrecognized content] " + xmlhtml.toString() + "  [end] ";
				LinkElement(flow).addChild(spanElement);
			} else if ( isParagraph(flow) ) {
				spanElement = new SpanElement();
				spanElement.styleName = "code";
				spanElement.text = " [Unrecognized content] " + xmlhtml.toString() + "  [end] ";
				ParagraphElement(flow).addChild(spanElement);
			} else if ( isDiv(flow) ) {
				// Simple content must be wrapped with a paragraph and a span to be added to a div
				spanElement = new SpanElement();
				spanElement.styleName = "code";
				spanElement.text = xmlhtml.toXMLString();
				var paraElement:ParagraphElement = new ParagraphElement();
				paraElement.styleName = "blockquote";
				paraElement.addChild(spanElement);
				FlowGroupElement(flow).addChild(paraElement);
			} else {
				trace("Don't know how to add this unknown element");
			}
		}
		
		public static function  isTextFlow(flow:FlowElement):Boolean{
			if(getQualifiedClassName(flow)== 'flashx.textLayout.elements::TextFlow'){
				return true;
			}else{
				return false
			}
		}
		public static function isFlowGroup(flow:FlowElement):Boolean {
			if ( getQualifiedClassName(flow) == 'flashx.textLayout.elements::DivElement' || getQualifiedClassName(flow) == 'flashx.textLayout.elements::TextFlow') {
				return true; } else { return false; }
		}

		public static function isDiv(flow:FlowElement):Boolean {
			if ( getQualifiedClassName(flow) == 'flashx.textLayout.elements::DivElement') {
				return true; } else { return false; }
		}
		
		public static function isParagraph(flow:FlowElement):Boolean {
			if ( getQualifiedClassName(flow) == 'flashx.textLayout.elements::ParagraphElement') {
				return true; } else { return false; }
		}
		
		public static function isSpan(flow:FlowElement):Boolean {
			if ( getQualifiedClassName(flow) == 'flashx.textLayout.elements::SpanElement') {
				return true; } else { return false; }
		}
		
		public static function isLink(flow:FlowElement):Boolean {
			if ( getQualifiedClassName(flow) == 'flashx.textLayout.elements::LinkElement') {
				return true; } else { return false; }
		}

	}
}