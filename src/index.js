import './main.css';
import { Main } from './Main.elm';
import registerServiceWorker from './registerServiceWorker';

var elmApp = Main.embed(document.getElementById('root'));

var canvas = document.getElementById("canvas");
var ctx = canvas.getContext("2d");
var size = 5;

var drawPos = function(pos) {
    ctx.fillRect(
        size * pos[0],
        size * pos[1],
        size,
        size
    );
};


elmApp.ports.initBorder.subscribe(function(posList) {
    ctx.fillStyle = `rgba(0,100,0,1)`;
    for (var i = 0; i < posList.length; i++) {
        var pos = posList[i];
        drawPos(pos);
    }
});

elmApp.ports.drawNewCells.subscribe(function(posList) {
    ctx.fillStyle = `rgba(80,205,80,1)`;
    for (var i = 0; i < posList.length; i++) {
        var pos = posList[i];
        drawPos(pos);
    }
});

registerServiceWorker();
