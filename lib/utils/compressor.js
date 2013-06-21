uglify_js = require('transformers')['uglify-js'];
uglify_css = require('transformers')['uglify-css'];

module.exports = function(content, extension){

  // https://github.com/mishoo/UglifyJS
  // TODO: This should ignore js files with ".min" in the name
  if (extension === 'js') {
    console.log('internal uglify');
    console.log(content);
    console.log('END internal uglify');

    return uglify_js.renderSync(content);
  }

  // https://github.com/GoalSmashers/clean-css
  if (extension === 'css'){
    return uglify_css.renderSync(content);
  }

  return content;

};
