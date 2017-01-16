//qml .pragma library
module dzhyun{


	function formatNumber(num:number) :string {
		var s:string;

		var u = "";
		if (num >= 1e12){
			s = (num/1e12).toFixed(6);
		   	u = "万亿";
		}else if (num >= 1e8){
			s = (num/1e8).toFixed(6);
		   	u = "亿";
		}else if (num > 1e4){
			s = (num/1e4).toFixed(6)
			u = "万";
		}else{
			s = num.toFixed(6);
		}
		s = s.replace(/\.?0+$/, "");
		return s + u;
	}

	export class TableData {
		head:string[];
		datas:any[];
		constructor(public schema:string, rows:number){
			this.parseSchema(schema);
			this.datas = new Array(rows);
		}
		parseSchema (schema:string) {
			var a = schema.split(/[;]/g);

			this.head = new Array();
			for(var i = 0; i < a.length; i += 1){
				this.head.push(a[i]);
			}
		}
		getRows () : number{
			return this.datas.length;
		}

		getCols () :number{
			return this.head.length;
		}

		getValue (i, j) :any{
			return this.datas[i][j];
		}

		setValue ( i, j, v) {
			this.datas[i][j] = v;
		}

		getRow (i) :any {
			return this.datas[i];
		}

		setRow (i, row) {

			return this.datas[i] = row;
		}

		insertRow (i, row) {
			return this.datas.splice(i, 0, row);
		}
	}


	export class LineGroup {
		constructor(public datas?:TableData){
			if (!datas){
				this.datas = new TableData("type:s;data:t;name:s;color:s", 0);
			}
		}

		range (){
			var lineCol = 1;
			var minV = Number.MAX_VALUE;
			var maxV = Number.MIN_VALUE;
			for(var row = 0; row < this.datas.getRows(); row++){
				var d = this.data(row);
				var name = this.name(row);

				//skip resevered index except main kline
				if (name.slice(0,2) == "__" && name != "__KLINE__")
					continue;

				for(var i = 0; i < d.getRows(); i++){
					for(var j = 0; j < d.getCols(); j++) {
						var v = d.getValue(i, j);
						if (v < minV)
							minV = v;
						if (v > maxV)
							maxV = v;
					}
				}
			}
			return {maxValue : maxV, minValue : minV, range: maxV - minV};
		}

		count ():number {
			return this.datas.getRows();
		}

		type (i):string {
			return this.datas.getValue(i, 0);
		}

		data (i) :TableData{
			return this.datas.getValue(i, 1);
		}

		name (i) : string {
			return this.datas.getValue(i, 2);
		}

		color (i):string {
			return this.datas.getValue(i, 3);
		}

		addLine (type, data, name, color){
			this.datas.insertRow(-1, new Array(type, data, name, color));
		}

		asObject () {
			for(var i = 0; i < this.count(); i++){
				//this.data(i).__proto__ = TableData.prototype;
			}
		}
	}


	export class Rect {
		constructor(public x:number, public y:number,
				public width:number, public height: number){

		}
	}

	export class Point{
		constructor(public x:number, public y:number){

		}
	}

	export class Coord {
		Sh:number;
		Sy:number;
		Sw:number;
		Sx:number;

		Rh:number;
		Ry:number;
		Rw:number;
		Rx:number;

		constructor(realRect:Rect, screenRect:Rect, public axis:Axis){
			this.Sh = screenRect.height;
			this.Sy = screenRect.y;
			this.Rh = realRect.height;
			this.Ry = realRect.y;

			this.Sw = screenRect.width;
			this.Sx = screenRect.x;
			this.Rw = realRect.width;
			this.Rx = realRect.x;
		}
		SY (Ry){
			return this.Sh - (this.Sh / this.Rh) * (Ry - this.Ry) + this.Sy;
		}

		RY (Sy){
			return this.Rh - ((Sy - this.Sy) * this.Rh) / this.Sh + this.Ry;
		}

		SX (Rx){
			return this.Sw * (Rx - this.Rx) /this.Rw + this.Sx;
		}

		RX (Sx){
			return this.Rw * (Sx - this.Sx)/this.Sw + this.Rx;
		}
	}

	export class Axis {
		axises:number[];
		minValue:number;
		maxValue:number;
		stepValue:number;

		constructor(minValue:number, maxValue:number, splitCount:number){
			if (minValue > maxValue)
				throw "Invaild paraments";
			var r = maxValue - minValue;
			var n = splitCount;
			var u1 = r / n;
			var exp = Math.floor(Math.log(u1) / Math.LN10);
			var u2 = u1 / Math.pow(10, exp);

			//var fixed_units = new Array (2, 2.5, 3, 5, 6, 7.5, 8, 10) ;
			var fixed_units = new Array (2, 2.5, 5, 7.5, 10) ;
			var u3 = Number.MAX_VALUE;
			var u3i = 0;
			for(var i = 0; i < fixed_units.length; i++){
				var diff = Math.abs(u2 - fixed_units[i]);
				if (u3 > diff){
					u3 = diff;
					u3i = i;
				}
			}
			u3 = fixed_units[u3i] * Math.pow(10, exp);

			var axises = new Array();
			var start = Math.floor(minValue / u3) * u3;
			var axis = start;
			axises.push(axis);
			while(axis < maxValue || Math.abs(axis - maxValue) < 0.00000001) {
				axis = axis + u3;
				axises.push(axis.toFixed(5));
			}
			this.axises = axises;
			this.minValue = Number(axises[0]);
			this.maxValue = Number(axises[axises.length - 1]);
			this.stepValue = Number(u3);
		}

