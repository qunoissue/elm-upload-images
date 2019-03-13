require('./style/reset.scss');
require('./style/layout.scss');
require('./style/index.scss');

const { Elm } = require('./Main.elm');
const hljs = require("highlight.js/lib/highlight.js");
hljs.registerLanguage('elm', require('highlight.js/lib/languages/elm.js'));
hljs.registerLanguage('scss', require('highlight.js/lib/languages/scss.js'));
window.hljs = hljs;

const app = Elm.Main.init({
  node: document.getElementById('elm'),
  flags: null
});
