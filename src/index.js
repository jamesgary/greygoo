import './main.css';
import { Main } from './Main.elm';
import registerServiceWorker from './registerServiceWorker';

var elmApp = Main.embed(document.getElementById('root'));

var canvas = document.getElementById("canvas");
var ctx = canvas.getContext("2d");

ctx.fillStyle = `rgba(0,0,0,1)`;

elmApp.ports.initOutline.subscribe(function(posList) {
    var size = 5;
    for (var i = 0; i < posList.length; i++) {
        var pos = posList[i];
        ctx.fillRect(
          size * pos.x,
          size * pos.y,
          size,
          size
        );
    }
});

registerServiceWorker();
