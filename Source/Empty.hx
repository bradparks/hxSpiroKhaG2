package;
import kha.Framebuffer;
import kha.Scheduler;
import kha.System;
import kha.Color;
import kha.Assets;
import kha.Font;
import kha.graphics2.Graphics;
import zui.Zui;
import zui.Id;
import justTriangles.Triangle;
import justTriangles.Draw;
import justTriangles.Point;
import justTriangles.PathContext;
import justTriangles.ShapePoints;
import justTriangles.QuickPaths;
import justTriangles.SvgPath;
import justTriangles.PathContextTrace;
import spiroHelpers.CurveKha;
import spiroHelpers.SpiroTriPathContext;
import kha.input.Mouse;

using justTriangles.QuickPaths;
@:enum
    abstract RainbowColors( Int ){
        var Violet = 0xFF9400D3;
        var Indigo = 0xFF4b0082;
        var Blue   = 0xFF0000FF;
        var Green  = 0xFF00ff00;
        var Yellow = 0xFFFFFF00;
        var Orange = 0xFFFF7F00;
        var Red    = 0xFFFF0000;
        var Black  = 0xFF000000;
    }
@:enum 
abstract MouseButton( Int ){
    var leftMouse = 0;
    var rightMouse = 1;
}
enum EditMode {
    ADD;
    MODIFY;
    REMOVE;
}
class Empty {
    var rainbow = [ Black, Red, Orange, Yellow, Green, Blue, Indigo, Violet ]; 
    var curveKha: CurveKha; 
    var circIndex: Int;
    var editMode = ADD;
    var ui: Zui;
    var font: Font;
    public function new() {
        System.notifyOnRender(render);
        Scheduler.addTimeTask(update, 0, 1 / 60);
        Assets.loadEverything(loadingFinished);
    }
    
    function loadingFinished(){
        curveKha = new CurveKha();
        Draw.drawTri = Triangle.drawTri;
        font = Assets.fonts.Abel_Regular;
        ui = new Zui( font, 17, 16, 0, 1.0 );
        Mouse.get().notify(onMouseDn,onMouseUp,onMouseMove,null);
    }
    function update(): Void {}
    function render(framebuffer: Framebuffer): Void {
        renderTriangles( framebuffer, 512, 256, 256 );
        if( ui != null ) {
            ui.begin( framebuffer.g2 );
            if( ui.window( Id.window(), 0, 0, 100, 300 )){
                    if( ui.button('ADD') ){
                        editMode = ADD;
                    }
                    if( ui.button('MODIFY') ){
                        editMode = MODIFY;
                    }
            }
            ui.end();
        }
    }
    private var dragging: Bool = false;
    public function onMouseDn( button: Int, x: Int, y: Int ){
        if( button == cast leftMouse ) {
            switch( editMode ){
                case ADD:
                trace('adding point at ' + x + ' ' + y );
                    var p: Point =  { x: x - 3 , y: y - 3 };
                    curveKha.addPoint( p );
                case MODIFY:
                    var i: Int = curveKha.checkCircle( x - 6, y - 6 );
                    if( i != null ) {
                        circIndex = i;
                        dragging = true;
                    }
                case REMOVE:
                    var i: Int = curveKha.checkCircle( x - 6, y - 6 );
                    // TODO implement remove circle with index i.
            }
        }
    }
    public function onMouseUp(button: Int, x: Int, y: Int ){
        if( button == cast leftMouse ) {
            dragging = false;
            trace( 'mouse left up at x: ' + x + ', y: ' + y );
        }
    }
    public function onMouseMove( x: Int, y: Int, cx: Int, cy: Int ){
        if( dragging ){
            curveKha.redrawCircle( circIndex, x , y );
        }
    }
    inline function renderTriangles( frameBuffer: Framebuffer, s: Float, ox: Float, oy: Float ){
        var w = System.windowWidth() / 2;
        var h = System.windowHeight() / 2;
        var g = frameBuffer.g2;
        var tri: Triangle;
        var khaColor: Color;
        var triangles = Triangle.triangles;
        g.begin();
        for( i in 0...triangles.length ){
            tri = triangles[ i ];
            khaColor = cast( rainbow[ tri.colorID ], Int );
            g.color = khaColor;
            g.fillTriangle( ox + tri.ax * s, oy + tri.ay * s
                        ,   ox + tri.bx * s, oy + tri.by * s
                        ,   ox + tri.cx * s, oy + tri.cy * s );
        }
        g.end();
    }
}
