uglify_js = require('transformers')['uglify-js'];
uglify_css = require('transformers')['uglify-css'];

module.exports = function(content, extension){

  // https://github.com/mishoo/UglifyJS
  // TODO: This should ignore js files with ".min" in the name
  if (extension === 'js') return uglify_js.renderSync(content);

  if (extension === 'css') return uglify_css.renderSync(content);

  return content;

};
