var canvas;
window.WebGl=false;
try {
    canvas = document.createElement('canvas');
    window.WebGl = canvas.getContext('webgl') || canvas.getContext('experimental-webgl');
}
catch (e) {
}


canvas = undefined;