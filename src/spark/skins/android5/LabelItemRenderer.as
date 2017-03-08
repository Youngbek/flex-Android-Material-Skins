////////////////////////////////////////////////////////////////////////////////
//
//  Licensed to the Apache Software Foundation (ASF) under one or more
//  contributor license agreements.  See the NOTICE file distributed with
//  this work for additional information regarding copyright ownership.
//  The ASF licenses this file to You under the Apache License, Version 2.0
//  (the "License"); you may not use this file except in compliance with
//  the License.  You may obtain a copy of the License at
//
//      http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
//
////////////////////////////////////////////////////////////////////////////////

package spark.skins.android5
{
	import flash.display.GradientType;
	import flash.events.Event;
	import flash.filters.DropShadowFilter;
	import flash.geom.Matrix;
	
	import mx.core.DPIClassification;
	import mx.core.FlexGlobals;
	import mx.core.IDataRenderer;
	import mx.core.IFlexDisplayObject;
	import mx.core.ILayoutElement;
	import mx.core.UIComponent;
	import mx.core.mx_internal;
	import mx.events.FlexEvent;
	
	import spark.components.DataGroup;
	import spark.components.IItemRenderer;
	import spark.components.supportClasses.InteractionState;
	import spark.components.supportClasses.InteractionStateDetector;
	import spark.components.supportClasses.StyleableTextField;

	use namespace mx_internal;
	
	//--------------------------------------
	//  Events
	//--------------------------------------
	
	[Event(name="dataChange", type="mx.events.FlexEvent")]
	
	//--------------------------------------
	//  Excluded APIs
	//--------------------------------------
	
	[Exclude(name="focusBlendMode", kind="style")]
	[Exclude(name="focusThickness", kind="style")]

	[Style(name="fontFamily", type="String", inherit="yes")]
	[Style(name="fontSize", type="Number", format="Length", inherit="yes")]
	[Style(name="fontStyle", type="String", enumeration="normal,italic", inherit="yes")]
	[Style(name="fontWeight", type="String", enumeration="normal,bold", inherit="yes")]
	[Style(name="leading", type="Number", format="Length", inherit="yes")]
	[Style(name="letterSpacing", type="Number", inherit="yes")]
	[Style(name="textAlign", type="String", enumeration="left,center,right", inherit="yes")]
	[Style(name="textDecoration", type="String", enumeration="none,underline", inherit="yes")]
	[Style(name="textIndent", type="Number", format="Length", inherit="yes")]

	[Style(name="color", type="uint", format="Color", inherit="yes")]
	[Style(name="fontFamily", type="String", inherit="yes")]
	[Style(name="paddingLeft", type="Number", format="Length", inherit="no")]
	[Style(name="useOpaqueBackground", type="Boolean",  inherit="yes")]
	[Style(name="verticalAlign", type="String", enumeration="bottom,middle,top", inherit="no")]
	[Style(name="alternatingItemColors", type="Array", arrayType="uint", format="Color", inherit="yes", theme="spark, mobile")]
	[Style(name="chromeColor", type="uint", format="Color", inherit="yes", theme="spark, mobile")]
	[Style(name="downColor", type="uint", format="Color", inherit="yes", theme="spark, mobile")]
	[Style(name="focusColor", type="uint", format="Color", inherit="yes", theme="spark, mobile")]
	[Style(name="paddingBottom", type="Number", format="Length", inherit="no")]
	[Style(name="paddingTop", type="Number", format="Length", inherit="no")]
	[Style(name="rollOverColor", type="uint", format="Color", inherit="yes")]
	[Style(name="selectionColor", type="uint", format="Color", inherit="yes")]
	[Style(name="symbolColor", type="uint", format="Color", inherit="yes", theme="spark,mobile")]
		
	public class LabelItemRenderer extends UIComponent
		implements IDataRenderer, IItemRenderer
	{
		
		//--------------------------------------------------------------------------
		//
		//  Constructor
		//
		//--------------------------------------------------------------------------
		
		/**
		 *  Constructor.
		 *  
		 *  @langversion 3.0
		 *  @playerversion AIR 2.5
		 *  @productversion Flex 4.5
		 */
		public function LabelItemRenderer()
		{
			super();
			
			switch (applicationDPI)
			{
				case DPIClassification.DPI_640:
				{
					minHeight = 176;
					break;
				}
				case DPIClassification.DPI_480:
				{
					minHeight = 132;
					break;
				}
				case DPIClassification.DPI_320:
				{
					minHeight = 88;
					break;
				}
				case DPIClassification.DPI_240:
				{
					minHeight = 66;
					break;
				}
				case DPIClassification.DPI_120:
				{
					minHeight = 33;
					break;
				}
				default:
				{
					// default PPI160
					minHeight = 44;
					break;
				}
			}
			
			interactionStateDetector = new InteractionStateDetector(this);
			interactionStateDetector.addEventListener(Event.CHANGE, interactionStateDetector_changeHandler);
			
			cacheAsBitmap = true;
		}
		
		//--------------------------------------------------------------------------
		//
		//  Private Properties
		//
		//--------------------------------------------------------------------------
		
		/**
		 *  @private
		 *  Helper class to help determine when we are in the hovered or down states
		 */
		private var interactionStateDetector:InteractionStateDetector;
		
		/**
		 *  @private
		 *  Whether or not we're the last element in the list
		 */
		mx_internal var isLastItem:Boolean = false;
		
		//--------------------------------------------------------------------------
		//
		//  Overridden properties: UIComponent
		//
		//--------------------------------------------------------------------------
		
		//----------------------------------
		//  baselinePosition
		//----------------------------------
		
		/**
		 *  @private
		 */
		override public function get baselinePosition():Number
		{
			// The text styles aren't known until there is a parent.
			if (!parent)
				return NaN;
			
			return labelDisplay.baselinePosition;
		}
		
		//--------------------------------------------------------------------------
		//
		//  Public Properties 
		//
		//--------------------------------------------------------------------------
		
		//----------------------------------
		//  data
		//----------------------------------
		
		/**
		 *  @private
		 */
		private var _data:Object;
		
		[Bindable("dataChange")]
		
		/**
		 *  The implementation of the <code>data</code> property
		 *  as defined by the IDataRenderer interface.
		 *  When set, it stores the value and invalidates the component 
		 *  to trigger a relayout of the component.
		 *
		 *  @see mx.core.IDataRenderer
		 *  
		 *  @langversion 3.0
		 *  @playerversion AIR 2.5
		 *  @productversion Flex 4.5
		 */
		public function get data():Object
		{
			return _data;
		}
		
		/**
		 *  @private
		 */
		public function set data(value:Object):void
		{
			_data = value;
			
			if (hasEventListener(FlexEvent.DATA_CHANGE))
				dispatchEvent(new FlexEvent(FlexEvent.DATA_CHANGE));
		}
		
		//----------------------------------
		//  down
		//----------------------------------
		/**
		 *  @private
		 *  storage for the down property 
		 */    
		private var _down:Boolean = false;
		
		/**
		 *  Set to <code>true</code> when the user is pressing down on an item renderer.
		 *
		 *  @default false
		 * 
		 *  @langversion 3.0
		 *  @playerversion AIR 2.5
		 *  @productversion Flex 4.5
		 */    
		protected function get down():Boolean
		{
			return _down;
		}
		
		/**
		 *  @private
		 */    
		protected function set down(value:Boolean):void
		{
			if (value == _down)
				return;
			
			_down = value; 
			invalidateDisplayList();
		}
		
		//----------------------------------
		//  hovered
		//----------------------------------
		/**
		 *  @private
		 *  storage for the hovered property 
		 */    
		private var _hovered:Boolean = false;
		
		/**
		 *  Set to <code>true</code> when the user is hovered over the item renderer.
		 *
		 *  @default false
		 * 
		 *  @langversion 3.0
		 *  @playerversion AIR 2.5
		 *  @productversion Flex 4.5
		 */    
		protected function get hovered():Boolean
		{
			return _hovered;
		}
		
		/**
		 *  @private
		 */    
		protected function set hovered(value:Boolean):void
		{
			if (value == _hovered)
				return;
			
			_hovered = value; 
			invalidateDisplayList();
		}
		
		//----------------------------------
		//  itemIndex
		//----------------------------------
		
		/**
		 *  @private
		 *  storage for the itemIndex property 
		 */    
		private var _itemIndex:int;
		
		/**
		 *  @inheritDoc 
		 *
		 *  @default 0
		 * 
		 *  @langversion 3.0
		 *  @playerversion AIR 2.5
		 *  @productversion Flex 4.5
		 */    
		public function get itemIndex():int
		{
			return _itemIndex;
		}
		
		/**
		 *  @private
		 */    
		public function set itemIndex(value:int):void
		{
			var wasLastItem:Boolean = isLastItem;       
			var dataGroup:DataGroup = parent as DataGroup;
			isLastItem = (dataGroup && (value == dataGroup.numElements - 1));
			
			// if whether or not we are the last item in the last has changed then
			// invalidate our display. note:  even if our new index has not changed,
			// whether or not we're the last item may have so we perform this check 
			// before the value == _itemIndex check below
			if (wasLastItem != isLastItem) 
				invalidateDisplayList();
			
			if (value == _itemIndex)
				return;
			
			_itemIndex = value;
			
			// only invalidateDisplayList() if this causes use to redraw which
			// is only if alternatingItemColors are defined (and technically also
			// only if we are not selected or down, etc..., but we'll ignore those
			// as this will shortcut 95% of the time anyways)
			if (getStyle("alternatingItemColors") !== undefined)
				invalidateDisplayList();
		}
		
		//----------------------------------
		//  label
		//----------------------------------
		
		/**
		 *  @private 
		 *  Storage var for label
		 */ 
		private var _label:String = "";
		
		/**
		 *  The text component used to 
		 *  display the label data of the item renderer.
		 * 
		 *  @langversion 3.0
		 *  @playerversion AIR 2.5
		 *  @productversion Flex 4.5
		 */
		protected var labelDisplay:StyleableTextField;
		
		/**
		 *  @inheritDoc 
		 *
		 *  @default ""  
		 * 
		 *  @langversion 3.0
		 *  @playerversion AIR 2.5
		 *  @productversion Flex 4.5  
		 */
		public function get label():String
		{
			return _label;
		}
		
		/**
		 *  @private
		 */ 
		public function set label(value:String):void
		{
			if (value == _label)
				return;
			
			_label = value;
			
			// Push the label down into the labelTextField,
			// if it exists
			if (labelDisplay)
			{
				labelDisplay.text = _label;
				invalidateSize();
			}
		}
		
		//----------------------------------
		//  showsCaret
		//----------------------------------
		
		/**
		 *  @private
		 *  Storage for the showsCaret property 
		 */
		private var _showsCaret:Boolean = false;
		
		/**
		 *  @inheritDoc 
		 *
		 *  @default false  
		 * 
		 *  @langversion 3.0
		 *  @playerversion AIR 2.5
		 *  @productversion Flex 4.5
		 */    
		public function get showsCaret():Boolean
		{
			return _showsCaret;
		}
		
		/**
		 *  @private
		 */    
		public function set showsCaret(value:Boolean):void
		{
			if (value == _showsCaret)
				return;
			
			_showsCaret = value;
			invalidateDisplayList();
		}
		
		//----------------------------------
		//  selected
		//----------------------------------
		
		/**
		 *  @private
		 *  storage for the selected property 
		 */    
		private var _selected:Boolean = false;
		
		/**
		 *  @inheritDoc 
		 *
		 *  @default false
		 * 
		 *  @langversion 3.0
		 *  @playerversion AIR 2.5
		 *  @productversion Flex 4.5
		 */    
		public function get selected():Boolean
		{
			return _selected;
		}
		
		/**
		 *  @private
		 */    
		public function set selected(value:Boolean):void
		{
			if (value == _selected)
				return;
			
			_selected = value; 
			invalidateDisplayList();
		}
		
		//----------------------------------
		//  dragging
		//----------------------------------
		
		/**
		 *  @private
		 *  Storage for the dragging property. 
		 */
		private var _dragging:Boolean = false;
		
		/**
		 *  @inheritDoc  
		 * 
		 *  @langversion 3.0
		 *  @playerversion AIR 2.5
		 *  @productversion Flex 4.5
		 */
		public function get dragging():Boolean
		{
			return _dragging;
		}
		
		/**
		 *  @private  
		 */
		public function set dragging(value:Boolean):void
		{
			_dragging = value;
		}
		
		
		//----------------------------------
		//  authorDensity
		//----------------------------------
		/**
		 *  Returns the DPI of the application.
		 *  
		 *  @langversion 3.0
		 *  @playerversion AIR 2.5
		 *  @productversion Flex 4.5
		 */
		public function get applicationDPI():Number
		{
			return FlexGlobals.topLevelApplication.applicationDPI;
		}
		
		//--------------------------------------------------------------------------
		//
		//  Overridden methods: UIComponent
		//
		//--------------------------------------------------------------------------
		
		/**
		 *  @private
		 */
		override protected function createChildren():void
		{
			super.createChildren();
			
			if (!labelDisplay)
			{
				createLabelDisplay();
				labelDisplay.text = _label;
			}
		}
		
		/**
		 *  Creates the labelDisplay component
		 * 
		 *  @langversion 3.0
		 *  @playerversion AIR 2.5
		 *  @productversion Flex 4.5
		 */ 
		protected function createLabelDisplay():void
		{
			labelDisplay = StyleableTextField(createInFontContext(StyleableTextField));
			labelDisplay.styleName = this;
			labelDisplay.editable = false;
			labelDisplay.selectable = false;
			labelDisplay.multiline = false;
			labelDisplay.wordWrap = false;
			
			addChild(labelDisplay);
		}
		
		/**
		 *  Destroys the labelDisplay component
		 * 
		 *  @langversion 3.0
		 *  @playerversion AIR 2.5
		 *  @productversion Flex 4.5
		 */
		protected function destroyLabelDisplay():void
		{
			removeChild(labelDisplay);
			labelDisplay = null;
		}
		
		/**
		 *  @private
		 */
		override protected function measure():void
		{
			super.measure();
			
			if (labelDisplay)
			{
				// reset text if it was truncated before.
				if (labelDisplay.isTruncated)
					labelDisplay.text = label;
				
				var horizontalPadding:Number = getStyle("paddingLeft") + getStyle("paddingRight");
				var verticalPadding:Number = getStyle("paddingTop") + getStyle("paddingBottom");
				
				// Text respects padding right, left, top, and bottom
				labelDisplay.commitStyles();
				measuredWidth = getElementPreferredWidth(labelDisplay) + horizontalPadding;
				// We only care about the "real" ascent
				measuredHeight = getElementPreferredHeight(labelDisplay) + verticalPadding; 
			}
			
			measuredMinWidth = 0;
		}
		
		/**
		 *  @private
		 */
		override protected function updateDisplayList(unscaledWidth:Number, unscaledHeight:Number):void
		{
			// clear the graphics before calling super.updateDisplayList()
			graphics.clear();
			
			super.updateDisplayList(unscaledWidth, unscaledHeight);
			
			drawBackground(unscaledWidth, unscaledHeight);
			
			layoutContents(unscaledWidth, unscaledHeight);
		}
		
		//--------------------------------------------------------------------------
		//
		//  Methods
		//
		//--------------------------------------------------------------------------
		
		protected function drawBackground(unscaledWidth:Number, unscaledHeight:Number):void
		{
			// figure out backgroundColor
			var backgroundColor:*;
			var downColor:* = getStyle("downColor");
			var drawBackground:Boolean = true;
			var opaqueBackgroundColor:* = undefined;
			
			if (down && downColor !== undefined)
			{
				backgroundColor = downColor;
			}
			else if (selected)
			{
				backgroundColor = getStyle("selectionColor");
			}
			else if (hovered)
			{
				backgroundColor = getStyle("rollOverColor");
			}
			else if (showsCaret)
			{
				backgroundColor = getStyle("selectionColor");
			}
			else
			{
				var alternatingColors:Array;
				var alternatingColorsStyle:Object = getStyle("alternatingItemColors");
				
				if (alternatingColorsStyle)
					alternatingColors = (alternatingColorsStyle is Array) ? (alternatingColorsStyle as Array) : [alternatingColorsStyle];
				
				if (alternatingColors && alternatingColors.length > 0)
				{
					// translate these colors into uints
					styleManager.getColorNames(alternatingColors);
					
					backgroundColor = alternatingColors[itemIndex % alternatingColors.length];
				}
				else
				{
					// don't draw background if it is the contentBackgroundColor. The
					// list skin handles the background drawing for us. 
					drawBackground = false;
				}
				
			} 
			// draw backgroundColor
			// the reason why we draw it in the case of drawBackground == 0 is for
			// mouse hit testing purposes
			graphics.beginFill(backgroundColor, drawBackground ? 1 : 0);
			graphics.drawRect(0, 0, unscaledWidth, unscaledHeight);
			graphics.endFill();
			if (selected || down)
			{
				graphics.beginFill(0x000000, .2);
				graphics.drawRect(0, 0, unscaledWidth, unscaledHeight);
				graphics.endFill();
			}
			else if (drawBackground)
			{
				// If our background is a solid color, use it as the opaqueBackground property
				// for this renderer. This makes scrolling considerably faster.
				var useOpaqueBackground: * = getStyle("useOpaqueBackground") ;        // if not defined, then true
				if (useOpaqueBackground == undefined || useOpaqueBackground == true )
					opaqueBackgroundColor = backgroundColor;
			}
				
			opaqueBackground =  opaqueBackgroundColor;
		}

		protected function layoutContents(unscaledWidth:Number, unscaledHeight:Number):void
		{
			if (!labelDisplay)
				return;
			
			var paddingLeft:Number   = getStyle("paddingLeft"); 
			var paddingRight:Number  = getStyle("paddingRight");
			var paddingTop:Number    = getStyle("paddingTop");
			var paddingBottom:Number = getStyle("paddingBottom");
			var verticalAlign:String = getStyle("verticalAlign");
			
			var viewWidth:Number  = unscaledWidth  - paddingLeft - paddingRight;
			var viewHeight:Number = unscaledHeight - paddingTop  - paddingBottom;
			
			var vAlign:Number;
			if (verticalAlign == "top")
				vAlign = 0;
			else if (verticalAlign == "bottom")
				vAlign = 1;
			else // if (verticalAlign == "middle")
				vAlign = 0.5;			
			// measure the label component
			// text should take up the rest of the space width-wise, but only let it take up
			// its measured textHeight so we can position it later based on verticalAlign
			var labelWidth:Number = Math.max(viewWidth, 0); 
			var labelHeight:Number = 0;
			
			if (label != "")
			{
				labelDisplay.commitStyles();
				
				// reset text if it was truncated before.
				if (labelDisplay.isTruncated)
					labelDisplay.text = label;
				
				labelHeight = getElementPreferredHeight(labelDisplay);
			}
			
			setElementSize(labelDisplay, labelWidth, labelHeight);    
			
			// We want to center using the "real" ascent
			var labelY:Number = Math.round(vAlign * (viewHeight - labelHeight))  + paddingTop;
			setElementPosition(labelDisplay, paddingLeft, labelY);
			
			// attempt to truncate the text now that we have its official width
			labelDisplay.truncateToFit();
			
		}
		
		//--------------------------------------------------------------------------
		//
		//  Methods: Layout Helpers
		//
		//--------------------------------------------------------------------------

		protected function setElementPosition(element:Object, x:Number, y:Number):void
		{
			if (element is ILayoutElement)
			{
				ILayoutElement(element).setLayoutBoundsPosition(x, y, false);
			}
			else if (element is IFlexDisplayObject)
			{
				IFlexDisplayObject(element).move(x, y);   
			}
			else
			{
				element.x = x;
				element.y = y;
			}
		}

		protected function setElementSize(element:Object, width:Number, height:Number):void
		{
			if (element is ILayoutElement)
			{
				ILayoutElement(element).setLayoutBoundsSize(width, height, false);
			}
			else if (element is IFlexDisplayObject)
			{
				IFlexDisplayObject(element).setActualSize(width, height);
			}
			else
			{
				element.width = width;
				element.height = height;
			}
		}
		
		protected function getElementPreferredWidth(element:Object):Number
		{
			var result:Number;
			
			if (element is ILayoutElement)
			{
				result = ILayoutElement(element).getPreferredBoundsWidth();
			}
			else if (element is IFlexDisplayObject)
			{
				result = IFlexDisplayObject(element).measuredWidth;
			}
			else
			{
				result = element.width;
			}
			
			return Math.round(result);
		}
		
		protected function getElementPreferredHeight(element:Object):Number
		{
			var result:Number;
			
			if (element is ILayoutElement)
			{
				result = ILayoutElement(element).getPreferredBoundsHeight();
			}
			else if (element is IFlexDisplayObject)
			{
				result =  IFlexDisplayObject(element).measuredHeight;
			}
			else
			{
				result =  element.height;
			}
			
			return Math.ceil(result);
		}
		
		//--------------------------------------------------------------------------
		//
		//  Event Handlers
		//
		//--------------------------------------------------------------------------
		
		private function interactionStateDetector_changeHandler(event:Event):void
		{
			down = (interactionStateDetector.state == InteractionState.DOWN);
			hovered = (interactionStateDetector.state == InteractionState.OVER);
		}
		
		
	}
}