		toString () {
			return this.axises.join(",");
		}

		range () {
			return this.maxValue - this.minValue;
		}
	}

	export class PaintStyle{
		config: any;
		constructor(style:any) {
			this.config = style;
		}
		drawBackground (context:CanvasRenderingContext2D, rect:Rect) {
			context.beginPath();
			context.fillStyle = this.config.bgColor;
			context.strokeStyle = this.config.gridLineColor;
			context.fillRect(rect.x, rect.y, rect.width, rect.height);
			context.strokeRect(rect.x + this.config.leftRulerWidth, rect.y, rect.width - this.config.leftRulerWidth - this.config.rightRulerWidth, rect.height);
			context.stroke();
		}

		drawBorder (context:CanvasRenderingContext2D, rect:Rect) {
			context.beginPath();
			context.strokeStyle = this.config.borderColor;
			context.lineWidth   = this.config.borderLineWidth;
			context.strokeRect(rect.x, rect.y, rect.width, rect.height);
			context.stroke();
		}

		drawGrid (context:CanvasRenderingContext2D, from:Point, to:Point){
			context.beginPath();
			context.strokeStyle = this.config.gridLineColor;
			context.lineWidth   = this.config.gridLineWidth;
			context.moveTo(from.x, from.y);
			context.lineTo(to.x, to.y);
			context.stroke();
		}

		drawBgGrid (context:CanvasRenderingContext2D, coord:Coord) {
			context.beginPath();
			context.strokeStyle = this.config.gridLineColor;
			context.lineWidth   = this.config.gridLineWidth;
			var axises = coord.axis.axises;
			for(var i = 0; i < axises.length; i++) {
				var ry = Number(axises[i]);
				var sy = coord.SY(ry);
				context.moveTo(coord.Sx, sy);
				context.lineTo(coord.Sx + Math.floor(coord.Sw / this.config.countRatio), sy);
			}
			context.stroke();
			context.save();
			context.beginPath();
			context.font = this.config.gridFont;
			context.strokeStyle = this.config.gridFontColor;
			context.fillStyle   = this.config.gridFontColor;
			context.textAlign = "right";
			for(var i = 0; i < axises.length; i++) {
				var ry = Number(axises[i]);
				var sy = coord.SY(ry);
				context.textBaseline = "middle";
				if (i == 0)
					context.textBaseline= "bottom";
				if (i == axises.length - 1)
					context.textBaseline= "top";

				var text = formatNumber(ry)
				context.fillText(text, this.config.leftRulerWidth, sy);
			}
			context.stroke();
			context.restore();
		}

		drawKLine (context:CanvasRenderingContext2D, kdatas, coord:Coord){
			var spaceRatio = this.config.spaceRatio;

			for(var i = coord.Rx; i < coord.Rw + coord.Rx; i++){
				var open  = kdatas.getValue(i, 0);
				var high  = kdatas.getValue(i, 1);
				var low   = kdatas.getValue(i, 2);
				var close = kdatas.getValue(i, 3);

				var openS  = coord.SY(open);
				var highS  = coord.SY(high);
				var lowS   = coord.SY(low);
				var closeS = coord.SY(close);

				var left       = coord.SX(i - coord.Rx);
				var right      = coord.SX(i - coord.Rx + 1);
				var centerS    = Math.floor(coord.SX(i - coord.Rx + 0.5)) - 0.5;
				var width      = right - left;
				var space      = width * spaceRatio;
				var halfWidthS = Math.floor(width * (1 - spaceRatio) / 2);
				var leftS      = centerS - halfWidthS;
				var rightS     = centerS + halfWidthS;

				context.lineWidth = this.config.kLineWidth;
				if (open > close) {
					context.beginPath();
					context.strokeStyle = this.config.dropColor;
					context.fillStyle   = this.config.dropColor;
					context.moveTo(centerS, highS);
					context.lineTo(centerS, openS);
					context.fillRect(leftS, closeS, rightS - leftS, openS - closeS);
					context.moveTo(centerS, closeS);
					context.lineTo(centerS, lowS);
					context.stroke();

				} else {
					context.beginPath();
					context.strokeStyle = this.config.riseColor;
					context.fillStyle   = this.config.riseColor;
					context.moveTo(centerS, highS);
					context.lineTo(centerS, closeS);
					context.strokeRect(leftS, openS, rightS - leftS, closeS - openS);
					context.moveTo(centerS, openS);
					context.lineTo(centerS, lowS);
					context.stroke();
				}
			}
		}

