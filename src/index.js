import './main.css';
import { Main } from './Main.elm';
import registerServiceWorker from './registerServiceWorker';

var elmApp = Main.embed(document.getElementById('root'), Date.now());

var canvas = document.getElementById("canvas");
var ctx = canvas.getContext("2d");
var size = 5;
var WIDTH = 100;
var HEIGHT = 100;

var drawPos = function(pos) {
    ctx.fillRect(
        size * pos[0],
        size * pos[1],
        size,
        size
    );
};

elmApp.ports.drawNewCells.subscribe(function(posList) {
    ctx.fillStyle = `rgba(80,205,80,1)`;
    for (var i = 0; i < posList.length; i++) {
        var pos = posList[i];
        drawPos(pos);
    }
});

elmApp.ports.resetCanvas.subscribe(function(posList) {
    ctx.fillStyle = `rgba(255,255,255,1)`;
    ctx.fillRect(
        0, 0,
        WIDTH * size,
        HEIGHT * size
    );
    ctx.fillStyle = `rgba(80,205,80,1)`;
    for (var i = 0; i < posList.length; i++) {
        var pos = posList[i];
        drawPos(pos);
    }
});

registerServiceWorker();