		drawLine (context:CanvasRenderingContext2D, datas:TableData, coord:Coord, color:string){
			var spaceRatio = this.config.spaceRatio;

			context.beginPath();
			context.lineWidth = this.config.kLineWidth;
			context.strokeStyle = color;

			var lastX = coord.SX(coord.Rx + 0.5);
			var lastY = coord.SY(datas.getValue(0, 0));
			for(var i = coord.Rx + 1; i < coord.Rw + coord.Rx, i < datas.getRows(); i++){
				var value  = datas.getValue(i, 0);
				var currentY  = coord.SY(value);
				var currentX    = coord.SX(i - coord.Rx + 0.5);

				context.moveTo(lastX, lastY);
				context.lineTo(currentX, currentY);
				lastX = currentX;
				lastY = currentY;
			}
			context.stroke();
		}

		drawLineGroup (context:CanvasRenderingContext2D, lines, coord:Coord){
			var j = 0;
			for (var i = 0; i < lines.count(); i++) {
				var type  = lines.type(i);
				var name  = lines.name(i);
				var data  = lines.data(i);
				var color = lines.color(i);

				switch(type){
					case "kline":
						this.drawKLine(context, data, coord);
						break;
					case "line":
						if (color == "") {
							color = this.config.lineColors[j % this.config.lineColors.length];
							j++;
						}
						this.drawLine(context, data, coord, color);
						break;
				}
			}
		}
	}
	export class Graph {
		datas: Date[];
		coord: Coord;
		ps: PaintStyle;
		lines: LineGroup;
		constructor(public context:CanvasRenderingContext2D,
				public screenRect:Rect, style:any){
			this.ps = new PaintStyle(style);
		}

		setData(data:LineGroup) {
			this.lines = data;
			this.setLayout()
		}

		setLayout(){
			if (this.lines == null)
				return;
			var range = this.lines.range();
			var axis = new Axis(range.minValue, range.maxValue, this.screenRect.height/80);
			var realRect = new Rect(0, axis.minValue,
			this.lines.data(0).getRows(), axis.maxValue - axis.minValue);
			var screenRect = new Rect(
				this.screenRect.x + this.ps.config.leftRulerWidth, 
				this.screenRect.y,
				Math.floor((this.screenRect.width - this.ps.config.leftRulerWidth - this.ps.config.rightRulerWidth) * this.ps.config.countRatio),
				this.screenRect.height
				);
			this.coord = new Coord(realRect, screenRect, axis);
		}

		onMinData(data:LineGroup, lastPrice:number){
			this.lines = data;
			var range = this.lines.range();
			var max = Math.max( Math.abs(lastPrice-range.maxValue),
			Math.abs(lastPrice - range.minValue));
			//max = Math.round((max - lastPrice) / lastPrice) * lastPrice;
			var axis = new Axis(lastPrice - max, lastPrice + max, this.screenRect.height/80);
			var realRect = new Rect(0, axis.minValue,
			240, axis.maxValue - axis.minValue);
			var screenRect = new Rect(
				this.ps.config.leftRulerWidth + this.screenRect.x,
				this.screenRect.y,
				Math.floor((this.screenRect.width - this.ps.config.leftRulerWidth - this.ps.config.rightRulerWidth) * this.ps.config.countRatio),
				this.screenRect.height
				);
			this.coord = new Coord(realRect, screenRect, axis);
		}

		paint() {
			var context = this.context;
			var screenRect = this.screenRect;
			this.ps.drawBackground(context, screenRect);
			this.ps.drawBgGrid(context, this.coord);
			this.ps.drawLineGroup(context, this.lines, this.coord);
		}
	}

	export class GraphGroup {

		graphics: Graph[];
		defaultSplits: number[][];

		constructor(public screenRect:Rect) {
			this.graphics = [];
			this.defaultSplits = [
				[],
				[1.0],
				[0.6, 0.4],
				[0.5, 0.25, 0.25],
				[0.4, 0.2, 0.2, 0.2],
				[0.4, 0.15, 0.15, 0.15, 0.15],
				[0.25, 0.15, 0.15, 0.15, 0.15, 0.15],
			];
		}

		addGraph(g:Graph) {
			this.graphics.push(g);
			this.reLayout();
		}

		reLayout() {
			var splits;
			if (this.graphics.length < this.defaultSplits.length) {
				splits = this.defaultSplits[this.graphics.length]
			}else{
				var span = 1.0/this.graphics.length;
				splits = [];
				for(var i= 0; i < this.graphics.length; i++){
					splits.push(span);
				}
			}
			var x = this.screenRect.x;
			var y = this.screenRect.y;
			for(var i = 0; i < splits.length; i++) {
				var width = this.screenRect.width;
				var height = Math.round(this.screenRect.height * splits[i]);
				var rect = new Rect(x, y, width, height);
				this.graphics[i].screenRect = rect;
				this.graphics[i].setLayout();
				y += height;
			}
		}

		paint() {
			for(var i = 0; i < this.graphics.length; i++) {
				this.graphics[i].paint();
			}
		}

	}
}
